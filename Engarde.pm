package Engarde;

###############################################################################
#
# Engarde
#
# Engarde - Provides an OO interface to Engarde competition files
#
# Copyright 2007, Peter Smith, psmith@rekar.co.uk
#

# use Exporter;

use strict;
use File::Stat;
use File::Basename;
use Storable qw(dclone);
use Data::Dumper;
use Carp;

use Engarde::Tireur;
use Engarde::Nation;
use Engarde::Club;
use Engarde::Tableau;
# use Engarde::Spreadsheet;
use Engarde::Poule;

use vars qw($VERSION @ISA);
@ISA = qw(Exporter);

$VERSION = '0.01'; 

our $AUTOLOAD;

our $ERRSTR;

sub AUTOLOAD 
{
	my $self = shift;
	my $type = ref($self)
		    or croak "$self is not an object";

	my $name = $AUTOLOAD;
	$name =~ s/.*://;   # strip fully-qualified portion

	# unless (exists $self->{_permitted}->{$name} ) 
	# {
	# croak "Can't access `$name' field in class $type";
	# }

	# if (@_) 
	# {
	# return $self->{$name} = shift;
	# } 
	# else 
	# {
	# return $self->{$name};
	# }
	return $self->{$name};
}  

###############################################################################
#
# constructor
#
###############################################################################

sub new {

	undef $ERRSTR;

    my $class = shift;
	my $file = shift;

	# print "NEW: class = $class\n";
	# print "NEW: file = $file\n";

    my $self  = {};

	unless (-r $file)
	{
		$ERRSTR = "Cannot read file $file";
		return undef;
	}

	$self->{mtime} = (stat($file))[9];

	my $dir = dirname($file);
	$self->{dir} = $dir;

	# print "NEW: dir = $self->{dir}\n";
	
	open IN, "$file" || die $!;

	my $unparsed;
	my $inside;

	# keywords1 have quoted values
	my @keywords1 = qw(titre_reduit titre_ligne organisateur championnat annee titre1 titre2 titre3 titre4);

	# keywords2 have unquoted values
	my @keywords2 = qw(arme categorie sexe);

	while (<IN>)
	{
		chomp;

		if (/^\(def ma_competition/ || $inside)
		{
			# print "NEW: inside, _ = $_\n";

			if (/^\)$/)
			{
				undef $inside;
				next;
			}
			else
			{
				$inside = 1;

				foreach my $key (@keywords1)
				{
					# print "key 1 = $key\n";

					if (/  $key /)
					{
						s/  $key \"//;
						s/\"$//;

						$self->{$key} = $_;
						last;
					}
				}

				foreach my $key (@keywords2)
				{
					# print "key 2 = $key\n";

					if (/  $key /)
					{
						s/  $key //;

						$self->{$key} = $_;
						last;
					}
				}

				# Date is a special case

				if (/  date /)
				{
					s/  date \"~//;
					s/\"$//;

					$self->{date} = $_;
				}

				# As is tableauxactifs

				if (/  tableauxactifs /)
				{
					s/  tableauxactifs \(//;
					s/\)$//;
					s/a//g;

					my @t = split / /,$_;

					my $t = {};

					foreach (@t)
					{
						$t->{$_} = 1;
					}

					$self->{tableauxactifs} = $t;
				}
			}
		}
	}

	close IN;


	$file = "$dir/tour_de_poules.txt";

	open IN, $file;

	# print "NEW: opening $file\n";
	# print "NEW: $!\n";

	while (<IN>)
	{
		# print "NEW: $_\n";
		if ( /nombre_poules/ )
		{
			my $num = $_;
			$num =~ s/.*\[nombre_poules //;
			$num =~ s/\].*//;
			$self->{nombre_poules} = $num;
		}
	}

	close IN;

    bless  $self, $class;
    return $self;
}


#########################################################
#
# initialise all competition info
#
#########################################################

sub initialise
{
	undef $ERRSTR;

	my $c = shift;
	
	$c->tireur;
	$c->nation;
	$c->club;

	my $tab = $c->tableauxactifs;

	foreach my $t (keys (%$tab))
	{
		$c->tableau($t);
	}
}


##################################################
#
# match
#
# returns a specific match from a tableau
#
##################################################

sub match
{
	undef $ERRSTR;

	my $c = shift;
	my $t = shift;
	my $m = shift;

	my $tab = $c->tableau($t);

	my $match = $tab->match($m);

	# print "c = $c, t = $t, m = $m\n";

	my $out = {};

	my $fa = $c->tireur($match->{fencerA}) if $match->{fencerA};
	my $fb = $c->tireur($match->{fencerB}) if $match->{fencerB};

	my $winner = $c->tireur($match->{winner}) if $match->{winner};

	my $ca = $c->club($fa->{club1}) if $fa->{club1};
	my $cb = $c->club($fb->{club1}) if $fb->{club1};

	my $na = $c->nation($fa->{nation}) if $fa->{nation};
	my $nb = $c->nation($fb->{nation}) if $fb->{nation};

	# print "MATCH: winner [$winner] = " . Dumper($winner);

	# print "fencer A = " . Dumper ($fa);

	$out->{fencerA} = $fa->nom if $fa->{nom};
	$out->{fencerB} = $fb->nom if $fb->{nom};

	$out->{winner} = $winner->nom if $winner;
	$out->{scoreA} = $match->{scoreA};
	$out->{scoreB} = $match->{scoreB};
	$out->{piste} = $match->{piste};
	$out->{time} = $match->{time};
	$out->{clubA} = $ca if $ca;
	$out->{clubB} = $cb if $cb;
	$out->{nationA} = $na->nom if $na;
	$out->{nationB} = $nb->nom if $nb;
	$out->{idA} = $match->{fencerA} if $match->{fencerA};
	$out->{idB} = $match->{fencerB} if $match->{fencerB};

	return $out;

}




#################################################
#
# DATA LOAD methods
#
#################################################


#########################################################
#
# loads the fencers and returns a new tireur object
# only load if mtime has changed
#
# return a hash with fencer info if called with id param
#
#########################################################

sub tireur
{
	undef $ERRSTR;

	my $c = shift;	
	my $id = shift;

	# print "TIREUR 1: c = " . Dumper($c);
	# print "TIREUR: id = $id\n" if $id;

	my $dir = $c->dir();

	my $self;
	my $old_mtime = 0;


	if ($c->{tireur})
	{
		$self = $c->{tireur};
		$old_mtime = $self->{mtime};

	}
	else
	{
		$self = {};
		$self->{file} = "$dir/tireur.txt";
		bless $self, "Engarde::Tireur";
	}

	$self->{mtime} = (stat($self->{file}))[9];

	# print "TIREUR 2: " . Dumper(\$self);

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading tireur data...\n";

		$self->load();
		$self->{rangpou} = 0;
		# print Dumper (\$self);
		$c->{tireur} = $self;
	}
	else
	{
		# print "Not loading tireur data...\n";
	}

	if ($id)
	{
		# print "TIREUR: id = $id\n";
		# print "TIREUR: self = " . Dumper(\$self);

		if ($self->{$id})
		{
			# print "TIREUR: self->id = " . Dumper ($self->{$id});
			return $self->{$id};
		}
		else
		{
			# print "TIREUR: returning undef\n";
			return undef;
		}
	}
	else
	{
		return $self;
	}
}


sub nation
{
	undef $ERRSTR;

	my $c = shift;	
	my $id = shift;
	my $dir = $c->dir();

	my $self;
	my $old_mtime = 0;

	if ($c->{nation})
	{
		$self = $c->{nation};
		$old_mtime = $self->mtime();
	}
	else
	{
		$self = {};
		$self->{file} = "$dir/nation.txt";
		bless $self, "Engarde::Nation";
	}

	$self->{mtime} = (stat($self->{file}))[9];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading nation data...\n";
		$self->load();
		$c->{nation} = $self;
	}
	else
	{
		# print "Not loading nation data...\n";
	}

	if ($id)
	{
		return $self->{$id}->{nom};
	}
	else
	{
		return $self;
	}
}


sub club
{
	undef $ERRSTR;


	my $c = shift;	
	my $id = shift;
	my $dir = $c->dir();

	# print "inside club id = $id, c = $c\n";

	my $self;
	my $old_mtime = 0;

	if ($c->{club})
	{
		$self = $c->{club};
		$old_mtime = $self->mtime();
	}
	else
	{
		$self = {};
		$self->{file} = "$dir/club.txt";
		bless $self, "Engarde::Club";
	}

	$self->{mtime} = (stat($self->{file}))[9];

	if ($self->{mtime} > $old_mtime)
	{
		# print "Loading club data...\n";
		$self->load();
		$c->{club} = $self;
	}
	else
	{
		# print "Not loading club data...\n";
	}

	if ($id)
	{
		return $self->{$id}->{nom};
	}
	else
	{
		return $self;
	}
}


sub tableau
{
	undef $ERRSTR;

	my $c = shift;
	my $level = shift;
	my $decode = shift;

	my $dir = $c->dir();

	my $self;
	my $old_mtime = 0;

	my $t = "tableauA$level";

	if ($c->{$t})
	{
		$self = $c->{$t};
		$old_mtime = $self->mtime();
	}
	else
	{
		$self = {};
		$self->{file} = "$dir/$t.txt";
		$self->{level} = $level;
		bless $self, "Engarde::Tableau";
	}

	$self->{mtime} = (stat($self->{file}))[9];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading $t data...\n";

		$self->load($level);
		$c->{$t} = $self;
	}
	else
	{
		# print "Not loading $t data...\n";
	}

	return $self unless $decode;

	my $decoded = {};

	foreach my $m (keys %$self)
	{
		if ($m =~ /\d+/)
		{
			my $match = $c->match($level, $m);

			# print "m = $m\n";
			# print "old match = " . Dumper(\$self->{$m});
			# print "new match = " . Dumper(\$match);

			$decoded->{$m} = $match;
		}
		elsif ($m =~ /etat/)
		{
			$decoded->{etat} = $self->{etat};
		}
	}

	return $decoded;
}


sub poule
{
	undef $ERRSTR;

	my $c = shift;
	my $round = shift;
	my $poule = shift;

	my $dir = $c->dir;
	my $self;
	my $old_mtime = 0;
	my $p = "pouleT${round}P${poule}";

	if ($c->{$p})
	{
		$self = $c->{$p};
		$old_mtime = $self->mtime();
	}
	else
	{
		$self = {};
		$self->{file} = "$dir/$p.txt";
		bless $self, "Engarde::Poule";
	}

	$self->{mtime} = (stat($self->{file}))[9];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		print "Loading $round, $poule data...\n";
		$self->load;
		$c->{$p} = $self;
	}
	else
	{
		# print "Not loading $t data...\n";
	}

	return $self;
}


sub ranking
{
	# load clas_fin_poules.txt or clastab_initial.txt
	
	my $c = shift;
	# o = overall, p = after pools
	my $type = shift || "o";

	# print "RANKING: type = $type\n";

	my $seeds = {};

	my $dir = $c->dir;

	my $file = "$dir/claspou_fin_1.txt";

	# my $file = $type eq "p" ? "$dir/claspou_fin_1.txt" : "$dir/clastab_initial.txt";

	open RANKING, $file || return undef;

	while (<RANKING>)
	{
		# group ; rank ; id ; v ; m ; hs ; hr
		# q;1;160;6;6;30;8;
		
		chomp;

		# print "$_\n";

		my @result = split /;/, $_;

		my $t = $c->tireur($result[2]);

		if (($result[0] ne "q" && $type eq "o") || $type eq "p")
		{
			my $ind = $result[5] - $result[6];
			my $name = $t->nom;
			my $cid = $t->club;
			my $club = $cid ? $c->club($cid) : "";
			my $nid = $t->nation;
			my $nation = $nid ? $c->nation($nid) : "";
			my $serie = $t->serie;
	
			$seeds->{$result[2]} = { group=>$result[0], nom=>$name, club=>$club, nation=>$nation, 
								 	 v=>$result[4], m=>$result[3], hs=>$result[5], hr=>$result[6], 
									 ind=>$ind, seed=>$result[1], serie=>$serie };
		}
		else
		{
			# if this is a ranking after the pools or an eliminated fencer,
			# we just use the ranking after the pools value
			$t->rangpou($result[1]);
		}
	}

	# print Dumper($seeds);

	close RANKING;

	my $ranking = {};

	if ($type eq "o")
	{
		my $tab = $c->tableauxactifs;

		# for each complete round
		# 	find eliminated fencers
		# 	sort into tableau seeding order
		# 	rank according to sort order
		# end

		foreach my $t (sort { $b <=> $a } keys (%$tab))
		{
			my $round = $c->tableau($t);
			my $etat = $round->etat;

			# print "round = $t, etat = $etat\n";

			if ($etat eq "termine")
			{
				unless ($t == 2)
				{
					my $eliminated = $round->eliminated;
					# print "round = $t, " . Dumper ($eliminated);
					my $next_rang = ($t / 2);
					$next_rang++; 
	
					my $elim = {};	# eliminated this round
	
					foreach my $e (@$eliminated)
					{
						my $t = $c->tireur($e);
						my $rang = $t->rangpou;
						my $nom = $t->nom;
						my $clubid = $t->club;
						my $club = $clubid ? $c->club($clubid) : "";
						my $nationid = $t->nation;
						my $nation = $nationid ? $c->nation($nationid) : "";

						# print "e = $e, rangpou = $rang\n";

						$elim->{$e} = {nom=>$nom, nation=>$nation, club=>$club, rangpou=>$rang}; 
					}

					my $current_rang = $next_rang-1;
					my $last_rang = 0;

					foreach my $e (sort { $elim->{$a}->{rangpou} <=> $elim->{$b}->{rangpou}} keys(%$elim))
					{
						my $rangpou = $elim->{$e}->{rangpou};
	
						$current_rang = $next_rang if $rangpou > $last_rang;
						$next_rang++;
						$last_rang = $rangpou;
	
						$seeds->{$e} = $elim->{$e};
						$seeds->{$e}->{seed} = $current_rang;

						# print "e = $e, ranking = $current_rang, next = $next_rang\n";
					}
				}
				else
				{
					my $final = $c->match(2,1);
					# print "final = " . Dumper($final);

					if ($final->{winner} eq $final->{fencerA})
					{
						$seeds->{$final->{idA}} = {nom=>$final->{fencerA}, nation=>$final->{nationA}, club=>$final->{clubA}, seed=>1}; 
						$seeds->{$final->{idB}} = {nom=>$final->{fencerB}, nation=>$final->{nationB}, club=>$final->{clubB}, seed=>2}; 
					}
					else
					{
						$seeds->{$final->{idA}} = {nom=>$final->{fencerA}, nation=>$final->{nationA}, club=>$final->{clubA}, seed=>2}; 
						$seeds->{$final->{idB}} = {nom=>$final->{fencerB}, nation=>$final->{nationB}, club=>$final->{clubB}, seed=>1}; 
					}

				}
			}
		}
	}

	# print Dumper ($ranking);
	return $seeds;
}

# fencers, poules, pistes
sub fpp
{
	my $c = shift;

	my $output = {};

	my $num = $c->nombre_poules;

	# print "FPP: nombre_poules = $num\n";

	my $i = 1;

	while ($i<=$num)
	{
		# assume only one round of poules for now
		my $p = $c->poule(1, $i);
		# print Dumper($p);

		my $tir = $p->les_tir_cons;

		foreach my $id (@$tir)
		{
			my $f = $c->tireur($id);

			my $club = $c->club($f->club);
			my $nom = $f->nom;
			my $serie = $f->serie;
			my $nation = $f->nation ? $c->nation($f->nation) : "";
			my $heure = $p->heure;
			my $piste_no = $p->piste_no;

			# print "FPP: id = $id, club = $club " . Dumper($f);
			
			$output->{$id} = { nom=>$nom, club=>$club, serie=>$serie, nation=>$nation, poule=>$i, heure=>$heure, piste_no=>$piste_no };
		}
		$i++;
	}

	return $output;
}

sub spreadsheet
{
	undef $ERRSTR;

	my $self = shift;
	my $name = shift;

	# print "spreadsheet: name = $name\n";
	# print "spreadsheet: _ = @_\n";

	return Engarde::Spreadsheet::writeL32($self, $name);
}



sub html
{
	my $self = shift;

	my $options = shift;
	# my $level = shift;
	# my $end = shift;

	my $level = $options->{level};
	my $end_level = $options->{end};
	my $style = $options->{style};

	my $active = $self->tableauxactifs;

	# print "HTML: options = " . Dumper($options);

	my $no_results = "<div align=\"center\">\n<p /><p />\nThere are no currently no results for this stage</div>";

	return $no_results unless exists $active->{$level};

	# print "HTML: self = " . Dumper($self);

	my $out;
	my $match = 1;

	my @weapons = ("we", "me", "wf", "mf", "ws", "ms");

	my @levels = ("pool", "16", "8", "4", "2");
	my %level_names = (
				pool => "Pool", 
				64 => "Tableau of 64", 
				32 => "Tableau of 32", 
				16 => "Tableau of 16", 
				8 => "Tableau of 8", 
				4 => "Semi Final", 
				2 => "Final"
			);


	my %order = ( 
				128 => [undef, 	1, 128, 64, 65, 33, 96, 32, 97, 17, 128, 48, 128, 49, 128, 16, 128, 
								9, 128, 56, 128, 41, 128, 24, 128, 25, 128, 40, 128, 57, 128, 8, 128, 
							   	5, 128, 60, 128, 37, 128, 28, 128, 21, 128, 44, 128, 53, 128, 12, 128, 
								13, 128, 52, 128, 45, 128, 20, 128, 29, 128, 36, 128, 61, 128, 4, 128, 
								3, 128, 62, 128, 35, 128, 30, 128, 19, 128, 46, 128, 51, 128, 14, 128, 
								11, 128, 54, 128, 43, 128, 22, 128, 27, 128, 38, 128, 59, 128, 6, 128, 
								7, 128, 58, 128, 39, 128, 26, 128, 23, 128, 42, 128, 55, 128, 10, 128, 
								15, 128, 50, 128, 47, 128, 18, 128, 31, 128, 34, 128, 63, 128, 2],
				64 => [undef, 	1, 64, 33, 32, 17, 48, 49, 16, 
								9, 56, 41, 24, 25, 40, 57, 8, 
								5, 60, 37, 28, 21, 44, 53, 12, 
								13, 52, 45, 20, 29, 36, 61, 4, 
								3, 62, 35, 30, 19, 46, 51, 14, 
								11, 54, 43, 22, 27, 38, 59, 6, 
								7, 58, 39, 26, 23, 42, 55, 10, 
								15, 50, 47, 18, 31, 34, 63, 2],
				32 => [undef, 	1, 32, 17, 16, 9, 24, 25, 8, 
								5, 28, 21, 12, 13, 20, 29, 4, 
								3, 30, 19, 14, 11, 22, 27, 6, 
								7, 26, 23, 10, 15, 18, 31, 2],
				16 => [undef, 	1, 16, 9, 8, 
								5, 12, 13, 4, 
								3, 14, 11, 6, 
								7, 10, 15, 2],
				8 => [undef, 	1, 8, 5, 4, 3, 6, 7, 2],
				4 => [undef, 	1, 4, 3, 2],
				2 => [undef, 	1, 2]
			);


	my %names = ( 	we => "Womens Epee",
					me => "Mens Epee",	
					wf => "Womens Foil",	
					mf => "Mens Foil",	
					ws => "Womens Sabre",	
					ms => "Mens Sabre"	);

	my $end = $level/2;

	# print Dumper(\%tableau);

	unless (defined $level)
	{
		# add_output("No results for tableau");
		return undef;
	}

	$out = "<table cellspacing=0 summary=\"$level_names{$level}\">\n";
  	$out .= "<col width=20>\n";
  	$out .= "<col width=200>\n";
  	$out .= "<col width=30>\n";
  	$out .= "<col width=200>\n";

	while ($match <= $end)
	{
		my $m = $self->match($level, $match);

		# print "HTML: match = $match, m = " . Dumper($m);

		my $A = $m->{'fencerA'} || "";
		my $B = $m->{'fencerB'} || "";
		my $scoreA = $m->{'scoreA'};
		my $scoreB = $m->{'scoreB'};
		my $winner = $m->{'winner'};

		my $cA = $m->{clubA} || $m->{nationA} || "";
		my $cB = $m->{clubB} || $m->{nationB} || "";

		#add_output("A = $A");
		#add_output("B = $B");
		#add_output("scoreA = $scoreA");
		#add_output("scoreB = $scoreB");

		# Fencer A
		$out .= "<tr>\n";
		$out .= "<td align=right>$order{$level}[($match*2)-1]&nbsp;</td>\n"; 
  		$out .= "<td bgcolor=\"#B8D9DC\">&nbsp;$A</td>";
  		$out .= "<td bgcolor=\"#B8D9DC\">&nbsp;$cA</td>\n";
		$out .= "</tr>\n";

		# Winner
		$out .= "<tr>\n";
  		$out .= "<td>&nbsp;</td>\n";
  		$out .= "<td>&nbsp;</td>\n";
  		$out .= "<td>&nbsp;</td>\n";

		if ($winner)
		{
  			$out .= "<td bgcolor=\"#FFCCCC\">&nbsp;$winner</td>\n";
		}
		else
		{
  			$out .= "<td bgcolor=\"#FFCCCC\">&nbsp;</td>\n";
		}

		$out .= "</tr>\n";

		# Fencer B
		$out .= "<tr>\n";
		$out .= "<td align=right>$order{$level}[$match*2]&nbsp;</td>\n"; 
  		$out .= "<td bgcolor=\"#B8D9DC\">&nbsp;$B</td>";
  		$out .= "<td bgcolor=\"#B8D9DC\">&nbsp;$cB</td>\n";

		if ($winner && $scoreA ne "" && $scoreB ne "")
		{
  			$out .= "<td>&nbsp;&nbsp;&nbsp;$scoreA/$scoreB</td>\n";
		}
		else
		{
			$out .= "<td>&nbsp;</td>";
		}

		$out .= "</tr>\n";

		# Blank
		$out .= "<tr height=25>\n<td>&nbsp;</td>\n</tr>\n";

		$match++;
	}

	$out .= "</table>\n";

	return $out;
}



sub load 
{
	undef $ERRSTR;

    my $self = shift;	

	my $file = $self->{file};

	# print "LOAD: " . Dumper(\$self);

	open IN, "$file" || die $!;
	my $unparsed;

	while (<IN>)
	{
		chomp;
	
		if (/^\{\[classe / && $unparsed)
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
}


############################################################
#
# Custom accessor methods
#
############################################################

sub arme
{
	my $self = shift;
	return substr($self->{arme},0,1);
}

sub sexe
{
	my $self = shift;
	return $self->{sexe} eq "masculin" ? "m" : "f";
}


1;


__END__

