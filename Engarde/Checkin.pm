package Engarde::Checkin;
require Exporter;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde Exporter);
our @EXPORT = qw(desk displayList);

use Data::Dumper;

use CGI::Pretty qw(:standard *table -no_xhtml);
use Fcntl qw(:DEFAULT :flock);
use Engarde::Control;

sub desk {
	my $JSCRIPT="function doLoad() {\n  setTimeout('window.location.reload()',".$::checkinTimeout.");\n}";
	print header(),
        start_html(
          -title => 'Birmingham International Fencing Tournament - Check-in Desk',
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
	foreach (@::weapons) {
		my $w = $_;
		my $state = &readStatus($w->{'path'});
		if ((defined($state->{'status'}) && $state->{'status'} !~ /hidden/i) && 
			(defined($state->{'hidden'}) && $state->{'hidden'} =~ /false/i)) 
		{
      			print "<tr><td align=left><a href=".url()."?wp=$w->{'path'}>$w->{'name'}</a></td></tr>" ;
    		}
  	}

  	print "</table><br><a href=\"index.html\">Back</a>\n" ;
  	print end_html();
}


sub displayList {
	
	my $JSCRIPT="function edit(item) {\n  eWin = window.open(\"".url()."?wp=$::weaponPath&Action=Edit&Item=\" + item,\"edit\",\"height=560,width=640\");\n}\n";
	$JSCRIPT=$JSCRIPT."function check(item) {\n  cWin = window.open(\"".url()."?wp=$::weaponPath&Action=Check&Item=\" + item,\"check\",\"height=100,width=640\")\n}\n";
	$JSCRIPT=$JSCRIPT."function doLoad() {\n  setTimeout('window.location.reload()',20000);\n}";

	my $row = 0;
	my $state = &readStatus($::weaponPath);

	print header(),
	start_html(
       	-title => 'Birmingham International Fencing Tournament - Check-in',
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
	print "<a href=javascript:edit('-1')>Add Fencer</a>" unless ($state->{'status'} !~ /Check in/i);
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
        			print "<a href=javascript:check('".$fid."')>Check-in</a>" unless ($state->{'status'} !~ /Check in/i);
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

1;

__END__
