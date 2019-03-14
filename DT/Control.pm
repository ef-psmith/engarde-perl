# vim: ts=4 sw=4 noet:
package DT::Control;

###############################################################################
#
# 	Control.pm
#
# 	DT::Control - Provides the functions needed for DT, check-in, etc
#
# 	Copyright	2012-2018, Peter Smith, peter.smith@englandfencing.org.uk
#				2012-2013, England Fencing 
#				2012-2013, BIFTOC (for inspiration and the original code)
#
#	V2 - 2018	Move all form generation to Template::Toolkit
#				Support FencingTime

use 5.018;
use Engarde;
use FencingTime;
require Exporter;
use warnings;
no warnings 'io';
use JSON;
use Template;
use DT::Log;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);

$VERSION=2.00;

our @EXPORT = qw(	frm_control frm_config frm_screen frm_checkin_desk frm_checkin_list frm_fencer_edit
					config_read config_update_basic config_update_output config_update_ip config_trash
					weapon_add weapon_delete weapon_disable weapon_enable weapon_series_update weapon_series_update_ajax 
					weapon_config_update fencer_checkin fencer_scratch fencer_edit
					HTMLdie );

use Data::Dumper::Concise;
use Cwd qw/abs_path cwd/;
use File::Find;
use File::Basename;

use CGI qw(:standard *table -no_xhtml);
use CGI::Cookie;
    
use Fcntl qw(:flock :DEFAULT);
use Scalar::Util qw(blessed);

use XML::Simple;
# $XML::Simple::PREFERRED_PARSER = "XML::Parser";

# use XML::Dumper;
my @available_comps;
my $tt = Template->new({ INCLUDE_PATH => '/home/engarde/live/templates', ENCODING => 'utf8', PRE_CHOMP => 1 });


########################################################
#
# General purpose error handler
#
#########################################################

sub HTMLdie 
{
  
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

	my $c;
	my $titre;
	my $type;

	if ($config->{ftserver})
	{
		my $ft = FencingTime->instance({host => $config->{ftserver}});
		$c = $ft->event($path);

		$titre = $c->titre_ligne;

		$type = "ft";
	}
	else
	{	
		$c = Engarde->new($path . "/competition.egw", 2);
		$titre = $c->titre_ligne;
		$type = "engarde";
	}
	
	my @colours = qw/	blue chartreuse coral cyan darkgreen deeppink dodgerblue gold hotpink magenta 
				orange red seagreen tomato yellow darkorchid darksalmon goldenrod peachpuff thistle
				wheat peru moccasin mediumpurple/; 
	
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

	$comps->{$nextid}->{type} = $type;
	
	config_write($config);
	
	print redirect(url());
}


sub weapon_delete
{
	my $cid = shift;
	
	my $config = config_read();
	
	my $seriescomps = _series_by_comp($config);
	
	foreach my $s (0..13)
	{
		# skip non-existant series
		next unless ${$seriescomps->{$cid}}[$s];
			
		my @result = grep { $_ ne $cid } @{$config->{series}->{$s+1}->{competition}};
	
		$config->{series}->{$s+1}->{competition} = \@result;
	}

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
		
#	print "Location: " . url() . "\n\n" ;
	print redirect(url());
}

sub weapon_series_update
{
	my $cid = shift;
	_weapon_series_update($cid);
	print redirect(url());
}

sub weapon_series_update_ajax
{
	my $cid = shift;

	my $config = _weapon_series_update($cid);

	my $series = _series_by_comp($config);

	print header('application/json');

	print encode_json($series->{$cid});
}

sub _weapon_series_update
{
	my $cid = shift;

	#my @screens = param("screens");
	my @screens;
	my $s = param("s");
	my $message = param("message");

	if ($s)
	{
		# ajax rather than post
		@screens = split(/&*screens=/, $s);
	}

	my %screens = map {$_ => 1 } @screens;

	my $config=config_read();

	foreach my $s (0..13)
	{	
		# remove the comp from the list - leave everything else intact
		my @result = grep { $_ ne $cid } @{$config->{series}->{$s+1}->{competition}};
		
		# now add back the required screens
		push @result, $cid if exists $screens{$s};
		
		$config->{series}->{$s+1}->{competition} = \@result;
	}	
	
	if ($message)
	{
		$config->{competition}->{$cid}->{message} = $message;
	}
	else
	{
		delete $config->{competition}->{$cid}->{message};
	}
	
	config_write($config);	

	return $config;
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
	my $paid = shift;   # why?

	Engarde::debug(2,"fencer_checkin(): starting config_read() at " . localtime());

	my $config=config_read();

	#HTMLdie(Dumper($config->{competition}->{$cid}));
	
	Engarde::debug(2,"fencer_checkin(): starting new() at " . localtime());
	
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
	
	Engarde::debug(2,"fencer_checkin(): starting to_text() at " . localtime());
		
	$f->to_text;
	
	Engarde::debug(2,"fencer_checkin(): redirecting at " . localtime());
	
	print redirect(-uri=>"check-in.cgi?wp=$cid&Action=list");
}

sub fencer_scratch
{
	my $cid = param("wp");
	my $fid = param("Item");
	my $paid = shift;   # why?

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
	
	for (qw/nom prenom licence presence club newclub nation comment ranking/)
	{
		#Engarde::debug(1,"fencer_edit: setting $_ to " . param($_));
		$item->{$_} = param($_);
	}

	# $item->{scratched} = "scr" if param("scratched");
	# $item->{expired} = "exp" if param("expired");
	$item->{presence} = "absent" unless $item->{presence};
	$item->{nom} = uc($item->{nom});
	$item->{prenom} = ucfirst($item->{prenom});
	$item->{cle} = $cle;
	$item->{date_nais} = _dob_to_date(param("dob"));

	# need a drop down for status rather than 2/3 params
	$item->{status} = "scratched" if param("scratched");
	# $item->{status} = "scratched" if param("scratched");

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
	
	for (0..13)
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
	
	foreach my $s (1..14)
	{
		$config->{series}->{$s}->{enabled} = "true";
	}
}


sub _config_location
{
	my $dir = cwd();

	my @locations = (	"/home/engarde/live/web/live.xml",
						"/home/engarde/live/live.xml",
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
		
		my $data = XMLin($cf, KeyAttr=>'id', ForceArray=>1); 
		
		my $debug = $data->{debug};
		
		$Engarde::DEBUGGING = $debug;
		
        return $data;
}

sub config_write
{
	my $data = shift;
	my $cf = shift || _config_location();

	return undef unless $cf;

	open my $FH, ">$cf" . ".tmp" or HTMLdie ("Could not open $cf.tmp for writing: $!");
	flock($FH, LOCK_EX) || HTMLdie ("Couldn't obtain exclusive lock on $cf");

	my $out = "<?xml version=\"1.0\"?>\n";
	$out .= XMLout($data, KeyAttr=>'id', AttrIndent=>1, SuppressEmpty => undef, RootName=>'config');

	print $FH "$out";
	close $FH;

	rename "$cf.tmp", $cf or HTMLDie("rename failed: $!");
}

#########################################################
#
# subs for the configuration and data input screens
#
#########################################################

# TODO: Move all of the form generation to templates

sub frm_control
{
	my $data = config_read();
	my $ft;

	if ($data->{ftserver})
	{
		$ft = FencingTime->instance({host => $data->{ftserver}});
	}

	my $comps = $data->{competition};

	$comps = {} unless ref $comps eq "HASH";
	
	foreach my $cid (sort { $a <=> $b } keys(%$comps)) 
	{
		my ($c, $name, $path, $etat, @w);

		if ($comps->{$cid}->{type} eq "ft")
		{
			$c = $ft->tournament($data->{tournamentname})->event($comps->{$cid}->{source});
		}
		else
		{
			$c = Engarde->new($comps->{$cid}->{source});
		}

		next unless $c;

		$data->{competition}->{$cid}->{etat} = $c->etat;

		my $lockstat = 0;

		if ($comps->{$cid}->{type} eq "engarde")
		{
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

		}

		$data->{competition}->{$cid}->{lockstat} = $lockstat;

		my $where = $c->whereami;
		@w = split (/\s+/,$where);
		$etat = $c->etat;

		TRACE($etat);
		TRACE($where);

		$data->{competition}->{$cid}->{where} = $where;

		SWITCH:
		{
			if ($etat eq "tableaux")
			{
				$data->{competition}->{$cid}->{matchlist} = $c->matchlist(2);
			}
		}
		#####

		
	}

	$tt->process('control.tt', { title => 'Event Status', data => $data, });
}

sub frm_screen
{
	my $config = config_read();
	
	my $comps = $config->{competition};

	my $data = {};

	$comps = {} unless ref $comps eq "HASH";
	
	my $series = $config->{series};
	my $seriescomps = _series_by_comp($config);

	$data->{series} = $seriescomps;
		
	my $ft;

	if ($config->{ftserver})
	{
		$ft = FencingTime->instance({host => $config->{ftserver}});
	}
		
	foreach my $cid (sort { $a <=> $b } grep /\d+/, keys(%$comps)) 
	{
		my $src = $comps->{$cid}->{source};

		my $c;

		if ($config->{ftserver})
		{
			$c = $ft->event($src); 
		}
		else
		{
			$c = Engarde->new($src,2);
		}
		
		next unless $c;

		$data->{comps}->{$cid}->{titre_ligne} = $c->titre_ligne;
		$data->{comps}->{$cid}->{source} = $src;
		$data->{comps}->{$cid}->{enabled} = 1 if $comps->{$cid}->{enabled} eq "true";
		
	}	

	###########################################
	#
	#	Add a competition
	#
	###########################################
	
	$data->{newcomps} = _find_comps($config);

	TRACE ( sub { Dumper(\$data) } );	
	
	# Render
	$tt->process('screen.tt', { title => 'Screen Configuration', data => $data, }) 
		|| TRACE ( $tt->error() );

	TRACE ( "after render");
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
					"For the EF Server, this should be /home/engarde/live/web",
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
		next unless $state eq "check-in";

		my ($name, $path);
		
		my $c = Engarde->new($w->{source} . "/competition.egw", 2);
		next unless defined $c;

		$name = $c->titre_ligne;
		$path = $c->dir();
		
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
	
	my $c = Engarde->new($config->{competition}->{$cid}->{source} . "/competition.egw");
	HTMLdie("invalid competition") unless $c;
	HTMLdie("Check-in no longer actvive") unless $config->{competition}->{$cid}->{state} eq "check-in";
	
	$f = $c->tireur;
	$clubs = $c->club;
	$nations = $c->nation;
	$titre_ligne = $c->titre_ligne;
	
	my $JSCRIPT="var compid = $cid;";
	
	_std_header($titre_ligne  ." Check-in", $JSCRIPT, "GetFencers();", "script/check-in.js");

	print "<div id=\"openModal\" class=\"modalDialog\">";
	print "<div class=\"labeled\"><div class=\"spinner\"><div class=\"bar1\"></div><div class=\"bar2\"></div><div class=\"bar3\"></div>";
	print "<div class=\"bar4\"></div><div class=\"bar5\"></div><div class=\"bar6\"></div><div class=\"bar7\"></div><div class=\"bar8\"></div>";
	print "<div class=\"bar9\"></div><div class=\"bar10\"></div><div class=\"bar11\"></div><div class=\"bar12\"></div></div>Please wait&hellip;</div>";
	print "</div>";

	print br, br, "<div class=\"absent\">";
	print h2("Fencers to be checked in");
	
	print "<input id=\"lic\"></input>&nbsp;<button id=\"AddByLicButton\" onclick=\"AddByLic()\">Add by Licence</button>";
	print "<table id=\"Absent\" class=\"chktable\"><thead>";
	print "<th>&nbsp;</th><th class=\"name\">Name</th><th class=\"club\">Club</th><th class=\"nation\">Nation</th>";
	print "<th class=\"ranking\">Ranking</th><th class=\"memnum\">Mem Num</th><th class=\"paid\">Owing</th><th>&nbsp;</th><th>&nbsp;</th></thead>";
	print "</table>";
	print "</div>";
	print "<div class=\"present\">";
	print "<h2>Recent Check-ins &amp; Scratches</h2>";
	print "<table id=\"Recent\" class=\"chktable\">";
	print "<thead>";
	print "<th>&nbsp;</th><th class=\"name\">Name</th><th class=\"club\">Club</th><th class=\"nation\">Nation</th><th>&nbsp;</th><th>&nbsp;</th>";
	print "</thead>";
	print "</table>";
	print "<h2>Scratched</h2>";

	print "<table id=\"Scratched\" class=\"chktable\"><thead>";
	print "<th>&nbsp;</th><th class=\"name\">Name</th><th class=\"club\">Club</th><th class=\"nation\">Nation</th><th>&nbsp;</th><th>&nbsp;</th>";
	print "</thead>";	
	print "</table>";

	print h2("Present");
	print "<table id=\"Present\" class=\"chktable\"><thead>";
	print "<th>&nbsp;</th><th class=\"name\">Name</th><th class=\"club\">Club</th><th class=\"nation\">Nation</th><th>&nbsp;</th><th>&nbsp;</th>";
	print "</thead>";
	print "</table>";
	print "</div>";
	
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
	
	_std_header( "Edit Item", "", "", "script/check-in.js");

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
          -override=>'true'),
		hidden(
          -name=>'entry_id',
          -value=>param('entry_id'),
          -override=>'true'
	);

	print "<fieldset><legend>Fencer Information</legend>\n";
	
	print table({border => 0, cellspacing=>2, cellpadding=>0},
		Tr({},
		[
			td(["Surname :",textfield(-name=>'nom',-value=>$f->{surname},-size=>32,-maxlength=>32)]),
			td(["Forename :",textfield(-name=>'prenom',-value=>$f->{prenom},-size=>32,-maxlength=>32)]),
			td(["Licence No :",textfield(-name=>'licence',-value=>$f->{licence},-size=>32,-maxlength=>32)]),
			td(["Notes :",textfield(-name=>'comment',-value=>$f->{mode},-size=>32,-maxlength=>32)]),
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
						textfield(-name=>'dob',-value=>blessed($f) ? $f->dob : $f->{dob}),
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


	print "Presence: ";
	
	if ($state eq "check-in") 
	{
		my @presence = ("absent", "present", "scratched");
		
		print popup_menu(
        -name    => 'presence',
        -values  => \@presence,
        -default => $f->{presence});
		
		# print checkbox(-name=>'presence',-value=>'present',-checked=> (($f->{presence} && $f->{presence} eq "present") ? 1 : 0),-label=>'Present');
		#print checkbox(-name=>'scratched',-value=>'scratched',-checked=> ($f->{scratched} ? 1 : 0),-label=>'Scratched');
		#print checkbox(-name=>'expired',-value=>'expired',-checked=> ($f->{expired} ? 1 : 0),-label=>'Expired');
		
	} 
	else 
	{
		print hidden(-name=>'presence',-value=>$f->presence,-override=>'true');
		#print hidden(-name=>'scratched',-value=>$f->scratched,-override=>'true');
		#print hidden(-name=>'expired',-value=>$f->expired,-override=>'true');
	}
	
	print "<br>";
	print "</fieldset>\n";
  
	print submit(-label=>'Update Record');
	
	print "<button onClick=\"javascript:CancelEdit()\">Cancel</button>";
  
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
	my $config = shift;
	undef @available_comps;

	if ($config->{ftserver})
	{
		my $ft = FencingTime->instance({host => $config->{ftserver}});
		
		my $e = $ft->tournament($config->{tournamentname})->events;

		foreach (values %$e)
		{
			$_ =~ s/Saber/Sabre/g;
		}

		return $e;
	}
	else
	{
		
		my @possibledirs = ("../../data/examples", "/home/engarde/public/data/current");

		my @dirs;
	
		foreach (@possibledirs)
		{
			push @dirs, $_ if -d;
		}
	
		HTMLdir("no top dir") unless @possibledirs;
		
		find (\&_wanted, @dirs);
	}
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
	
	# live.xml format is
	# <series id="1">
	#	<competition>1</competition>
	#	<competition>2</competition>
	# </series>
	my $series = $config->{series};
	
	#HTMLdie(Dumper\$series);
	my $comps = $config->{competition};
	
	# HTMLdie(ref($comps));
	return undef unless ref $comps eq "HASH";
	
	my $out = {};
	
	# build an empty array
	foreach my $cid (keys %$comps)
	{
		my @row = (0,0,0,0,0,0,0,0,0,0,0,0,0,0);
		$out->{$cid} = \@row;
	}
	
	# now populate by iterating onver the series
	foreach my $sid (1..14)
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
	my $js	=	shift || "";
	
  	print header(),
	start_html(
		-title => $title,
		-lang => 'en-GB',
		-style => {'src' => ['./css/dt.css', './css/hint.css']},
		-text => '#000000',
		-vlink => '#000000',
		-alink => '#999900',
		-link => '#000000',
		-script => [ $JSCRIPT, { -src=>$js } ],
		-onload => $onload
	);

	print table({border => 0, cellspacing=>2, cellpadding=>0},
		Tr(
			td( img({-src => './graphics/logo_small.jpg', -alt=>'Logo', -height=>100, -width=>150})),
			td("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
			td("<h1>$title</h1>")
		)
	);
	
	# warningsToBrowser(1);
}

sub _std_footer
{
	# print "<br>";
	
	print "<div class=\"footer\">";
	
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
	
	print "</div>";
	print "</body></html>";
}

sub _club_list
{
	my $c = shift;
	my $sel = shift || -1;
	
	Engarde::debug(1,"_club_list: sel = $sel");
	
	my @ckeys;
	my %clubnames;

	my $clublist;
	
	$clublist = $c->club;
	
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

	my @nkeys = sort {uc($n->{$a}->{'nom_etendu'}) cmp uc($n->{$b}->{'nom_etendu'})} (grep /\d+/, keys(%$n));

	%nationnames = map {$_ => "$n->{$_}->{nom_etendu} => $n->{$_}->{nom}" } @nkeys;

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
