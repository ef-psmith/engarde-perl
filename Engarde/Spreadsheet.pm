package Engarde::Spreadsheet;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use strict;
use Spreadsheet::WriteExcel;


sub writeL32
{
	my $comp = shift;
	my $ssname = shift;

	# print "writeL32: comp = $comp, ssname = $ssname\n";

	my $t32 = $comp->tableau(32);

	my %tableau;

	my $fh = FileHandle->new('>'. $ssname);
	
	if (not defined $fh) 
	{
		print "Can't open $ssname. It may be in use or protected";
		return undef;
	}

	binmode($fh);

	# Create a new Excel workbook
	my $workbook = Spreadsheet::WriteExcel->new($fh);

	unless ($workbook)
	{
		print "no workbook\n";
		return undef;
	}

	my $yellow = $workbook->set_custom_color(40, 255, 255, 204);
	my $green = $workbook->set_custom_color(41, 204, 255, 204);

	my $f_l32_name = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>22);
	my $f_l16_name = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>$yellow);
	my $f_l16_name_pad = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>$yellow, right=>1);
	my $f_l8_name = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>$yellow);
	my $f_l8_name_pad = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>$yellow, right=>1);
	my $f_l4_name = $workbook->add_format(align=>'vcenter', size=>14, bold=>1, bg_color=>$green);

	my $f_l32_club = $workbook->add_format(align=>'right', text_wrap=>1, size=>12, bold=>1, bg_color=>22, right=>1);
	my $f_title = $workbook->add_format(size=>14, bold=>1);
	my $f_seed = $workbook->add_format(size=>12, align=>'right', valign=>'vcenter');
	my $f_match = $workbook->add_format(size=>12, align=>'right', valign=>'vcenter', bold=>1, right=>1);

	my $f_score = $workbook->add_format(size=>10, align=>'left', valign=>'top', indent=>1);

	my $f_blank_border = $workbook->add_format(size=>10, right=>1);

	my $f_time = $workbook->add_format(size=>10, align=>'center', valign=>'vcenter', italic=>1);

	my $sheet;

	for ($sheet = 0; $sheet<4; $sheet++)
	{
		# Add a worksheet
		my $worksheet = $workbook->add_worksheet("Q" . ($sheet + 1));

		my @titles = ("Tableau of 32", undef,"Tableau of 16", undef, "Tableau of 8", undef, "Semi-Finalist");
		my @widths = (6,40,25,30,5,30,5,30);

		for (my $i=0;$i<=$#widths;$i++)
		{
			$worksheet->set_column($i,$i,$widths[$i]);
		}

		for (my $i=3;$i<18;$i++)
		{
			$worksheet->set_row($i,34);
		}

		# setup titles	
		$worksheet->write_row('B2', \@titles, $f_title);


		my $m;

		# print L32
		

		my $affiliation;
		my $winner;
		my $row = 3;
		my $match = ($sheet * 4) + 1;

		my $end = $match+4;

		while ($match < $end)
		{

			$m = $comp->match(32,$match);

			$worksheet->write($row,0,$m->{'seedA'},$f_seed);
			$worksheet->write($row,1,$m->{'fencerA'},$f_l32_name);

			$affiliation = $m->{'clubA'} || "" . $m->{'nationA'} || "";
			$worksheet->write($row,2,$affiliation,$f_l32_club);

			$worksheet->write($row+1, 2, "E$match", $f_match);

			$worksheet->write($row,0,$m->{'seedB'},$f_seed);
			$worksheet->write($row+2,1,"$m->{'fencerB'}",$f_l32_name);

			$affiliation = $m->{'clubB'} || "" . $m->{'nationB'} || "";
			$worksheet->write($row+2,2,$affiliation,$f_l32_club);

			$winner = $m->{'winner'};

			if ($winner)
			{
				$worksheet->write($row+1,3,$m->{'winner'}, $f_l16_name);
				$worksheet->write($row+2,3,($m->{'scoreA'} + 0) . "/" . ($m->{'scoreB'} + 0), $f_score);
			}
			else
			{
				$worksheet->write_blank($row+1,3, $f_l16_name);
			}

			$worksheet->write_blank($row+1,4,$f_l16_name_pad);

			if ($row % 2)
			{
				if ($m->{'piste'})
				{
					$worksheet->write($row+1,1,"$m->{'time'}, Piste $m->{'piste'}", $f_time);
				}
			}

			$match++;
			$row +=4;
		}

		$worksheet->write_blank(5,4,$f_blank_border);
		$worksheet->write_blank(7,4,$f_blank_border);
		$worksheet->write_blank(13,4,$f_blank_border);
		$worksheet->write_blank(15,4,$f_blank_border);


		# print L16
		
		$match = ($sheet * 2) + 1;

		$end = $match+2;
		$row = 6;


		while ($match < $end)
		{
		
			$m = $comp->match(16,$match);

			$winner = $m->{'winner'};

			if ($winner)
			{
				$worksheet->write($row,5,"$m->{'winner'}", $f_l8_name);
				$worksheet->write($row+1,5,($m->{'scoreA'} + 0) . "/" . ($m->{'scoreB'} + 0), $f_score);
			}
			else
			{
				$worksheet->write_blank($row,5,$f_l8_name);
			}

			$worksheet->write_blank($row,6,$f_l8_name_pad);

			$worksheet->write($row, 4, "D$match", $f_match);

			if ($m->{'piste'})
			{
				# print "match $match, piste = $tableau{16}{$match}{'piste'}\n";

				$worksheet->write($row,3,"$m->{'time'}, Piste $m->{'piste'}", $f_time);
			}

			$match++;
			$row += 8;
		}

		$worksheet->write_blank(7,6, $f_blank_border);
		$worksheet->write_blank(8,6, $f_blank_border);
		$worksheet->write_blank(9,6, $f_blank_border);
		$worksheet->write_blank(11,6, $f_blank_border);
		$worksheet->write_blank(12,6, $f_blank_border);
		$worksheet->write_blank(13,6, $f_blank_border);

		# L8
		
		$match = $sheet + 1;
		$row = 10;
  
		$m = $comp->match(8,$match);

		# print "L8: \$m = " . Dumper(\$m);


		$winner = $m->{'winner'};

		if ($winner)
		{
			$worksheet->write($row,7,$winner, $f_l4_name);
			$worksheet->write($row+1,7,($m->{scoreA} + 0) . "/" . ($m->{scoreB} + 0), $f_score);
		}
		else
		{
			$worksheet->write_blank($row,7, $f_l4_name);
		}

		$worksheet->write($row, 6, "C$match", $f_match);

		if ($m->{'piste'})
		{
			$worksheet->write($row,5,"$m->{'time'}, Piste $m->{'piste'}", $f_time);
		}
		
		$worksheet->set_landscape();	# print in landscape
		$worksheet->hide_gridlines(1);	# don't print gridlines
		$worksheet->fit_to_pages(1, 1); # Fit to 1x1 pages	
	}

	$workbook->close();

	return $ssname;
}
