# (c) Copyright Oliver Smith & Peter Smith 2007-2009 
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

# for dev purposes (mostly)
use lib "..";

use strict;
use Engarde;
use Data::Dumper;
# use IO::Handle;

use vars qw($pagedetails);

##################################################################################
# writeTableauMatch
##################################################################################
sub writeTableauMatch 
{
    my $bout = shift;
	my $roundnumber = shift;

	my $tab = $roundnumber == 1 ? "" : "\t";
	my $noseed = $roundnumber == 1 ? "" : "noseed";

	# print "writeTableauMatch: bout = " . Dumper(\$bout);

	print WEBPAGE "$tab\t\t<!-- ************ BOUT ************ -->\n";
	print WEBPAGE "$tab\t\t<div id=\"container\"><div id=\"position\">\n";
	print WEBPAGE "$tab\t\t\t<div class=\"bout\">\n";						# BOUT 

	foreach my $key (qw/A B/)
	{
		my $fencer = $bout->{'fencer' . $key};
		my $seed = $bout->{'seed' . $key};

		if (!defined($fencer)) 
		{
			$fencer = '';
			# $seed = '';
		}
		my $result = "";

		$result = "winner" if (defined($bout->{'winner'}) && $bout->{'winner'} eq $fencer);

		print WEBPAGE "$tab\t\t\t\t<div class=\"$key $result\">\n";
		print WEBPAGE "$tab\t\t\t\t<div id=\"container\"><div id=\"position\">\n";

		print WEBPAGE "$tab\t\t\t\t\t<span class=\"seed\">$seed</span>\n" if $roundnumber == 1;
		
		print WEBPAGE "$tab\t\t\t\t\t<span class=\"fencer $noseed\">$fencer</span>\n";

		if ($roundnumber == 1) 
		{
			my $country = $bout->{'nation' . $key};

			if (defined($country)) 
			{
				print WEBPAGE "$tab\t\t\t\t\t<span class=\"country\">$country</span>\n";
			}
		} 

		print WEBPAGE "$tab\t\t\t\t</div></div>\n";
		print WEBPAGE "$tab\t\t\t\t</div>\n";

		my $title = "";

		if ($key eq "A")
		{
			if ($bout->{'winner'})
			{
				if ($bout->{'fencerA'} && $bout->{'fencerB'})
				{
					$title = "$bout->{'scoreA'} / $bout->{'scoreB'}";
				}
			}
			else
			{
				$title = "Piste: " . $bout->{'piste'} if $bout->{'piste'};
				$title .= " Time: $bout->{'time'}" if $bout->{'time'} && $bout->{'time'} ne "0:00";
			}

			print WEBPAGE "$tab\t\t\t\t<div class=\"boutinfo\">\n";			
			print WEBPAGE "$tab\t\t\t\t<div id=\"container\"><div id=\"position\">$title</div></div>\n";
			print WEBPAGE "$tab\t\t\t\t</div> <!-- boutinfo -->\n";
		}
	} 

	print WEBPAGE "$tab\t\t\t</div> <!-- bout -->\n";   # close BOUT div
	print WEBPAGE "$tab\t\t</div></div>  <!-- container -->\n";								# close 4th DIV
	print WEBPAGE "$tab\t\t<!-- ************ END BOUT ************ -->\n\n";
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
    my $bkcolour = $page->{'background'};
    my $csspath = $page->{'csspath'};
    my $scriptpath = $page->{'scriptpath'};

	# DO NOT ADD A "DOCTYPE" LINE 
	# We need the browser to be in quirks mode for some of the CSS layout to work properly 
	# and any DOCTYPE causes firefox to operate in strict mode
	print WEBPAGE "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"en\" xml:lang=\"en\">\n";
    
    print WEBPAGE "<head>\n";
    
    print WEBPAGE "<title>$pagetitle</title>\n";

    print WEBPAGE "<META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\">\n";
	print WEBPAGE "<META HTTP-EQUIV=\"CACHE-CONTROL\" CONTENT=\"NO-CACHE\">\n";

	print WEBPAGE "<style type=\"text/css\">\n\t#top, #bottom, #left, #right { background: $bkcolour;}\n</style>\n";

    print WEBPAGE "<link href=\"".$csspath."live.css\" rel=\"stylesheet\" type=\"text/css\" media=\"screen\" />\n";

    print WEBPAGE "<script type=\"text/javascript\">\n";
	print WEBPAGE "\tvar next_location=\"$nextpage\";\n";
		
	print WEBPAGE "</script>\n";

	# this must come after the local variables above and for some reason the XHTML closure doesn't 
	# always work so we need to use </script> in full
    print WEBPAGE "<script src=\"".$scriptpath."scroll.js\" type=\"text/javascript\"></script>\n";
	print WEBPAGE "</head>\n";
	print WEBPAGE "<body onload=\"onPageLoaded()\">\n";
    
	print WEBPAGE "<div id=\"left\"></div>\n";
	print WEBPAGE "<div id=\"right\"></div>\n";
	print WEBPAGE "<div id=\"top\"></div>\n";
	print WEBPAGE "<div id=\"bottom\"></div>\n";

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

	print WEBPAGE "<div class=\"title\"><h2>$compname Round $round</h2></div>\n";
	print WEBPAGE "<div class=\"$poule_class\" id=\"$div_id\">\n";
    
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
# Write out a tableau, writeTableau(data, pagedetails)
sub writeTableau 
{
    my $comp = shift;
    my $page = shift;

	my $where = $page->{'where'};
	
	# print "Where: $where \n";

    # this is the bout before this tableau.  Should be divisible by 2.
    my $preceeding_bout = $page->{'preceeding_bout'};
    
	print WEBPAGE "<div class=\"$page->{title_class}\" id=\"$page->{'title_id'}\"><h2>$page->{'tableau_title'}</h2></div>\n";
    print WEBPAGE "<div class=\"$page->{tableau_class}\" id=\"$page->{'tableau_div'}\">\n";  # 1st DIV		"tableau"

	my $numrounds = $page->{'num_cols'};
	if (!defined($numrounds)  || $numrounds < 2) {
		$numrounds = 3;
	}
	
	# Work out the number of bouts
	my $lastN = $page->{'lastN'};
	my $numbouts = $page->{'num_bouts'};
	
	# print "writeTableau: Number of rounds: $numrounds Number of bouts: $numbouts\n";

	my $minbout = $preceeding_bout + 1;
	my $maxbout = $minbout + $numbouts;

	my $bout;
	
    for (my $roundnum = 1; $roundnum <= $numrounds; $roundnum++) 
	{
		# print "writeTableau: roundnum = $roundnum\n";

        my $colname = $roundnum == 1 ? "col1" : "col";
        print WEBPAGE "<div class=\"$colname\">\n";						# COLUMN

        for (my $boutnum = $minbout; $boutnum < $maxbout; $boutnum++) 
		{
			if ($boutnum == $minbout || $boutnum == $minbout + 2) 
			{
				print WEBPAGE "\t<!-- **************************** HALF **************************** -->\n";
				print WEBPAGE "\t<div class=\"half\">\n" if ($roundnum < 3 && ($boutnum == $minbout || $boutnum == $minbout + 2));						# VERTICAL DIVIDER
			}

			if ($roundnum == 1 )
			{
				print WEBPAGE "\t\t<!-- *************************** QUARTER **************************** -->\n";
				print WEBPAGE "\t\t<div class=\"quarter\">\n"; 
			}

			# print WEBPAGE "<!--   MATCH GOES HERE -->\n";

			$bout = $comp->match($where, $boutnum);
			writeTableauMatch($bout, $roundnum);

			print WEBPAGE "\t\t</div> <!-- quarter -->\n" if $roundnum == 1 ;					# close VERTICAL DIVIDER
			print WEBPAGE "\t</div>  <!-- half -->\n" if ($roundnum < 3 && ($boutnum == $minbout + 1 || $boutnum == $minbout + 3));	
		}

        print WEBPAGE "</div><!-- col -->\n";				# close 2nd DIV
        # end of col div

        # next round has half as many bouts
        
        $numbouts /= 2;
        my $newlastN = $lastN/2;
        $preceeding_bout /=2; 
		$minbout = $preceeding_bout + 1;
		$maxbout = $minbout + $numbouts;

		# Change the where
		$where =~ s/$lastN/$newlastN/; 
		$lastN = $newlastN;

		# print "writeTableau: where = $where, lastN = $lastN\n";

    }

	if ($bout->{'winner'})
	{
		print WEBPAGE "<div class=\"col\">\n";
		print WEBPAGE "\t<div id=\"container\"><div id=\"position\">\n";
		print WEBPAGE "\t\t<div class=\"A final winner\">\n";
		print WEBPAGE "\t\t\t<div id=\"container\"><div id=\"position\">\n";
		print WEBPAGE "\t\t\t\t$bout->{'winner'}\n";
		print WEBPAGE "\t\t\t</div></div>\n";
		print WEBPAGE "\t\t</div>\n";
		print WEBPAGE "\t</div></div>\n";
		print WEBPAGE "</div>\n";
	}
    
    print WEBPAGE "</div>  <!-- tableau -->\n";					# close 1st DIV
}

##################################################################################
# writeEntryListFencer
##################################################################################
# write a fencer into an entry list.  (key to data, webpage, details of list);
sub writeEntryListFencer {
    my $EGData = shift;
    my $col_details = shift;

	# flag to indicate if the style should be amended based on the "group" value
	my $adjust_style = shift || 0;

	my $row_class = "";

	if ($adjust_style)
	{
		my $group = $EGData->{"group"};
		$row_class = "class=\"$group\"";
	}
		
    print WEBPAGE "\t\t\t<tr $row_class>\n";

    foreach my $column_def (@{$col_details}) 
	{
		my $col_class = $column_def->{'class'};
		my $col_key = $column_def->{'key'};
		my $col_val = defined $EGData->{$col_key} ? $EGData->{$col_key} : "&nbsp;";

		print WEBPAGE "\t\t\t\t<td class=\"$col_class\">$col_val</td>\n";
    }

    print WEBPAGE "\t\t\t</tr>\n"; 

}

sub writeFencerListDivHeader
{
	my $div_id = shift;
	my $class = "vlist_body";

	$class .= " hidden" if ($div_id > 0);

    print WEBPAGE "\t<div class=\"$class\" id=\"V$div_id\">\n";
    print WEBPAGE "\t\t<table class=\"vlist_table\">\n";
}


sub writeFencerListDivFooter
{
    print WEBPAGE "\t\t</table>\n\t</div>\n";
}



##################################################################################
# writeFencerList
##################################################################################
# Write out the entry list in table format  - used for all vlist divs
sub writeFencerList 
{
    local $pagedetails = shift;		# must be scoped as local to allow for sort funcs

    my $list_title = $pagedetails->{'list_title'};
    my $col_details = $pagedetails->{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";
	my $size = $pagedetails->{'size'};

    print WEBPAGE "<div class=\"vlist\">\n";
    print WEBPAGE "\t<div class=\"vlist_title\"><h2>$list_title</h2></div>\n";
    print WEBPAGE "\t<div class=\"vlist_header\">\n";
    print WEBPAGE "\t\t<table class=\"vlist_table\">\n\t\t\t<tr>\n";
    foreach my $column_def (@{$col_details}) 
	{
		my $col_class = $column_def->{'class'};
		my $col_heading = $column_def->{'heading'};
		
		print WEBPAGE "\t\t\t\t<td class=\"$col_class\">$col_heading</td>\n";
	}

    print WEBPAGE "\t\t\t\</tr>\n\t\t</table>\n\t</div>\n";

	my $div_id = 0;
  
	writeFencerListDivHeader($div_id);

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
				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details, 1);

					if ($entryindex == $size)
					{
						writeFencerListDivFooter();
						$div_id += 1;
						$entryindex = 0;
						writeFencerListDivHeader($div_id);
					}
					else
					{
				   		$entryindex += 1;
					}
				}
			}
			else
			{
				foreach my $entrydetail (%$entry_list) 
				{
				   	writeEntryListFencer($entry_list->{$entrydetail}, $col_details);

					if ($entryindex == $size)
					{
						writeFencerListDivFooter();
						$div_id += 1;
						$entryindex = 0;
						writeFencerListDivHeader($div_id);
					}
					else
					{
				   		$entryindex += 1;
					}
				}
			}
		}
		else
		{
			foreach my $entry (@$entry_list)
			{
				writeEntryListFencer($entry, $col_details);

				if ($entryindex == $size)
				{
					writeFencerListDivFooter();
					$div_id += 1;
					$entryindex = 0;
					writeFencerListDivHeader($div_id);
				}
				else
				{
			   		$entryindex += 1;
				}
			}
		}
    }
    
	writeFencerListDivFooter();
	
	print WEBPAGE "\n</div>";
}

##################################################################################
# writeEntryList
##################################################################################
# Write out the entry list in CSS3 multi column format 
sub writeEntryList 
{
    local $pagedetails = shift;

    my $list_title = $pagedetails->{'list_title'};
    my $col_details = $pagedetails->{'column_defs'};
	my $sort_func = $pagedetails->{'sort'};
	my $entry_list = $pagedetails->{'entry_list'};
	my $ref = ref $pagedetails->{'entry_list'} || "";

    print WEBPAGE "<div class=\"vlist_title\"><h2>$list_title</h2></div>\n";
    print WEBPAGE "<div class=\"col_multi\" id=\"V0\">\n";

    if (defined ($entry_list))
	{
		my $entryindex = 0;

		foreach my $entrydetail (sort namesort keys %$entry_list) 
		{
			my $affiliation = $entry_list->{$entrydetail}->{'club'} || "&nbsp;";
			my $nom = $entry_list->{$entrydetail}->{'nom'};

			print WEBPAGE "<span class=\"col_name\">$nom</span>";
			print WEBPAGE "<span class=\"col_club\">$affiliation</span><br>\n";

		   	$entryindex += 1;
		}
    }
    
    print WEBPAGE "</div>\n";
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
    
	#  my @localswaps;

    my @defs;
    my $defindex = 0;
   	
   	my $numPoulesPerPage = 3;

	my $poule;

	do {
		$poule = $competition->poule($round,$defindex + 1);

		if (defined($poule)) 
		{
			if (0 == $defindex % $numPoulesPerPage) 
			{
				my %def;

				my $divname = "T" . int($defindex / $numPoulesPerPage);

				# $localswaps[int($defindex / $numPoulesPerPage)] = $divname;

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
	# $retval{'swaps'} = \@localswaps;
   
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
    #	default is two columns
	my $numcols = 3;


	# PRS - this bit allows a single quarter to be displayed
	# not used here but left in for consistency

    if ($tableaupart =~ m%(\d)/(\d)in(\d)%) {
		$chosenpart = $1;
		$numparts = $2;
		$numcols = $3;
    	print "Tableau Part: $tableaupart or $chosenpart / $numparts \n";
    }
        
    my $compname = $competition->titre_ligne;
    
  	my $retval = {};
	
	my $tab;
	my $roundsize = 0;


	# PRS - minroundsize controls the number of fencers in col1 - now fixed at 8
	my $minroundsize = 8; 
	  
   	my $where = $competition->whereami;

	# print "\n\ncreateRoundTableaus: where = $where\n";

 	if ($where =~ /tableau/ || $where eq "termine")
	{
		if ($where =~ /tableau/)
		{
			$where =~ s/tableau //;

			# start at the last complete tableau if possible.
			#
			my @t = $competition->tableaux;

			# print "\ncreateRoundTableaus: t = @t\n";

			if (defined $t[0])
			{
				$where = $t[0];
			}
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
		# PRS - not used in current "auto" config
		if ($numparts) 
		{
			$roundsize = $numparts * $minroundsize;
			
			print "where = $where\n";
			$where =~ s/\d+/$roundsize/;
			print "Now where is (after round definition)  $where\n";
		}	

		# print "where = $where\n";
		$tab = $competition->tableau($where);

		$roundsize = $tab->taille if ref $tab;
		# print "Roundsize $roundsize, Minroundsize $minroundsize\n";

		if ($roundsize < $minroundsize)	# assume it's the final - wouldn't be true if all the DE places were fought
		{
			# do it this way since we can't be certain that the tableau letter is "a" - e.g. A grade formula would be "bf"
			# after the preliminary tableau
			$where =~ s/$roundsize/$minroundsize/;
			$roundsize = $minroundsize;
		}
	}
	else
	{
		# Nothing to display
		return $retval;
	}

	# my @localswaps;

    my @defs;
    my $defindex = 0;

    my $preceedingbout = 0;
    while ($preceedingbout < $roundsize / 2) 
	{
		# print "Preceeding Bout: $preceedingbout Chosen part: $chosenpart \n";
    
		if (0 == $chosenpart || $preceedingbout == ($minroundsize /2) * $chosenpart) 
		{
			my %def;

			$def{'where'} = $where;
			$def{'num_bouts'} = $minroundsize /2;
			
			my $part = ($defindex + 1);
			if (0 != $chosenpart) {
				$part = $chosenpart;
			}

			# $part is 1 indexed and our divs are 0 indexed to avoid confusing me.
			my $divname = "T" . $part - 1;
			my $title_id = "TT" . ($part - 1);
		
			# $localswaps[$defindex] = $divname;
		
			$def{'tableau_div'} = $divname;
			$def{'title_id'} = $title_id;
			$def{'num_cols'} = $numcols;

			if ($preceedingbout == 0 && $roundsize <= 8) 
			{
	    		$def{'tableau_title'} = $compname . " Final";
			} 
			elsif ($preceedingbout == 0 && $roundsize == $minroundsize)
			{
	    		$def{'tableau_title'} = $compname . " Last $minroundsize";
			}
			else 
			{
	    		$def{'tableau_title'} = $compname . " Last ". $roundsize . " part " . $part;
			}

			$def{'lastN'} = $roundsize;
			$def{'preceeding_bout'} = $preceedingbout;
		
			if ($preceedingbout != 0 && 0 == $chosenpart) 
			{
	    		$def{'tableau_class'} = 'tableau hidden';
	    		$def{'title_class'} = 'title hidden';
			}
			else
			{
	    		$def{'tableau_class'} = 'tableau';
	    		$def{'title_class'} = 'title';
			}

			$defs[$defindex] = \%def;
			$defindex++;
		}

		$preceedingbout += 4;
   	}

   	$retval->{'definitions'} = \@defs;
	# $retval->{'swaps'} = \@localswaps;
   	
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
	my %currentseries;
	my $series = {};
    my $inpage = 0;
    my $inseries = 0;

    while (<PAGEDEFFILE>) 
	{
		if (/^\[SERIES\]$/)
		{
			$inseries = 1;
			undef %currentseries;
			undef @pagedefs;
			undef %currentpage;
		}
		elsif ((my $name, my $value) = ($_ =~ /(\w*)=(.*)/)) 
		{
			$currentpage{$name} = $value if $inpage; 
			$currentseries{$name} = $value if $inseries && not $inpage; 
        }
		elsif (/^\[PAGE\]$/) 
		{
			# Beginning of a page so clear everything
			undef %currentpage;
			$inpage = 1;
		}
		elsif ((my $name, my $value) = ($_ =~ /(\w*)=(.*)/)) 
		{
			if ($inpage) 
			{
				# Got a name value pair
				$currentpage{$name} = $value;
			}
			elsif ($inseries)
			{
			}
       	}
		elsif (/^\[\/PAGE\]$/) 
		{
			# End of a page so check whether we want this or not
			my $enabled = $currentpage{'enabled'};

			if (defined($enabled) && $enabled eq 'true') 
			{
				# PRS - copy series values to page - makes life easier later on....
				foreach my $skey (keys %currentseries)
				{
					next if $skey eq "name";
					$currentpage{$skey} = $currentseries{$skey};
				}

				push @pagedefs, {%currentpage};
			}

			$inpage = 0;
		}
		elsif (/^\[\/SERIES\]$/) 
		{
			if (defined($currentseries{'enabled'})  && $currentseries{'enabled'} eq "true")
			{
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

				$series->{$currentseries{'name'}} = {};
				$series->{$currentseries{'name'}}->{'pagedefs'} = [@pagedefs];

				foreach my $key (keys %currentseries)
				{
					$series->{$currentseries{'name'}}->{$key} = $currentseries{$key};
				}
			}
		}

		$pageindex++;
	}
    close PAGEDEFFILE;

	# print "pagedefs = " . Dumper(\@pagedefs);
	return $series;
}
	


##################################################################################
# createpage
##################################################################################
sub createpage 
{
	my $pagedef = shift;

	# print "\n\ncreatepage: pagedef = " . Dumper(\$pagedef);
	
	#Create the competition
	my $compname = 	$pagedef->{'competition'};
	my $comp = Engarde->new($compname);
	
	die "no comp" unless $comp;	
	# initialise the competition
	$comp->initialise;
	
	# $pagedef->{'comp'} = $comp;

	$pagedef->{'pagetitle'} = $comp->titre_ligne;
	
	# default refresh time of 30s.  This is changed later to be a minimum of 10 seconds per tableau view or the size of the vertical list.
	my $refreshtime = 30;

	# If there are tableaus then we need to create them
	my $hastableau = want($comp, "tableau");

	# print "createpage: hastableau = $hastableau\n";

	my $tabdefs;
	
	if ($hastableau) 
	{ 
		$tabdefs = createRoundTableaus($comp, $pagedef->{'tableau'});

		# $pagedef->{'swaps'} = $tabdefs->{'swaps'};
		
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

		# $pagedef->{'swaps'} = $pouledefs{'swaps'};
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

			my $entrylistdef = [ {'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
						{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'},
						# {'class' => 'init_rank', 'heading' => 'Ranking', key => 'fencer_rank'},
						{'class' => 'vlist_poule', 'heading' => 'Poule', key=> 'poule'},
						{'class' => 'vlist_piste', 'heading' => 'Piste', key=> 'piste_no'}];						
   
   
			$listdef = { 'sort' => \&namesort, 'size'=> $pagedef->{'vlistsize'},
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
				$fencers = $comp->ranking("p", $haspoules);
			}
			else
			{
				# PRS: need something extra here - final ranking after poules will never get displayed
				$fencers = $comp->ranking("p", $haspoules - 1);
			}
	
			my $entrylistdef = [ 
				{'class' => 'seed', 'heading' => ' ', key => 'seed'},
				{'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
				{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'},
				# might need to spilit this (v/m) into 3 cols now...
				{'class' => 'vm', 'heading' => 'vm', key => 'vm'},
				{'class' => 'ind', 'heading' => 'ind', key=> 'ind'},
				{'class' => 'hs', 'heading' => 'hs', key=> 'hs'} ];						
    
			$listdef = 	{	'sort' => \&ranksort, 'size' => $pagedef->{'vlistsize'},
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
							{'class' => 'vlist_position', 'heading' => ' ', key => 'seed'},
							{'class' => 'vlist_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'vlist_club', 'heading' => 'Club', key => 'club'}];		
    
			$listdef = {	'sort' => \&ranksort, 'size' => $pagedef->{'vlistsize'},
							'list_title' => 'Overall Ranking', 
							'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		}
		elsif ($vertlist eq 'entry')
		{
			$fencers = $comp->tireurs;

			my $entrylistdef = [ 
							{'class' => 'fencer_name', 'heading' => 'Name', key=> 'nom'},
							{'class' => 'fencer_club', 'heading' => 'Club', key => 'club'}];		
    
			$listdef = {	'sort' => \&namesort, 'size' => $pagedef->{'entrylistsize'},
							'list_title' => $comp->titre_ligne . ' Entries', 
							'entry_list' => $fencers, 'column_defs' => $entrylistdef
						};
		}
	}
	

	my $pagename = $pagedef->{'targetlocation'} . $pagedef->{'target'};
	open( WEBPAGE,"> $pagename") || die("can't open $pagename: $!");

	my $fh = select(WEBPAGE);
	$| = 1;			# unbuffered output
	select($fh);

	# WEBPAGE->autoflush(1);

	writeBlurb($pagedef);
		
	# Write the tableaus if appropriate
	if ($hastableau) 
	{ 
		foreach my $tabdef (@{$tabdefs->{'definitions'}}) 
		{
			# print "\n\ntabdef = " . Dumper(\$tabdef);
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
		if ($vertlist eq "entry")
		{
			writeEntryList($listdef);
		}
		else
		{
			writeFencerList($listdef)
		}
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

	# print "WANT: what = $what, where = $where\n";

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

my $fh = select(STDOUT);
$| = 1;
select($fh);
# STDOUT->autoflush(1);  # to ease debugging!

while (1)
{
	print "\nRunning......";
	my $pages = readpagedefs ($pagedeffile);
	foreach my $series (keys %$pages)
	{
		foreach my $pagedef (@{$pages->{$series}->{'pagedefs'}}) 
		{
			createpage ($pagedef);
		}

		# create series index page here!
	}	

	# print "Done\nSleeping...\n";

	sleep 30;
}
			
