package Engarde::Poule;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

# Poules need a custom load / decode method
sub load
{
	my $self = shift;

	open IN, $self->{file} || die $!;

	<IN>;	#	skip {[numero 1]
 	<IN>;	#	skip  [les_tir_cons (191 152 188 190 160 158 212)]

	my $tir = <IN>;	# [les_tir_feuille (212 188 191 190 158 152 160)]

	chomp $tir;

	$tir =~ s/\[les_tir_feuille \(//;
	$tir =~ s/\)\]$//;

	my @tir = split / /, substr($tir,1);
 
	<IN>;	#	skip  [ordre_des_matches odm7]
 	<IN>;	#	skip  [critere_placement nation]

	$self->{les_tir_cons} = \@tir;

	my $unparsed;

	while (<IN>)
	{
		chomp;

		# print "POULE: in = $_\n";

		if (/^ \[/ && $unparsed)
		{
			$self->decode($unparsed);
			$unparsed = $_;
		}
		else
		{
			$unparsed .= $_;
		}
	}

	$self->decode($unparsed) if $unparsed;
	close IN;

	# special cases

	$self->{heure} =~ s/\~//g if $self->{heure};
	
	if ($self->{grille})
	{
		# print "POULE: raw grille = $self->{grille}\n";

		$self->{grille} =~ s/^\((.*)\)$/$1/;

		# print "POULE: cooked grille = $self->{grille}\n";

		my @g = _unbracket($self->{grille});

		# print "POULE: split grille = " . Dumper(\@g);

		# looks messy but this stips the extra brackets, etc 
		# off and makes it a consistent text grid
		foreach (@g)
		{
			#s/\(\((\()/$1/g;
			#s/(\))\)\)/$1/g;
			#s/\(\*\*\* (\(\))\)/$1/g;
			#s/^([a-z])/\($1/;
			#s/([0-5])$/$1\)/;
		}

		$self->{grille} = \@g;

		my $i =0;

		while ($self->{les_tir_cons}[$i])
		{
			my $line = $self->{grille}[$i];

			my @res = _unbracket($line);
			
			my $v = 0;

			my @fights;

			for($v=0;defined $res[$v];$v++)
			{
				my $fight = {};

				if ($i == $v) 
				{
					push @fights, $fight;
				}
				else
				{
					($fight->{result}, $fight->{score}) = split / /, $res[$v];
					push @fights, $fight;
				}
			}
		
			$self->{results}->{$self->{les_tir_cons}[$i]} = \@fights;

			$i++;
		}
	}

	if ($self->{scores})
	{
		$self->{scores} =~ s/^\((\(.*\))\)$/$1/;
		my @scores = _unbracket($self->{scores});
		# print "POULE: scores = " . Dumper(\@scores);

		# scores can be any of these
		#  'e 4 691 3 0 8 15',
		#  'f 6 725 0 0 0 0',
		#  'z 7 697 0 0 0 0',
		#  'a 5 695 0 0 0 0',
	
		# status, position in poule, fencer no, matches, victories,	hs, hr

		# e = normal (??)
		# f = scratch (forfait)
		# z = eliminated (?? black card)
		# a = abandon

		my $s = {};

		foreach my $score (@scores)
		{

			my @ss = split / /, $score;

			my $status = "normal";

			$status = "abandon" if $ss[0] eq "a";
			$status = "scratch" if $ss[0] eq "f";
			$status = "exclude" if $ss[0] eq "z";

			$s->{$ss[2]}->{status} = $status;
			$s->{$ss[2]}->{position} = $ss[1];
			$s->{$ss[2]}->{m} = $ss[3];
			$s->{$ss[2]}->{v} = $ss[4];
			$s->{$ss[2]}->{hs} = $ss[5];
			$s->{$ss[2]}->{hr} = $ss[6];
		}

		$self->{scores} = $s;
	}
}



sub decode
{
	my $self = shift;
	my $in = shift;

	my @keywords = qw/piste_no heure scores grille/;

	foreach my $key (@keywords)
	{
		if ($in =~ /\[$key /)
		{
			$in =~ s/\[$key //;
			$in =~ s/\].*//;
			$in =~ s/\"//g;		

			$self->{$key} = substr($in,1);
			last;
		}
	}
}



sub _unbracket
{
	# prive sub used to resolve strings with an arbitary number of 
	# pairs of brackets into an array of strings each of which will 
	# inevitably also contain pairs of brackets
	#
	# needed because "split" cant cope with the endless variations!
	#
	
	my $in = shift;

	my $depth = 0;
	my $i = 0;
	my $string;
	my @g;

	while($i < length $in)
	{
		my $char = substr($in,$i,1);

		$depth++ if $char eq "(";
		$depth-- if $char eq ")";

		if ($depth == 0 && $char eq ")")
		{
			push @g, $string;
			$string = "";
		}
		elsif (($depth == 0 && $char eq " ") || ($depth == 1 && $char eq "("))
		{
			# skip space after closing bracket
			# and opening left bracket
		}
		else
		{
			$string .= $char;
		}

		$i++;
	}

	return @g;
}


sub grid
{
	my $self = shift;
	my $c = $self->parent;


	# print "GRID: parent = " . Dumper(\$c);

	my $tir = $self->les_tir_cons;

	# print "GRID: les_tir_cons = " . Dumper(\$tir);

	my $res = $self->results;
	my $scores = $self->scores;

	# the idea is to produce a table including all of the data for a poule
	#
	# ID 	Name	Club/Nation		results eg V 1-5 V1-5 X A S  	V/M  HS	Ind	Pl
	#
	# qw/id name club result result result result result result result vm hs ind pl/;
	
	#	697 BLOGGS Fred	GBR	() V V4 3 A S X	2/3	11	+3	1
	#										abandon	()	()	5
	#										scratch	()	()	6
	#										excluded ()	()	7	
	
	my @out;
	my $domain = $c->domaine_compe;

	my $poulesize =  scalar @$tir;

	# print "GRID: poulesize = $poulesize\n";

	my @titles = qw/id name/;

	push @titles, "club" if ($domain eq "national");
	push @titles, "nation" if ($domain eq "international");

	foreach (@$tir)
	{
		push @titles, "result";
	}

	push @titles, qw/vm hs ind pl/;

	# print "GRID: titles = " . Dumper(\@titles);

	push @out, \@titles;
 
	foreach my $f (@$tir)
	{
		my $fencer = $c->tireur($f);
		my $affiliation;
	   
		$affiliation = $c->nation($fencer->nation) if $domain eq "international";
		$affiliation = $c->club($fencer->club) if $domain eq "national";

		# print "GRID: f = $f, fencer = " . Dumper(\$fencer);
		# print "GRID: affiliation = $affiliation\n\n";
		
		my @line;

		push @line, $f;
		push @line, $fencer->nom;
		push @line, $affiliation;

		my $i;

		for ($i=0;$i<$poulesize;$i++)
		{
			# print "GRID: result = " . Dumper($res->{$f});

			my $st = $res->{$f}[$i]->{status};
			my $r = $res->{$f}[$i]->{result} || "";
			my $s = $res->{$f}[$i]->{score} || 0;

			$r = "X" if $r eq "xx";
			$r = "V" if $r eq "v" && $s == 5;
			$r = "V$s" if $r eq "w";
			$r = "A" if $r eq "a";
			$r = "S" if $r eq "f";
			$r = "E" if $r eq "z";
			$r = $s if $r eq "d";

			push @line, $r;
		}

		push @line, $scores->{$f}->{v} ."/". $scores->{$f}->{m};
		push @line, $scores->{$f}->{hs};
		push @line, ($scores->{$f}->{hs} - $scores->{$f}->{hr});
		push @line, $scores->{$f}->{position};

		push @out, \@line;
	}

	return @out;
}
