# vim: ts=4 sw=4 noet:
package Engarde::Control;

###############################################################################
#
# 	Control.pm
#
# 	Engarde::Control - Provides the functions needed for DT, check-in, etc
#
# 	Copyright	2012-2013, Peter Smith, peter.smith@englandfencing.org.uk
#				2012-2013, England Fencing 
#				2012-2013, BIFTOC (for inspiration and the original code)

use Engarde;
require Exporter;
use strict;
no warnings 'io';

use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);

$VERSION=1.28;

our @EXPORT = qw(	frm_control frm_config frm_screen frm_checkin_desk frm_checkin_list frm_fencer_edit
					config_read config_update_basic config_update_output config_update_ip config_trash
					weapon_add weapon_delete weapon_disable weapon_enable weapon_series_update weapon_config_update 
					fencer_checkin fencer_scratch fencer_edit
					HTMLdie );

use Data::Dumper;
use Cwd qw/abs_path cwd/;
#use DBI;
use File::Find;
use File::Basename;

use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Pretty qw(:standard *table -no_xhtml);
use CGI::Cookie;
    
use Fcntl qw(:flock :DEFAULT);
use Scalar::Util qw(blessed);

use XML::Simple;
# $XML::Simple::PREFERRED_PARSER = "XML::Parser";

# use XML::Dumper;
my @available_comps;


########################################################
#
# General purpose error handler
#
#########################################################

sub HTMLdie {
  
	my ($msg,$title) = @_;
  
  	$title || ($title = "Error");
    
	_std_header("Error");

  	print h1($msg);
  	
	_std_footer();
  	exit;
}


#########################################################
#
# subs to update the competition (weapon) related entries
# in the config file
#
#########################################################

sub weapon_add
{
	my $config = config_read();
	
	my $path = shift;
	my $titre = shift;
	
	my @colours = qw/blue chartreuse coral cyan darkgreen deeppink dodgerblue gold hotpink magenta orange red seagreen tomato yellow/; 
	
	# initialise the hash if this is the first comp added
	$config->{competition} = {} unless ref $config->{competition} eq "HASH";
	
	my $comps = $config->{competition};
	
	my $nextid = 1;
	
	while (defined $comps->{$nextid})
	{
		$nextid++;
	}
	
	$comps->{$nextid}->{source} = $path;
	$comps->{$nextid}->{titre_ligne} = $titre;
	$comps->{$nextid}->{enabled} = 'true';
	$comps->{$nextid}->{nif} = 0;
	$comps->{$nextid}->{background} = $colours[$nextid - 1];
	$comps->{$nextid}->{state} = 'active';
	
	config_write($config);
	print redirect(url());
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
	
	print redirect(url());
	
}

sub weapon_disable
{
	my $cid = shift;
	my $config = config_read();
	
	$config->{competition}->{$cid}->{enabled} = 'false';
	
	config_write($config);
		
	print redirect(url());
}


sub weapon_enable
{
	my $cid = shift;
	my $config = config_read();
	
	$config->{competition}->{$cid}->{enabled} = 'true';
	
	config_write($config);
		
	print "Location: " . url() . "\n\n" ;
	print redirect(url());
}


sub weapon_series_update
{
	my $cid = shift;
	my @screens = param("screens");
	my $message = param("message");
	
	my %screens = map {$_ => 1 } @screens;
	
	my $config=config_read();
	
	foreach my $s (0..11)
	{	
		# remove the comp from the list - leave everything else intact
		my @result = grep { $_ ne $cid } @{$config->{series}->{$s+1}->{competition}};
		
		# now add back the required screens
		push @result, $cid if exists $screens{$s};
		
		$config->{series}->{$s+1}->{competition} = \@result;
	}	
	
	if ($message)
	{
		# this is clunky, but forces the message to be an element
		my @msg;
		push @msg, $message;
	
		$config->{competition}->{$cid}->{message} = \@msg;
	}
	else
	{
		delete $config->{competition}->{$cid}->{message};
	}
	
	config_write($config);
	
	print redirect(url());
}

sub weapon_config_update
{
	my $id = shift;
	my $key = shift;
	my $value = shift;
	
	# return unless ($id && $key && $value);
	
	my $config = config_read();
	$config->{competition}->{$id}->{$key} = $value;
	config_write($config);
	print redirect(url());
}

#########################################################
#
# subs to update fencers and clubs
#
#########################################################

sub fencer_checkin
{
	# HTMLdie(Dump());
	
	my $cid = param("wp");
	my $fid = param("Item");
	my $paid = shift;

	print STDERR "DEBUG: fencer_checkin(): starting config_read() at " . localtime() . "\n";

	my $config=config_read();

	
	#HTMLdie(Dumper($config->{competition}->{$cid}));
	
	print STDERR "DEBUG: fencer_checkin(): starting new() at " . localtime() . "\n";
	my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw", 2);
	HTMLdie("invald compeition $cid") unless $c;
	
	# my $ETAT;
	open(ETAT, "+< " . $c->{dir} . "/etat.txt"); 
	
	# HTMLdie("lock error: $!") unless ETAT;
	
	my $lockstat = flock(ETAT,LOCK_EX);

	#HTMLdie("calling _running");
	
	HTMLdie("Competition Locked: $^E") unless $lockstat;
	
	my $f = $c->tireur;
	
	$f->{$fid}->{presence} = "present";
	
	flock(ETAT,LOCK_UN);
	close ETAT;
	# _release($ETAT);
	
	print STDERR "DEBUG: fencer_checkin(): starting to_text() at " . localtime() . "\n";
	#HTMLdie("calling to_text");
	$f->to_text;

	print STDERR "DEBUG: fencer_checkin(): redirecting at " . localtime() . "\n";

	print redirect(-uri=>"check-in.cgi?wp=$cid&Action=list");
	
}

sub fencer_scratch
{
	# HTMLdie(Dump());
	
	my $cid = param("wp");
	my $fid = param("Item");
	my $paid = shift;

	print STDERR "DEBUG: fencer_scratch(): starting config_read() at " . localtime() . "\n";

	my $config=config_read();

	
	#HTMLdie(Dumper($config->{competition}->{$cid}));
	
	print STDERR "DEBUG: fencer_scratch(): starting new() at " . localtime() . "\n";
	my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw", 2);
	HTMLdie("invald compeition $cid") unless $c;
	
	# my $ETAT;
	open(ETAT, "+< " . $c->{dir} . "/etat.txt"); 
	
	# HTMLdie("lock error: $!") unless ETAT;
	
	my $lockstat = flock(ETAT,LOCK_EX);

	#HTMLdie("calling _running");
	
	HTMLdie("Competition Locked: $^E") unless $lockstat;
	
	my $f = $c->tireur;
	
	$f->{$fid}->{scratched} = 1;
	$f->{$fid}->{presence} = "absent";
	$f->{$fid}->{comment} = "scratched at check in";
	
	flock(ETAT,LOCK_UN);
	close ETAT;
	# _release($ETAT);
	
	print STDERR "DEBUG: fencer_scratch(): starting to_text() at " . localtime() . "\n";
	#HTMLdie("calling to_text");
	$f->to_text;

	print STDERR "DEBUG: fencer_scratch(): redirecting at " . localtime() . "\n";

	print redirect(-uri=>"check-in.cgi?wp=$cid&Action=list");
	
}


sub fencer_edit
{
	my $config=config_read();
	my $wp = param("wp");
	my $cle = param("Item");
	
	return undef unless $wp;
	
	HTMLdie("Check-in closed") unless $config->{competition}->{$wp}->{state} eq "check-in";
	
	# HTMLdie(Dump());
	
	my $item = {};
	
	for (qw/nom prenom licence presence club newclub nation comment/)
	{
		#Engarde::debug(1,"fencer_edit: setting $_ to " . param($_));
		$item->{$_} = param($_);
	}

	$item->{scratched} = "scr" if param("scratched");
	$item->{expired} = "exp" if param("expired");
	$item->{presence} = "absent" unless $item->{presence};
	$item->{nom} = uc($item->{nom});
	$item->{prenom} = ucfirst($item->{prenom});
	$item->{cle} = $cle;
	$item->{date_nais} = _dob_to_date(param("dob"));
	
	if (param("paid"))
	{
		delete $item->{paiement};
	}
	
	
	my $c=Engarde->new($config->{competition}->{$wp}->{source}, 2);
	
	HTMLdie("invalid competition") unless $c;
	
	my $id = $c->tireur_add_edit($item);
	
	print redirect(-uri=>"check-in.cgi?wp=$wp&Action=list");
}

#########################################################
#
# subs to update the non-competition related entries
# in the config file
#
#########################################################
sub config_update_basic
{
	my $config = config_read();
	
	my $checkintimeout = param("checkintimeout");
	my $statustimeout = param("statustimeout");
	my $debuglevel = param("debuglevel");
	my $restrictip = param("restrictip");
	my $allowunpaid = param("allowunpaid");
	my $tournamentname = param("tournamentname");
	
	$config->{checkintimeout} = $checkintimeout * 1000;
	$config->{statusTimeout} = $statustimeout * 1000;
	$config->{debug} = $debuglevel;
	$config->{restrictIP} = $restrictip;
	$config->{allowunpaid} = $allowunpaid;
	$config->{tournamentname} = $tournamentname;
	
	config_write($config);
	print redirect(url());
	
}

sub config_update_output
{
	my $config = config_read();
	
	my $targetlocation = param("targetlocation");
	my $log = param("log");
	my $nif = param("nif");
	
	$config->{targetlocation} = $targetlocation;
	$config->{log} = $log;
	$config->{nif} = $nif;
	
	config_write($config);
	print redirect(url());
}


sub config_update_ip
{
	my $config = config_read();
	
	my @ips;
	
	for (0..11)
	{
		push @ips, param("ip_" . $_) if param("ip_" . $_);
	}
	
	$config->{controlIP} = \@ips;
	
	config_write($config);
	print redirect(url());
}


sub config_trash
{
	# WARNING - Here be dragons!
	#
	# Make sure you've done an "are you sure" prompt before calling this
	
	my $config = {};
	
	$config->{statusTimeout} = 20000;
	$config->{checkintimeout} = 60000;
	$config->{restrictIP} = "false";
	$config->{allowunpaid} = "false";
	$config->{debug} = 0;
	$config->{targetlocation} = "/home/engarde/live/web";
	$config->{log} = "./out.txt";
	
	foreach my $s (1..12)
	{
		$config->{series}->{$s}->{enabled} = "true";
	}
}


sub _config_location
{
	# return "DB" if defined $Engarde::DB::VERSION;
	
	my $dir = cwd();

	my @locations = (	"/home/engarde/live/web/live.xml",
						"/home/engarde/eng-live/web/live.xml",
						"c:/users/psmith/Documents/prs2712\@gmail.com/escrime/eng-live/web/live.xml",
						"$dir/web/live.xml",
						"$dir/live.xml",
						"$dir/../live.xml",
					);
	
	foreach (@locations)
	{
		return $_ if -r $_ ;
	}
}

sub config_read
{
        my $cf = shift || _config_location();
		
		return undef unless $cf;
		
		# need to initialise this as $data = {} possibly
		my $data;
		
		if ($cf eq "DB")
		{
			$data = Engarde::DB::config_read();
		}
		else
		{
			#my $data = XMLin($cf, KeyAttr=>'id', ForceArray=>qr/competition message/); 
			$data = XMLin($cf, KeyAttr=>'id', ForceArray=>1); 
		}
		
		my $debug = $data->{debug};
		
		$Engarde::DEBUGGING = $debug;
		
        return $data;
}

sub config_write
{
	my $data = shift;
	my $cf = shift || _config_location();

	return undef unless $cf;

	if ($cf eq "DB")
	{
		Engarde::DB::config_write($data);
	}
	else
	{
		open my $FH, ">$cf" . ".tmp" or HTMLdie ("Could not open $cf.tmp for writing: $!");
		flock($FH, LOCK_EX) || HTMLdie ("Couldn't obtain exclusive lock on $cf");

		my $out = "<?xml version=\"1.0\"?>\n";
		$out .= XMLout($data, KeyAttr=>'id', AttrIndent=>1, SuppressEmpty => undef, RootName=>'config');

		print $FH "$out";
		close $FH;
	
		rename "$cf.tmp", $cf or HTMLDie("rename failed: $!");
	}
}

#########################################################
#
# subs for the configuration and data input screens
#
#########################################################

sub frm_control {
	my $config = config_read();

	#my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$config->{statusTimeout}.");\n}";
	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',900000);\n}";
	
	_std_header("$config->{tournamentname} Control Panel", $JSCRIPT, "doLoad()");
	
	# print "<script type=\"text/javascript\" src=\"script/status.js\"></script>\n";
 
	print "<br><table border=1 cellspacing=0 cellpadding=4 \n";
	print "<tr><td></td><th colspan=3 align=left>Status</th><th colspan=2 align=left>Actions</th></tr>\n" ;

	# my $u = "escrime";
	# my $p = "escrime";

	# my $dbh = DBI->connect("DBI:mysql:escrime:127.0.0.1", $u, $p);
	
	my $comps = $config->{competition};

	$comps = {} unless ref $comps eq "HASH";
	
	# HTMLdie("xxx" . Dumper($comps));	

	foreach my $cid (sort { $a <=> $b } keys(%$comps)) 
	{
		my $w = $comps->{$cid};
		next unless $w->{enabled} eq "true"; 
		# HTMLdie(Dumper($w));
		my $state = $w->{'state'};

		my ($c, $name, $path, $etat, @w);
		my $lockstat = 0;
		
		if (defined $Engarde::DB::VERSION)
		{
			$name = $w->{'titre_ligne'};
			$path = $w->{'source'};
			$etat = $w->{'state'};
			$lockstat = 1;
		}
		else
		{
			$c = Engarde->new($w->{source} . "/competition.egw", 1);
	
			next unless $c;
		
			$path = $c->dir();
				
			# test to see if Engarde is running
		
			if ($^O =~ /Win32/)
			{
				open(ETAT, "+< $path/etat.txt"); 
				$lockstat = flock(ETAT,LOCK_EX);
		
				# immediately release the lock just in case
				flock(ETAT,LOCK_UN);
				close ETAT;
			}
			else
			{
				my $file = "$path/etat.txt";
				$file =~ s/ /\\ /g;
				$lockstat = 1 unless `lsof $file`;
			}
			$name = $c->titre_ligne;
			
			my $where = $c->whereami;
			@w = split (/\s+/,$where);
			$etat = $c->etat;
      
			# print "DEBUG: etat = $etat";
		}
		
		print "<tr><th align=left>$cid - $name<br><font color='grey' size=1>$path</font></th>" ;
				
		if ($lockstat)
		{
			print "<td><img src='./graphics/unlock-small.png' /></td>";
		}
		else 
		{
			print "<td><img src='./graphics/lock-small.png' /></td>";
		}

		
		SWITCH: 
		{
			if ($etat eq "termine") 
			{
				print "<td>Complete</td><td></td>";
				last SWITCH;
			}

 			if ($etat eq "debut") 
			{
				my $f;
				
				if (defined $Engarde::DB::VERSION)
				{
					$f = Engarde::DB::tireur($cid);
				}
				else
				{
					$f = $c->tireur;
				}
				
				my $present = $f->{present};
				my $total = $f->{entries};
				my $scratch = $f->{scratch};
				
				# my $total = (scalar grep /\d+/, keys %$f);
				#my $total = (scalar keys %$f) - 7;
				
				if ($lockstat)
				{
					if ($state eq "check-in") 
					{
						print "<td>Check-in Open</td>"; 
						print "<td>$present/$total ($scratch scratched) <a href=\"".url()."?wp=".$cid."&Action=update&Status=active\">Close check-in</a></td>";
					} 
					else 
					{
						print "<td>Ready</td>";
						print "<td>$present/$total ($scratch scratched) <a href=\"".url()."?wp=".$cid."&Action=update&Status=check-in\">Open check-in</a></td>";
					}
				}
				else
				{
					if ($state eq "check-in")
					{
						# auto close check in if Engarde is running
						$w->{state} = "active";
						config_write($config);
					}
					print "<td>Check-in</td><td>$present/$total Locked</td>";
				}
				
  				last SWITCH;
			}
				
			if ($etat eq "poules") 
			{
				print "<td>Poules</td><td>Round $w[1] : " ;
  				if ($w[2]) 
				{
					my @p = (@w);
					shift @p;
					my $round = shift @p;
					
					my $poules = $c->poules($round, @p);
					
					# HTMLdie(Dumper(\$poules));
					
					
 					print scalar(@p)." poules running.<br>";
					
					print start_table({-class=>"table1"});
					print "<tr><th>Poule</th>";
					foreach (sort { $a <=> $b } keys %$poules) 
					{
						print "<td>$_</td>";
					}
					
					print "</tr>";
					print "<tr><th>Piste</th>";
					
					foreach (sort { $a <=> $b } keys %$poules) 
					{
						print "<td>$poules->{$_}->{piste_no}</td>";
					}
					
					print "</tr>";
					print end_table;
				} 
				else 
				{
					# print "complete.</td>";
					# print "<td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
				}
				last SWITCH;
			}

			if ($etat eq "tableaux") 
			{
				if ($w[2] && $w[2] eq "finished")
				{
					print "<td>Poules</td><td>Finished" ;						
				}
				elsif ($w[1])
				{
					print "<td>D.E.</td>" ;
				
					# my @levels = split / /, $c->tableaux_en_cours;
					
					my $matchlist = $c->matchlist(2);
					
					# my %by_piste = map {$_ => $matchlist->{$_}->{nom} } @ckeys;
					
					print "<td>";
					
					# print STDERR Dumper(\$matchlist);
						
					foreach my $piste (sort { $a <=> $b } keys %$matchlist)
					{
						my $ll = $matchlist->{$piste};
						
						next unless $ll->{unfinished_matches};
						
						Engarde::debug(1,"frm_control: piste = $piste");
						
						# HTMLdie("piste = $piste: " . Dumper(\$ll));
						
						print start_table({-class=>"table1"});
						
						print "<tr>";
						
						my $end = sprintf ("%02d:%02d", (localtime($ll->{end_time}))[2,1]);
						my $start = sprintf("%02d:%02d", (localtime($ll->{start_time}))[2,1]);
						
						my $late = "";
						
						$late = "late" if $ll->{status}  && $ll->{status} eq "late";
						
						print th({-class=>"hint--bottom hint--rounded hint--info $late", 'data-hint'=> "$ll->{total_matches} bouts, $ll->{unfinished_matches} unfinished. Start: $start, End: $end"}, "<font size=+1><b>" . uc($piste eq "-1" ? "None" : $piste) . "</b></font>");
						
						# my $data = {};
						
						# my $pistes;
						
						# change this sort order to by piste and add secondary sort on match no
						# { ($ll->{$a}->{piste_no} || "" . $a) <=> ($ll->{$b}->{piste_no} || "" . $b) } perhaps
						
						foreach (grep /\d+/, (keys %$ll))
						{
							my $lll = $ll->{$_};
						
							Engarde::debug(1,"frm_control: tableau = $_");
						
						
							# HTMLdie(Dumper($ll));
							
							foreach my $m (sort {$a <=> $b} keys %$lll)
							{
								next unless ($lll->{$m}->{idA} && $lll->{$m}->{idB} && not $lll->{$m}->{winnerid});
						
								Engarde::debug(1,"frm_control: match = $m");
						
								# $data->{$m}->{$ll->{$m}->{piste}} = 
								print "<td class='hint--bottom hint--rounded hint--info' data-hint=\"$lll->{$m}->{fencerA_court} -v- $lll->{$m}->{fencerB_court}\">$lll->{$m}->{num}</td>";
								# $pistes->{$m} = $lll->{$m};
							}
						}
						
						# HTMLdie(Dumper(\@pistes));
						
						print "</tr>";
						# print Tr( td({-style=>'border: thin solid red; padding: 0; width: 10px;'},[@pistes] ));
						
						print "<tr>";
						
						#foreach (sort keys %$pistes)
						#{
						#	my ($min, $hr) = (localtime($pistes->{$_}->{end_time}))[1,2];
							
						#	print td({-class=>"hint--bottom hint--rounded hint--info", 'data-hint'=> "End: $hr:$min"}, ($pistes->{$_}->{piste} || ""));
							# print td({-class=>"hint--bottom hint--rounded hint--info", 'data-hint'=> Dumper($pistes->{$_})}, $pistes->{$_}->{piste});
						#}
						
						print "</tr>";
						
						print end_table;
						# print "<br>";
					}
					
					print "</td>";
				}
					
				last SWITCH;
			}

			print "<td>Error</td><td>Unknown</td><td></td><td></td>" ;
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

	print "</table><br>";
	
	_std_footer();
	
}

sub frm_screen
{
	my $config = config_read();
	
	HTMLdie("no config file found: " . cwd()) unless $config;
	_std_header("Screen Configuration");

	###########################################
	#
	#	Screen config
	#
	###########################################
	print "<br><fieldset><legend>Screen Configuration</legend>\n";
	
	print "<br><table border=1 cellspacing=0 cellpadding=4 width=1080\n";
	print "<tr><th align=left rowspan=2 colspan=2>Competition</th></th><th colspan=12 align=left>Screens</th><th rowspan=2>Message</th><th rowspan=2>Save</th><th rowspan=2>Enabled?</th></tr>\n" ;

	print "<tr><th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th><th>12</th></tr>";
	
	my $comps = $config->{competition};

	$comps = {} unless ref $comps eq "HASH";
	
	my $series = $config->{series};
	my $seriescomps = _series_by_comp($config);
		
	# print "<tr><td>" . Dumper(\$seriescomps) . "</td></tr>";
		
	foreach my $cid (sort { $a <=> $b } keys(%$comps)) 
	{
		my $src = $comps->{$cid}->{source};
		my $c = Engarde->new($src,2);
		
		next unless $c;

		my $name = $c->titre_ligne;
		# my $src = $comps->{$cid}->{source};
		#my $short_src = $comps->{$cid}->{source};
		
		#$short_src =~ s/.*\/examples\///;
		#$short_src =~ s/.*\\examples\\//;
		#$short_src =~ s/.*\/current\///;
		
		print "<tr><th align='left'>$cid - $name<br><font size=1>$src</font></th>";
		print "<td><a href=\"".url()."?wp=".$cid."&Action=delete\"><img src='./graphics/red-cross-icon.png' /></a></td>";		
		
		my @values = (1..12);
		my @default;
		
		# my %labels = (
		# 'red' => 'A Red One',
		# 'green' => 'A Green One',
		# 'blue' => 'A Blue One',
		# 'yellow' => 'A Yellow One' );
 
		# print checkbox_group(
		# -name => 'color_choices',
		# -values => ['red', 'green', 'blue', 'yellow'],
		# -default => ['red', 'blue'],
		# -labels => \%labels
		# ); 
		
		# my %labels;
	
		print start_form(-name=>"screens_$cid");
		print hidden(-name=>"wp", -value=>"$cid");
		print hidden(-name=>"Action", -value=>"update");
		
		for my $i (0..11)
		{
			# push @default,$i if ${$seriescomps->{$cid}}[$i];
			
			print "<td>" . checkbox(-name=>"screens", -value=>$i, -checked=>${$seriescomps->{$cid}}[$i], -label=>"") . "</td>";
		}
		
		my $msg = ${$comps->{$cid}->{message}}[0]; 
		
		# cope with an empty message element
		$msg = "" if ref $msg eq "HASH";
		
		print "<td>" . textfield(-name=>"message", -value=>$msg) . "</td>";
		# print "<td colspan=12>" . checkbox_group(-name => "screens", -values=> \@values, -default => \@default) . "</td>";
		print "<td align='center'><a href=\"javascript: document.screens_$cid.submit();\"><img src='./graphics/green-disk-icon.png' /></a></td>";
		print end_form();

		my $enabled = $comps->{$cid}->{enabled} || "false";
		
		if ($enabled eq "true")
		{
			print "<td align='center'><a href=\"".url()."?wp=".$cid."&Action=disable\"><img src='./graphics/green-document-icon.png' /></a></td>";
		}
		else
		{
			print "<td align='center'><a href=\"".url()."?wp=".$cid."&Action=enable\"><img src='./graphics/blue-document-cross-icon.png' /></a></td>";
		}
		
		print "</tr>";
	}	
	
	print "</table>\n";
	print "</fieldset>\n";
	
	print "<br>";
			
	###########################################
	#
	#	Add a competition
	#
	###########################################
	print start_form(-name=>"form_add");	
	print "<fieldset><legend>Add a Competition</legend>\n";
	print hidden(-name=>"Action", -value=>"newcomp");
	
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});
	_find_comps();
	print Tr(td( popup_menu(-name=>'newcomp', -values=>\@available_comps)), td("<a href='javascript: document.form_add.submit();'><img src='./graphics/green-plus-icon.png' /></a>"));
	
	print end_table();
	print end_form();
	print "</fieldset><br>\n";

	_std_footer();

}


sub frm_config
{
	my $config = config_read();
	
	# <config checkintimeout="20000"
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
					"Output from the writexml.pl script",
					"Allow Check-in for fencers who owe entry fees?",
					"The Name of the Tournament e.g. \"The Little Whinging 6 Weapon Bun Fight\"",
					"Highlight highly ranked fencers on the entry list",
				);
				
	my $gap = '&nbsp;&nbsp;&nbsp;';
				
	_std_header("Configuration");
 
 
	###########################################
	#
	#	Base config
	#
	###########################################
	print start_form(
          -method=>'POST',
          -action=>url()
        );

	print "<br><fieldset><legend>Basic Configuration</legend>\n";
	print table({border => 0, cellspacing=>6, cellpadding=>2},
		Tr({},
		[
 			"<td>Event / Tournament Name :</td><td colspan=4>" . textfield(-name=>'tournamentname', -value=>$config->{tournamentname},-size=>50,-maxlength=>50) . "</td><td>$gap</td><td>$hints[7]</td>",
			td(["Check In Timeout :",radio_group(-name=>'checkintimeout', -values=>[60, 80, 100, 120], -default=>$config->{checkintimeout} / 1000, -linebreak=>'false'),$gap,$hints[0]]),
			td(["Allow Unpaid Check-in :",radio_group(-name=>'allowunpaid', -values=>['true', 'false'], -default=>$config->{allowunpaid}, -linebreak=>'false'),'','',$gap,$hints[6]]),
			td(["Status Timeout :",radio_group(-name=>'statustimeout', -values=>[10, 20, 30, 40], -default=>$config->{statusTimeout} / 1000, -linebreak=>'false'),$gap,$hints[1]]),
			td(["Debug Level :",radio_group(-name=>'debuglevel', -values=>[0, 1, 2], -default=>$config->{debug}, -linebreak=>'false'),'', $gap, $hints[2]]),
			td(["Restrict IP :",radio_group(-name=>'restrictip', -values=>['true', 'false'], -default=>$config->{restrictIP}, -linebreak=>'false'),'','',$gap,$hints[3]]),			
		])
	);

	print submit(-name=>'basic', -label=>'Update');
	
	print end_form();
	
	print "</fieldset>\n";


	###########################################
	#
	#	Output files / directories
	#
	###########################################	
	print start_form();
	print "<fieldset><legend>Output</legend>\n";
	print start_table({border => 0, cellspacing=>6, cellpadding=>2});
	print "<tr><td>Show NIF? :</td>" . td([radio_group(-name=>'nif', -values=>['true','false'], -default=>$config->{nif}, -linebreak=>'false'),$hints[8]]);
	print "<tr><td>Target Location :</td><td colspan=2>" . textfield(-name=>'targetlocation',-value=>$config->{targetlocation},-size=>80,-maxlength=>132) . "</td><td>$hints[4]</td></tr>";
	print "<tr><td>Debug Output :</td><td colspan=2>" . textfield(-name=>'log',-value=>$config->{log},-size=>80,-maxlength=>132) . "</td><td>$hints[5]</td></tr>";
	print end_table();
	
	print submit(-name=>'output', -label=>'Update');
	print end_form();
	
	print "</fieldset>\n";

	###########################################
	#
	#	IP Restrictions
	#
	###########################################
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
	
	###########################################
	#
	#	Set to Defaults
	#
	###########################################
	print start_form();
	
	print "<fieldset><legend>Set to Defaults	</legend>\n";
	
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});

	print "<tr><td><img src = './graphics/trash-icon-48.png' /></td><td>Set to Defaults - *** WARNING *** THIS CANNOT BE UNDONE!</td></tr>";
	print end_table();
	
	print end_form();
	print "</fieldset>\n";

	print "<br>";

	_std_footer();
}

sub frm_checkin_desk {
	
	my $config = config_read();
	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$config->{checkintimeout}.");\n}";

	_std_header("$config->{tournamentname} Check In Desk", $JSCRIPT, "doLoad()");
  
	print "<table border=1 cellspacing=0 cellpadding=0 width=640>";
	print "<tr><th>Please choose a weapon/competition.</th></tr>";
	print "<tr><td>&nbsp;</td></tr>";

	my $weapons = $config->{competition};

	foreach my $cid (sort { $a <=> $b } keys %$weapons) 
	{
		my $w = $weapons->{$cid};
		next unless $w->{enabled} eq "true";

		my $state = $w->{'state'};

		my ($name, $path);
		
		if (defined $Engarde::DB::VERSION)
		{
			$name = $w->{'titre_ligne'};
			$path = $w->{'source'};
		}
		else
		{
			next unless $state eq "check-in";
			my $c = Engarde->new($w->{source} . "/competition.egw", 2);
			next unless defined $c;

			$name = $c->titre_ligne;
			$path = $c->dir();
		}
		
		print "<tr><td><a href=".url()."?wp=$cid&Action=list>$cid - $name<br><font color='grey' size=1>$path</font></a></td></tr>" ;
  	}

  	print "</table><br>";
	
	_std_footer();
}


sub frm_checkin_list {
	my $cid = shift;
	my $config = config_read();

	my %cookies=CGI::Cookie->fetch;
	
	my ($f, $clubs, $nations, $titre_ligne);
	
	if (defined $Engarde::DB::VERSION)
	{
		$f = Engarde::DB::tireur();
		$titre_ligne = $config->{competition}->{$cid}->{titre_ligne};
	}
	else
	{
		my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw");
		HTMLdie("invalid competition") unless $c;
		HTMLdie("Check-in no longer actvive") unless $config->{competition}->{$cid}->{state} eq "check-in";
	
		$f = $c->tireur;
		$clubs = $c->club;
		$nations = $c->nation;
		$titre_ligne = $c->titre_ligne;
	}
	
	my $JSCRIPT="function edit(item) {\n  window.location.href=\"".url()."?wp=".$cid."&Action=Edit&Item=\" + item;\n}\n";
	$JSCRIPT=$JSCRIPT."function check(item,row) {\n  var m=document.getElementById('openModal'); m.style.opacity=1; m.style.pointerEvents='auto'; row.style.backgroundColor = 'green'; window.location.href = \"".url()."?wp=$cid&Action=Check&Item=\" + item\n}\n";
	$JSCRIPT=$JSCRIPT."function scratch(item,row) {\n  var m=document.getElementById('openModal'); m.style.opacity=1; m.style.pointerEvents='auto'; row.style.backgroundColor = 'grey'; window.location.href = \"".url()."?wp=$cid&Action=scratch&Item=\" + item\n}\n";
	$JSCRIPT=$JSCRIPT."function doLoad() {\n  setTimeout('window.location.reload()'," . $config->{checkintimeout} . ");\n}\n\n";
	$JSCRIPT=$JSCRIPT."function showAll(val) { \n document.cookie='showAll='+val; window.location.reload();}";

	my $row = 0;
	my $state = $config->{competition}->{$cid}->{state};

	my $fencers = {};
	
	_std_header($titre_ligne  ." Check-in", $JSCRIPT, "doLoad();");
	
	print "<div id=\"openModal\" class=\"modalDialog\">";
	print "<div class=\"labeled\"><div class=\"spinner\"><div class=\"bar1\"></div><div class=\"bar2\"></div><div class=\"bar3\"></div>";
	print "<div class=\"bar4\"></div><div class=\"bar5\"></div><div class=\"bar6\"></div><div class=\"bar7\"></div><div class=\"bar8\"></div>";
	print "<div class=\"bar9\"></div><div class=\"bar10\"></div><div class=\"bar11\"></div><div class=\"bar12\"></div></div>Please wait&hellip;</div>";
	print "</div>";
	
	# not sure this is needed... should just grep the keys statement below
	foreach my $fid (grep /\d+/, (keys %$f))
	{
		$fencers->{$fid} = $f->{$fid};
	}
	
	my $present = $f->{present};
	my $total = scalar keys %$fencers;
	my $showall = "false";
	$showall = $cookies{'showAll'}->value if $cookies{'showAll'};
	
	$showall = $showall eq "true" ? 1 : 0;
	
	# print "showall = $showall<br>";
	print "<br>";

	print "<table border=0 cellspacing=0 cellpadding=0><tr><td align=center>\n" ;
	print "<table border=0 cellspacing=5 cellpadding=0 width=100%><tr><td><a href=".url().">Check-in Desk</a></td>";
	print "<td align=center>Fencers Present : ".$present."/".$total."</td>";
	print "<td>Show all " . checkbox(-name=>'showAll', -checked=>$showall, -onClick=>'showAll(this.checked)', -label=>"") . "</td>";
	print "<td align=right>";
	print "<a href=javascript:edit('-1')>Add Fencer</a>" unless ($state ne "check-in");
	print "</td>";
	print "</tr></table>\n" ;
	print "<table border=1 cellspacing=0 cellpadding=2>\n" ;
	print "<tr><th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th><th>NAME</th><th>CLUB</th><th>NATION</th><th>LICENCE NO</th><th>CAT	</th><th>OWING</th><th>NOTES</th><th></th><th></th></tr>\n" ;

	# HTMLdie(Dumper(\$fencers));
	
	foreach my $fid (sort {$fencers->{$a}->{nom} cmp $fencers->{$b}->{nom}} keys %{$fencers})
	{
		if (!$showall)
		{	
			next if $fencers->{$fid}->{presence} && $fencers->{$fid}->{presence} eq "present";
		}
		
		my ($name, $first, $club, $nation, $licence, $owing, $nva, $comment);
		my $bgcolour = "green" ;
   
		$nva = "";
		
    	$owing  = $fencers->{$fid}->{paiement} || "";
		
		$owing = "" if $owing eq "0.00";

		$name = $fencers->{$fid}->{nom} . " " . $fencers->{$fid}->{prenom};
		$club = $fencers->{$fid}->{club1};
		$club = $clubs->{$club}->{nom} if $club;
		$nation = $fencers->{$fid}->{nation1};
		$nation = $nations->{$nation}->{nom} if $nation;

		$licence = $fencers->{$fid}->{licence};

		my $link = "";
		
		$comment = $fencers->{$fid}->{comment};
		
	
		if (!$fencers->{$fid}->{presence} || $fencers->{$fid}->{presence} ne "present") 
		{
			$link = "<button onclick=javascript:check('".$fid."',document.getElementById('row_$fid'))>Check-in</button>";
			
			if ( $fencers->{$fid}->{scratched} )
			{
				# set to grey if scratched
				$bgcolour = "grey";
				$link = "";
			}
			elsif ( $fencers->{$fid}->{expired} )
			{
				# set to red if membership expired
				$bgcolour = "red";
				$link = "";
			}
			
			elsif ($owing) 
			{
				$owing  = "&pound;".$owing;
				$bgcolour = "yellow";
				
				$link = "" unless $config->{allowunpaid} eq "true";
			} 
			else 
			{
				$bgcolour = "white";
			}
		}

		$nva = $fencers->{$fid}->{category};
    	
		$nva = "" if $nva eq "S";
		
		print "<tr bgcolor=\"$bgcolour\" id='row_$fid'>";
    	print "<td>$link</td>";
    	print "<td>",$name,"</td>" ;
    	print "<td>",$club || "","</td>" ;
    	print "<td>",$nation || "","</td>" ;
    	print "<td>",$licence || "","</td>" ;
    	print "<td align='center'>$nva</td>" ;
    	print "<td>",$owing || "","</td>" ;
    	print "<td>",$comment || "","</td>" ;
    	print "<td><button onclick=javascript:edit('".$fid."')>Edit</button></td>" ;
		print $fencers->{$fid}->{scratched} ? "<td></td>" : "<td><button onclick=javascript:scratch('".$fid."',document.getElementById('row_$fid'))>Scratch</button></td>" ;
    	print "</tr>\n" ;
    	$row += 1;
  	}
  	print "</table>" ;
  	print "</td></tr></table>" ;

  	_std_footer();
}


sub frm_fencer_edit
{
	my $weaponPath = shift;
	my $config = config_read();

	my $c=Engarde->new($config->{competition}->{$weaponPath}->{source} . "/competition.egw", 2);
	HTMLdie("invalid competition") unless $c;
	
	# check lock state here
	# actually...only check it on update as this form may be on the screen for some time
	
	# my ($name, $first, $club, $nation, $licence, $presence, $owing, $nva);
	my $state = $config->{competition}->{$weaponPath}->{state};

	my $f = {};
	my $item = param('Item');
	
	if ($item != -1)
	{
		$f = $c->tireur($item);
	}
	else
	{
		$item = {};
	}
	
	_std_header( "Edit Item");

	print start_form(
          -method=>'POST',
          -action=>url()
        ),
        hidden(
          -name=>'wp',
          -value=>$weaponPath,
          -override=>'true'
        ),
        hidden(
          -name=>'Action',
          -value=>'write',
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
			td(["Surname :",textfield(-name=>'nom',-value=>$f->{nom},-size=>32,-maxlength=>32)]),
			td(["Forename :",textfield(-name=>'prenom',-value=>$f->{prenom},-size=>32,-maxlength=>32)]),
			td(["Licence No :",textfield(-name=>'licence',-value=>$f->{licence},-size=>32,-maxlength=>32)]),
			td(["Notes :",textfield(-name=>'comment',-value=>$f->{comment},-size=>32,-maxlength=>32)]),
		])
	);

	print "</fieldset>\n";
	
	print "<fieldset><legend>Affilliation</legend>\n";
	
	my $selclub   = $f->{club1} || -1;
	my $selnation = $f->{nation1} || -1;
	
	# $selclub .= ",$selnation";

	print table({border => 0, cellspacing=>2, cellpadding=>0},
		Tr({},
		[
			td(	[	"Club :",_club_list($c, $selclub),
					$selclub eq -1 ? 
					textfield(-name=>'newclub',-value=>"",-size=>32,-maxlength=>32) :
					textfield(-name=>'newclub',-value=>"",-size=>32,-maxlength=>32, -disabled=>'disabled')
			]),
			td("Nation :") . td({colspan=>(2)},  _nation_list($c, $selnation)),               
		])
	);
		
	print "<fieldset><legend>Additional Information</legend>\n";
  
	print start_table({border => 0, cellspacing=>2, cellpadding=>0});
	my $cat  = $f->{category};
	
	print	Tr({},
			[
				td( [	"Date of Birth :",
						textfield(-name=>'dob',-value=>blessed($f) ? $f->dob : ""),
						textfield(-name=>'cat',-size=>5, -value=>$cat,-checked=>1,-label=>'Veteran',-disabled=>1),
						"Enter the DoB as d/m/yyyy or just yyyy.  Only a year is needed to work out the age category"
					]
				),
			]
		);
	
	#if ($f->{paiement}) 
	#{
		print "<tr bgcolor='yellow'><td>&pound;" . ($f->{paiement} || "0.00") . " outstanding</td><td>" . checkbox(-name=>'paid',-value=>1,-checked=>0,-label=>'Paid') . "</td></tr>";
	#}
  
	print end_table;
	
	print "</fieldset>\n";
	print "<fieldset><legend>Flags</legend>\n";
  
	if ($state eq "check-in") 
	{
		print checkbox(-name=>'presence',-value=>'present',-checked=> (($f->{presence} && $f->{presence} eq "present") ? 1 : 0),-label=>'Present');
		print checkbox(-name=>'scratched',-value=>'scratched',-checked=> ($f->{scratched} ? 1 : 0),-label=>'Scratched');
		print checkbox(-name=>'expired',-value=>'expired',-checked=> ($f->{expired} ? 1 : 0),-label=>'Expired');
		
	} 
	else 
	{
		print hidden(-name=>'presence',-value=>$f->presence,-override=>'true');
		print hidden(-name=>'scratched',-value=>$f->scratched,-override=>'true');
		print hidden(-name=>'expired',-value=>$f->expired,-override=>'true');
	}
	
	print "<br>";
	print "</fieldset>\n";
  
	print submit(-label=>'Update Record');
	
	print "<button onclick=\"javascript:window.history.back();\">Cancel</button>";
  
	print end_form();

	print end_html();
}



#########################################################
#
# Private subs
#
#########################################################

sub _find_comps
{
	undef @available_comps;
	
	my @possibledirs = ("../../data/examples", "/home/engarde/public/data/current", "c:/users/psmith/Documents/prs2712\@gmail.com/escrime/DATA/examples");

	my @dirs;
	
	foreach (@possibledirs)
	{
		push @dirs, $_ if -d;
	}
	
	HTMLdir("no top dir") unless @possibledirs;
	
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
	# since this is a private sub, it makes sense to pass in $config instead or reloading it
	# but it could be changed for consistency
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

# lost my way here....  probably delete _open later
sub _open
{
	my $c = shift;
	
	open(my $fh, "+< " . $c->{dir} . "/etat.txt");
	return $fh;
}

sub _running 
{   
   my $fh = shift;
   
   # HTMLdie($fh);
   
   eval 
   {
      local $SIG{ALRM} = sub { die "alarm\n" };
      alarm 5; # set timeout to 5 seconds
      flock( $fh, LOCK_EX ); # attempt to get an exclusive lock
      alarm 0; # cancel any timeouts if we successfully got a lock
   };
   
   # returns true if the flock call timed out, false otherwise
   #return $@ eq "alarm\n";
   HTMLdie($@);
}

 
sub _release 
{
   my $fh = shift;
   # release the lock and close the filehandle
   flock( $fh, LOCK_UN );
   close( $fh );
} 

sub _std_header
{
	# prints the standard CGI.pm blurb
	
	# my $config = shift;
	my $title = shift || "Engarde.pm";
	my $JSCRIPT = shift || "";
	my $onload = shift || "";
	
  	print header(),
	start_html(
		-title => $title,
		-lang => 'en-GB',
		-style => {'src' => ['./css/dt.css', './css/hint.css']},
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

sub _std_footer
{
	# print "<br>";
	
	print table
	(
		{ cellpadding=>20 },
		Tr(
			td( [
					"<a href='index.html'>Home</a>",
					"<a href='check-in.cgi'>Check-in Desk</a>",
					"<a href='status.cgi'>Status / Control</a>",
					"<a href='screens.cgi'>Screen Configuration</a>",
					"<a href='config.cgi'>General Configuration</a>"
				])
		)
	);
	
	print "</body></html>";
}

sub _club_list
{
	my $c = shift;
	my $sel = shift || -1;
	
	Engarde::debug(1,"_club_list: sel = $sel");
	
	my @ckeys;
	my %clubnames;

	my $clublist = $c->club;
	
	# Generate Club List
	
	@ckeys = sort {uc($clublist->{$a}->{'nom'}) cmp uc($clublist->{$b}->{'nom'})} (grep /\d+/, keys(%$clublist));
	
	%clubnames = map {$_ => $clublist->{$_}->{nom} } @ckeys;
	
	push (@ckeys, '-1');
	$clubnames{'-1'} = 'Other';
	
	return popup_menu(	-name=>'club',
						-values=>\@ckeys,
						-labels=>\%clubnames,
						-default=>$sel,
						-onchange=>"if (club.value == -1) {newclub.disabled = false;} else {newclub.disabled = true;}"
					);
}


sub _nation_list
{
	my $c = shift;
	my $sel = shift || -1;
	my %nationnames;

  	#
  	# Generate Nation List
  	#

	my $n = $c->nation;
	
	$n->default unless $n->{max};
	
	my $defaultNation = "GBR";

	my @nkeys = sort {uc($n->{$a}->{'nom'}) cmp uc($n->{$b}->{'nom'})} (grep /\d+/, keys(%$n));

	%nationnames = map {$_ => "$n->{$_}->{nom} => $n->{$_}->{nom_etendu}" } @nkeys;

	# %nationnames = map {$_ => $n->{$_}->{nom} } @nkeys;

	push (@nkeys, '-1');
	$nationnames{'-1'} = "None";

	return popup_menu(	-name=>'nation',
						-values=>\@nkeys,
						-labels=>\%nationnames,
						-default=>$sel,
						-onchange=>"if (nation.value == -1) {newnation.disabled = false;} else {newnation.disabled = true;}"
					);
}

sub _dob_to_date
{
	# this isn't strictly needed but is useful to have in case
	# we need to use real dates from a date picker for example
	
	my $dob = shift;
	return undef unless $dob;
	
	Engarde::debug(3,"_dob_to_date(): dob = $dob");
	
	my @parts = split /\//, $dob;
	@parts = reverse @parts;
	
	Engarde::debug(1,"_dob_to_date(): parts = [@parts]");
	
	return "~$parts[2]/$parts[1]/$parts[0]" if (scalar @parts == 3);
	return "~$parts[1]/$parts[0]" if (scalar @parts == 2);
	return "~$parts[0]" if (scalar @parts == 1);
	return "~$dob";
}

sub _lock
{
	my $c = shift;
	my $dir = $c->dir;
	
	my $tries = 0;
	
	while ($tries < 2)
	{
		if (-f "$dir/eflock.txt")
		{
			sleep 2;
			$tries += 1;
		}
		else
		{
		
		}
	}
}

sub _unlock
{
	my $c = shift;
	my $dir = $c->dir;		
}


1;

__END__
