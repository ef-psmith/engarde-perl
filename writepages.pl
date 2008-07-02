# (c) Copyright Oliver Smith 2007 
# oliver_rps@yahoo.co.uk

use strict;
use Engarde;
use Data::Dumper;

use vars qw($pagedetails);


##################################################################################
# writeTableauFencer
##################################################################################
sub writeTableauFencer {
    my $webpage = $_[0];
    my $boutref = $_[1];
    my $postfix = $_[2];
    my $roundnumber = $_[3];
    my $forceFencer = $_[4];
	my $result; #  = $_[4]; # Not used 
    
    my $fencerKey = 'fencer'.$postfix;
    my $nofencerKey = 'nofencer'.$postfix;
    my $resultKey = 'result'.$postfix;
    my $seedKey = 'seed'.$postfix;
    my $countryKey = 'nation'.$postfix;
    my $clubKey = 'club'.$postfix;
    my $scoreKey = 'score'.$postfix;
  
	#	print "writeTableauFencer: bout = " . Dumper(\$boutref);
    
    if (defined($boutref)) {
		# There is a bout to be done.
		my $fencer = ${$boutref}{$fencerKey};
		
		# Work out the state of the bout.  If there is a time then assume that the bout is ongoing.  If there is a winner then
		# it has finished.
		my $winner = ${$boutref}{'winner'};
		my $time = ${$boutref}{'time'};
		
		if (defined($winner)) {
		
			if ($winner eq $fencer) {
				$result = "winner";
			} else {
				$result = "loser";
			}
		}
			
		# Only do anything if there is a fencer
		if (defined($fencer)) {

			print $webpage "\t\t\t<div class=\"de-element $fencerKey $result\">\n";
			if (1 == $roundnumber) {
				print $webpage "\t\t\t\t<div class=\"fencer\">$fencer</div>\n";

				my $seed = ${$boutref}{$seedKey};
				if (defined($seed)) {
				print $webpage "\t\t\t\t<div class=\"seed\">$seed</div>\n";
				}
				#my $country = ${$boutref}{$countryKey};
				#if (defined($country)) {
				#print $webpage "\t\t\t\t<div class=\"country\">$country</div>\n";
				#}
			} else {
				print $webpage "\t\t\t\t<div class=\"fenceronly\">$fencer</div>\n";
			}
			my $score = ${$boutref}{$scoreKey};
			if (defined($score)) {
			print $webpage "\t\t\t\t<div class=\"score\">$score</div>\n";
			}
			print $webpage "\t\t\t</div>\n";
		} else {
			if (defined($forceFencer)) {
	    		$fencerKey = 'fencer'.$forceFencer;
			}
			print $webpage "\t\t\t<div class=\"de-element $nofencerKey\">\n\t\t\t</div>\n";
		}
    }
}

##################################################################################
# writeBlurb
##################################################################################
# Write the blurb at the top of the file
sub writeBlurb {
    my $webpage = $_[0];
    local $pagedetails = $_[1];
   
   	# PRS: Add css path variable to allow for multiple comps with common css
	
    my $nextpage = ${$pagedetails}{'nextpage'};
    my $pagetitle = ${$pagedetails}{'pagetitle'};
    my $refresh = ${$pagedetails}{'refresh_time'};
    my $layout = ${$pagedetails}{'layout'};
    my $bkcolour = ${$pagedetails}{'background'};
    
    print $webpage '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">';
    print $webpage "\n<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\">\n<head>\n";
    
    print $webpage "\t<style type=\"text/css\">\n\t\tbody {background-color: $bkcolour}\n\t</style>\n";

    print $webpage '<link href="tableau_style.css" rel="stylesheet" type="text/css" media="screen" />';
    print $webpage "\n<link href=\"$layout.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";
    print $webpage '<link href="fencer_list.css" rel="stylesheet" type="text/css" media="screen" />';
    
    print $webpage "\n<script type=\"text/javascript\">\n\tonerror=handleErr\n";
    print $webpage "\tfunction handleErr(msg,url,l) {\n\t\talert(msg);\n\t\t//Handle the error here\n";
    print $webpage "\t\treturn true;\n\t}\n\n";
    
    my $pagefinishedcondition = "true";
    
    # Start function to kick off the scrolling and swapping
    print $webpage "\tfunction onPageLoaded() {\n";
    # If there are any scrolling lists then we need to call onPauseTimer
    if (defined(${$pagedetails}{'vert_scrolling_div'}) or defined(${$pagedetails}{'hori_scrolling_div'})) {
    
       	# Set the body onload
       	print $webpage "\t\tvar listElement = document.getElementById(\"vert_list_id\");\n";
        print $webpage "\t\tlistheight = listElement.offsetHeight;\n";
        print $webpage "\t\tvar listContainerElement = document.getElementById(\"list_cont_id\");\n";
        print $webpage "\t\tvar contheight = listContainerElement.offsetHeight;\n";
        print $webpage "\t\tvar listElementElement = document.getElementById(\"list_row_0\");\n";
        print $webpage "\t\tvar elemheight = listElementElement.offsetHeight;\n";
        print $webpage "\t\tvar listHeaderElement = document.getElementById(\"vert_list_header_id\");\n";
        print $webpage "\t\tvar headerheight = listHeaderElement.offsetHeight;\n";
        print $webpage "\t\tvar titleheight = listHeaderElement.offsetTop;\n";
                 
        print $webpage "\t\tscrollLimit = contheight - elemheight - headerheight - titleheight;\n";
        print $webpage "\t\tpauseTime = Math.floor($refresh * 1000 / (Math.floor(listheight/scrollLimit) + 2));\n";
               
       	print $webpage "\t\tonPauseTimer();\n";
    }
    # If there are any swaps then we need to start them off.
    if (defined(${$pagedetails}{'swaps'})) {
    	print $webpage "\t\tstartSwapTimers();\n";
    }
    print $webpage "\t}\n";
    
    # pause function to stop lists scrolling too soon.
	print $webpage "\tvar top = 0;\n\tvar left=0;\n\tvar pageStartTop=0;\n\n";
    print $webpage "\tfunction onPauseTimer() {";
    print $webpage "\t\tpageStartTop = top;\n";
    print $webpage "\t\tt1=setTimeout(\"onScrollTimer()\",pauseTime);\n\t}\n";
    
    
    if (defined(${$pagedetails}{'vert_scrolling_div'})) 
    {
		# Update the page finished
		$pagefinishedcondition .= " && list_finished";
		
		# scroll stuff.  All scroll together.
		print $webpage "\tvar list_finished = false;\n\tfunction onScrollTimer() {\n\t\tvar topVal = top + 'px';\n";
	    
        foreach my $vert_scroll (@{${$pagedetails}{'vert_scrolling_div'}}) {
            print $webpage "\t\tdocument.getElementById(\"$vert_scroll\").style.top = topVal;\n";
        }
	    
		print $webpage "\t\ttop -= 5;\n";
		print $webpage "\t\tif (top <= pageStartTop - scrollLimit || top + listheight < 0) {\n";             
		print $webpage "\t\t\tif (top + listheight < 0) {\n";
		print $webpage "\t\t\t\tlist_finished = true;\n";
		print $webpage "\t\t\t\tcheckFinished();\n";
		print $webpage "\t\t\t} else {\n";
		print $webpage "\t\t\t\tonPauseTimer();\n";
		print $webpage "\t\t\t}\n";
		print $webpage "\t\t} else {\n";
		print $webpage "\t\t\tt2=setTimeout(\"onScrollTimer()\",50);\n";
		print $webpage "\t\t}\n\t}\n\n";
	}
    
    
    #if (defined(${$pagedetails}{'hori_scrolling_div'})) 
    #{
    #    foreach my $hori_scroll (@{${$pagedetails}{'hori_scrolling_div'}}) {
    #        print $webpage "\t\tdocument.getElementById(\"$hori_scroll\").style.left = leftVal;\n";
    #    }
    #}

    # swapping function
    # first work out the refresh times
    my @swaptimers;
    if (defined(${$pagedetails}{'swaps'})) {
    
		# Update the page finished
		$pagefinishedcondition .= " && tableau_finished";
		
    	my $seriesnum = 0;
    	foreach (@{${$pagedetails}{'swaps'}}) {
    	    	    
    	    print $webpage "\tvar tableau_finished = false;\n\tvar swaps$seriesnum = new Array();\n";
    	    
    	    my $index = 0;
    	    foreach (@{$_}) {
    	    	print $webpage "\tswaps$seriesnum";
    	    	print $webpage "[$index] = \"$_\";\n";
    	    	$index++;
    	    }
    	    print $webpage "\tvar swapindex$seriesnum = 0;\n";
    	    
    	    print $webpage "\tfunction onSwapTimer$seriesnum() {\n";
    	    print $webpage "\t\tif (swapindex$seriesnum == swaps$seriesnum.length - 1) {\n";
    	    print $webpage "\t\t\ttableau_finished = true;\n\t\t\tcheckFinished();\n\t\t\treturn;\n";
    	    print $webpage "\t\t}\n";
    	    
	    # Refresh time is in seconds, swaptimer in milliseconds (and yes I know int() shouldn't be used to round but I don't care)
	    $swaptimers[$seriesnum] = int($refresh / @{$_} * 1000);
    	    if (@{$_} > 1) { 
		    print $webpage "\t\tvar oldDiv = swaps$seriesnum";
		    print $webpage "[swapindex$seriesnum];\n";
		    print $webpage "\t\tdocument.getElementById(oldDiv).style.visibility = \"hidden\";\n";
		    print $webpage "\t\tswapindex$seriesnum += 1;\n";
		    print $webpage "\t\tdocument.getElementById(swaps$seriesnum";
		    print $webpage "[swapindex$seriesnum]).style.visibility = \"visible\";\n";
		    print $webpage "\t\tif (swapindex$seriesnum < swaps$seriesnum.length) {\n";
		    print $webpage "\t\t\tvar t = setTimeout(\"onSwapTimer$seriesnum()\",$swaptimers[$seriesnum]);\n";
		    print $webpage "\t\t}\n";
	    }
	    print $webpage "\t}\n";
    	    
    	    $seriesnum++;
    	}
    }
    
    
    print $webpage "\tfunction startSwapTimers() {\n";
    if (defined(${$pagedetails}{'swaps'})) 
    {
		my $seriesnum = 0;
		foreach (@{${$pagedetails}{'swaps'}}) {

			print $webpage "\t\tvar t = setTimeout(\"onSwapTimer";
			print $webpage "$seriesnum";
			print $webpage "()\",$swaptimers[$seriesnum]);\n";

			$seriesnum++;
		}
    }
    print $webpage "\t}\n";
    print $webpage "\tfunction checkFinished() { \n";
    print $webpage "\t\tif ($pagefinishedcondition) {\n";
	print $webpage "\t\t\twindow.location.replace(\"$nextpage\");\n";
    print $webpage "\t\t}\n\t}\n\n";
    
    print $webpage "\n</script>\n\n</head>\n<body onload=\"onPageLoaded()\">";

    print $webpage "\n<title>$pagetitle</title>\n";

}

##################################################################################
# writePoule
##################################################################################
# Write out a poule, writePoule(data, pagehandle, pagedetails)
sub writePoule 
{
    my $EGData = shift;
    my $webpage = shift;
    local $pagedetails = shift;

	# print "writePoule: EGData = " . Dumper(\$EGData);
	print "writePoule: pagedetails = " . Dumper(\$pagedetails);

    my $div_id = $pagedetails->{'poule_div'};
    my $poule_title = $pagedetails->{'poule_title'};
    # Note that we are going to use tableau as the generic container for poules as well.
    my $poule_class = 'tableau';
	my $where = $pagedetails->{'where'};
	print Dumper $where;

    if (defined($pagedetails->{'poule_class'})) 
	{
        $poule_class = $pagedetails->{'poule_class'};
    }
    
	my @g = $pagedetails->{'poule'}->grid;

	print $webpage "<div class=\"$poule_class\" id=\"$div_id\">\n";
    print $webpage "\t<h2>$poule_title</h2>\n";
	print $webpage "\t<table cellpadding=\"5\" border=\"1\">\n";
	
	my $lineNum = 0;

	my $firstResult = 0;
	foreach my $line (@g)
	{
		print "line = " . Dumper(\$line);

		print $webpage "\t\t<tr>\n";

		my $cellNum = 0;
		foreach my $cell (@$line)
		{
			if ($cellNum > 0) {
				if ($lineNum > 0) {
					# Just a normal line but need to check whether it is the fencer vs self fight
					if ($lineNum == ($cellNum - $firstResult + 1)) {
						print $webpage "\t\t\t<td style=\"background-color: black\">$cell</td>\n";
					} else {
						print $webpage "\t\t\t<td>$cell</td>\n";
					}
				} else {
					# It is a header, two impacts: it uses <th> elements and it replaces some "result" with a number
					my $header = $cell;
					if ("result" eq $header) {
						if (0 == $firstResult) {
							$firstResult = $cellNum;
						}
						$header = ($cellNum - $firstResult + 1);
					}
					print $webpage "\t\t\t<th>$header</th>\n";
				}
			} else {
				# Want to add the Fencer numbers within the poule
				# But only for the non header line
				my $num = "";
				if ($lineNum > 0) {
					$num = $lineNum;
				}
				print $webpage "\t\t\t<td>$num</td>\n";
			}
			$cellNum++;
		}

		print $webpage "\t\t</tr>\n";
		$lineNum++;
	}

	print $webpage "\t</table>\n</div>\n";

}

##################################################################################
# writeTableau
##################################################################################
# Write out a tableau, writeTableau(data, pagehandle, pagedetails)
sub writeTableau 
{
    my $EGData = shift;
    my $webpage = shift;
    local $pagedetails = shift;

	# print "writeTableau: EGData = " . Dumper(\$EGData);
	print "writeTableau: pagedetails = " . Dumper(\$pagedetails);

    my $div_id = $pagedetails->{'tableau_div'};
    my $tableau_title = $pagedetails->{'tableau_title'};
    my $tableau_class = 'tableau';
	my $where = $pagedetails->{'where'};
	print Dumper $where;

    if (defined($pagedetails->{'tableau_class'})) 
	{
        $tableau_class = $pagedetails->{'tableau_class'};
    }

    my $lastN = ${$pagedetails}{'lastN'};
    # this is the bout before this tableau.  Should be divisible by 2.
    my $preceeding_bout = $pagedetails->{'preceeding_bout'};
    
    print $webpage "<div class=\"$tableau_class\" id=\"$div_id\">\n";
    print $webpage "\t<h2 class=\"tableau_title\">$tableau_title</h2>\n";

    # Work out how many bouts there are.  Note that we never display the winner in the tableau, merely the final
    my $numbouts = 4;

	$numbouts = 4 if $lastN <= 4;

	my $result = "bout-started";

    for (my $roundnum = 1; $roundnum <= 2; $roundnum++) 
	{
        my $colname = "r" . $roundnum . "col";
        print $webpage "\t<div class=\"$colname\">\n";

        for (my $boutnum = 1; $boutnum <= $lastN / 2; $boutnum++) {
	   		print "round = $roundnum, lastN = $lastN, numbouts = $numbouts, boutnum=$boutnum\n";
            my $boutname = "r" . $roundnum . "bout-" . $boutnum;
            print $webpage "\t\t<div class=\"$boutname bout\">\n";
            
			my $bout = $EGData->{$where}->{$boutnum};

			# print "XXX: boutnum = $boutnum\n";
			# print "bout = " . Dumper(\$bout);
            
			if (defined($bout)) {
				print $webpage "\t\t\t<div class=\"pistecontainer\">\n\t\t\t\t<div class=\"de-element fencerA\">";
				print $webpage "Piste: " . ${$bout}{'piste'}  . "</div>\n\t\t\t</div>\n";
				
				print "writeTableau: roundnum = $roundnum, result = $result\n";
	
				# PRS: change to use data we already have
				writeTableauFencer($webpage, $bout, 'A',$roundnum);
				writeTableauFencer($webpage, $bout, 'B',$roundnum);
	
				#print $webpage "\t\t\t<div class=\"de-element nofencerA\">\n\t\t\t</div>\n";
	   			#print $webpage "\t\t\t<div class=\"de-element nofencerB\">\n\t\t\t</div>\n";
			} else {
				# $bout = undef();
        	}
            
            #end of bout div
            print $webpage "\t\t</div>\n"
		}

		# Need to include the Winner!
		# writeTableauFencer($webpage, $bout, 'Winner', $roundnum, $result);

        # end of col div
        print $webpage "\t</div>\n";
        
        $result = "bout-pending";
        # next round has half as many bouts
        
	my $oldLastN = $lastN;
        $numbouts /= 2;
        $lastN /= 2;
        $preceeding_bout /=2; 

	# Change the where
	$where =~ s/$oldLastN/$lastN/;       
    }
    
    print $webpage "\t\t\t</div>\n\t\t</div>\n\t</div>\n";
    
    print $webpage "</div>\n";
}

##################################################################################
# writeEntryListFencer
##################################################################################
# write a fencer into an entry list.  (key to data, webpage, details of list);
sub writeEntryListFencer {
    my $EGData = $_[0];
    my $webpage = $_[1];
    my $col_details = $_[2];
    my $entry_index = $_[3];

	print "writeEntryListFencer: EGData = " . Dumper (\$EGData);
        	
    print $webpage "\t\t\t<tr id=\"list_row_$entry_index\">\n";
    foreach my $column_def (@{$col_details}) {
		my $col_class = ${$column_def}{'class'};
		my $col_key = ${$column_def}{'key'};
		my $col_val = ${$EGData}{$col_key};
		
		
		print $webpage "\t\t\t\t<td class=\"$col_class\">$col_val</td>\n";
		
    }
    print $webpage "\t\t\t</tr>\n"; 

}

##################################################################################
# writeFencerList
##################################################################################
# Write out the entry list (data, pagehandle,details)
sub writeFencerList 
{
    my $webpage = $_[0];
    local $pagedetails = $_[1];

	# print "writeFencerList: pagedetails = " . Dumper(\$pagedetails);
    
    my $div_id = ${$pagedetails}{'list_div'};
    my $list_title = ${$pagedetails}{'list_title'};
    my $col_details = ${$pagedetails}{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";

    print $webpage "<div class=\"vert_list_container\" id=\"list_cont_id\">\n";
    print $webpage "\t<h2 class=\"list_title\">$list_title</h2>\n";
    print $webpage "\t<div class=\"list_header\" id=\"vert_list_header_id\">\n";
    print $webpage "\t\t<table>\n\t\t\t<tr>\n";
    foreach my $column_def (@{$col_details}) 
	{
		my $col_class = ${$column_def}{'class'};
		my $col_heading = ${$column_def}{'heading'};
		
		print $webpage "\t\t\t\t<td class=\"$col_class\">$col_heading</td>\n";
	}

    print $webpage "\t\t\t\</tr>\n\t\t</table>\n\t</div>\n";
    print $webpage "\t<div class=\"list_body\">\n";
    print $webpage "\t\t<table class=\"list_table\" id=\"$div_id\">\n";
   
	print "writeFencerList: entry_list = " . Dumper(\$entry_list);

	print "ref = $ref\n";

    if (defined ($entry_list))
	{
		if ($ref eq "HASH")
		{
			my $entryindex = 0;
			if ($sort_func)
			{
				foreach my $entrydetail (sort $sort_func keys %$entry_list) 
				{
				   	writeEntryListFencer($entry_list->{$entrydetail}, $webpage, $col_details,$entryindex);
				   	$entryindex += 1;
				}
			}
			else
			{
				foreach my $entrydetail (%$entry_list) 
				{
				   	writeEntryListFencer($entry_list->{$entrydetail}, $webpage, $col_details,$entryindex);
				   	$entryindex += 1;
				}
			}
		}
		else
		{
			foreach my $entry (@$entry_list)
			{
			   writeEntryListFencer($entry, $webpage, $col_details);
			}
		}
    }
    
    print $webpage "\t\t</table>\n\t</div>\n</div>";
}


##################################################################################
# writeMessageList
##################################################################################
# A horizontal list of fencers still to check in.
sub writeMessageList {
    my $webpage = $_[0];
    local $pagedetails = $_[1];
    
    my $div_id = ${$pagedetails}{'list_div'};
    my $list_title = ${$pagedetails}{'list_title'};

    print $webpage "<div class=\"hori_list_container\">\n";
    print $webpage "\t<h2 class=\"list_title\">$list_title</h2>";
    
    print $webpage "\t\t<table class=\"list_table\" id=\"$div_id\">\n\t\t\t<tr>\n";
    
    if (defined(${$pagedetails}{'message_list'})) {
		for (my $i = 0; $i < 5; $i++) {
    		foreach my $message (@{${$pagedetails}{'message_list'}}) {
	    	
				print $webpage "\t\t\t\t<td class=\"message\">$message</td>\n"; 
    		}
    		
			print $webpage "\t\t\t\t<td class=\"messagespace\">&nbsp;</td>\n";
		}
    }
    
    print $webpage "\t\t\t</tr>\n\t\t</table>\n\t</div>\n</div>";

}

##################################################################################
# createPouleDefinitions($comp);
##################################################################################
# create an array of definitions for a set of pages describing a complete round of a tableau
# the first will be visible the later ones not
sub createPouleDefinitions {
    my $competition = shift;
    my $compname = $competition->titre_reduit();

  	my %retval;
    
    my @localswaps;

    my @defs;
    my $defindex = 0;
   	my $where = $competition->whereami;

	my $poule;
	do {
		$poule = undef;
		$poule = $competition->poule(1,$defindex + 1);
		if (defined($poule) && defined($poule->{'mtime'})) {
			print Dumper ($poule) . "\n";

			my %def;
			
			$def{'poule'} = $poule;

			$def{'where'} = $where;

			my $divname = "P1" . "-" . $defindex;
		
			$localswaps[$defindex] = $divname;
		
			$def{'poule_div'} = $divname;

			
			$def{'poule_title'} = $compname . " Poule " . ($defindex + 1);
			

			$def{'poule_num'} = ($defindex + 1);
		
			if ($defindex > 0) {
	    			$def{'poule_class'} = 'tableau hidden';
			}

			# print "createRoundTableaus: defindex = $defindex, defs = " . Dumper(\%def);

			$defs[$defindex] = \%def;
		}

		$defindex++;
   	} while(defined($poule) && defined($poule->{'mtime'}));
	


   	$retval{'definitions'} = \@defs;
   	$retval{'swaps'} = \@localswaps;
   	
   	print "Poules: @localswaps\n";
   	return \%retval;


}

##################################################################################
# createRoundTableaus
##################################################################################
# create an array of definitions for a set of pages describing a complete round of a tableau
# the first will be visible the later ones not
sub createRoundTableaus {
    my $competition = shift;
    my $compname = $competition->titre_reduit();
	# print "Compname: $compname\n";
    
  	my %retval;
	
	my $tab;
	my $roundsize;
  
	# my @tx = $competition->tableaux;

	# print "tx = " . Dumper(\@tx);

   	my $where = $competition->whereami;

	print "where = $where\n";

 	if ($where =~ /tableau/ || $where eq "termine")
	{
		if ($where =~ /tableau/)
		{
			$where =~ s/tableau //;
		}
		else
		{
			my @tableaux = $competition->tableaux();
			$where = $tableaux[$#tableaux];

			print "termine: where = $where\n";
		}

		$tab = $competition->tableau($where,1);

		$roundsize = $tab->taille;

		print "roundsize = [$roundsize]\n";

		$retval{$where} = $tab;

		if ($roundsize == 2)	# assume it's the final
		{
			# do it this way since we can't be certain that the tableau letter is "a" - e.g. A grade formula would be "bf"
			# after the preliminary tableau
			$where =~ s/2/4/;
			my $t4 = $competition->tableau($where,1);

			$retval{$where} = $t4;

			$roundsize = 4;
		}
	}	

    print "Round used: $roundsize\n";
    
    my @localswaps;

    my @defs;
    my $defindex = 0;

    my $preceedingbout = 0;
    while ($preceedingbout < $roundsize / 2) {
		my %def;

		$def{'where'} = $where;

		my $divname = "R".$roundsize . "-" . $defindex;
	
		$localswaps[$defindex] = $divname;
	
		$def{'tableau_div'} = $divname;

		if ($preceedingbout == 0 && $roundsize <= 8) {
	    	$def{'tableau_title'} = $compname . " Finals";
		} else {
	    	$def{'tableau_title'} = $compname . " Last ".$roundsize . " part " . ($defindex + 1);
		}

		$def{'lastN'} = $roundsize;
		$def{'preceeding_bout'} = $preceedingbout;
	
		if ($preceedingbout > 0) {
	    	$def{'tableau_class'} = 'tableau hidden';
		}

		# print "createRoundTableaus: defindex = $defindex, defs = " . Dumper(\%def);

		$defs[$defindex] = \%def;

		$preceedingbout += 4;
		$defindex++;
   	}


   	$retval{'definitions'} = \@defs;
   	$retval{'swaps'} = \@localswaps;
   	
   	print "Tableaus: @localswaps\n";
   	return \%retval;
}

##################################################################################
# readpagedefs
##################################################################################
sub readpagedefs {

	my $pagedeffile = $_[0];

    open (PAGEDEFFILE, $pagedeffile) or die "Couldn't open page definitions file";

    my @pagedefs;
    my $pageindex = 0;
    my %currentpage;
    my $inpage = 0;
    while (<PAGEDEFFILE>) {
		if ($_ =~ /^\[PAGE\]$/) {
			# Beginning of a page so clear everything
			%currentpage = ();
			$inpage = 1;
		}
		if ((my $name, my $value) = ($_ =~ /(\w*)=(.*)/)) {
			if ($inpage) {
				# Got a name value pair
				$currentpage{$name} = $value;
				#print "NV pair: $name => $value\n";
			}
        }
		if ($_ =~ m!^\[/PAGE\]$!) 
		{
			# End of a page so check whether we want this or not
			my $enabled = $currentpage{'enabled'};

			if (defined($enabled) && $enabled eq 'true') 
			{
				# Need to make a local copy so that the correct reference is stored.  Otherwise we overwrite
				my %localpage = %currentpage;
				$pagedefs[@pagedefs] = \%localpage;
				my $pagenum = @pagedefs;
			}

			$inpage = 0;
		}

		$pageindex++;
    }
    close PAGEDEFFILE;
    if (@pagedefs > 0) {
		for (my $iter = 0; $iter < @pagedefs; $iter++) {
			if ($iter < $#pagedefs) {
				${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[$iter + 1]}{'target'};
			} else {
				${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[0]}{'target'};
			}
		}
		$pagedefs[0] 
	}
	#foreach my $thispage (@pagedefs) {
	#	foreach my $key ( keys %{$thispage}) {
	#		my $val = ${$thispage}{$key};
	#		print "Final NV pair: $key => $val\n";
	#	}
	#}
	return \@pagedefs;
}
	
##################################################################################
# createpage
##################################################################################
sub createpage {

	my $pagedef = $_[0];
	
	#Create the competition
	my $compname = 	$pagedef->{'competition'};
	my $comp = Engarde->new($compname);
	 
	# initialise the competition
	$comp->initialise;
	
	$pagedef->{'pagetitle'} = $comp->titre_ligne();
	
	my $layoutcss = "";
	# default refresh time of 30s.  This is changed later to be a minimum of 10 seconds per tableau view or the size of the vertical list.
	my $refreshtime = 30;

	# If there are tableaus then we need to create them
	my $hastableau = $pagedef->{'tableau'};

	my $tabdefs;
	
	if (defined($hastableau) && $hastableau eq 'true') 
	{ 
		$tabdefs = createRoundTableaus($comp);
		# PRS: At this point, tabdefs contains all the data we need to print a tableau
		# print "createpage: tabdefs = " . Dumper(\$tabdefs);

		my $swaps = [ $tabdefs->{'swaps'}];
		$pagedef->{'swaps'} = $swaps;
		
		# Add the tableau to the css file we need for layout
		$layoutcss .= "tableau";
		
		my $mindisplaytime = @{$tabdefs->{'swaps'}} * 10;
		if ($mindisplaytime > $refreshtime) 
		{
			print "Changing refresh time from $refreshtime to $mindisplaytime due to tableaus\n";
			$refreshtime = $mindisplaytime;
		}
	}
	# If there are poules then we need to create them
	my $haspoules = $pagedef->{'poules'};
	my $pouledefs;
	
	if (defined($haspoules) && $haspoules eq 'true') 
	{ 
		# Just check that we don't have both poules and tableau

		if (defined($hastableau) && $hastableau eq 'true') 
		{ 
			die "Can't have both tableau and poules";
		}


		$pouledefs = createPouleDefinitions($comp);
		# We now have the information to create the poule divs, now set the pages up so it swaps correctly

		if (defined ($pagedef->{'swaps'})) {
			my $swaps = [ $pagedef->{'swaps'}, $pouledefs->{'swaps'}];
			$pagedef->{'swaps'} = $swaps;
		} else {
			my $swaps = [ $pouledefs->{'swaps'}];
			$pagedef->{'swaps'} = $swaps;
		}
		
		# Add the tableau to the css file we need for layout, note that we are using Tableau as the layout
		# for the poules as well as it is just a box with screens that replace.
		$layoutcss .= "tableau";
		
		my $mindisplaytime = @{$pouledefs->{'swaps'}} * 10;
		if ($mindisplaytime > $refreshtime) 
		{
			print "Changing refresh time from $refreshtime to $mindisplaytime due to tableaus\n";
			$refreshtime = $mindisplaytime;
		}
	}

	my $messagelistdef = undef();
	# Now check for urgent messages, actually never do this.
    if (open (EXTRAMESSAGES, "messages.txt")) 
	{
    
		my @messages;
		while (<EXTRAMESSAGES>) 
		{
			$messages[@messages] = $_;
		}
    
		$messagelistdef = {'list_div' => 'message_list_id',	'list_title' => 'Urgent Messages', 'message_list' => \@messages};
		
		# Add the scrolling list
		my $horis = ['message_list_id'];
		$pagedef->{'hori_scrolling_div'} = $horis;
		close EXTRAMESSAGES;
		
		# Add the horizontal list to the css file we need for layout
		$layoutcss .= "hlist";
    }
    
    # Now sort out the vertical list
	my $vertlist = $pagedef->{'list'};
	my $listdef = undef();
	my $fencers;
	
	if (defined($vertlist) && $vertlist ne 'none') 
	{
		if ($vertlist eq 'entry') 
		{
			#######################################################
			# Fencers, Pools, Pistes
			#######################################################

			print "Calling fpp...\n";

			$fencers = $comp->fpp();

			# print Dumper (\$fencers);

			my $listdataref = $fencers;

			my $entrylistdef = [ {'class' => 'fencer_name', 'heading' => 'Fencer', key=> 'nom'},
						{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'},
						# {'class' => 'init_rank', 'heading' => 'Ranking', key => 'fencer_rank'},
						{'class' => 'poule_num', 'heading' => 'Poule', key=> 'poule'},
						{'class' => 'piste_num', 'heading' => 'Piste', key=> 'piste_no'}];						
   
   
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&namesort,
						'list_title' => $comp->titre_reduit() .': Fencers - Pools - Pistes', 
						'entry_list' => $listdataref, 'column_defs' => $entrylistdef };

		} 
		elsif ($vertlist eq 'seeding') 
		{
		
			#######################################################
			# Ranking after the pools
			#######################################################

			$fencers = $comp->ranking("p");
	
			# print Dumper(\$fencers);	
			
			print "Number of seeding results: " . keys (%{$fencers}) . "\n";
		
			my $entrylistdef = [ 
				{'class' => 'seed', 'heading' => 'Seed', key => 'seed'},
				{'class' => 'fencer_name', 'heading' => 'Fencer', key=> 'nom'},
				{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'},
				# might need to spilit this (v/m) into 3 cols now...
				{'class' => 'v-over-m', 'heading' => 'V/M', key => 'v-over-m'},
				{'class' => 'ind', 'heading' => 'HS-HR', key=> 'ind'},
				{'class' => 'hs', 'heading' => 'HS', key=> 'hs'} ];						
    
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&ranksort,
				'list_title' => $comp->titre_reduit() .': Ranking after the pools', 
				'entry_list' => $fencers, 'column_defs' => $entrylistdef};
	
		} 
		elsif ($vertlist eq 'result') 
		{ 
		 		
			#######################################################
			# Final Ranking
			#######################################################
			
			$fencers = $comp->ranking();
			
			# print Dumper(\$fencers);

			print "Number of final results: " . keys (%{$fencers}) . "\n";
			
			my $entrylistdef = [ 
							{'class' => 'position', 'heading' => ' ', key => 'seed'},
							{'class' => 'fencer_name', 'heading' => 'Fencer', key=> 'nom'},
							{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'}];		
    
    
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&ranksort,
						'list_title' => $comp->titre_reduit() .': Final Ranking', 
						'entry_list' => $fencers, 'column_defs' => $entrylistdef};
		}
		
		#######################################################
		# Set refresh time
		#######################################################

		if ( keys %$fencers > $refreshtime) 
		{
			print "Changing refresh time due to list.  From $refreshtime to listsize\n";
			$refreshtime = scalar keys %$fencers;
		}
		# Add the scrolling list
		my $verts = ['vert_list_id'];
		$pagedef->{'vert_scrolling_div'} = $verts;
		# Add the vertical list to the css file we need for layout
		$layoutcss .= "vlist";
	}
	
	$pagedef->{'refresh_time'} = $refreshtime;
	$pagedef->{'layout'} = $layoutcss;

	my $pagename = $pagedef->{'targetlocation'} . $pagedef->{'target'};
	open(my $page,"> $pagename") || die("can't open $pagename: $!");

	writeBlurb($page, $pagedef);
	
		
	# Write the tableaus if appropriate
	if (defined($hastableau) && $hastableau eq 'true') 
	{ 
		# print "createpage: writing tableau. definitions = " . Dumper($tabdefs->{'definitions'});

		foreach my $tabdef (@{$tabdefs->{'definitions'}}) 
		{
			print "createpage: calling writeTableau\n";
			# print "createpage: tabdef = " . Dumper(\$tabdef);
			# PRS: Need to pass tabdefs->{level} here as well or change the way writeTableau is called
			writeTableau($tabdefs, $page, $tabdef);
		}
	}
	# Write the poules if appropriate
	if (defined($haspoules) && $haspoules eq 'true') 
	{ 
		# print "createpage: writing poules. definitions = " . Dumper($tabdefs->{'definitions'});

		foreach my $pouledef (@{$pouledefs->{'definitions'}}) 
		{
			print "createpage: calling writePoule\n";
			# print "createpage: pouledef = " . Dumper(\$tabdef);
			# PRS: Need to pass tabdefs->{level} here as well or change the way writeTableau is called
			writePoule($pouledefs, $page, $pouledef);
		}
	}
	# If we have the horizontal scrolling then add that
	if (defined($messagelistdef)) 
	{
		writeMessageList($page, $messagelistdef);
	}
	# If we have a vertical list definition defined then add that
	if (defined($listdef)) 
	{
		writeFencerList($page, $listdef)
	}

	print $page "</body>\n";

}	# end sub

##################################################################################
# sorting subs for use by list output
##################################################################################
sub namesort
{
	$pagedetails->{'entry_list'}->{$a}->{nom} cmp $pagedetails->{'entry_list'}->{$b}->{nom};
}

sub ranksort
{
	$pagedetails->{'entry_list'}->{$a}->{seed} <=> $pagedetails->{'entry_list'}->{$b}->{seed};
}

##################################################################################
# Main starts here (I think)
##################################################################################
my $pagedeffile = shift || "pagedefinitions.ini";

# read the page definitions
my $pages = readpagedefs ($pagedeffile);
my $numpages = @{$pages};
print "number of pages: $numpages\n"; 
foreach my $pagedef (@{$pages}) {
	print "calling createpage for: " . Dumper(\$pagedef);

	createpage ($pagedef);
}
			
