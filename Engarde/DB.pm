package Engarde::DB;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DBI;
use JSON;
use Fcntl qw(:flock :DEFAULT);

my $dbh;

$VERSION=0.21;

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


sub _connect 
{
	$dbh = DBI->connect("DBI:mysql:engarde:127.0.0.1",
				"engarde", "engarde", 
				{'RaiseError' => 1, AutoCommit => 1}
			) or die $DBI::errstr;
}

sub reconnect 
{
	$dbh->disconnect;
	_connect();
}


sub tireur
{
	my $cid = shift;
	my $fid = shift;

	my $sth = $dbh->prepare("select * from v_event_entries where event_id = ?");
	
	$sth->execute($cid);
	
	my $data = $sth->fetchall_hashref('cle');
	
	my ($present, $absent, $scratched);
	
	foreach my $id (keys %$data)
	{
		$present +=1 if $data->{$id}->{presence} eq "present";
		$absent +=1 if $data->{$id}->{presence} eq "absent";
		$scratched +=1 if $data->{$id}->{presence} eq "scratched";
	}
	
	$data->{entries} = scalar keys %$data;
	$data->{present} = $present || 0;
	$data->{absent} = $absent || 0;
	$data->{scratched} = $scratched || 0;
	
	return $data->{$fid} if $fid;
	return $data;
}


sub people
{
	my $lic = shift || "";
	
	my $sth;
	
	if ($lic)
	{
		$sth = $dbh->prepare("select * from people where licence = ?");
		$sth->execute($lic);
	}
	else
	{
		$sth = $dbh->prepare("select * from people");
		$sth->execute();
	}
	
	my $data = $sth->fetchall_hashref('licence');		
	
	$sth->finish;
	
	return $data->{$lic} if $lic;
	return $data;
}


sub club
{
	my $name = shift || "";
	my $sth;
	
	if ($name)
	{
		$sth = $dbh->prepare("select cle from clubs where nom = ?");
		$sth->execute($name);
	}
	else
	{
		$sth = $dbh->prepare("select cle, nom, nom_court, nation1 from clubs");
		$sth->execute();
	}
	
	my $data = $sth->fetchall_hashref('cle');
	
	$sth->finish;
	
	return $data;

}

sub nation
{
	my $cid = shift;
	my $name = shift || "";
	
	my $sth;
	
	if ($name)
	{
		$sth = $dbh->prepare("select cle from nations where event_id = ? and nom = ?");
		$sth->execute($cid, $name);
	}
	else
	{
		$sth = $dbh->prepare("select * from nations where event_id = ?");
		$sth->execute($cid);
	}
	
	my $data = $sth->fetchall_hashref('cle');
	
	$sth->finish;
	
	return $data;
}

sub config_write
{
	#Engarde::debug(1,"DB::config_write starting");
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
	
	Engarde::debug(2, "confg_write_series: new comps = " . Dumper(\$new_comps));
	
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

sub config_read_json
{
	my $out = config_read();
	print "Content-Type: application/json\r\n\r\n";	
	print encode_json $out;
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
	my $config = _config_read_events();
	
	my $out = {};
	my @events;
	
	for my $k (sort keys %$config)
	{
		push @events, $config->{$k} if $config->{$k}->{state} eq "check-in";
	}
	
	$out->{events} = \@events;
	
	print "Content-Type: application/json\r\n\r\n";	
	print encode_json $out;
	
}

sub fencer_checkin_list
{
	my $cid = shift;
	my $t = tireur($cid);
	my $out = {};

	my @absent;
	my @present;
	my @scratched;
	
	# $absent->{count} = $t->{absent} || 0;
	# $present->{count} = $t->{present} || 0;
	# $scratched->{count} = $t->{scratched} || 0;

	foreach my $k (sort { $t->{$a}->{nom} . " " . $t->{$a}->{prenom} cmp $t->{$b}->{nom} . " " . $t->{$b}->{prenom}} grep /\d+/, keys %$t)
	{
		$t->{$k}->{licence} = "TBD" unless $t->{$k}->{licence};
		# print "$k $t->{$k}->{presence}\n";
		my $p = $t->{$k}->{presence};
		my $v = $t->{$k};
		# print Dumper($v);

		push @absent,$v if $p eq "absent";
		push @present,$v if $p eq "present";
		push @scratched,$v if $p eq "scratched";
	}
	
	$out->{present} = \@present;
	$out->{absent} = \@absent;
	$out->{scratched} = \@scratched;
	
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

	if (_is_open($cid))	
	{
		my $sth = $dbh->prepare("update entries set presence = ?, comment = ? where event_id = ? and person_id = ?");
		$sth->execute($presence, $comment, $cid, $fid);
	
		Engarde::debug(1,"Engarde::DB::fencer_checkin(): presence update for for fencer $fid status: " . $sth->err);
	
		fencer_checkin_list($cid);
	}
	else
	{
		my $out = {};
		$out->{present} = 0;
		$out->{absent} = 0;
		$out->{scratched} = 0;
		
		print "Content-Type: application/json\r\n\r\n";	
		print encode_json $out;
	}
}

sub fencer_add_by_lic
{
	my $cid = shift;
	my $lic = shift;
	
	my $f = people($lic);
	
	# return undef unless $fid;
	tireur_add_edit($f, $cid) if $f;
	
	fencer_checkin_list($cid);
}


sub nation_add_edit
{
	my $item = shift;
	my $cid = shift;
	
	Engarde::debug(1,"Engarde::DB::nation_add_edit(): adding item to cid $cid :" . Dumper($item));
	
	# $item = { cle=> x, nom=>y }
	
	my $sth = $dbh->prepare("replace into nations (event_id, cle, nom, nom_etendu) values (?,?,?,?)");
	
	$sth->execute($cid, $item->cle, $item->nom, $item->nom_etendu);

	$sth->finish();
}

sub club_add_edit
{
	my $item = shift;
	my $cid = shift;
	
	Engarde::debug(1,"Engarde::DB::club_add_edit(): adding item to cid $cid :" . Dumper($item));
	
	my $sth = $dbh->prepare("replace into clubs (event_id, cle, nom, nation1) values (?,?,?,?)");
	
	$sth->execute($cid, $item->cle, $item->nom, $item->nation1);

	$sth->finish();
}

sub tireur_add_edit
{
	# my $cid = shift;
	my $item = shift;
	my $cid = shift;
	
	# my $t = tireur();
	Engarde::debug(1,"Engarde::DB::tireur_add_edit(): starting item " . Dumper($item));
	
	#if ($item->{nation})
	#{
	#	# import from Engarde file will have nation1 as a numeric value.
	#	
	#	# if nation was numeric already, it must be an existing entry
	#	if ($item->{nation} =~ m/\d+/)
	#	{
	#		$item->{nation1} = $item->{nation};
	#	}
	#	else
	#	{
	#		# lookup id for given name
	#		my $n = nation($item->{nation});
	#		
	#		my @nid = keys %$n;
	#		$item->{nation1} = $nid[0] if scalar @nid;
	#	}
	#}
	#delete $item->{nation};
	#
	## this will allow U/A implicitly
	## not sure if that's correct really but it's consistent with Engarde
	
	#if ($item->{club} == -1)
	#{
	#	if ($item->{newclub})
	#	{
	#		my $c = {};
	#		$c->{nom} = uc($item->{newclub});
	#		$c->{nation1} = $item->{nation1} || undef;
	#		
	#		Engarde::debug(1,"Engarde::DB::tireur_add_edit(): adding club " . Dumper($c));
	#		my $club = club_add($c);
	#		Engarde::debug(1,"Engarde::DB::tireur_add_edit(): added club $club");
	#		$item->{club1} = $club;
	#	}
	#	delete $item->{newclub};
	#}
	#else
	#{
	#	$item->{club1} = $item->{club};
	#}
	
	# delete $item->{club};
	
	Engarde::debug(1,"Engarde::DB::tireur_add_edit(): processing item = " . Dumper($item));
	
	# if cid is null, just add to people otherwise add to people and add an entry to the comp
	
	################## REPLACE THIS LINE #######################################################################################

	my $sth = $dbh->prepare("insert into people (engarde_id, nom, prenom, licence, dob, nation1, sexe, expires) values (?,?,?,?,?,?,?,?)");

	################## REPLACE THIS LINE #######################################################################################
	
	$item->{cle} = undef if $item->{cle} eq "-1";
	
	$sth->execute($item->{cle}, $item->{nom}, $item->{prenom}, $item->{licence}, $item->{dob}, $item->{nation1}, substr($item->{sexe},0,1), $item->{expires});
	
	my $fid = $sth->{mysql_insertid};
	
	Engarde::debug(1,"Engarde::DB::tireur_add_edit: fencer $fid added");
	
	$sth->finish;
	
	if ($fid && $cid)
	{
		$sth = $dbh->prepare("replace into entries (id, event_id, person_id, cle, club1, presence, ranking, paiement, comment) values (?,?,?,?,?,?,?,?,?)");
		$sth->execute($item->{entry_id}, $cid, $fid, $item->{cle}, $item->{club1}, $item->{presence}, $item->{serie}, $item->{paiement}, $item->{comment});
		
		my $eid = $sth->{mysql_insertid};
		
		$sth->finish;
	
		Engarde::debug(1,"Engarde::DB::tireur_add_edit: entry $eid added");
	}
}

sub club_add
{
	my $item = shift;
	Engarde::debug(1,"Engarde::DB::club_add(): starting item " . Dumper($item));
	
	my $sth = $dbh->prepare("insert into clubs (nom, short_name, nation1) values (?,?,?)");
	$sth->execute($item->{nom}, $item->{nom}, $item->{nation1});
	
	Engarde::debug(1,"Engarde::DB::club_add failed " . $dbh->errstr . " " . $DBI::errstr) if $sth->err; 
	# Engarde::debug(1,"Engarde::DB::club_add returned " . $dbh->last_insert_id); 
	
	return $sth->{mysql_insertid};
}

sub weapon_delete
{
	# should really make sure to_text has been called before we do this so there is a backup
	my $cid = shift;
	

	# Only need to delete the event now
	# DB triggers will do the rest

	# my $sth = $dbh->prepare("delete from entries where event_id = ?");
	my $sth2 = $dbh->prepare("delete from events where id = ?");
	
	# $sth->execute($cid);
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

	if ($key eq "state" && $value eq "active")
	{
		# update files
		_weapon_update_files($cid);
	}
}

sub _weapon_update_files
{
	my $cid = shift;
	my $config = config_read();

	my $source = $config->{competition}->{$cid}->{source};

	# print "source = $source\n";

	my $c = Engarde->new($source . "/competition.egw");

	return undef unless $c;

	_nation_to_text($c, $cid);
	_club_to_text($c, $cid);
	_tireur_to_text($c, $cid);
}


sub _tireur_to_text
{
	my $c = shift;
	my $cid = shift;
	my $t = $c->tireur;
	# print Dumper(\$t);

	my $sth = $dbh->prepare("select * from v_tireur where event_id = ?");

	$sth->execute($cid);

	my $data = $sth->fetchall_hashref('cle');
	print Dumper(\$data);

    my $file = $t->{file};
    my $dir = $t->{dir};

	$t = $data;

    # the caller must ensure that engarde is not running since we don't
    # want a multiple writer conflict and linux doesn't like multiple locks on the
    # same file

    # open ETAT, "+< $dir/etat.txt";
    # flock(ETAT, LOCK_EX) || return undef;

    open (my $FH, ">",  "$file.tmp") or do
    {
        Engarde::debug(1,"open failed on $file.tmp $!");
        return undef;
    };

    # {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MINIMAL"]
    # [prenom "Minimal"] [cle 56]}
    #
    # {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MONTY"]
    # [prenom "Full"] [serie 123] [club1 29] [nation1 1] [date_nais "~27/12/1962"] [licence
    # "100123"] [licence_fie "1995120501"] [mobile "07802 312401"] [points 4.00] [dossard
    # 888] [paiement 9.99] [mode "mode string"] [cle 57]}

    my @keywords1 = qw/nom prenom licence mobile licence_fie mode date_nais/;
    my @keywords2 = qw/club1 nation1 presence serie cle sexe paiement/;

    foreach my $id (sort {$t->{$a}->{nom} cmp $t->{$b}->{nom}} grep /\d+/,keys %$t)
    {
        # Engarde::debug(3,"tireur: to_text(): processing id $id");

        if (defined $t->{$id}->{comment})
        {

        	$t->{$id}->{mode} = $t->{$id}->{comment} || "";

        }

		if ($t->{$id}->{presence} eq "scratched")
		{
			$t->{$id}->{presence} = "absent";
			$t->{$id}->{mode} = "scratched at check in";
		}	

        my $out;
        $out = "{[classe tireur] [status normal] [points 0.00]";

        foreach my $key (@keywords1)
        {
            $out .= " [$key \"" . $t->{$id}->{$key} . "\"]" if $t->{$id}->{$key};

            if (length($out) > 80)
            {
                print $FH $out . "\r";
                $out = "";
            }
        }

        foreach my $key (@keywords2)
        {
            $out .= " [$key $t->{$id}->{$key}]" if $t->{$id}->{$key};

            if (length($out) > 80)
            {
                print $FH $out . "\r";
                $out = "";
            }
        }

        $out .= "}\r";

        #Engarde::debug(3,"tireur: to_text(): id $id = $out");

        print $FH $out;
    }

   	close $FH;

    rename "$file.tmp", $file or die("rename failed: $!");

	$sth->finish();
}


sub _nation_to_text
{
	my $c = shift;
	my $cid = shift;
	my $n = $c->nation;
	my $sth = $dbh->prepare("select * from nations where event_id = ?");
	
	$sth->execute($cid);
	my $data = $sth->fetchall_hashref('cle');

    my $file = $n->{file};
    my $dir = $n->{dir};

    open my $FH, "> $file" . ".tmp";
    flock($FH, LOCK_EX) || return undef;

    my $out;

    foreach my $id (sort {$a <=> $b} grep /\d+/,keys %$data)
    {
        $out .= "{[classe nation] [nom \"$data->{$id}->{nom}\"] [nom_etendu \"$data->{$id}->{nom_etendu}\"] [cle $id]}\r\n";
    }

    print $FH $out;
    close $FH;

    rename "$file.tmp", $file or die("rename failed: $!");
}

sub _club_to_text
{
	my $c = shift;
	my $cid = shift;
	my $club = $c->club;
	my $sth = $dbh->prepare("select * from clubs where event_id = ?");
	
	$sth->execute($cid);
	my $data = $sth->fetchall_hashref('cle');

    my $file = $club->{file};
    my $dir = $club->{dir};

    open (my $FH, ">",  "$file.tmp") or do
    {
        Engarde::debug(1,"club_to_text(): open failed on $file.tmp $!");
        return undef;
    };

    flock($FH, LOCK_EX) or do
    {
        Engarde::debug(1,"club_to_text(): lock failed on $file.tmp $!");
        return undef;
    };


    my $seq = 1;

    # {[classe club] [nom "126"] [cle 23]}
    my $out = "";

    # Engarde saves clubs in alpha order rather than id order
    foreach my $id (sort {$data->{$a}->{nom} cmp $data->{$b}->{nom}} grep /\d+/,keys %$data)
    {
        Engarde::debug(3,"club: to_text(): processing id $id");
        $out .= "{[classe club] [nom \"$data->{$id}->{nom}\"] [cle $id]}\r\n";

        Engarde::debug(3,"club_to_text(): id $id = $out");
    }
    print $FH $out;
    close $FH;

    rename "$file.tmp", $file or die("rename failed: $!");
}



sub _is_open()
{
	my $cid = shift;

	my $sth = $dbh->prepare("select state from events where id = ?");

	$sth->execute($cid);

	my $value;
	$sth->bind_columns(\$value);
	$sth->fetch();

	return 1 if $value eq "check-in";
	return 0;
}

1;
