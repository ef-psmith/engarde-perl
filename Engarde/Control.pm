package Engarde::Control;

use Engarde;
require Exporter;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);
our @EXPORT = qw(control read_config update_status show_weapon hide_weapon loadFencerData HTMLdie desk displayList editItem);

use Data::Dumper;
use Cwd;
use DBI;

use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Pretty qw(:standard *table -no_xhtml);
    
use Fcntl qw(:DEFAULT :flock);

use XML::Simple;


sub readStatus {
  my $data ;
  my $opt ;
  my %status = ();
  my $path = shift;

  if (-e $path .  "/weapon.status") {
    open(FH,"< $path/weapon.status") || HTMLdie("Couldn't open $path/weapon.status");
    LINE: while (<FH>) {
      chomp;
      next LINE if ($_ eq "");
      ($opt, $data) = split(/\s+/,$_,2);
      $status{$opt} = $data;
    }
    close(FH);
  }
  return \%status;
}

sub HTMLdie {
  
	my ($msg,$title) = @_;
  
  	$title || ($title = "Error");
    
	_std_header(undef, "Error");

  	print h1($msg);
  	print end_html();
  	exit;
}

sub update_status {
	my $config = shift;
	my $cid = shift;
	my $status = shift;
	
	$config->{competition}->{$cid}->{state} = $status;

	write_config("/tmp/live2a.xml",$config);

	# reload the page with out the query string
	print "Location: ".url()."\n\n" ;
}

sub update_hidden {
  my ($path, $new_status) = @_;
  if ($path) {
    my $state = &readStatus($path);
    if ($new_status) {
      $state->{'hidden'} = $new_status;
      sysopen(FH, "$path/weapon.status", O_WRONLY | O_CREAT, 0666) || HTMLdie("Could not open $path/weapon.status for writing\n$!");
      flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
      foreach (keys(%$state)) {
        print FH "$_ $state->{$_}\n" ;
      }
      close(FH);
    }
  }
}

sub hide_weapon {
  my ($path) = @_;
  if ($path) {
    &update_hidden($path, "true");
  }
  # reload the page with out the query string
  print "Location: ".url()."\n\n" ;
}

sub show_weapon {
  my ($path) = @_;
  if ($path) {
    &update_hidden($path, "false");
  }
  # reload the page with out the query string
  print "Location: ".url()."\n\n" ;
}


sub control {
	my $config = shift;

	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$$config->{statusTimeout}.");\n}";

	_std_header(undef, "Control Panel", $JSCRIPT, "doLoad()");
  
	print "<br><table border=1 cellspacing=0 cellpadding=4 width=1080\n";
	print "<tr><td></td><th colspan=2 align=left>Status</th><th colspan=2 align=left>Actions</th></tr>\n" ;

	my $u = "escrime";
	my $p = "escrime";
	
	my $dbh = DBI->connect("DBI:mysql:escrime:127.0.0.1", $u, $p);
	
	my $comps = $$config->{competition};

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
		
		sysopen(ETAT, "$path/etat.txt", O_RDWR | O_CREAT) || HTMLdie("Could not open etat.txt\n$!");
		my $lockstat = flock(ETAT,LOCK_EX);
		
		sysopen(FH, "$path/weapon.status", O_WRONLY | O_CREAT, 0666) || HTMLdie("Could not open $path/weapon.status for writing\n$!");
		flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
		
		
		# HTMLdie(Dumper(\$c));

		my $name = $c->titre_ligne;

 		#unless (defined $state) 
		#{
			#$w->{'state'} = "hidden";
			# &update_hidden($w->{'path'}, "true");
		#}

		#$name =~ s/"//g;
		print "<tr><th align=left>$cid - $name</th>" ;

		if ((!defined $state) || ($state eq "hidden")) 
		{
			print "<td>Check-in</td><td>Not Ready</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Ready\">Setup check-in</a></td><td>Hidden</td></tr>" ;

		} 
		elsif ($state eq "check in") 
		{
			print "<td>Check-in</td><td>Open</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Running\">Close check-in</a></td>";
			print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
			print "</tr>" ;
		} 
		elsif ($state eq "ready") 
		{
			print "<td>Check-in</td><td>Ready</td><td><a href=\"".url()."?wp=".$cid."&Action=update&Status=Check%20in\">Open check-in</a></td>";
			print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
			print "</tr>";
		} 
		else 
		{
			my $where = $c->whereami;
			my @w = split (/\s+/,$where);
			my $etat = $c->etat;
      
			SWITCH: 
			{
				if ($etat eq "termine") 
				{
					print "<td>Complete</td><td></td><td><a href=\"".url()."?wp=".$cid."&Action=details\">Details</a></td><td></td></tr>";
					last SWITCH;
				}

 				if ($etat eq "debut") 
				{
	  				print "<td>Waiting</td><td>Start</td><td><a href=\"".url()."?wp=". $cid ."&Action=details&Name=$name\">Details</a></td>";
 					print "<td><a href=\"".url()."?wp=".$cid ."&Action=hide\">Hide</a></td>";
					print "</tr>" ;
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

	 					print scalar(@p)." poules running.</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
						print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
 						print "</tr>";
	  				} 
					else 
					{
						print "complete.</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
 						print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
 						print "</tr>" ;
 					}

	  				last SWITCH;
				}

				if ($etat eq "tableaux") 
				{
					# need to amend this - should print "poules" if $w[2] == "constitution"
	 				print "<td>D.E.</td><td>" ;

 					if ($w[2]) 
					{
 						shift @w;
						shift @w;

	 					foreach (@w) 
						{
							print "$_ ";
	 						#if ($_ > 8) 
							#{
  							#print " Last $_ " ;
							#} 
							#elsif ($_ == 8) 
							#{
							#print " Quarter final ";
 							#} 
							#elsif ($_ == 4) 
							#{
	 						#print " Semi final ";
 							#} 
							#else 
							#{
	 						#print " Final";
							#}
 						}
					}

					print "</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td>";
 					print "<td><a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a></td>";
	 				print "</tr>";
  					last SWITCH;
				}

				print "<td>Error</td><td>Unknown</td><td></td><td></td></tr>" ;
			}
		}
	}

	print "</table><br><a href=\"index.html\">Back</a>\n" ;
	print end_html();
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

	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$$config->{checkinTimeout}.");\n}";

	_std_header($config, "Check In Desk", $JSCRIPT, "doLoad()");
  
	# my $t=localtime();
	# print "$t\n";
	print "<table border=0 cellspacing=0 cellpadding=0 width=640>";
	print "<tr><th>Please choose a weapon/competition.</th></tr>";


	my $weapons = $$config->{competition};

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


sub read_config
{
        my $cf = shift;
		
		unless ($cf)
		{
			my $dir = cwd();
			
			$cf = "$dir/live.xml" if ( -r "$dir/live.xml" && not $cf);
			$cf = "$dir/../live.xml" if ( -r "$dir/../live.xml" && not $cf);
		}
		
        my $data = XMLin($cf, KeyAttr=>'id', ForceArray=>qr/competition/);
        return $data;
}

sub write_config
{
        my $cf = shift;
        my $data = shift;

        #sysopen(FH, "$cf" . ".tmp", "O_WRONLY") || HTMLdie ("Could not open $cf.tmp for writing: $!");
        #flock(FH, LOCK_EX) || HTMLdie ("Couldn't obtain exclusive lock on $cf");

        XMLout($data, KeyAttr=>'id', AttrIndent=>1, RootName=>'config', OutputFile=>$cf);

        #rename("$cf" . ".tmp", "$cf");
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
