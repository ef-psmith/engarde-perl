# (c) Copyright Oliver Smith & Peter Smith 2007-2008 
# oliver_rps@yahoo.co.uk

# modified to reduce the amount of info needed in the config file by
# having a standard layout for each stage of the competition based on the "whereami" output
# as follows
#
#
#	poules not drawn	-	check-in list
#	poules drawn		-	fencers, poules, pistes
#	poules in progress	-	poules + fpp
#	poules finished		-	poules + ranking 
#	tableau drawn		-	tableau + final ranking

# for dev purposes only
use lib "../";

use strict;
use Engarde;
use Data::Dumper;
use IO::Handle;

use vars qw($pagedetails);

##################################################################################
# writeTableauMatch
##################################################################################
sub writeTableauMatch 
{
    my $bout = shift;
	my $roundnumber = shift;

	# print "writeTableauMatch: bout = " . Dumper(\$bout);

	foreach my $key (qw/A B/)
	{
		my $fencer = $bout->{'fencer' . $key};
		my $seed = $bout->{'seed' . $key};

		if ($roundnumber == 1 && defined($seed)) 
		{
			print WEBPAGE "\t\t\t<div class=\"seed$key\">$seed</div>\n";
		}

		if (defined($fencer)) 
		{
			my $result = "";
	
			if (defined($bout->{'winner'})) 
			{
				if ($bout->{'winner'} eq $fencer) 
				{
					$result = "winner";
				} 
				else 
				{
					$result = "loser";
				}
			}

			print WEBPAGE "\t\t\t<div class=\"de-element fencer$key $result\">\n";

			if ($roundnumber == 1) 
			{
				print WEBPAGE "\t\t\t\t<div class=\"fencer\">$fencer</div>\n";
	
				my $country = $bout->{'nation' . $key};

				if (defined($country)) 
				{
					print WEBPAGE "\t\t\t\t<div class=\"country\">$country</div>\n";
				}
			} 
			else 
			{
				print WEBPAGE "\t\t\t\t<div class=\"fenceronly\">$fencer</div>\n";
			}
	
			print WEBPAGE "\t\t\t</div>\n";
	
		} 
		else 
		{
			print WEBPAGE "\t\t\t<div class=\"de-element nofencer$key\">\n";
			print WEBPAGE "\t\t\t</div>\n";
		}
	}
}

##################################################################################
# writeBlurb
##################################################################################
# Write the blurb at the top of the file
sub writeBlurb 
{
	# print "writeBlurb: starting\n";

    my $page = shift;

	# print "writeBlurb: page = " . Dumper(\$page);
   
    my $nextpage = $page->{'nextpage'};
    my $pagetitle = $page->{'pagetitle'};
    my $refresh = $page->{'refresh_time'};
    my $layout = $page->{'layout'};
    my $bkcolour = ${$page}{'background'};
    my $csspath = ${$page}{'csspath'};

    print WEBPAGE "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n";
    print WEBPAGE "\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
	print WEBPAGE "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n";
    
    print WEBPAGE "<head>\n";
    
    print WEBPAGE "<title>$pagetitle</title>\n";

    print WEBPAGE "\t<style type=\"text/css\">\n/*<![CDATA[*/\n\t\tbody {background-color: $bkcolour}\n/*]]>*/\t</style>\n";

    print WEBPAGE "<link href=\"".$csspath."tableau_style.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";
    print WEBPAGE "<link href=\"".$csspath."poule_style.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";
    print WEBPAGE "<link href=\"$csspath$layout.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";
    print WEBPAGE "<link href=\"".$csspath."fencer_list.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";
    
    print WEBPAGE "<script type=\"text/javascript\">\n//<![CDATA[\n\tonerror=handleErr\n";
    print WEBPAGE "\tfunction handleErr(msg,url,l) {\n\t\talert(msg);\n\t\t//Handle the error here\n";
    print WEBPAGE "\t\treturn true;\n\t}\n\n";
    
    my $pagefinishedcondition = "true";
    
    # Start function to kick off the scrolling and swapping
    print WEBPAGE "\tfunction onPageLoaded() {\n";

    # If there are any scrolling lists then we need to call onPauseTimer
    if (defined($page->{'vert_scrolling_div'}) or defined($page->{'hori_scrolling_div'})) 
	{
       	# Set the body onload
       	print WEBPAGE "\t\tvar listElement = document.getElementById(\"vert_list_id\");\n";

		print WEBPAGE "\t\tif (listElement == null) {\n";
		print WEBPAGE "\t\t\twindow.location.replace(\"$nextpage\");\n";
		print WEBPAGE  "\t\t}\n";

        print WEBPAGE "\t\tlistheight = listElement.offsetHeight;\n";
        print WEBPAGE "\t\tvar listContainerElement = document.getElementById(\"list_cont_id\");\n";
        print WEBPAGE "\t\tvar contheight = listContainerElement.offsetHeight;\n";
        print WEBPAGE "\t\tvar listElementElement = document.getElementById(\"list_row_0\");\n";
        print WEBPAGE "\t\tvar elemheight;\n\t\tif (listElementElement==null) {\n";
	   	print WEBPAGE "\t\t\telemheight = 0;\n\t\t} else {\n";
	   	print WEBPAGE "\t\t\telemheight = listElementElement.offsetHeight;\n\t\t}\n";
        print WEBPAGE "\t\tvar listHeaderElement = document.getElementById(\"vert_list_header_id\");\n";
        print WEBPAGE "\t\tvar headerheight = listHeaderElement.offsetHeight;\n";
        print WEBPAGE "\t\tvar titleheight = listHeaderElement.offsetTop;\n";
                 
        print WEBPAGE "\t\tscrollLimit = contheight - elemheight - headerheight - titleheight;\n";

		# similarly, don't bother calculating this - fix at 15s per page.
		# print WEBPAGE "\t\tpauseTime = Math.floor($refresh * 1000 / (Math.floor(listheight/scrollLimit) + 2));\n";
        print WEBPAGE "\t\tpauseTime = 15000;\n";

		# print WEBPAGE "\t\talert(pauseTime);\n";
               
       	print WEBPAGE "\t\tonPauseTimer();\n";
    }

    # If there are any swaps then we need to start them off.
    if (defined($page->{'swaps'})) 
	{
    	print WEBPAGE "\t\tstartSwapTimers();\n";
    }

    print WEBPAGE "\t}\n";
    
    # pause function to stop lists scrolling too soon.
	print WEBPAGE "\tvar top = 0;\n\tvar left=0;\n\tvar pageStartTop=0;\n\n";
    print WEBPAGE "\tfunction onPauseTimer() {\n";
    print WEBPAGE "\t\tpageStartTop = top;\n";
    print WEBPAGE "\t\tt1=setTimeout(\"onScrollTimer()\",pauseTime);\n\t}\n";
    
    
    if (defined($page->{'vert_scrolling_div'})) 
    {
		# Update the page finished
		$pagefinishedcondition .= " && list_finished";
		
		# scroll stuff.  All scroll together.
		print WEBPAGE "\tvar list_finished = false;\n\tfunction onScrollTimer() {\n";
		print WEBPAGE "\t\tif (listheight < scrollLimit) {\n\t\t\tlist_finished = true;\n\t\t\treturn;\n\t\t}\n";
		print WEBPAGE "\t\tvar topVal = top + 'px';\n";
	    
		print WEBPAGE "\t\tvar listId = document.getElementById(\"$page->{'vert_scrolling_div'}\");\n";
		print WEBPAGE "\t\tlistId.style.top = topVal;\n";
	   
		print WEBPAGE "\t\ttop -= 5;\n";
		print WEBPAGE "\t\tif (top <= pageStartTop - scrollLimit || top + listheight < 0) {\n";             
		print WEBPAGE "\t\t\tif (top + listheight < 0) {\n";
		print WEBPAGE "\t\t\t\tlistId.style.top = 0;\n";
		print WEBPAGE "\t\t\t\ttop = 0;\n";
		print WEBPAGE "\t\t\t\tlist_finished = true;\n";
		print WEBPAGE "\t\t\t\tcheckFinished();\n";
		print WEBPAGE "\t\t\t\tonPauseTimer();\n";
		print WEBPAGE "\t\t\t} else {\n";
		print WEBPAGE "\t\t\t\tcheckFinished();\n";
		print WEBPAGE "\t\t\t\tonPauseTimer();\n";
		print WEBPAGE "\t\t\t}\n";
		print WEBPAGE "\t\t} else {\n";
		print WEBPAGE "\t\t\tt2=setTimeout(\"onScrollTimer()\",50);\n";
		print WEBPAGE "\t\t}\n\t}\n\n";
	}
    
    
    # swapping function
    # first work out the refresh times
	# my @swaptimers;
	my $swaptimers;
    if (defined($page->{'swaps'})) 
	{
		# print "writeBlurb: page = " . Dumper(\$page);

		# Update the page finished
		$pagefinishedcondition .= " && tableau_finished";

		# my $seriesnum = 0;
		# foreach my $s (@swaps) 
		# {
		# print WEBPAGE "\tvar tableau_finished = false;\n\tvar swaps$seriesnum = new Array();\n";
    	    print WEBPAGE "\tvar tableau_finished = false;\n\tvar swaps = new Array();\n";
    	    
    	    my $index = 0;
    	    foreach my $s (@{$page->{swaps}}) 
			{
				# print "writeBlurb: s = " . Dumper(\$s);

    	    	print WEBPAGE "\tswaps\[$index] = \"$s\";\n";
    	    	$index++;
    	    }

    	    print WEBPAGE "\tvar swapindex = 0;\n";
    	    
    	    print WEBPAGE "\tfunction onSwapTimer() {\n";
    	    print WEBPAGE "\t\tif (swapindex == swaps.length - 1) {\n";
    	    print WEBPAGE "\t\t\ttableau_finished = true;\n";
			print WEBPAGE "\t\t\tcheckFinished();\n";

		   	print WEBPAGE "\t\t\tdocument.getElementById(swaps\[swaps.length -1]).style.visibility = \"hidden\";\n";
		   	print WEBPAGE "\t\t\tdocument.getElementById(swaps\[0]).style.visibility = \"visible\";\n";
    	    print WEBPAGE "\t\t\tswapindex= 0;\n";
		   	print WEBPAGE "\t\t\tsetTimeout(\"onSwapTimer()\",15000);\n";

			print WEBPAGE "\t\t\treturn;\n";
    	    print WEBPAGE "\t\t}\n";
    	    
	    	# Refresh time is in seconds, swaptimer in milliseconds (and yes I know int() shouldn't be used to round but I don't care)
			# PRS: page refresh is total time / no of pages.  Not sure this calc is needed - just fix the refresh at 15s surely?
			# $swaptimers[$seriesnum] = int($refresh / @{$s} * 1000);

	    	$swaptimers = 15000;

    	    if (@{$page->{swaps}} > 1) 
			{ 
		    	print WEBPAGE "\t\tvar oldDiv = swaps\[swapindex];\n";
		    	print WEBPAGE "\t\tdocument.getElementById(oldDiv).style.visibility = \"hidden\";\n";
		    	print WEBPAGE "\t\tswapindex += 1;\n";
		    	print WEBPAGE "\t\tdocument.getElementById(swaps\[swapindex]).style.visibility = \"visible\";\n";
		    	print WEBPAGE "\t\tif (swapindex< swaps.length) {\n";
		    	print WEBPAGE "\t\t\tvar t = setTimeout(\"onSwapTimer()\",$swaptimers);\n";
		    	print WEBPAGE "\t\t}\n";
	    	}
	    	print WEBPAGE "\t}\n";
    	    
			# $seriesnum++;
			# }
    }
    
    
    print WEBPAGE "\tfunction startSwapTimers() {\n";
    if (defined($page->{swaps})) 
    {
		print WEBPAGE "\t\tvar t = setTimeout(\"onSwapTimer()\",$swaptimers);\n";
    }
    print WEBPAGE "\t}\n";
    print WEBPAGE "\tfunction checkFinished() { \n";
    print WEBPAGE "\t\tif ($pagefinishedcondition) {\n";
	print WEBPAGE "\t\t\twindow.location.replace(\"$nextpage\");\n";
    print WEBPAGE "\t\t}\n\t}\n\n";
    
    print WEBPAGE "\n//]]>\n</script>\n\n</head>\n<body onload=\"onPageLoaded()\">\n";


}

##################################################################################
# writePoule
##################################################################################
# Write out a poule, writePoule(comp, page)
sub writePoule 
{
    my $comp = shift;
    my $page = shift;

	my $round = $page->{'poules'}[0]->{'round'};
	my $compname = $comp->titre_ligne;

    my $div_id = $page->{'poule_div'};

    # Note that we are going to use tableau as the generic container for poules as well.
    my $poule_class = 'tableau';

    if (defined($page->{'poule_class'})) 
	{
        $poule_class = $page->{'poule_class'};
    }

	print WEBPAGE "<div class=\"$poule_class\" id=\"$div_id\">\n";
    
	print WEBPAGE "\t<h2>$compname Round $round</h2>\n";
    my @poules = @{$page->{'poules'}};
    
    foreach my $pouledef (@poules) 
	{
		my @g = $pouledef->{'poule'}->grid;

		print WEBPAGE "\t<h3>" . $pouledef->{'poule_title'} . "</h3>\n";
		print WEBPAGE "\t<table class=\"poule\">\n";
		
		my $lineNum = 0;
		my $titles = $g[0];
		
		print WEBPAGE "\t\t<tr>\n";

		my $cellNum;
		my $resultNum = 1;

		for ($cellNum = 1; $cellNum < scalar @$titles; $cellNum++)
		{
			my $text = $$titles[$cellNum];
			my $class = $$titles[$cellNum] || "blank";

			if ($$titles[$cellNum] eq "result")
			{	
				$text = $resultNum;
				$resultNum++;
			}

			print WEBPAGE "\t\t\t<th class=\"poule-title-$class\">$text</th>\n";
		}

		print WEBPAGE "\t\t</tr>\n";
		my $lineNum = 1;

		foreach my $line (@g)
		{
			$resultNum = 1;
			# skip titles
			next if $$line[0] eq "id";

			print WEBPAGE "\t\t<tr>\n";

			for ($cellNum = 1; $cellNum < scalar @$line; $cellNum++)
			{
				my $text = $$line[$cellNum];
				$text = "" if $text eq "()";

				my $class = $$titles[$cellNum] || "emptycol";

				if ($class eq "result")
				{
					$class = "blank" if $resultNum eq $lineNum;
					$resultNum++;
				}
	
				print WEBPAGE "\t\t\t<td class=\"poule-grid-$class\">$text</td>\n";
			}

			print WEBPAGE "\t\t</tr>\n";
			$lineNum++;
		}

		print WEBPAGE "\t</table>\n";
		print WEBPAGE "\t<p>&nbsp;</p>\n";
	}

	print WEBPAGE "</div>\n";

}

##################################################################################
# writeTableau
##################################################################################
# Write out a tableau, writeTableau(data, pagehandle, pagedetails)
sub writeTableau 
{
    my $comp = shift;
    my $page = shift;

    my $div_id = $page->{'tableau_div'};
    my $tableau_title = $page->{'tableau_title'};
	my $where = $page->{'where'};
	
	print "Where: $where \n";

    # this is the bout before this tableau.  Should be divisible by 2.
    my $preceeding_bout = $page->{'preceeding_bout'};
    
    print WEBPAGE "<div class=\"$page->{tableau_class}\" id=\"$div_id\">\n";  # 1st DIV		"tableau"
    print WEBPAGE "\t<h2 class=\"tableau_title\">$tableau_title</h2>\n";

    # Work out how many bouts there are.  Note that we never display the winner in the tableau, merely the final
    my $numbouts = 4;
	$numbouts = 2 if $page->{'lastN'} <= 4;

	my $minbout = $preceeding_bout + 1;
	my $maxbout = $minbout + $numbouts;


	my $result = "bout-started";

    for (my $roundnum = 1; $roundnum <= 2; $roundnum++) 
	{
        my $colname = "r" . $roundnum . "col";
        print WEBPAGE "\t<div class=\"$colname\">\n";		# 2nd DIV  "r1col"

        for (my $boutnum = $minbout; $boutnum < $maxbout; $boutnum++) 
		{
            my $boutname = "r" . $roundnum . "bout-" . ($boutnum - $preceeding_bout);
            print WEBPAGE "\t\t<div class=\"$boutname bout\">\n";		# 3rd DIV			"r1bout-1 bout" etc
            
			my $bout = $comp->match($where, $boutnum);

			print WEBPAGE "\t\t\t<div class=\"pistecontainer\">";		# 4th DIV

			my $title = "";

			if ($bout->{'winner'})
			{
				if ($bout->{'fencerA'} && $bout->{'fencerB'})
				{
					$title = "$bout->{'scoreA'} / $bout->{'scoreB'}";
				}
			}
			else
			{
				$title = "Piste: $bout->{'piste'}" if $bout->{'piste'};
				$title .= " Time: $bout->{'time'}" if $bout->{'time'} && $bout->{'time'} ne "0:00";
			}
			
			print WEBPAGE "$title</div>\n";	# close 4th DIV
	
			writeTableauMatch($bout, $roundnum);
	
            #end of bout div
            print WEBPAGE "\t\t</div>\n"		# close 3rd DIV
		}

        # end of col div
        print WEBPAGE "\t</div>\n";				# close 2nd DIV
        
        $result = "bout-pending";
        # next round has half as many bouts
        
		my $newlastN = $page->{'lastN'};
        $numbouts /= 2;
        $newlastN /= 2;
        $preceeding_bout /=2; 
		$minbout = $preceeding_bout + 1;
		$maxbout = $minbout + $numbouts;

		# Change the where
		$where =~ s/$page->{'lastN'}/$newlastN/;       
    }
    
    print WEBPAGE "</div>\n";					# close 1st DIV
}

##################################################################################
# writeEntryListFencer
##################################################################################
# write a fencer into an entry list.  (key to data, webpage, details of list);
sub writeEntryListFencer {
    my $EGData = shift;
    my $col_details = shift;
    my $entry_index = shift;

	# flag to indicate if the style should be amended based on the "group" value
	my $adjust_style = shift || 0;

	my $row_class = "";

	if ($adjust_style)
	{
		my $group = ${$EGData}{group};
		$row_class = "class=\"$group\"";
	}
		
    print WEBPAGE "\t\t\t<tr id=\"list_row_$entry_index\" $row_class>\n";

    foreach my $column_def (@{$col_details}) 
	{
		my $col_class = ${$column_def}{'class'};
		my $col_key = ${$column_def}{'key'};
		my $col_val = defined ${$EGData}{$col_key} ? ${$EGData}{$col_key} : "&nbsp;";

		print WEBPAGE "\t\t\t\t<td class=\"$col_class\">$col_val</td>\n";
    }

    print WEBPAGE "\t\t\t</tr>\n"; 

}

##################################################################################
# writeFencerList
##################################################################################
# Write out the entry list (data, pagehandle,details)
sub writeFencerList 
{
    local $pagedetails = shift;

    my $div_id = ${$pagedetails}{'list_div'};
    my $list_title = ${$pagedetails}{'list_title'};
    my $col_details = ${$pagedetails}{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";

    print WEBPAGE "<div class=\"vert_list_container\" id=\"list_cont_id\">\n";
    print WEBPAGE "\t<h2 class=\"list_title\">$list_title</h2>\n";
    print WEBPAGE "\t<div class=\"list_header\" id=\"vert_list_header_id\">\n";
    print WEBPAGE "\t\t<table>\n\t\t\t<tr>\n";
    foreach my $column_def (@{$col_details}) 
	{
		my $col_class = ${$column_def}{'class'};
		my $col_heading = ${$column_def}{'heading'};
		
		print WEBPAGE "\t\t\t\t<td class=\"$col_class\">$col_heading</td>\n";
	}

    print WEBPAGE "\t\t\t\</tr>\n\t\t</table>\n\t</div>\n";
    print WEBPAGE "\t<div class=\"list_body\">\n";
    print WEBPAGE "\t\t<table class=\"list_table\" id=\"$div_id\">\n";
   
    if (defined ($entry_list))
	{
		my $entryindex = 0;
		if ($ref)
		{
			if ($sort_func)
			{
				foreach my $entrydetail (sort $sort_func keys %$entry_list) 
				{
					# print "entry = " . Dumper($entry_list->{$entrydetail});

				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details,$entryindex, 1);
				   	$entryindex += 1;
				}
			}
			else
			{
				foreach my $entrydetail (%$entry_list) 
				{
				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details,$entryindex);
				   	$entryindex += 1;
				}
			}
		}
		else
		{
			foreach my $entry (@$entry_list)
			{
				writeEntryListFencer($entry, $col_details, $entryindex);
				$entryindex += 1;
			}
		}
    }
    
    print WEBPAGE "\t\t</table>\n\t</div>\n</div>";
}


##################################################################################
# createPouleDefinitions($comp);
##################################################################################
# create an array of definitions for a set of pages describing a complete round of poules
# the first will be visible the later ones not
sub createPouleDefinitions 
{
    my $competition = shift;
	my $round = shift;

	# print "createPouleDefinitions: round = $round\n";

  	my %retval;
    
    my @localswaps;

    my @defs;
    my $defindex = 0;
   	
   	my $numPoulesPerPage = 2;

	my $poule;

	do {
		$poule = $competition->poule($round,$defindex + 1);

		if (defined($poule)) 
		{
			if (0 == $defindex % $numPoulesPerPage) 
			{
				my %def;

				my $divname = "P1" . "-" . $defindex;

				$localswaps[int($defindex / $numPoulesPerPage)] = $divname;

				$def{'poule_div'} = $divname;
			
	    		$def{'poule_class'} = 'tableau hidden' if ($defindex / $numPoulesPerPage > 0); 

				$defs[$defindex / $numPoulesPerPage] = \%def;
				
				# my @pouledefs;
				# $def{'poules'} = \@pouledefs;	
			}

			my %pouledef;

			$pouledef{'poule'} = $poule;	
			$pouledef{'round'} = $round;

			my $piste = $poule->piste_no;
			my $time = $poule->time();

			my $title = "Poule " . ($defindex + 1);

			$title .= ", Piste: $piste" if $piste;
			$title .= ", Time: $time" if $time;

			$pouledef{'poule_title'} = $title;

			${${$defs[$defindex / $numPoulesPerPage]}{'poules'}}[$defindex % $numPoulesPerPage] = \%pouledef;
		}
		$defindex++;
   	} 
	while(defined($poule) && defined($poule->{'mtime'}));
	


   	$retval{'definitions'} = \@defs;
   	$retval{'swaps'} = \@localswaps;
   
   	return %retval;
}

##################################################################################
# createRoundTableaus
##################################################################################
# create an array of definitions for a set of pages describing a complete round of a tableau
# the first will be visible the later ones not
sub createRoundTableaus 
{
    my $competition = shift;
    my $tableaupart = shift;
    my $chosenpart = 0;
    my $numparts = 0;

    if ($tableaupart =~ m%(\d)/(\d)%) {
		$chosenpart = $1;
		$numparts = $2;
    }
    print "Tableau Part: $tableaupart or $chosenpart / $numparts \n";
        
    my $compname = $competition->titre_reduit();
    
  	my $retval = {};
	
	my $tab;
	my $roundsize;
  
   	my $where = $competition->whereami;

 	if ($where =~ /tableau/ || $where eq "termine")
	{
		if ($where =~ /tableau/)
		{
			$where =~ s/tableau //;
		}
		elsif ($where eq "termine")
		{
			my @tableaux = $competition->tableaux();
			$where = $tableaux[-1];
		}
		else
		{
			my @tableaux = $competition->tableaux(1);
			$where = $tableaux[0];
		}

		# Move to the specified place in the tableau
		if (0 != $numparts) {
			$roundsize = $numparts * 8;
			
			print "where = $where\n";
			$where =~ s/\d+/$roundsize/;
			print "Now where is (after round definition)  $where\n";
			
		}	

		# print "where = $where\n";
		$tab = $competition->tableau($where);

		$roundsize = $tab->taille if ref $tab;

		if ($roundsize == 2)	# assume it's the final - wouldn't be true if all the DE places were fought
		{
			# do it this way since we can't be certain that the tableau letter is "a" - e.g. A grade formula would be "bf"
			# after the preliminary tableau
			$where =~ s/2/4/;
			$roundsize = 4;
		}
	}
	else
	{
		# Nothing to display
		return $retval;
	}

    my @localswaps;

    my @defs;
    my $defindex = 0;

    my $preceedingbout = 0;
    while ($preceedingbout < $roundsize / 2) {
    
		print "Preceeding Bout: $preceedingbout Chosen part: $chosenpart \n";
    
		if (0 == $chosenpart || $preceedingbout == 4 * $chosenpart) 
		{
			my %def;

			$def{'where'} = $where;

			my $divname = "R".$roundsize . "-" . $defindex;
		
			$localswaps[$defindex] = $divname;
		
			$def{'tableau_div'} = $divname;

			if ($preceedingbout == 0 && $roundsize <= 4) 
			{
	    		$def{'tableau_title'} = $compname . " Finals";
			} 
			elsif ($preceedingbout == 0 && $roundsize == 8)
			{
	    		$def{'tableau_title'} = $compname . " Last 8";
			}
			else 
			{
				my $part = ($defindex + 1);
				if (0 != $chosenpart) {
					$part = $chosenpart;
				}
	    		$def{'tableau_title'} = $compname . " Last ". $roundsize . " part " . $part;
			}

			$def{'lastN'} = $roundsize;
			$def{'preceeding_bout'} = $preceedingbout;
		
			if ($preceedingbout != 0 && 0 == $chosenpart) 
			{
	    		$def{'tableau_class'} = 'tableau hidden';
			}
			else
			{
	    		$def{'tableau_class'} = 'tableau';
			}

			$defs[$defindex] = \%def;
			$defindex++;
		}

		$preceedingbout += 4;
   	}

   	$retval->{'definitions'} = \@defs;
   	$retval->{'swaps'} = \@localswaps;
   	
   	return $retval;
}

##################################################################################
# readpagedefs
##################################################################################
sub readpagedefs 
{

	my $pagedeffile = shift;

    open PAGEDEFFILE, $pagedeffile or die "Couldn't open page definitions file";

    my @pagedefs;
    my $pageindex = 0;
    my %currentpage;
    my $inpage = 0;
    while (<PAGEDEFFILE>) 
	{
		if (/^\[PAGE\]$/) 
		{
			# Beginning of a page so clear everything
			undef %currentpage;
			$inpage = 1;
		}

		if ((my $name, my $value) = ($_ =~ /(\w*)=(.*)/)) 
		{
			if ($inpage) 
			{
				# Got a name value pair
				$currentpage{$name} = $value;
			}
        }

		if (/^\[\/PAGE\]$/) 
		{
			# End of a page so check whether we want this or not
			my $enabled = $currentpage{'enabled'};

			if (defined($enabled) && $enabled eq 'true') 
			{
				# PRS - Not sure this is needed...
				# Need to make a local copy so that the correct reference is stored.  Otherwise we overwrite
				my %localpage = %currentpage;
				push @pagedefs, \%localpage;
			}

			$inpage = 0;
		}

		$pageindex++;
    }
    close PAGEDEFFILE;

    if (@pagedefs > 0) 
	{
		for (my $iter = 0; $iter < @pagedefs; $iter++) 
		{
			if ($iter < $#pagedefs) 
			{
				${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[$iter + 1]}{'target'};
			} 
			else 
			{
				${$pagedefs[$iter]}{'nextpage'} = ${$pagedefs[0]}{'target'};
			}
		}
	}

	# print "pagedefs = " . Dumper(\@pagedefs);

	return @pagedefs;
}
	


##################################################################################
# createpage
##################################################################################
sub createpage 
{
	my $pagedef = shift;
	
	#Create the competition
	my $compname = 	$pagedef->{'competition'};
	my $comp = Engarde->new($compname);
	 
	# initialise the competition
	$comp->initialise;
	
	# $pagedef->{'comp'} = $comp;

	$pagedef->{'pagetitle'} = $comp->titre_ligne();
	
	my $layoutcss = "";
	# default refresh time of 30s.  This is changed later to be a minimum of 10 seconds per tableau view or the size of the vertical list.
	my $refreshtime = 30;

	# If there are tableaus then we need to create them
	my $hastableau = want($comp, "tableau");

	# print "createpage: hastableau = $hastableau\n";

	my $tabdefs;
	
	if ($hastableau) 
	{ 
		$tabdefs = createRoundTableaus($comp, $pagedef->{'tableau'});

		$pagedef->{'swaps'} = $tabdefs->{'swaps'};
		
		# Add the tableau to the css file we need for layout
		$layoutcss .= "tableau";
	}
	# If there are poules then we need to create them

	my @hp = want($comp, "poules");

	# print "createpage: hp = @hp\n";

	my $haspoules = $hp[1];

	my %pouledefs;
	
	if ($haspoules) 
	{ 
		if ($hp[2] eq "constitution")
		{
			%pouledefs = createPouleDefinitions($comp, $haspoules-1);
		}
		else
		{
			%pouledefs = createPouleDefinitions($comp, $haspoules);
		}

		# We now have the information to create the poule divs, now set the pages up so it swaps correctly

		$pouledefs{'round'} = $haspoules;

		$pagedef->{'swaps'} = $pouledefs{'swaps'};
		
		# Add the tableau to the css file we need for layout, note that we are using Tableau as the layout
		# for the poules as well as it is just a box with screens that replace.
		$layoutcss .= "tableau";
	}

    # Now sort out the vertical list
	my $vertlist = want($comp, "list");

	my $listdef = undef();
	my $fencers;
	
	if ($vertlist) 
	{
		if ($vertlist =~ /fpp/) 
		{
			#######################################################
			# Fencers, Pools, Pistes
			#######################################################

			$fencers = $comp->fpp();

			my $listdataref = $fencers;

			my $entrylistdef = [ {'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
						{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'},
						# {'class' => 'init_rank', 'heading' => 'Ranking', key => 'fencer_rank'},
						{'class' => 'poule_num', 'heading' => 'Poule', key=> 'poule'},
						{'class' => 'piste_num', 'heading' => 'Piste', key=> 'piste_no'}];						
   
   
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&namesort,
						'list_title' => 'Fencers - Pools - Pistes', 
						'entry_list' => $listdataref, 'column_defs' => $entrylistdef };

		} 
		elsif ($vertlist =~ /ranking/) 
		{
			#######################################################
			# Ranking after the pools
			#######################################################

			# Need to check the round no
			if ($hp[2] eq "finished")
			{
				# don't think this will ever get executed - hastableau is wrong condition
				$fencers = $comp->ranking("p", $haspoules);
			}
			else
			{
				# PRS: need something extra here - final ranking after poules will never get displayed
				$fencers = $comp->ranking("p", $haspoules - 1);
			}
	
			my $entrylistdef = [ 
				{'class' => 'seed', 'heading' => 'Rank', key => 'seed'},
				{'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
				{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'},
				# might need to spilit this (v/m) into 3 cols now...
				{'class' => 'vm', 'heading' => 'V/M', key => 'vm'},
				{'class' => 'ind', 'heading' => 'Ind', key=> 'ind'},
				{'class' => 'hs', 'heading' => 'HS', key=> 'hs'} ];						
    
			$listdef = 	{'list_div' => 'vert_list_id', 'sort' => \&ranksort,
						'list_title' => 'Ranking after the pools', 
						'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		} 
		elsif ($vertlist eq 'result') 
		{ 
			#######################################################
			# Final Ranking
			#######################################################
			
			$fencers = $comp->ranking();
			
			my $entrylistdef = [ 
							{'class' => 'position', 'heading' => ' ', key => 'seed'},
							{'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'}];		
    
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&ranksort,
						'list_title' => 'Overall Ranking', 
						'entry_list' => $fencers, 'column_defs' => $entrylistdef};
		}
		elsif ($vertlist eq 'entry')
		{
			$fencers = $comp->tireurs;

			my $entrylistdef = [ 
							{'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'}];		
    
			$listdef = {'list_div' => 'vert_list_id', 'sort' => \&namesort,
						'list_title' => $comp->titre_ligne . ' Entries', 
						'entry_list' => $fencers, 'column_defs' => $entrylistdef};
		}
		
		# Add the scrolling list
		my $verts = 'vert_list_id';
		$pagedef->{'vert_scrolling_div'} = $verts;
		# Add the vertical list to the css file we need for layout
		$layoutcss .= "vlist";
	}
	
	$pagedef->{'refresh_time'} = $refreshtime;
	$pagedef->{'layout'} = $layoutcss;

	my $pagename = $pagedef->{'targetlocation'} . $pagedef->{'target'};
	open( WEBPAGE,"> $pagename") || die("can't open $pagename: $!");

	WEBPAGE->autoflush(1);

	writeBlurb($pagedef);
		
	# Write the tableaus if appropriate
	if ($hastableau) 
	{ 
		foreach my $tabdef (@{$tabdefs->{'definitions'}}) 
		{
			writeTableau($comp, $tabdef);
		}
	}

	# Write the poules if appropriate
	if ($haspoules) 
	{ 
		foreach my $pouledef (@{$pouledefs{'definitions'}}) 
		{
			writePoule($comp, $pouledef);
		}
	}

	# If we have a vertical list definition defined then add that
	if (defined($listdef)) 
	{
		writeFencerList($listdef)
	}

	print WEBPAGE "</body>\n</html>";

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
# subs to determine page content
##################################################################################

#		Whereami					Poules?				Tableau?		List
#
#		???								N					N			entry
#		poules x y y y 					Y					N			fpp
#		poules x finished				Y					N			ranking
#		tableau z99						N					Y			result
#
#

sub want
{
	my $c = shift;
	my $what = shift;

	my $where = $c->whereami;

	print "WANT: what = $what, where = $where\n";

	if ($what eq "tableau")
	{ 
		return 1 if ($where =~ /tableau/ || $where =~ /termine/);
	}
	elsif ($what eq "poules")
	{
		return undef if $where eq "poules 1 constitution";
		return split / /,$where if ($where =~ /poules/);
	}
	elsif ($what eq "list")
	{
		return which_list($where);
	}
	else
	{
		return undef;
	}
}


sub which_list
{
	my $where = shift;

	if ($where =~ /poules/)
	{
		if ($where =~ /constitution/)
		{
			# start of comp - poules not drawn yet
			return "entry" if $where =~ /poules 1/;

			# all poules in, ranking run, next round not drawn
			return "ranking";
		}
		elsif ($where =~ /finished/)
		{
			return "ranking";
		}
		else
		{
			return "fpp";
		}
	}
	elsif ($where =~ /tableau/ || $where eq "termine")
	{
		return "result";
	}
	elsif ($where eq "debut")
	{
		return "entry";
	}
}

##################################################################################
# Main starts here (I think)
##################################################################################
my $pagedeffile = shift || "pagedefinitions.ini";

# read the page definitions

# print "MAIN: pages = " . Dumper(\@pages);

STDOUT->autoflush(1);  # to ease debugging!

while (1)
{
	print "\nRunning......";
	my @pages = readpagedefs ($pagedeffile);
	foreach my $pagedef (@pages) 
	{
		createpage ($pagedef);
	}

	print "Done\nSleeping...\n";

	sleep 15;
}
			
