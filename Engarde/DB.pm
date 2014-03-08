package Engarde::DB;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DBI;

my $dbh;

$VERSION=0.03;

BEGIN 
{
	# print "begin block running\n";

	# connect to db
	# my $dsn = "DBI:mysql:database=engarde";

    #  $dbh = DBI->connect($dsn, "engarde", "engarde");

	$dbh = DBI->connect_cached("DBI:mysql:engarde:127.0.0.1",
				"engarde", "engarde", 
				{'RaiseError' => 1, AutoCommit => 1}
			) or die $DBI::errstr;
	
	# print Dumper($dbh);
}

sub tireur
{
	my $cid = shift;
	
	my $sth = $dbh->prepare("select * from v_event_entries where event_id = ?");
	
	$sth->execute($cid);
	
	my $data = $sth->fetchall_hashref('entry_id');
	
	my ($present, $absent, $scratched);
	
	foreach my $id (keys %$data)
	{
		$present +=1 if $data->{$id}->{presence} eq "present";
		$absent +=1 if $data->{$id}->{presence} eq "absent";
	}
	
	$data->{present} = $present;
	$data->{absent} = $absent;
	$data->{scratched} = $scratched;
	
	return $data;
}

sub config_write
{
	my $data = shift;

	_config_write_core($data);	
	_config_write_events($data);	

	1;
}


sub _config_write_core
{
	my $data = shift;

	my $sth = $dbh->prepare("update control set config_value = ? where config_key = ?");
	
	foreach my $key (keys %$data)
	{
		next if $key eq "competition";
		next if $key eq "controlIP";
		
		$sth->execute($data->{$key}, $key);
	}
}

sub _config_write_events
{
	my $data = shift;
	
	my $comp = $data->{competition};

	my $sth = $dbh->prepare("insert into events (id, source, titre_ligne, state, enabled, nif, background) 
							values (?,?,?,?,?,?,?) on duplicate key update 
							source=values(source), titre_ligne=values(titre_ligne), 
							state=values(state), enabled=values(enabled), nif=values(nif), 
							background=values(background)");
	
	foreach my $key (keys %$comp)
	{
		$sth->execute($key}, $comp->{$key}->{source}, $comp->{$key}->{titre_ligne}, $comp->{$key}->{state}, $comp->{$key}->{enabled}, $comp->{$key}->{nif}, $comp->{$key}->{background});
	}

	1;
}

sub config_read
{
	my $data = {};

	_config_read_core($data);	
	_config_read_events($data);	

	return $data;
}


sub _config_read_core
{
	my $data = shift;

	my $sth = $dbh->prepare("select config_key, config_value from control");
	$sth->execute();
				
	my ($key, $value);
	$sth->bind_columns(\$key, \$value);
	
	while ($sth->fetch)
	{
		$data->{$key} = $value;
	}
}

sub _config_read_events
{
	my $data = shift;

	my $sth = $dbh->prepare("select * from events");
	$sth->execute();
	
	$data->{competition} = $sth->fetchall_hashref('id');

	#print Dumper(\$data);
}

1;