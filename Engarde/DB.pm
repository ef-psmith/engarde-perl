package Engarde::DB;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DBI;
use JSON;

my $dbh;

$VERSION=0.04;

BEGIN 
{
	# print "begin block running\n";

	# connect to db
	# my $dsn = "DBI:mysql:database=engarde";

    #  $dbh = DBI->connect($dsn, "engarde", "engarde");

	# $dbh = DBI->connect_cached("DBI:mysql:engarde:127.0.0.1",
	$dbh = DBI->connect("DBI:mysql:engarde:127.0.0.1",
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
	
	$data->{entries} = scalar keys %$data;
	$data->{present} = $present || 0;
	$data->{absent} = $absent || 0;
	$data->{scratched} = $scratched || 0;
	
	return $data;
}


sub club
{
	my $sth = $dbh->prepare("select * from clubs");
	$sth->execute();
	
	my $data = $sth->fetchall_hashref('id');
	return $data;
}

sub nation
{
	my $sth = $dbh->prepare("select * from nations");
	$sth->execute();
	
	my $data = $sth->fetchall_hashref('cle');
	return $data;
}

sub config_write
{
	Engarde::debug(1,"DB::config_write starting");
	my $data = shift;

	_config_write_core($data);	
	_config_write_events($data);	
	_config_write_series($data);	

	1;
}


sub _config_write_core
{
	Engarde::debug(1,"DB::config_write_core starting");
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
	Engarde::debug(1,"DB::config_write_events starting");
	my $data = shift;
	
	my $comp = $data->{competition};

	my $sth = $dbh->prepare("insert into events (id, source, titre_ligne, state, enabled, nif, background, message) 
							values (?,?,?,?,?,?,?,?) on duplicate key update 
							source=values(source), titre_ligne=values(titre_ligne), 
							state=values(state), enabled=values(enabled), nif=values(nif), 
							background=values(background), message=values(message)");
	
	foreach my $key (keys %$comp)
	{
		$sth->execute($key, $comp->{$key}->{source}, $comp->{$key}->{titre_ligne}, $comp->{$key}->{state}, 
			$comp->{$key}->{enabled}, $comp->{$key}->{nif}, $comp->{$key}->{background}, $comp->{$key}->{message});
	}

	1;
}

sub _config_write_series
{
	my $data = shift;

	my $series = $data->{series};
	
	my $sth = $dbh->prepare("insert into series (comp_id, series_mask) values (?, ?)");
	
	my $delete_sth = $dbh->prepare("delete from series");
	$delete_sth->execute();

	my $new_comps = {};
	
	foreach my $key (keys %$series)
	{
		# my @c = @{$series->{$key}->{competition}};
		
		foreach (@{$series->{$key}->{competition}})
		{
			$new_comps->{$_} |= 1<<$key;
		}
	}
	
	Engarde::debug(1, Dumper(\$new_comps));
	
	foreach (keys %$new_comps)
	{
		$sth->execute($_, $new_comps->{$_});
	}
	
}

sub config_read
{
	my $data = {};

	_config_read_core($data);	
	_config_read_events($data);	
	_config_read_series($data);
	
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

sub _config_read_series
{
	my $data = shift;

	my $sth = $dbh->prepare("select comp_id, series_mask from series");
	$sth->execute();
					
	my ($cid, $value);
	$sth->bind_columns(\$cid, \$value);
	
	my $s = {};
	
	while ($sth->fetch)
	{
		# my @comps;
		for (0..12)
		{
			push @{$s->{$_}->{competition}}, $cid if ($value & 1<<$_);
		}
		
		$data->{series} = $s;
	}
	
	# needs to end up as $data->{series}->{id:1-12}->{competition} = @array

	# print Dumper(\$data);
}

sub checkin_list_json
{
	my $cid = shift;
	
	my $t = tireur($cid);
	my $out = {};

	$out->{absent}->{count} = $t->{absent} || 0;
	$out->{present}->{count} = $t->{present} || 0;
	$out->{scratched}->{count} = $t->{scratched} || 0;

	foreach my $k (grep /\d+/, keys %$t)
	{
		# print "$k $t->{$k}->{presence}\n";
		my $p = $t->{$k}->{presence};
		my $v = $t->{$k};
		# print Dumper($v);

		$out->{$p}->{$k} = $v;
	}
	
	print "Content-Type: application/json\r\n\r\n";	
	print encode_json $out;
}

sub fencer_checkin
{
	my $cid = shift;
	my $fid = shift;

	_fencer_presence($cid, $fid, "present");
}

sub fencer_scratch
{
	my $cid = shift;
	my $fid = shift;

	_fencer_presence($cid, $fid, "scratched", "scratched at check-in");
}

sub fencer_absent
{
	my $cid = shift;
	my $fid = shift;

	_fencer_presence($cid, $fid, "absent");
}

sub _fencer_presence 
{
	my $cid = shift;
	my $fid = shift;
	my $presence = shift;
	my $comment = shift || undef;
	
	my $sth = $dbh->prepare("update entries set presence = ?, comment = ? where event_id = ? and person_id = ?");

	$sth->execute($presence, $comment, $cid, $fid);
}

sub weapon_delete
{
	# should really make sure to_text has been called before we do this so there is a backup
	my $cid = shift;
	
	my $sth = $dbh->prepare("delete from entries where event_id = ?");
	my $sth2 = $dbh->prepare("delete from events where id = ?");
	
	$sth->execute($cid);
	$sth2->execute($cid);
}

sub weapon_config_update
{
	my $cid = shift;
	my $key = shift;
	my $value = shift;
	
	my $sth;
	
	if ($key eq "hold")
	{
		$sth = $dbh->prepare("update events set hold = ? where id = ?");
	}
	elsif ($key eq "state")
	{
		$sth = $dbh->prepare("update events set state = ? where id = ?");
	}
	else
	{
		Engarde::debug(1,"DB::weapon_config_update: unknown key $key");
		return undef;
	}
	
	$sth->execute($value, $cid);
}

1;
