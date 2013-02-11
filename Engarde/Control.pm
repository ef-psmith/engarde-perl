package Engarde::Control;

use Engarde;
require Exporter;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);
our @EXPORT = qw(control config_read weapon_add weapon_delete loadFencerData HTMLdie desk displayList editItem config_update screen_config_grid config_form config_trash);

use Data::Dumper;
use Cwd qw/abs_path cwd/;
#use DBI;
use File::Find;
use File::Basename;

use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Pretty qw(:standard *table -no_xhtml);
    
use Fcntl qw(:flock :DEFAULT);

use XML::Simple;
# use XML::Dumper;
my @available_comps;



sub HTMLdie {
  
	my ($msg,$title) = @_;
  
  	$title || ($title = "Error");
    
	_std_header(undef, "Error");

  	print h1($msg);
  	print end_html();
  	exit;
}


sub weapon_add
{
	my $config = config_read();
	
	my $path = shift;
	
	$config->{competition} = {} unless ref $config->{competition} eq "HASH";
	
	my $comps = $config->{competition};
	
	my $nextid = 1;
	
	while (defined $comps->{$nextid})
	{
		$nextid++;
	}
	
	$comps->{$nextid}->{source} = $path;
	$comps->{$nextid}->{enabled} = 'true';
	$comps->{$nextid}->{nif} = 0;
	$comps->{$nextid}->{background} = 'FF000000';
	$comps->{$nextid}->{state} = 'active';
	
	config_write($config);
	
	# load the scrrens page
	print "Location: screens.cgi\n\n" ;
}


sub weapon_delete
{
	my $config = config_read();
	my $cid = shift;
	
	my $seriescomps = _series_by_comp($config);
	
	#my $msg;
	
	foreach my $s (0..11)
	{
		# skip non-existant series
		next unless ${$seriescomps->{$cid}}[$s];
		
		#$msg .= "cid $cid: " . Dumper($seriescomps->{$cid}) . "<br>";
		
		#$msg .= "series comps pre $s: " . Dumper($config->{series}->{$s+1}->{competition}) . "<br>";
		
		my @result = grep { $_ ne $cid } @{$config->{series}->{$s+1}->{competition}};
		
		$config->{series}->{$s+1}->{competition} = \@result;
		
		#$msg .= "series comps post $s: " . Dumper($config->{series}->{$s+1}->{competition}) . "<br><br>";
	}
	
	# HTMLdie($msg);
	
	delete $config->{competition}->{$cid};
	config_write($config);
	
	print "Location: " . url() . "\n\n" ;
	
}

sub weapon_series_update
{
	my $id = shift;
	my $sid = shift;
}

sub config_update
{
	my $id = shift;
	my $key = shift;
	my $value = shift;
	
	# return unless ($id && $key && $value);
	
	my $config = config_read();
	$config->{competition}->{$id}->{$key} = $value;
	config_write($config);
	print "Location: ".url()."\n\n" ;
}


sub config_trash
{
	# WARNING - Here be dragons!
	#
	# Make sure you've done an "are you sure" prompt before calling this
	
	my $config = {};
	
	$config->{statusTimeout} = 20000;
	$config->{checkinTimeout} = 20000;
	$config->{restrictIP} = "false";
	$config->{debug} = 0;
	$config->{targetLocation} = "/share/Qweb";
	$config->{log} = "./out.txt";
	
	foreach my $s (1..12)
	{
		$config->{series}->{$s}->{enabled} = "true";
	}
}


sub control {
	my $config = shift;

	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$config->{statusTimeout}.");\n}";

	_std_header(undef, "Control Panel", $JSCRIPT, "doLoad()");
  
	print "<br><table border=1 cellspacing=0 cellpadding=4 width=1080\n";
	print "<tr><td></td><th colspan=2 align=left>Status</th><th colspan=2 align=left>Actions</th></tr>\n" ;

#	my $u = "escrime";
#	my $p = "escrime";
	
#	my $dbh = DBI->connect("DBI:mysql:escrime:127.0.0.1", $u, $p);
	
	my $comps = $config->{competition};

	$comps = {} unless ref $comps eq "HASH";
	
	# HTMLdie("xxx" . Dumper($comps));	

	foreach my $cid (sort { $a <=> $b } keys(%$comps)) 
	{
		my $w = $comps->{$cid};
		next unless $w->{enabled} eq "true"; 
		# HTMLdie(Dumper($w));
		my $state = $w->{'state'};

		my $c = Engarde->new($w->{source} . "/competition.egw", 1);
	
		next unless $c;
		
		my $path = $c->dir();
		
		my $lockstat = 0;
		
		open(ETAT, "+< $path/etat.txt"); 
		$lockstat = flock(ETAT,LOCK_EX);

		# print "lockstat = $lockstat<br>";
		
		#open(FH, "$path/weapon.status") || HTMLdie("Could not open $path/weapon.status for writing\n$!");
		#flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
		
		
		# HTMLdie(Dumper(\$c));

		my $name = $c->titre_ligne;

 		#unless (defined $state) 
		#{
			#$w->{'state'} = "hidden";
			# &update_hidden($w->{'path'}, "true");
		#}

		#$name =~ s/"//g;
		print "<tr><th align=left>$cid - $name</th>" ;
		print "<td>";
		print "<img src='./graphics/unlock-small.png' alt='Engarde not Running'/>" if $lockstat;
		print "<img src='./graphics/lock-small.png' alt='Engarde Running'/>" unless $lockstat;
		print "</td>";

		if ((!defined $state) || ($state eq "hidden")) 
		{
			print "<td>Check-in</td><td>Not Ready</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Ready\">Setup check-in</a></td><td>Hidden</td>" ;

		} 
		elsif ($state eq "check in") 
		{
			print "<td>Check-in</td><td>Open</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Running\">Close check-in</a></td>";
			print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
		} 
		elsif ($state eq "ready") 
		{
			print "<td>Check-in</td><td>Ready</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Check%20in\">Open check-in</a></td>";
			print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
		} 
		else 
		{
			my $where = $c->whereami;
			my @w = split (/\s+/,$where);
			my $etat = $c->etat;
      
			# print "<td>" . Dumper(\@w) . "</td>";
			SWITCH: 
			{
				if ($etat eq "termine") 
				{
					print "<td>Complete</td><td></td><td><a href=\"".url()."?wp=".$cid."&Action=details\">Details</a></td><td></td>";
					last SWITCH;
				}

 				if ($etat eq "debut") 
				{
	  				print "<td>Waiting</td><td>Start</td><td><a href=\"".url()."?wp=". $cid ."&Action=details&Name=$name\">Details</a></td>";
 					print "<td><a href=\"".url()."?wp=".$cid ."&Action=hide\">Hide</a></td>";
	  				last SWITCH;
				}

				if ($etat eq "poules") 
				{
					print "<td>Poules</td><td>Round $w[1] : " ;

  					if ($w[2]) 
					{
	 					my @p = (@w);
						shift @p;
						shift @p;

	 					print scalar(@p)." poules running.<br>@p</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
						print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
	  				} 
					else 
					{
						print "complete.</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
 						print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
 					}

	  				last SWITCH;
				}

				if ($etat eq "tableaux") 
				{
					# need to amend this - should print "poules" if $w[2] == "finished"
					
					if ($w[2] eq "finished")
					{
						print "<td>Poules</td><td>Finished" ;
						
					}
					elsif ($w[2])
					{
						print "<td>D.E.</td><td>" ;
					
						# shift @w;
						# shift @w;

						my @levels = split / /, $c->tableaux_en_cours;
						
						my $matchlist = $c->matchlist(1);
						
	 					#foreach my $level (@levels) 
						#{
							# my $t = $c->tableau($level);	
							# print "[$level] " . Dumper(\$t);
 						#}
						
						# print Dumper(\$matchlist);
						
						foreach my $l (keys %$matchlist)
						{
							my $ll = $$matchlist{$l};
							
							print "<font size=+2><b>$l</b></font> ";

							foreach my $m (sort keys %$ll)
							{
								print "$m ";
							}
							print "<br>";
							# print Dumper(\$ll);
						}
						
						print "</td>";
					}

					print "<td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
 					print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
					
  					last SWITCH;
				}

				print "<td>Error</td><td>Unknown</td><td></td><td></td>" ;
			}
		}

		my $hold = $w->{hold} || 0;
		
		if ($hold)
		{
			print "<td><a href=\"".url()."?wp=".$cid."&Action=play\"><img src='./graphics/play.png' /></a></td>";
		}
		else
		{
			print "<td><a href=\"".url()."?wp=".$cid."&Action=pause\"><img src='./graphics/pause.png' /></a></td>";
		}
		
		print "<td><img src='./graphics/twitter.png' /></td>";
	 	print "</tr>";
	}

	print "</table><br><a href=\"index.html\">Back</a>\n" ;
	print end_html();
}

sub screen_config_grid
{
	my $config = config_read();

	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$config->{statusTimeout}.");\n}";

	#_std_header(undef, "Configuration", $JSCRIPT, "doLoad()");
	_std_header(undef, "Screen Configuration");
  
	print "<br><table border=1 cellspacing=0 cellpadding=4 width=1080\n";
	print "<tr><th align=left>Competition</th><th></th><th colspan=12 align=left>Screens</th><th></th><th></th></tr>\n" ;

	print "<tr><th></th><th></th><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th><th></th><th></th></tr>";
	
	my $comps = $config->{competition};

	$comps = {} unless ref $comps eq "HASH";
	
	my $series = $config->{series};
	my $seriescomps = _series_by_comp($config);
		
	# print "<tr><td>" . Dumper(\$seriescomps) . "</td></tr>";
		
	foreach my $cid (sort { $a <=> $b } keys(%$comps)) 
	{
		print "<tr><th align='left'>$cid - " . $comps->{$cid}->{source} . "</th>";
		print "<td><a href=\"".url()."?wp=".$cid."&Action=delete\"><img src='./graphics/red-cross-icon.png' /></a></td>";		
		
		# my @values = (1..12);
		# my @defaults;
		
		for my $i (0..11)
		{
			print "<td>" . checkbox(-name=>$cid, -checked=>${$seriescomps->{$cid}}[$i], -label=>"") . "</td>";
		}
		
		print "<td><a href=\"".url()."?wp=".$cid."&Action=update\"><img src='./graphics/green-disk-icon.png' /></a></td>";


		my $enabled = $comps->{$cid}->{enabled} || "false";
		
		if ($enabled eq "true")
		{
			print "<td><a href=\"".url()."?wp=".$cid."&Action=disable\"><img src='./graphics/green-document-icon.png' /></a></td>";
		}
		else
		{
			print "<td><a href=\"".url()."?wp=".$cid."&Action=enable\"><img src='./graphics/blue-document-cross-icon.png' /></a></td>";
		}
		
		# print "<td colspan=12>" . checkbox_group(-name=>$cid, -values=>\@values, -default=>\$seriescomps->{$cid}, -linebreak=>'false') . "</td>";
		#print checkbox_group(-name=>'group_name',
        #                        -values=>['eenie','meenie','minie','moe'],
        #                        -default=>['eenie','moe'],
	    #                    -linebreak=>'true',
	    #                    -labels=>\%labels);
		
		
		print "</tr>";
	}

	
	print "</table>\n";
	
	print "<br><a href=\"config.cgi\">General Configuration</a>\n";
	
	print "<br><a href=\"index.html\">Back</a>\n";
	
	print end_html();
}


sub config_form
{
	my $config = config_read();
	
	# <config checkinTimeout="20000"
    #    debug="1"
    #    log="./out.txt"
    #    restrictIP="false"
    #    statusTimeout="20000"
    #    targetlocation="C:/Users/peter/Documents/Insync/prs2712@gmail.com/escrime/eng-live/web"
    #    title="Competition Admin Portal">
	#
	# <controlIP>172.20.30.10</controlIP>
	# <controlIP>172.20.30.11</controlIP>
	# etc
	
	my @hints = (	"How often the check in screen will auto-refresh in seconds",
					"How often the status screen will auto-refresh in seconds",
					"The level of debug output - WARNING 2 may crash the web server!",
					"Restrict access to the check in and status pages?",
					"For the QNAP this should be /share/Qweb",
					"Output from the writexml.pl script"
				);
				
	my $gap = '&nbsp;&nbsp;&nbsp;';
				
	_std_header($config, "Configuration");
  
	print start_form(
          -method=>'POST',
          -action=>url()
        );

	print "<br><fieldset><legend>Basic Configuration</legend>\n";
	print table({border => 0, cellspacing=>6, cellpadding=>2},
		Tr({},
		[
			td(["Check In Timeout :",radio_group(-name=>'checkintimeout', -values=>[10, 20, 30, 40], -default=>$config->{checkinTimeout} / 1000, -linebreak=>'false'),$gap,$hints[0]]),
			td(["Status Timeout :",radio_group(-name=>'statustimeout', -values=>[10, 20, 30, 40], -default=>$config->{statusTimeout} / 1000, -linebreak=>'false'),$gap,$hints[1]]),
			td(["Debug Level :",radio_group(-name=>'debuglevel', -values=>[0, 1, 2], -default=>$config->{debug}, -linebreak=>'false'),'', $gap, $hints[2]]),
			td(["Restrict IP :",radio_group(-name=>'restrictip', -values=>['true', 'false'], -default=>$config->{restrictIP}, -linebreak=>'false'),'','',$gap,$hints[3]]),
			#("<td>Target Location :</td><td colspan=5>" . textfield(-name=>'targetlocation',-value=>$config->{targetlocation},-size=>80,-maxlength=>132)] . "</td>")
			# td(["Licence No :",textfield(-name=>'licence',-value=>'',-size=>32,-maxlength=>32)])
		])
	);

	print submit(-name=>'basic', -label=>'Update');
	
	print end_form();
	
	print "</fieldset>\n";

	print start_form();
	print "<fieldset><legend>Output</legend>\n";
	print start_table({border => 0, cellspacing=>6, cellpadding=>2});
	print "<tr><td>Target Location :</td><td>" . textfield(-name=>'targetlocation',-value=>$config->{targetlocation},-size=>80,-maxlength=>132) . "</td><td>$hints[4]</td></tr>";
	print "<tr><td>Debug Output :</td><td>" . textfield(-name=>'log',-value=>$config->{log},-size=>80,-maxlength=>132) . "</td><td>$hints[5]</td></tr>";
	print end_table();
	
	
	print submit(-name=>'output', -label=>'Update');
	
	print end_form();
	
	print "</fieldset>\n";

	print start_form();
	
	print "<fieldset><legend>Control IP Addresses</legend>\n";
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});
	
	foreach my $x (0..2)
	{
		print "<tr>";
		
		foreach my $y (0..3)
		{
			my $j = ($x*4)+$y;
			print "<td></td><td>" . textfield(-name=>"ip_$j", -value=>${$config->{controlIP}}[$j], -size=>20, -maxlength=>20) . "</td>";
		}
		print "</tr>\n";
	}
	print end_table();
	
	print submit(-name=>'controlip', -label=>'Update');
	
	print end_form();
	
	print "</fieldset>\n";
	
	print start_form(-name=>"form_add");
	
	print "<fieldset><legend>Add a Competition</legend>\n";
	
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});
	
	_find_comps();
	print Tr(td( popup_menu(-name=>'newcomp', -values=>\@available_comps)), td("<a href='javascript: document.form_add.submit();'><img src='./graphics/green-plus-icon.png' /></a>"));
	
	print end_table();
	print end_form();

	print "</fieldset>\n";
	
	print start_form();
	
	print "<fieldset><legend>Set to Defaults	</legend>\n";
	
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});

	print "<tr><td><img src = './graphics/trash-icon-48.png' /></td><td>Set to Defaults - *** WARNING *** THIS CANNOT BE UNDONE!</td></tr>";
	print end_table();
	
	print end_form();
	print "</fieldset>\n";

	print "<br><a href=\"screens.cgi\">Screen Configuration</a>\n";
	print "<br><a href=\"index.html\">Back</a>\n";
	
	print end_html();
}

sub _find_comps
{
	undef @available_comps;
	
	my @possibledirs = ("../../data/examples", "/share/Public/data/current");
	my @dirs;

	foreach (@possibledirs)
	{
        push @dirs, $_ if -d;
	}
	
	find (\&_wanted, @dirs);
}

sub _wanted
{
	unless ($File::Find::dir =~ /.*AUX/)
	{
		if ($_ eq "competition.egw")
		{
			# abs_path doesn't work on directories for some reason
			push @available_comps, dirname(abs_path($_));
		}
	}
}

sub _series_by_comp
{
	my $config = shift;
	
	my $series = $config->{series};
	
	#HTMLdie(Dumper\$series);
	my $comps = $config->{competition};
	
	# HTMLdie(ref($comps));
	return undef unless ref $comps eq "HASH";
	
	my $out = {};
	
	
	# build an empty array
	foreach my $cid (keys %$comps)
	{
		my @row = (0,0,0,0,0,0,0,0,0,0,0,0);
		$out->{$cid} = \@row;
	}
	
	# now populate by iterating onver the series
	foreach my $sid (1..12)
	{
		my $c = $series->{$sid}; #->{competition};
		
		next unless $c;
		
		foreach my $cid (@{$c->{competition}})
		{
			${$out->{$cid}}[$sid - 1] = 1;
		}
		# print "$sid - " . Dumper($series->{$sid}->{competition}) . "<br>";
	}
	return $out;
}

sub loadFencerData
{
	my $c = shift;
	$::fencers = $c->tireur;
	$::clubs = $c->club;
	$::nations = $c->nation;

	$::maxfkey = $::fencers->{'max'};
	$::maxckey = $::clubs->{'max'};
	$::maxnkey = $::nations->{'max'};
	
}

sub desk {
	
	my $config = shift;

	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$config->{checkinTimeout}.");\n}";

	_std_header($config, "Check In Desk", $JSCRIPT, "doLoad()");
  
	# my $t=localtime();
	# print "$t\n";
	print "<table border=0 cellspacing=0 cellpadding=0 width=640>";
	print "<tr><th>Please choose a weapon/competition.</th></tr>";


	my $weapons = $config->{competition};

	foreach my $cid (sort { $a <=> $b } keys %$weapons) 
	{
		my $w = $weapons->{$cid};
		next unless $w->{enabled} eq "true";

		my $state = $w->{'state'};

		next unless $state eq "check in";

		my $c = Engarde->new($w->{source} . "/competition.egw", 1);
		next unless defined $c;
   		print "<tr><td><a href=".url()."?wp=$cid>$cid - ".$c->titre_reduit."</a></td></tr>";
  	}

  	print "</table><br><a href=\"index.html\">Back</a>\n" ;
	# $t=localtime();
	# print "$t\n";
  	print end_html();
}


sub displayList {
	my $cid = shift;
	my $config = shift;
	
	my $JSCRIPT="function edit(item) {\n  eWin = window.open(\"".url()."?wp=$cid&Action=Edit&Item=\" + item,\"edit\",\"height=560,width=640\");\n}\n";
	$JSCRIPT=$JSCRIPT."function check(item) {\n  cWin = window.open(\"".url()."?wp=$cid&Action=Check&Item=\" + item,\"check\",\"height=100,width=640\")\n}\n";
	$JSCRIPT=$JSCRIPT."function doLoad() {\n  setTimeout('window.location.reload()',20000);\n}";

	my $row = 0;
	my $state = $$config->{competition}->{$cid}->{state};

	_std_header($config, "Check-in", $JSCRIPT, "doLoad();");

	my $present = $::fencers->{present};
	my $total = $present + $::fencers->{absent};
	my $showall = param("showall") || 0;

	print "<table border=0 cellspacing=0 cellpadding=0><tr><td align=center>\n" ;
	print "<table border=0 cellspacing=5 cellpadding=0 width=100%><tr><td><a href=".url().">Check-in Desk</a></td><td align=center>Fencers Present : ".$present."/".$total."</td><td>Show all <input type='checkbox' name='showall' value=".$showall."></td><td align=right>";
	print "<a href=javascript:edit('-1')>Add Fencer</a>" unless ($state ne "check in");
	print "</td></tr></table>\n" ;
	print "<table border=1 cellspacing=0 cellpadding=2>\n" ;
	print "<tr><th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>NAME</th><th>CLUB</th><th>NATION</th><th>LICENCE NO</th><th>NVA</th><th>OWING</th><th></th></tr>\n" ;

	my $f = {};

	foreach my $fid (keys %$::fencers)
	{
		next unless ($fid =~ /^\d+$/);
		$f->{$fid} = $::fencers->{$fid};
	}

	foreach my $fid (sort {$f->{$a}->{nom} cmp $f->{$b}->{nom}} keys %$f)
	{
		if (!$showall)
		{
			next if $f->{$fid}->{presence} eq "present";
		}
		my ($name, $first, $club, $nation, $licence, $owing, $nva);
		my $bgcolour = "#ffffff" ;
   
    	$owing  = $::additions{$fid}->{'owing'} || "";

		$name = $f->{$fid}->{nom} . " " . $f->{$fid}->{prenom};
		$club = $f->{$fid}->{club1};
		$club = $::clubs->{$club}->{nom} if $club;
		$nation = $f->{$fid}->{nation1};
		$nation = $::nations->{$nation}->{nom} if $nation;

		$licence = $f->{$fid}->{licence};

    	if ($owing) 
		{
      		$owing  = "&pound;".$owing;
      		$bgcolour = "#FFFF00" ;
    	} 

    	#$nva  = $::additions{$_}->{'nva'} || 0;

    	if ($nva) {
      		$nva  = "*";
    	} else {
      		$nva = "";
    	}
	
    	print "<tr><td>";

    	if ($::fencers->{$fid}->{'presence'} ne "present") 
		{
			if ($::allowCheckInWithoutPaid || ( $owing eq "")) 
			{
        			print "<a href=javascript:check('".$fid."')>Check-in</a>" unless ($state eq "Check in");
      		}
    	} 
		else 
		{
      		$bgcolour = "#009900" ;
    	}

    	print "</td>";
    	print "<td bgcolor=\"$bgcolour\">",$name,"</td>" ;
    	print "<td bgcolor=\"",$bgcolour,"\">",$club || "","</td>" ;
    	print "<td bgcolor=\"",$bgcolour,"\">",$nation || "","</td>" ;
    	print "<td bgcolor=\"",$bgcolour,"\">",$licence || "","</td>" ;
    	print "<td bgcolor=\"",$bgcolour,"\">",$nva,"</td>" ;
    	print "<td bgcolor=\"",$bgcolour,"\">",$owing || "","</td>" ;
    	print "<td><a href=javascript:edit('".$fid."')>Edit</a></td>" ;
    	print "</tr>\n" ;
    	$row += 1;

    	#if ($row == 20) 
		#{
      		#$row = 0;
      		#print "<tr><th></th><th>NAME</th><th>CLUB</th><th>NATION</th><th>LICENCE NO</th><th>NVA</th><th>OWING</th><th></th></tr>\n" ;
    	#}
  	}
  	print "</table>" ;
  	print "</td></tr></table>" ;

  	print end_html();
}


sub config_read
{
        my $cf = shift;
		
		unless ($cf)
		{
			my $dir = cwd();
			
			$cf = "$dir/live.xml" if ( -r "$dir/live.xml" && not $cf);
			$cf = "$dir/../live.xml" if ( -r "$dir/../live.xml" && not $cf);
		}
		
        my $data = XMLin($cf, KeyAttr=>'id', ForceArray=>qr/competition/);
		
		my $debug = $data->{debug};
		
		$Engarde::DEBUGGING = $debug;
		# HTMLdie "debug = " . $Engarde::DEBUGGING;
		
		# $Engarde::DEBUGGING = $data->{debug};
		
        return $data;
}

sub config_write
{
	my $data = shift;
	my $cf = shift;

	unless ($cf)
	{
		my $dir = cwd();
			
		$cf = "$dir/live.xml" if ( -w "$dir/live.xml" && not $cf);
		$cf = "$dir/../live.xml" if ( -w "$dir/../live.xml" && not $cf);
	}
		
	open my $FH, ">$cf" . ".tmp" or HTMLdie ("Could not open $cf.tmp for writing: $!");
	flock($FH, LOCK_EX) || HTMLdie ("Couldn't obtain exclusive lock on $cf");

	my $out = "<?xml version=\"1.0\"?>\n";
	$out .= XMLout($data, KeyAttr=>'id', AttrIndent=>1, SuppressEmpty => undef, RootName=>'config');

	print $FH "$out";
	close $FH;
	
	rename "$cf.tmp", $cf or HTMLDie("rename failed: $!");
}


sub editItem 
{
	my $weaponPath = shift;
	my $config = shift;
	my $comp = shift;

	my ($name, $first, $club, $nation, $licence, $presence, $owing, $nva);
	my $state = $$config->{competition}->{$weaponPath}->{state};

	# HTMLdie(Dumper($::fencers));
	if (param('Item') != -1) 
	{
		my $f = $::fencers->{param('Item')};

		$name     = $f->{'nom'} ;
		$first    = $f->{'prenom'} ;
		$licence  = $f->{'licence'} ;
		$presence = $f->{'presence'} ;
		$owing    = $f->{'owing'} || 0;
		$nva      = $f->{'nva'} || 0;
	} else {
		$name     = "";
		$first    = "";
		$licence  = "";
    	$presence = "absent";
    	$owing    = 0;
    	$nva      = 0;
  	}
  
	_std_header($config, "Edit Item", undef, undef);

	print start_form(
          -method=>'POST',
          -action=>url()
        ),
        hidden(
          -name=>'wp',
          -value=>$::weaponPath,
          -override=>'true'
        ),
        hidden(
          -name=>'Action',
          -value=>'Write',
          -override=>'true'
        ),
        hidden(
          -name=>'Item',
          -value=>param('Item'),
          -override=>'true'
        );

	print "<fieldset><legend>Fencer Information</legend>\n";
	print table({border => 0, cellspacing=>2, cellpadding=>0},
		Tr({},
		[
			td(["Surname :",textfield(-name=>'nom',-value=>$name,-size=>32,-maxlength=>32)]),
			td(["Forename :",textfield(-name=>'prenom',-value=>$first,-size=>32,-maxlength=>32)]),
			td(["Licence No :",textfield(-name=>'licence',-value=>$licence,-size=>32,-maxlength=>32)])
		])
	);

	print "</fieldset>\n";
	print "<fieldset><legend>Affilliation</legend>\n";
	my %clubnames = ();
	my %nationnames = ();
	my $selclub   = -1;
	my $selnation = -1;
	my (@ckeys,@nkeys);

	_club_list($comp, \@ckeys, \%clubnames, \$selclub);

  	#
  	# Generate Nation List
  	#
  	@nkeys = sort {uc($::nations{$a}->{'nom'}) cmp uc($::nations{$b}->{'nom'})} (keys(%::nations));
  	foreach (@nkeys) {
    	$nation   = $::nations{$_}->{'nom'} ;
    	$nation   =~ s/"//g ;
    	$nationnames{$_} = $nation;
    	if (param('Item') != -1) {
      	if ($_ == $::fencers{param('Item')}->{'nation1'}) {
        	$selnation = $_;
      	}
    	} else {
      	if ($nation eq $::defaultNation) {
        	$selnation = $_;
      	}
    	}
  	}
  	push (@nkeys, '-1');
  	$nationnames{'-1'} = 'Other';
  	print table({border => 0, cellspacing=>2, cellpadding=>0},
          	Tr({},
          	[
            td(["Club :",
                popup_menu(-name=>'club',
                           -values=>\@ckeys,
                           -labels=>\%clubnames,
                           -default=>$selclub,
                           -onchange=>"if (club.value == -1) {newclub.disabled = false;} else {newclub.disabled = true;}"
                          ),
                textfield(-name=>'newclub',-value=>"",-size=>32,-maxlength=>32,-disabled=>'true')
               ]),
            td(["Nation :",popup_menu(-name=>'nation',
                                  -values=>\@nkeys,
                                  -labels=>\%nationnames,
                                  -default=>$selnation,
                                  -onchange=>"if (nation.value == -1) {newnation.disabled = false;} else {newnation.disabled = true;}"
                                 ),
                textfield(-name=>'newnation',-value=>"",-size=>3,-maxlength=>3,-disabled=>'true')
               ]),
               
          ]
          )
        );
	print "<fieldset><legend>Additional Information</legend>\n";
  if ($nva) {
    print checkbox(-name=>'nva',-value=>1,-checked=>1,-label=>'NVA Member');
  } else {
    print checkbox(-name=>'nva',-value=>1,-checked=>0,-label=>'NVA Member');
  }
  if ($owing) {
    print "<br>&pound;".$owing." outstanding ".checkbox(-name=>'paid',-value=>1,-checked=>0,-label=>'Paid');
  }
  print "</fieldset>\n";
  print "<fieldset><legend>Flags</legend>\n";
  
  if ($state->{'status'} =~ /check in/i) {
    if ($presence eq "present") {
      print checkbox(-name=>'presence',-value=>'present',-checked=>1,-label=>'Present');
    } else {
      print checkbox(-name=>'presence',-value=>'present',-checked=>0,-label=>'Present');
    }
  } else {
    print hidden(-name=>'presence',-value=>$presence,-override=>'true');
  }
  print "<br>";
  print "</fieldset>\n";
  
  print submit(-label=>'Update Record');
  
  print end_form();

  print end_html();
}

sub _std_header
{
	# prints the standard CGI.pm blurb
	
	my $config = shift;
	my $title = shift || "Engarde.pm";
	my $JSCRIPT = shift || "";
	my $onload = shift || "";
	
  	print header(),
	start_html(
		-title => $title,
		-lang => 'en-GB',
		-style => {'src' => './styles/std.css'},
		-text => '#000000',
		-vlink => '#000000',
		-alink => '#999900',
		-link => '#000000',
		-script => $JSCRIPT,
		-onload => $onload
	);

	print table({border => 0, cellspacing=>2, cellpadding=>0},
		Tr(
			td( img({-src => './graphics/logo_small.jpg', -alt=>'Logo', -height=>100, -width=>150})),
			td("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
			td("<h1>$title</h1>")
		)
	);
	
	warningsToBrowser(1);
}


sub _club_list
{

	my $comp = shift;

	my $ckeys = shift;
	my $clubnames = shift;
	my $selclub = shift;

	my $clubs = $comp->club;

	print STDERR Dumper(\$clubs);

	# Generate Club List

	my $t =	$comp->tireur(param('Item')) if param('Item');

	#HTMLdie(Dumper($clubs));

	$$selclub=$t->club1 if $t;

	#HTMLdie(Dumper(keys %$clubs));

	@$ckeys = sort {uc($clubs->{$a}->{'nom'}) cmp uc($clubs->{$b}->{'nom'})} (keys(%$clubs));

	#HTMLdie(Dumper($ckeys));

	foreach (@$ckeys) {
		$$clubnames{$_} = $clubs->{$_}->{'nom'} ;
	}
	push (@$ckeys, '-1');
	$$clubnames{'-1'} = 'Other';
}


sub _nation_list
{

}


1;

__END__
