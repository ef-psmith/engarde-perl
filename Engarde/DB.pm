package Engarde::DB;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DBI;

my $dbh;

$VERSION=0.02;

BEGIN 
{
	# print "begin block running\n";

	# connect to db
	my $dsn = "DBI:mysql:database=engarde";

    #$dbh = DBI->connect($dsn, "engarde", "engarde");

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
	
	return $sth->fetchall_hashref('entry_id');
}

sub config_read
{
	my $data = {};

	_config_read_core($data);	
	_config_read_events($data);	

	# print Dumper($data);

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
