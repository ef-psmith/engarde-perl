package Engarde::Control;

use Engarde;
require Exporter;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);
our @EXPORT = qw(control read_config update_status show_weapon hide_weapon loadFencerData HTMLdie desk displayList editItem);

use Data::Dumper;

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
    
  print header(),
        start_html(
          -title => 'Error',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => '#000000',
          -vlink => '#000000',
          -alink => '#999900',
          -link => '#000000',
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );
  print h1($msg);
  print end_html();
       
  exit;
}

sub update_status {
  my ($path, $new_status) = @_;
  if ($path) {
    my $state = &readStatus($path);
    if ($new_status) {
      $state->{'status'} = $new_status;
      sysopen(FH, "$path/weapon.status", O_WRONLY | O_CREAT, 0666) || HTMLdie("Could not open $path/weapon.status for writing\n$!");
      flock(FH, LOCK_EX) || HTMLdie("Couldn't obtain exclusive lock on $path/weapon.status");
      foreach (keys(%$state)) {
        print FH "$_ $state->{$_}\n" ;
      }
      close(FH);
    }
  }
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
	print header(),
	start_html(
		-title => 'Control',
		-lang => 'en-GB',
		-style => {'src' => '/styles/bift.css'},
		-text => "#000000",
		-vlink => "#000000",
		-alink => "#999900",
		-link => "#000000",
		-script => $JSCRIPT,
		-onload => 'doLoad()'
	),
	table({border => 0, cellspacing=>0, cellpadding=>0},
		Tr(
			td([
				img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
				img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
			])
		)
	);
  
	print "<br><br><table border=0 cellspacing=0 cellpadding=0 width=720>\n";
	print "<tr><td></td><th align=left>Status</th><th align=left></th><th align=left>Action</th><th align=left></th></tr>\n" ;

	my $comps = $$config->{competition};

	# HTMLdie("xxx" . Dumper($comps));	

	foreach my $cid (sort keys(%$comps)) 
	{
		my $w = $comps->{$cid};
		next unless $w->{enabled} eq "true"; 
		# HTMLdie(Dumper($w));
		my $state = $w->{'state'};

		my $c = Engarde->new($w->{source} . "/competition.egw");

		# HTMLdie(Dumper(\$c));
 
		my $name = $c->titre_reduit;
    
    	unless (defined $state) 
		{
			$w->{'state'} = "hidden";
      		# &update_hidden($w->{'path'}, "true");
    	}

    	$name =~ s/"//g;
    	print "<tr><th align=left>$name</th>" ;
    
    	if ((!defined $state) || ($state eq "hidden")) 
		{
      		print "<td align=left>Check-in</td><td align=left>Not Ready</td><td align=left><a href=\"".url()."?wp=".$cid."&Action=update&Status=Ready\">Setup check-in</a></td><td>Hidden</td></tr>" ;

		} 
		elsif ($state eq "check in") 
		{
      		print "<td align=left>Check-in</td><td align=left>Open</td><td align=left><a href=\"".url()."?wp=".$cid."&Action=update&Status=Running\">Close check-in</a></td><td>";

      		if ($state ne "hidden") 
			{
        		print "<a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a>";
      		} else {
        		print "Hidden - <a href=\"".url()."?wp=".$cid."&Action=show\">Show</a>";
      		}

      		print "</td></tr>" ;
  		} 
		elsif ($state eq "ready") 
		{

      		print "<td align=left>Check-in</td><td align=left>Ready</td><td align=left><a href=\"".url()."?wp=".$cid."&Action=update&Status=Check%20in\">Open check-in</a></td><td>";

      		if ($state ne "hidden") 
			{
        		print "<a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a>";
      		} else {
				print "Hidden - <a href=\"".url()."?wp=".$cid."&Action=show\">Show</a>";
      		}
     	 print "</td></tr>" ;

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
					print "<td align=left>Complete</td><td align=left></td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";
					if ($state->{'hidden'} =~ /false/i) 
					{
            			print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          			} else {
           		 		print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
					}

					print "</td></tr>" ;
					last SWITCH;
				}

        		if ($etat eq "debut") 
				{
	  				print "<td align=left>Waiting</td><td align=left>Start</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";

          			if ($state->{'hidden'} =~ /false/i) 
					{
           		 		print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          			} 
					else 
					{
           				print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
          			}

          			print "</td></tr>" ;
	  				last SWITCH;
				}

        		if ($etat eq "poules") 
				{
				 	print "<td align=left>Poules</td><td align=left>Round $w[1] : " ;
	
	  				if ($w[2]) 
					{
	    				my @p = (@w);
						shift @p;
						shift @p;

	    				print scalar(@p)." poules running.</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td><td align=left>";

            			if ($state ne "hidden") 
						{
              				print "<a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a>";
           		 		} 
						else 
						{
           		   			print "Hidden - <a href=\"".url()."?wp=".$cid."&Action=show\">Show</a>";
           		 		}

           		 		print "</td></tr>" ;
	  				} 
					else 
					{
	    				print "complete.</td><td><a href=\"".url()."?wp=".$cid."&Action=details&Name=$name\">Details</a></td><td align=left>";
           		 		if ($state ne "hidden") 
						{
           		   			print "<a href=\"".url()."?wp=".$cid."&Action=hide\">Hide</a>";
           		 		} 
						else 
						{
           		   			print "Hidden - <a href=\"".url()."?wp=".$cid."&Action=show\">Show</a>";
           		 		}

           		 		print "</td></tr>" ;
	  				}

	  				last SWITCH;
				}

        		if ($etat eq "tableaux") 
				{
	  				print "<td align=left>D.E.</td><td align=left>" ;

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
	
	  				print "</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";

          			if ($state->{'hidden'} =~ /false/i) 
					{
           		 		print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
          			} 
					else 
				{
       		     	print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
       		   	}

   	  	   		print "</td></tr>";
		  		last SWITCH;
			}

				print "<td align=left>Error</td><td align=left>Unknown</td><td align=left></td><td align=left></td></tr>" ;
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

	print header(),
        start_html(
          -title => 'Check-in Desk',
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => "#000000",
          -vlink => "#000000",
          -alink => "#999900",
          -link => "#000000",
          -script => $JSCRIPT,
          -onload => 'doLoad()'
		),
		table({border => 0, cellspacing=>0, cellpadding=>0},
			Tr(
				td([
              		img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              		img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            	])
          	)
        );
  
		print "<table border=0 cellspacing=0 cellpadding=0 width=640>";
		print "<tr><td align=center><h2>Check-in Desk</h2></td></tr><tr><th align=left>Please choose a weapon/competition.</th></tr>";


		my $weapons = $$config->{competition};

		foreach my $cid (sort keys %$weapons) 
		{
			my $w = $weapons->{$cid};
			next unless $w->{enabled} eq "true";

			my $state = $w->{'state'};

			next if $state eq "hidden";

			my $c = Engarde->new($w->{source} . "/competition.egw");
      		print "<tr><td align=left><a href=".url()."?wp=$cid> $cid - ".$c->titre_reduit."</a></td></tr>" ;
  		}

  		print "</table><br><a href=\"index.html\">Back</a>\n" ;
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

	print header(),
	start_html(
       	-title => 'Check-in',
       	-lang => 'en-GB',
      	-style => {'src' => '/styles/bift.css'},
       	-text => "#000000",
       	-vlink => "#000000",
       	-alink => "#999900",
       	-link => "#000000",
       	-script => $JSCRIPT,
       	-onload => 'doLoad()'
	),
	table({border => 0, cellspacing=>0, cellpadding=>0},
		Tr(
           	td([
           		img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
           		img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
           	])
       	)
	);
  
	my $present = $::fencers->{present};
	my $total = $present + $::fencers->{absent};
	my $showall = param("showall") || 0;

	print "<table border=0 cellspacing=0 cellpadding=0><tr><td align=center>\n" ;
	print "<table border=0 cellspacing=5 cellpadding=0 width=100%><tr><td align=left><a href=".url().">Check-in Desk</a></td><td align=center>Fencers Present : ".$present."/".$total."</td><td>Show all <input type='checkbox' name='showall' value=".$showall."></td><td align=right>";
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
        my $data = XMLin($cf, KeyAttr=>'id', ForceArray=>qr/competition/);
        return $data;
}

sub write_config
{
        my $cf = shift;
        my $data = shift;

        sysopen(FH, "$cf" . ".tmp", "O_WRONLY") || cluck ("Could not open $cf for writing\n$!");
        flock(FH, LOCK_EX) || die ("Couldn't obtain exclusive lock on $cf");

        XMLout($data, KeyAttr=>'id', AttrIndent=>1, RootName=>'config', OutputFile=>$cf);

        rename("$cf" . ".tmp", "$cf");
}



sub editItem 
{
	my $weaponPath = shift;
	my $config = shift;

	my ($name, $first, $club, $nation, $licence, $presence, $owing, $nva);
	my $state = $$config->{competition}->{$weaponPath}->{state};

	# HTMLdie($state);
	if (param('Item') != -1) 
	{
		$name     = $::additions{param('Item')}->{'surname'} ;
		$name     =~ s/"//g ;
		$first    = $::additions{param('Item')}->{'name'} ;
		$first    =~ s/"//g ;
		$licence  = $::fencers{param('Item')}->{'licence'} ;
		$licence  =~ s/"//g ;
		$presence = $::fencers{param('Item')}->{'presence'} ;
		$owing    = $::additions{param('Item')}->{'owing'} || 0;
		$nva      = $::additions{param('Item')}->{'nva'} || 0;
	} else {
		$name     = "";
		$first    = "";
		$licence  = "";
    	$presence = "absent";
    	$owing    = 0;
    	$nva      = 0;
  	}
  
  	print header(),
		start_html(
			-title => 'Edit Fencer',
			-lang => 'en-GB',
			-style => {'src' => '/styles/bift.css'},
			-text => "#000000",
			-vlink => "#000000",
			-alink => "#999900",
			-link => "#000000"
		),
		table({border => 0, cellspacing=>0, cellpadding=>0},
			Tr(
            	td([
              		img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              		img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            	])
          	)
        );
  
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
          ]
          )
        );
  print "</fieldset>\n";
  print "<fieldset><legend>Affilliation</legend>\n";
  my %clubnames = ();
  my %nationnames = ();
  my $selclub   = -1;
  my $selnation = -1;
  my (@ckeys,@nkeys);
  #
  # Generate Club List
  #
  @ckeys = sort {uc($::clubs{$a}->{'nom'}) cmp uc($::clubs{$b}->{'nom'})} (keys(%::clubs));
  foreach (@ckeys) {
    $club   = $::addclubs{$_}->{'nom'} ;
    $club   =~ s/"//g ;
    $clubnames{$_} = $club;
    if (param('Item') != -1) {
      if ($_ == $::fencers{param('Item')}->{'club1'}) {
        $selclub = $_;
      }
    } else {
      if ($selclub == -1) {
        $selclub = $_;
      }
    }
  }
  push (@ckeys, '-1');
  $clubnames{'-1'} = 'Other';
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
	
  	print header(),
        start_html(
          -title => $title,
          -lang => 'en-GB',
          -style => {'src' => '/styles/bift.css'},
          -text => '#000000',
          -vlink => '#000000',
          -alink => '#999900',
          -link => '#000000',
        ),
        table({border => 0, cellspacing=>0, cellpadding=>0},
          Tr(
            td([
              img({-src => '/graphics/bift_logo_small.gif', -alt=>'Fencers', -height => 100, -width => 150}),
              img({-src => '/graphics/bift_title.gif', -alt => 'Birmingham International', -height => 100, -width => 490})
            ])
          )
        );

}
1;

__END__
