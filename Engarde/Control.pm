package Engarde::Control;

use Engarde;
require Exporter;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);
our @EXPORT = qw(control readConfiguration update_status show_weapon hide_weapon readStatus loadFencerData HTMLdie);

use Data::Dumper;

use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);

sub readConfiguration {
  my $data ;
  my $opt ;
  my $name ;
  my $path ;
  my $status ;

  open(FH,"< check-in.conf") || HTMLdie("Couldn't open check-in.conf");
  LINE: while (<FH>) {
    chomp;
    next LINE if ($_ eq "");
    ($opt, $data) = split(/\s+/,$_,2);
    SWITCH: {
      if ($opt =~ /controlIp/) {
        push(@::controlIP, $data);
        last SWITCH; 
      }
      if ($opt =~ /defaultNation/) {
        $::defaultNation = $data;
        last SWITCH; 
      }
      if ($opt =~ /allowCheckInWithoutPaid/) { 
        $::allowCheckInWithoutPaid = $data;
        last SWITCH; 
      }
      if ($opt =~ /weapon/) {
        ($name, $path) = ($data =~ /(".+"|[\w]+)\s+([\w\/]+)/);
        push(@::weapons, {name=>$name, path=>$path});
        last SWITCH;
      }
      if ($opt =~ /checkinTimeout/) { 
        $::checkinTimeout = $data;
        last SWITCH; 
      }
      if ($opt =~ /statusTimeout/) { 
        $::statusTimeout = $data;
        last SWITCH; 
      }
    }
  }
  close(FH);
}

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
          -title => 'Birmingham International Fencing Tournament - Error',
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
	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$::statusTimeout.");\n}";
	print header(),
	start_html(
		-title => 'Birmingham International Fencing Tournament - Control',
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
	
	foreach (@::weapons) 
	{
		my $w = $_;
		my $state = &readStatus($w->{'path'});
		my $name = $w->{'name'};
    
    	if (!defined $state->{'hidden'}) 
		{
      		$state->{'hidden'} = "true";
      		&update_hidden($w->{'path'}, "true");
    	}

    	$name =~ s/"//g;
    	print "<tr><th align=left>$name</th>" ;
    
    	if ((!defined $state->{'status'}) || ($state->{'status'} =~ /hidden/i)) 
		{

      		print "<td align=left>Check-in</td><td align=left>Not Ready</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Ready\">Setup check-in</a></td><td>Hidden</td></tr>" ;

		} elsif ($state->{'status'} =~ /check in/i) {

      		print "<td align=left>Check-in</td><td align=left>Open</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Running\">Close check-in</a></td><td>";

      		if ($state->{'hidden'} =~ /false/i) 
			{
        		print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
      		} else {
        		print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
      		}

      		print "</td></tr>" ;

  		} 
		elsif ($state->{'status'} =~ /ready/i) 
		{

      	print "<td align=left>Check-in</td><td align=left>Ready</td><td align=left><a href=\"".url()."?wp=".$w->{'path'}."&Action=update&Status=Check%20in\">Open check-in</a></td><td>";

      	if ($state->{'hidden'} =~ /false/i) 
		{
        	print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
      	} else {
			print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
      	}
     	 print "</td></tr>" ;

    	} else {
    
		my $comp = Engarde->new($w->{'path'} . "/competition.egw");

		HTMLdie("can't open comp " . $w->{'path'}) unless $comp;

		my $where = $comp->whereami;
		my @w = split (/\s+/,$where);
		my $etat = $comp->etat;
      
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
          		} else {
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

	    			print scalar(@p)." poules running.</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";

            		if ($state->{'hidden'} =~ /false/i) 
					{
              			print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
           		 	} else {
           		   		print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
           		 	}

           		 	print "</td></tr>" ;
	  			} else {
	    			print "complete.</td><td><a href=\"".url()."?wp=".$w->{'path'}."&Action=details&Name=$name\">Details</a></td><td align=left>";

           		 	if ($state->{'hidden'} =~ /false/i) 
					{
           		   		print "<a href=\"".url()."?wp=".$w->{'path'}."&Action=hide\">Hide</a>";
           		 	} else {
           		   		print "Hidden - <a href=\"".url()."?wp=".$w->{'path'}."&Action=show\">Show</a>";
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

1;

__END__

