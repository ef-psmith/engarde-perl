# vim: ts=4 sw=4 noet:
package Engarde;

###############################################################################
#
# Engarde
#
# Engarde - Provides an OO interface to Engarde competition files
#
# Copyright 2007-2013, Peter Smith, peter.smith@englandfencing.org.uk
#

# use Exporter;

use strict;
use Data::Dumper;
use Carp qw(croak cluck);
use Scalar::Util qw(weaken);
use Fcntl qw(:flock);

use Engarde::Tireur;
use Engarde::Nation;
use Engarde::Club;
use Engarde::Tableau;
# use Engarde::Spreadsheet;
use Engarde::Poule;
use Engarde::Arbitre;
use Time::Local;
# use HTML::Entities;
our $DEBUGGING = 0;

use vars qw($VERSION @ISA $ta);
@ISA = qw(Exporter);

our @EXPORT = qw(debug);

$VERSION = '1.22'; 

my %order = ( 
			128 => [undef, 	1, 128, 65, 64, 33, 96, 97, 32, 17, 112, 81, 48, 49, 80, 113, 16, 
							9, 120, 73, 56, 41, 88, 105, 24, 25, 104, 89, 40, 57, 72, 121, 8, 
						   	5, 124, 69, 60, 37, 92, 101, 28, 21, 108, 85, 44, 53, 76, 117, 12,
							13, 116, 77, 52, 45, 84, 109, 20, 29, 100, 93, 36, 61, 68, 125, 4,
							3, 126, 67, 62, 35, 94, 99, 30, 19, 110, 83, 46, 51, 78, 115, 14,
							11, 118, 75, 54, 43, 86, 107, 22, 27, 102, 91, 38, 59, 70, 123, 6,
							7, 122, 71, 58, 39, 90, 103, 26, 23, 106, 87, 42, 55, 74, 119, 10,
							15, 114, 79, 50, 47, 82, 111, 18, 31, 98, 95, 34, 63, 66, 127, 2],
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



our $AUTOLOAD;

sub AUTOLOAD 
{
	my $self = shift;
	my $type = ref($self) or croak "$self is not an object";

	my $name = $AUTOLOAD;
	$name =~ s/.*://;   # strip fully-qualified portion

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

sub parent
{
	my $self = shift; 
	@_ ? weaken($self->{parent} = shift) : $self->{parent};
}

###############################################################################
#
# constructor
#
###############################################################################

sub new {

	my $class = shift;
	my $file = shift;
	my $quick = shift || 0;

	# print "NEW: class = $class\n";
	debug(1,"new(): processing file $file");

	my $self  = {};

	$file .= "/competition.egw" if (-d $file);
	
	unless (-r $file)
	{
		debug(1, "new(): Cannot read file $file");
		return undef;
	}

	$self->{mtime} = (stat($file))[9];
	$self->{ctime} = (stat($file))[10];

	my $dir = $file; 
	
	$dir =~ s/[\\\/]competition.egw//;

	$self->{dir} = $dir;

	open IN, "$file" or die "cannot open $file: $!";

	my $unparsed;
	my $inside;

	while (<IN>)
	{
		chomp;

		s///g;
		
		if ((/^\(def ma_competition/ || /^\(def ma_formule/ || $inside))
		{
			if (/^\)$/)
			{
				undef $inside;
				next;
			}
			else
			{
				$inside = 1;

				if (/  date /)
				{
					s/  date \"~//;
					s/\"$//;

					$self->{date} = $_;
				}
				else
				{
					next if /  classe /;
					next if /  tableauxactifs /;
					next if /  contexte /;

					my ($key, $value) = m/  (.*?) (.*)/;
					$value =~ s/[\"\(\)]*//g if $value;
					next unless $value;
					$self->{$key} = $value;
				}
			}
		}
	}

	close IN;

    bless  $self, $class;

	$self->_init_tableaux unless $quick > 1;	
	$self->_init_poules unless $quick > 1;
	$self->initialise unless $quick;

    return $self;
}


sub _init_poules
{
	my $self = shift;

	my $dir = $self->dir;
	#
	# Poules
	#
	my $file = "$dir/tour_de_poules.txt";

	if (-r $file)
	{
		open IN, $file;

		# print "NEW: opening $file\n";
		# print "NEW: $!\n";

		my @nump;
		my @exempt;

		while (<IN>)
		{
			chomp;
			# print "NEW: $_\n";
			#
			s///g;

			if ( /nombre_poules/ )
			{
				my $num = $_;
				$num =~ s/.*\[nombre_poules //;
				$num =~ s/\].*//;
				push @nump, $num;
			}

			if ( /entites_exemptees/ )
			{
				my $num = $_;
				$num =~ s/.*\[entites_exemptees //;
				$num =~ s/\].*//;
				push @exempt, $num;
			}
		}

		$self->{nombre_poules} = \@nump;
		$self->{entites_exemptees} = \@exempt;
		$self->{nombre_tour} = scalar @nump;

		close IN;
	}
}


sub _init_tableaux
{
	my $self = shift;

	my $dir = $self->dir;

	# 
	# Tableaux
	#
	my $file = "$dir/description_tableau.txt";

	if (-r $file)
	{
		open IN, $file;

		# {[classe description_tableau] [suite a] [nom a64] [nom_etendu "prelimenary tableau of 64"]
 		# [cle 1] [nombre_entites 64] [taille 64] [destination_vainqueurs b64] [classe_apres
 		# (b64 b32 b16 b8 b4 b2)] [groupe_clasmt_battus 8] [rang_premier_battu 65]}

		my $unparsed;
		while (<IN>)
		{
			chomp;

			s///g;

			print STDERR "DEBUG: _init_tableaux(): _ = $_\n" if $DEBUGGING > 1;

			if (/\[classe description_tableau/ && $unparsed)
			{
				my $item = _decode_tableau($unparsed);

				if ($item->{nom})
				{
					print STDERR "DEBUG: _init_tableaux(): adding " . $item->{nom} . " to tableauxactifs\n" if $DEBUGGING > 1;
					$self->{tableauxactifs}->{$item->{nom}} = $item unless $item->{inactif};
				}

				s/.*classe description_tableau\] //;
				$unparsed = $_;
			}
			else
			{
				s/.*classe description_tableau\] //;
				$unparsed .= $_;
				print STDERR "DEBUG: _init_tableaux(): fall through: unparsed = $_\n" if $DEBUGGING > 1;
			}
		}

		if ($unparsed)
		{
			my $item = _decode_tableau($unparsed);

			if ($item->{nom})
			{
				print STDERR "DEBUG: _init_tableaux(): adding " . $item->{nom} . " to tableauxactifs\n" if $DEBUGGING > 1;
				$self->{tableauxactifs}->{$item->{nom}} = $item unless $item->{inactif};
			}
		}

		close IN;
	}

	print STDERR "DEBUG: _init_tableau(): tableauxactifs = " . Dumper($self->{tableauxactifs}) if $DEBUGGING > 1;
}


sub _decode_tableau
{
	my $unparsed = shift;

	# do something with $unparsed

	$unparsed =~ s/^\[//;
	$unparsed =~ s/\}$//;

	my $item = {};
	my @elements = split /[ \]]*\[/, $unparsed;

	# print STDERR "DEBUG: new(): elements = @elements\n" if $DEBUGGING;

	foreach (@elements)
	{
		my @keywords = qw/suite nom nom_etendu rang_premier_battu inactif taille destination_vainqueurs destination_battus/;

		s/\]//;

		print STDERR "DEBUG: _decode_tableau(): element = $_\n" if $DEBUGGING > 1;

		foreach my $key (@keywords)
		{
			# print "\tkey = $key _=[$_]\n";
			if (/^$key /)
			{
				s/$key //;
				s/\"//g;
				s/\]//;

				# print "\tvalue = $_\n";
				$item->{$key} = $_;
			}
		}
	}

	$item->{nom} = uc($item->{nom});
	$item->{destination_vainqueurs} = uc($item->{destination_vainqueurs}) if $item->{destination_vainqueurs};
	$item->{destination_battus} = uc($item->{destination_battus}) if $item->{destination_battus};

	return $item;
}


#########################################################
#
# initialise basic competition info
#
#########################################################

sub initialise
{
	my $c = shift;

	# $c->_init_poules;
	# $c->_init_tableaux;	

	$c->tireur;
	$c->nation;
	$c->club;

	# my $tab = $c->tableauxactifs;

	# print Dumper(\$tab);

	# foreach my $s (keys (%$tab))
	# {
		#my $t = $c->tableau($s);
		# $c->tableau($s);
		# }
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
	my $c = shift;
	my $t = shift;
	my $m = shift;

	my $tab = $c->tableau($t);

	return undef unless $tab;

	my $match = $tab->match($m);

	#print "\nEngarde::match: t = $t, m = $m\n";
	#cluck ("Engarde::match: tab match data = " . Dumper(\$match));

	my $out = {};

	my $fa = $c->tireur($match->{idA}) if $match->{idA};
	my $fb = $c->tireur($match->{idB}) if $match->{idB};

	# print "match: fa = " . Dumper (\$fa);
	# print "match: fb = " . Dumper (\$fb);

	my $winner = $c->tireur($match->{winnerid}) if $match->{winnerid};

	#print "match: winner = $match->{winnerid}\n";
	#print "match: winner = " . Dumper(\$winnerid);

	my $ca = $c->club($fa->{club1}) if $fa->{club1};
	my $cb = $c->club($fb->{club1}) if $fb->{club1};

	my $na = $c->nation($fa->{nation1}) if $fa->{nation1};
	my $nb = $c->nation($fb->{nation1}) if $fb->{nation1};

	# print "MATCH: winner [$winnerid] = " . Dumper($winner);

	# print "fencer A = " . Dumper ($fa);

	$out->{fencerA} = $fa->nom if $fa->{nom};
	$out->{fencerB} = $fb->nom if $fb->{nom};

	$out->{fencerA_court} = $fa->nom_court if $fa->{nom};
	$out->{fencerB_court} = $fb->nom_court if $fb->{nom};

	$out->{winnername} = $winner->nom if $winner;
	$out->{winnerid} = $match->{winnerid};
	$out->{scoreA} = $match->{scoreA};
	$out->{scoreB} = $match->{scoreB};
	$out->{piste} = $match->{piste};
	$out->{time} = $match->{time};
	$out->{clubA} = $ca if $ca;
	$out->{clubB} = $cb if $cb;
	$out->{nationA} = $na if $na;
	$out->{nationB} = $nb if $nb;
	$out->{idA} = $match->{idA} if $match->{idA};
	$out->{idB} = $match->{idB} if $match->{idB};
	
	$out->{categoryA} = $fa->{category};
	$out->{categoryB} = $fb->{category};
	
	if (defined $match->{'time'})
	{
		$out->{start_time} = _heure_to_time($match->{time});
	}
	else
	{
		$out->{start_time} = $tab->ctime + 900;		# 15 minutes after tableau creation
	}

	$out->{end_time} = $out->{start_time} + 1200;	# 20 minutes after start

	my $size = $tab->taille;

	if ($size <= 128)
	{
		# print "MATCH: size = $size, order = ". Dumper(\$order{$size});
		$out->{seedA} = ${$order{$size}}[($m*2)-1];
		$out->{seedB} = ${$order{$size}}[$m*2];
	}
	# print "match returning: " . Dumper(\$out);

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
	my $c = shift;	
	my $id = shift;

	# print "TIREUR 1: c = " . Dumper($c);
	# print "TIREUR: id = $id\n" if $id;

	my $dir = $c->dir();

	# print "tireur: dir = $dir\n";

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
		$self->{dir} = $dir;
		
		bless $self, "Engarde::Tireur";
	}

	$self->{mtime} = (stat($self->{file}))[9];
	$self->{ctime} = (stat($self->{file}))[10];

	# print "TIREUR 2: " . Dumper(\$self);

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading tireur data...\n";

		$self->load();
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
		$self->{dir} = $dir;
		
		bless $self, "Engarde::Nation";
	}

	$self->{mtime} = (stat($self->{file}))[9];
	$self->{ctime} = (stat($self->{file}))[10];

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
		$self->{dir} = $dir;
		
		bless $self, "Engarde::Club";
	}

	$self->{mtime} = (stat($self->{file}))[9];
	$self->{ctime} = (stat($self->{file}))[10];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
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
	my $c = shift;
	my $level = uc(shift);
	my $decode = shift;

	my $suite = substr($level,0,1);
	my $num = substr($level,1) || cluck();

	my $dir = $c->dir();

	my $self;
	my $old_mtime = 0;

	print STDERR "DEBUG: tableau(): procesing $level\n" if $DEBUGGING > 1;

	if ($c->{tableau}->{$level})
	{
		print STDERR "DEBUG: tableau(): level $level exists\n" if $DEBUGGING > 1;
		$self = $c->{tableau}->{$level};
		$old_mtime = $self->mtime();
	}
	else
	{
		print STDERR "DEBUG: tableau(): level $level does not exist yet\n" if $DEBUGGING > 1;
		$self = {};
		$self->{file} = "$dir/tableau$level.txt";
		$self->{nom} = $level;
		$self->{level} = $level;
		$self->{nom_etendu} = $c->{tableauxactifs}->{$level}->{nom_etendu};
		$self->{rang_premier_battu} = $c->{tableauxactifs}->{$level}->{rang_premier_battu};
		$self->{destination_vainqueurs} = $c->{tableauxactifs}->{$level}->{destination_vainqueurs};

		if ( $c->{tableauxactifs}->{$level}->{destination_battus})
		{
			print STDERR "DEBUG: destination_battus = " . $c->{tableauxactifs}->{$level}->{destination_battus} . "\n";
			$self->{destination_battus} = $c->{tableauxactifs}->{$level}->{destination_battus};
			$c->{tableauxactifs}->{$self->{destination_battus}}->{is_rep} = 1;
		}

		$self->{taille} = $c->{tableauxactifs}->{$level}->{taille};
		$self->{suite} = uc($c->{tableauxactifs}->{$level}->{suite});
		$self->{is_rep} = $c->{tableauxactifs}->{$level}->{is_rep};

		bless $self, "Engarde::Tableau";

		$self->parent($c);
	}

	unless (-r $self->{file})
	{
		print STDERR "DEBUG: tableau() cannot read " . $self->{file} . "\n" if $DEBUGGING;
		return undef;
	}

	$self->{mtime} = (stat("$self->{file}"))[9];
	$self->{ctime} = (stat("$self->{file}"))[10];

	print STDERR "DEBUG: tableau(): mtime = $self->{mtime}\n" if $DEBUGGING > 1;

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		print STDERR "DEBUG: tableau(): re-loading level $level\n" if $DEBUGGING > 1;
		# print "Loading $level data...\n";
		$self->load($level);
		$c->{tableau}->{$level} = $self;
	}
	else
	{
		print STDERR "DEBUG: tableau(): not re-loading level $level\n" if $DEBUGGING > 1;
		# print "Not loading $level data...\n";
	}

	return undef unless $self->etat();

	return $self unless $decode;

	print STDERR "DEBUG: tableau(): decoding level $level\n" if $DEBUGGING > 1;
	print STDERR "DEBUG: tableau(): level $level = " , Dumper(\$self) if $DEBUGGING > 1;

	foreach my $m (keys %$self)
	{
		if ($m =~ /\d+/)
		{
			print STDERR "DEBUG: tableau(): decoding $level match $m\n" if $DEBUGGING > 1;
			my $match = $c->match($level, $m);

			# print "m = $m\n";
			# print "old match = " . Dumper(\$self->{$m});
			# print STDERR "new match = " . Dumper(\$match);

			$self->{$m} = $match;
		}
	}

	return $self;
}

sub poules
{
	# return a selection of poules 
	my $c = shift;
	my $round = shift || 1;
	my @poules = @_;
	
	my $out = {};
	
	foreach my $pn (@poules)
	{
		my $p = $c->poule($round, $pn);
		$out->{$pn} = $p;
		
		delete $out->{$pn}->{parent};
	}
	
	return $out;
}

sub poule
{
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
		return undef unless -f "$dir/$p.txt";

		$self = {};
		$self->{file} = "$dir/$p.txt";
		bless $self, "Engarde::Poule";

		$self->parent($c);
	}

	$self->{mtime} = (stat($self->{file}))[9];
	$self->{ctime} = (stat($self->{file}))[10];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading $round, $poule data...\n";
		$self->load;
		$c->{$p} = $self;
	}
	else
	{
		# print "Not loading $round data...\n";
	}

	return $self;
}


sub arbitre 
{
	my $c = shift;
	my $id = shift;

	my $dir = $c->dir;
	my $self;
	my $old_mtime = 0;
	my $a = "arbitre";

	if ($c->{$a})
	{
		$self = $c->{$a};
		$old_mtime = $self->mtime();
	}
	else
	{
		return undef unless -f "$dir/$a.txt";

		$self = {};
		$self->{file} = "$dir/$a.txt";
		bless $self, "Engarde::Arbitre";
	}

	$self->{mtime} = (stat($self->{file}))[9];
	$self->{ctime} = (stat($self->{file}))[10];

	if ($self->{mtime} && $self->{mtime} > $old_mtime)
	{
		# print "Loading arbitre data...\n";
		$self->load;
		$c->{$a} = $self;
	}
	else
	{
		# print "Not loading arbitre data...\n";
	}


	if ($id)
	{
		return $self->{$id};
	}
	else
	{
		return $self;
	}
}


# 
# Currently this is not multi-round safe
# It needs to process clas_fin_poules.txt if all rounds of poules are finished
#
sub ranking
{
	# need to load clastab_initial.txt since it includes fencers with byes
	# and claspou_fin_1.txt for e and a types

	# print "RANKING: starting\n";
	
	my $c = shift;
	# o = overall, p = after pools
	my $type = shift || "o";
	my $round = shift || $c->nombre_tour;

	# sanity check
	if ($type eq "p")
	{
		my $where = $c->whereami;

		my @w = split / /, $where;

		return undef unless ($w[0] eq "tableau" || (defined($w[1]) && $w[1] >= $round) || $w[0] eq "termine");
	}
	
	my $exempt = $c->entites_exemptees;
	
	my $ex = $$exempt[$round-1] || 0;

	# print "Engarde:ranking: ex = $ex\n";

	my $seeds = {};

	my $dir = $c->dir;

	my $current_round = 1;
	while ($current_round <= $round)
	{
		my $file = "$dir/claspou_fin_$current_round.txt";

		# print "ranking: file = $file, round = $current_round\n";
			
		-s $file || return undef;

		open RANKING, $file || return undef;

		while (<RANKING>)
		{
			# group ; rank ; id ; v ; m ; hs ; hr
			# q;1;160;6;6;30;8;
			
			chomp;
			s///g;
	
			my @result = split /;/, $_;
	
			if ($result[0] eq "e" || $result[0] eq "a" || ($type eq "p" && $current_round == $round))
			{
				# either fencer is eliminated, abandoned or we just need a ranking after the poules
				my $t = $c->tireur($result[2]);
	
				my $ind = $result[5] - $result[6];
				my $name = $t->nom;
				my $shortname = $t->nom_court;
				my $category = $t->category;
				my $cid = $t->club;
				my $club = $cid ? $c->club($cid) : "";
				my $nid = $t->nation;
				my $nation = $nid ? $c->nation($nid) : "";
				my $serie = $t->serie;
				my $group = $result[0] eq "e" ? "elim_p" : "";
	
				$seeds->{$result[2]} = { group=>$group , nom=>$name, nom_court=>$shortname, club=>$club, nation=>$nation, 
							 	 	v=>$result[4], m=>$result[3], vm=>"$result[4]/$result[3]", hs=>$result[5], hr=>$result[6], 
								 	ind=>"$ind", seed=>$result[1]+$ex, serie=>$serie, category=>$category };
			}
		}

		close RANKING;
		$current_round++;
	}

	if ($type eq "o")
	{
		my $file = "$dir/clastab_initial.txt";

		open RANKING, $file || return undef;

		while (<RANKING>)
		{
			# group ; rank ; id ; v ; m ; hs ; hr
			# q;1;160;6;6;30;8;
			
			chomp;
			s///g;
	
			my @result = split /;/, $_;
	
			if ($result[0] eq "q" || $result[0] eq "x")
			{
				my $t = $c->tireur($result[2]);
				$t->rangpou($result[1]);
			}
		}

		# print Dumper($seeds);
	
		close RANKING;

		my $ranking = {};

		my @tab = $c->tableaux;

		# for each complete round
		# 	find eliminated fencers
		# 	sort into tableau seeding order
		# 	rank according to sort order
		# end

		foreach my $t (@tab)
		{
			my $round = $c->tableau($t);

			my $etat = $round->etat;

			print STDERR "DEBUG: ranking(): round $t, etat = $etat\n" if $DEBUGGING > 1;

			next unless $etat eq "termine";

			# print "RANKING: round = " . Dumper(\$round);

			my $taille = $round->taille;

			my $eliminated = $round->eliminated;

			debug(1, "ranking(): eliminated = " . Dumper(\$eliminated));

			my $next_rang = $round->rang_premier_battu;

			next unless $next_rang;

			my $elim = {};	# eliminated this round

			foreach my $e (@$eliminated)
			{
				my $t = $c->tireur($e);
				# debug(2, "ranking(): eliminated $e = " . Dumper(\$t));

				my $rang = $t->rangpou;
				my $nom = $t->nom;
				my $category = $t->category;
				my $nom_court = $t->nom_court;
				my $clubid = $t->club;
				my $club = $clubid ? $c->club($clubid) : "";
				my $nationid = $t->nation;
				my $nation = $nationid ? $c->nation($nationid) : "";

				# do something unless $rang for those with byes...

				$elim->{$e} = {nom=>$nom, nom_court=>$nom_court, nation=>$nation, club=>$club, rangpou=>$rang, group=>"elim_$taille", category=>$category}; 
			}

			my $current_rang = $next_rang-1;
			my $last_rang = 0;

			foreach my $e (sort { $elim->{$a}->{rangpou} <=> $elim->{$b}->{rangpou}} keys(%$elim))
			{
				# debug(2,"ranking(): e = " . Dumper(\$e));

				my $rangpou = $elim->{$e}->{rangpou};

				$current_rang = $next_rang if $rangpou > $last_rang;
				$next_rang++;
				$last_rang = $rangpou;

				$seeds->{$e} = $elim->{$e};
				$seeds->{$e}->{seed} = $current_rang;
				$seeds->{$e}->{seed} = 3 if $current_rang == 4;
			}
			debug(2, "ranking(): seeds = " . Dumper(\$seeds));

			if ($taille == 2)
			{
				# cluck "RANKING: getting winner\n";

				my $m = $c->match($t,1);
				# my $m = $round->match(1);

				# print "RANKING: match 1 = " . Dumper(\$m);

				my $nom = $m->{winnername} || "";

				my $nation = defined($m->{idA}) && $nom eq $m->{fencerA} ? $m->{nationA} : $m->{nationB};
				my $club = defined($m->{idB}) && $nom eq $m->{fencerA} ? $m->{clubA} : $m->{clubB};

				my $category = $nom eq $m->{fencerA} ? $m->{categoryA} : $m->{categoryB};
				
				# TODO - Add category - probably needs to come from the match object
				$seeds->{$m->{winner}} = {nom=>$nom, nation=>$nation, club=>$club, seed=>1, group=>"elim_0", category=>$m}; 

			}
		}
	}

	debug(2,"ranking(): seeds = " . Dumper(\$seeds));
	return $seeds;
}

# fencers, poules, pistes
sub fpp
{
	my $c = shift;

	# print "fpp: c = " . Dumper(\$c);

	my $round = shift || $c->nutour;

	my $output = {};

	my $nump = $c->nombre_poules;
	my $num = $$nump[$round-1];

	# print "fpp: num = " . Dumper($num);

	my $i = 1;

	while ($i<=$num)
	{
		# print "fpp: round = $round, i = $i\n";
		my $p = $c->poule($round, $i);

		my $tir = $p->les_tir_cons;

		my $dom = $c->domaine_compe;

		$dom = "international" unless $dom;

		$dom = "international" if $dom eq "championnat";

		foreach my $id (@$tir)
		{
			my $f = $c->tireur($id);

			next unless $f;

			my $club = $f->club ? $c->club($f->club) : "";
			my $nom = $f->nom;
			my $serie = $f->serie;
			my $nation = $f->nation ? $c->nation($f->nation) : "";
			my $heure = $p->heure;
			my $piste_no = $p->piste_no;
		
			my $aff = $dom eq "national" ? "$club" : "$nation";

			# print "FPP: id = $id, club = $club " . Dumper($f);
			
			$output->{$id} = { nom=>$nom, club=>$aff, serie=>$serie, nation=>$nation, poule=>$i, heure=>$heure, piste_no=>$piste_no };
		}

		$i++;
	}

	return $output;
}


###################################################
#
#	creates a list of outstanding matches
#
###################################################
sub matchlist 
{
	my $c = shift;

	my $raw = shift || 0;

	my $output = {};

	my @ta = split / /,$c->tableaux_en_cours;

	print STDERR "DEBUG: matchlist(): tableaux = " . Dumper(\@ta) if $DEBUGGING > 1;

	foreach my $t (@ta)
	{
		my $tab = $c->tableau($t, 1);

		print STDERR "DEBUG: matchlist(): tab = " . Dumper(\$tab) if $DEBUGGING > 2;

		foreach my $id (keys %$tab)
		{
			next unless $id =~ /\d+/;

			# my $match = $tab->match($id);
			my $match = $c->match($t, $id);

			next if $match->{'winnerid'};

			print STDERR "DEBUG: matchlist(): *****************************************************\n" if $DEBUGGING > 1;
			print STDERR "DEBUG: matchlist(): processing id $id\n" if $DEBUGGING > 1;
			print STDERR "DEBUG: matchlist(): match = " . Dumper(\$match) if $DEBUGGING > 1;

			unless ($raw)
			{
				next unless $match->{'idA'} && $match->{'idB'};
				next if $match->{'idA'} eq 'nobody' || $match->{'idB'} eq 'nobody';

				print STDERR "DEBUG: matchlist(): waiting for match = " . Dumper($match) if $DEBUGGING > 1;

				#$t =~ s/[A-Z]*//;

				$output->{$match->{'fencerA_court'}} = { 'round'=>$t, 'piste'=> $match->{'piste'}, 'time'=>$match->{'time'} };
				$output->{$match->{'fencerB_court'}} = { 'round'=>$t, 'piste'=> $match->{'piste'}, 'time'=>$match->{'time'} };

				print STDERR "DEBUG: matchlist(): output = " . Dumper(\$output) if $DEBUGGING > 1;

			}
			else
			{
				$output->{$t}->{$id} = $match ;
			}
		}
	}

	return $output;
}



###################################################
#
#	creates a de-referenced list of entries
#
###################################################
sub tireurs
{
	my $c = shift;
	my $present = shift || 0;
	my $output = {};

	my $t = $c->tireur;

	# print "tireurs: t = " . Dumper(\$t);

	foreach my $id (keys %$t)
	{
		next unless $id =~ /\d+/;

		my $f = $c->tireur($id);
		
		next if $present && $f->presence ne "present";

		# print "tireurs: f = " . Dumper(\$f);

		my $club = $f->club ? $c->club($f->club) : "";
		my $nom = $f->nom;
		my $serie = $f->serie;
		my $nation = $f->nation ? $c->nation($f->nation) : "";

		$output->{$id} = { nom=>$nom, club=>$club, serie=>$serie, nation=>$nation };
	}

	$output->{scratch} = $t->{scratch};
	$output->{present} = $t->{present};
	$output->{absent} = $t->{absent};
	$output->{entries} = $t->{entries};

	return $output;
}


sub spreadsheet
{
	my $self = shift;
	my $name = shift;

	# print "spreadsheet: name = $name\n";
	# print "spreadsheet: _ = @_\n";

	return Engarde::Spreadsheet::writeL32($self, $name);
}


sub load 
{
    my $self = shift;	

	my $file = $self->{file};

	# print "LOAD: " . Dumper(\$self);

	open IN, "$file" || die $!;
	my $unparsed;

	while (<IN>)
	{
		chomp;
		s///g;


		# print "load: $_\n";
	
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

sub tableaux
{
	# returns a list of complete tableaux sorted into ranking order (lowest first)
	my $self = shift;

	# if set to 1 returns just the current stage(s)
	my $current = shift || 0;

	local $ta = $self->tableauxactifs;

	print STDERR "DEBUG: tableaux(): tableauxactifs = " . Dumper(\$ta) if $DEBUGGING > 1;

	my $initial;
	my @tableaux;

	# much simpler now 
	# just return the full list of tableaux in ranking order 
	# without worrying about the state

	@tableaux = sort tableaux_sort keys %$ta;

#	foreach my $key (sort tableaux_sort keys %$ta)
	#{
		#print STDERR "DEBUG: tableaux(): current tableau = $key\n" if $DEBUGGING ;

		#my $tab = $self->tableau($key);

		#next unless $tab;

		#print STDERR "DEBUG: tableaux(): tab = " . Dumper(\$tab) if $DEBUGGING > 2;

		#my $etat = $tab->etat;

		#print STDERR "DEBUG: tableaux(): etat = $etat\n" if $DEBUGGING;

		#push @tableaux, $key if ($etat eq "en_cours");
		#push @tableaux, $key if ($etat eq "tableaux");
		#push @tableaux, $key if ($etat eq "termine" &&  not $current);
		#push @tableaux, $key if ($etat eq "vide" &&  not $current);
		
		#$initial = $key if $etat eq "termine";
		# print STDERR "DEBUG: tableaux(): initial tableau = $initial\n" if $DEBUGGING;
	#}

	$initial = $tableaux[0] unless $initial;
	# print "TABLEAUX: result @result\n";

	# return reverse @result unless $current == 2;
	return @tableaux unless $current == 2;
	return $initial if $current == 2;
}


sub tableaux_sort 
{

	my $rang_a = $ta->{$a}->{rang_premier_battu};
	my $rang_b = $ta->{$b}->{rang_premier_battu};
	my $dest_a = $ta->{$a}->{destination_battus};
	my $dest_b = $ta->{$b}->{destination_battus};

	print STDERR "DEBUG: taleaux_sort(): BEFORE: \n\ta = $a, \n\tb = $b, \n\trang_a = $rang_a, \n\trang_b = $rang_b, \n\tdest_a = $dest_a, \n\tdest_b = $dest_b\n" 
		if $DEBUGGING > 2;;
	# print STDERR "DEBUG: taleaux_sort(): BEFORE: next_dest_a = " . $ta->{$dest_a}->{rang_premier_battu} . "\n";
	# print STDERR "DEBUG: taleaux_sort(): BEFORE: next_dest_b = " . $ta->{$dest_b}->{rang_premier_battu} . "\n";

	$rang_a = $ta->{$dest_a}->{rang_premier_battu} + 1 unless $rang_a;
	$rang_b = $ta->{$dest_b}->{rang_premier_battu} + 1 unless $rang_b;

	print STDERR "DEBUG: taleaux_sort(): AFTER: rang_a = $rang_a, rang_b = $rang_b, dest_a = $dest_a, dest_b = $dest_b\n" if $DEBUGGING > 2;

	# my $series_a = substr($a,0,1);
	# my $series_b = substr($b,0,1);

	print STDERR "DEBUG: tableaux_sort(): $a $b $dest_a $dest_b\n" if $DEBUGGING > 2;

	return $rang_b <=> $rang_a;
}

sub next_tableau
{
	my $self = shift;
	my $level = shift;
	my $tab = $self->tableau($level);

	return $tab->destination_vainqueurs;
}


sub next_tableau_in_suite
{
	my $self = shift;
	my $level = shift;

	my $tab = $self->tableau($level);
	my $suite = $tab->suite;

	my @tab = $self->tableaux();

	print STDERR "DEBUG: next_tableau_in_suite(): tab = [@tab]\n" if $DEBUGGING > 2;

	while ($tab[0] ne $level)
	{
		shift (@tab);
	}
	shift(@tab);

	foreach my $t (@tab)
	{
		my $next_tab = $self->tableau($t);
		my $next_suite = $next_tab->suite; 

		return $t if $next_suite eq $suite;
	}

	return undef;
}


sub whereami
{
	# determine the current stage of the competition
	
	my $self = shift;

	my $result = "unknown";
	my $etat = $self->etat;
	
	my $etattour = $self->etattour || "";

	# nutour is the current round
	# etattour is either en_cours or constitution
	my $nutour = $self->nutour;	

	# print "whereami: etat = $etat\n";
	# print "whereami: etattour = $etattour\n";

	if ($etat eq "termine")
	{
		$result = "termine";
	}
	elsif ($etat eq "tableaux")
	{
		# poules are finished, so we are in the DE now need to find out where
		
		if ($etattour eq "constitution")
		{
			# All poules are entered and final ranking produced but tableaux not yet drawn
			$result = "poules " . $self->nutour . " finished";
		}
		else
		{
			#my @tab = $self->tableaux(1);
			#my $initial = $self->tableaux(2);
		
			my $tab = uc($self->tableaux_en_cours);
	
			print "DEBUG: whereami: tab = $tab\n" if $DEBUGGING > 1;

			$result = "tableau $tab";

			# $result = "tableau $initial $tab[0]";
			
			#$result = "tableau $initial $tab[0]" unless $tab[0] eq $initial;
			#$result = "tableau @tab" if $tab[0] eq $initial;
		}
	}
	elsif ($etat eq "debut")
	{
		$result = "debut";
	}
	else
	{
		# in rounds of poules
		# print "in poules\n";
	
		my $waiting = $self->poules_a_saisir || "finished";

		$waiting = "constitution" if $etattour eq "constitution";

		# print "poules to complete = $waiting\n";

		# $result = "poules $nutour $waiting" unless $waiting eq "finished";
		# $result = "poules " . ($nutour - 1) . " $waiting" if $waiting eq "finished";
		$result = "poules $nutour $waiting";
	}

	print STDERR "DEBUG: whereami: result = $result\n" if $DEBUGGING > 1;
	return $result; 
}


sub _unbracket
{
	# prive sub used to resolve strings with an arbitary number of 
	# pairs of brackets into an array of strings each of which will 
	# inevitably also contain pairs of brackets
	#
	# needed because "split" can't cope with the endless variations!
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


sub _heure_to_time
{
	my $in = shift;
	my ($hr, $min) = ($in =~ m/(\d*):(\d*)/);

	print STDERR "DEBUG: _heure_to_time(): in = $in, hr = $hr, min = $min\n" if $DEBUGGING > 1;

	# since we only have a hh:mm string we need to convert this to a time value
	# assuming the other values are "today"
	
	# use localtime instead of gmtime as we want it in the current timezone
	
	my @tm = localtime;
	# ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime($TimeInSeconds); 
	$tm[0] = 0;
	$tm[1] = $min;
	$tm[2] = $hr;

	my $out = timelocal(@tm);
	print STDERR "DEBUG: _heure_to_time(): returning " . localtime($out) . "\n" if $DEBUGGING > 1;
	return $out;
}

#################################################
#
# convenience sub to call $t->add
# should also allow add to be called on an uninitialised comp
# as $c->tireur will ititialise as needed
#
#################################################
sub tireur_add_edit
{
	my $self = shift;
	my $item = shift;
	my $t = $self->tireur;
	
	debug(1,"tireur_add_edit(): starting item " . Dumper($item));
	
	# this will allow U/A implicitly
	# not sure if that's correct really but it's consistent with Engarde
	
	if ($item->{club} == -1)
	{
		if ($item->{newclub})
		{
			my $c = {};
			$c->{nom} = uc($item->{newclub});
		
			debug(1,"tireur_add_edit(): adding club " . Dumper($c));
			my $cid = $self->club_add($c);
			debug(1,"tireur_add_edit(): got club $cid");
			$item->{club1} = $cid;
		}
		delete $item->{newclub};
	}
	else
	{
		$item->{club1} = $item->{club};
	}
	
	delete $item->{club};
	
	if ($item->{nation} > 0)
	{
		$item->{nation1} = $item->{nation};
	}
	
	delete $item->{nation};
	
	debug(1,"tireur_add_edit(): processing item = " . Dumper($item));
	
	return $t->add_edit($item);
}


sub club_add
{
	my $self = shift;
	my $item = shift;
	
	# debug(1,"club_add: item (start) = " . Dumper($item));
	
	delete $item->{nation1} if $item->{nation1} == -1;
	my $cl = $self->club;
	
	debug(1,"club_add: item (end) = " . Dumper($item));
	
	return $cl->add_edit($item);
}

sub piste_status
{
	my $self = shift;
	my $where = $self->whereami;

	my $out = {};

	my @w = split / /, $where;
	my $now = time;

	if ($w[0] eq "poules" && $w[2] ne "finished")
	{
		shift @w;
		my $round = shift @w;

		foreach my $pn (@w)
		{
			my $status;
			my $p = $self->poule($round ,$pn);

			unless ($p) 
			{
				print STDERR "DEBUG: piste_status(): poule object for round $round poule no $pn not found\n" if $DEBUGGING;
				next;
			}

			my $st = $p->start_time;
			my $et = $p->end_time;
			my $pistenum = $p->piste_no;
			$status = $et < $now ? "late" : "ok";

			$out->{$pistenum}->{'start_time'} = $st;
			$out->{$pistenum}->{'end_time'} = $et;
			$out->{$pistenum}->{'status'} = $status;
			$out->{$pistenum}->{'what'} = "poule";
			$out->{$pistenum}->{'count'} = $p->size;
		}
	}
	elsif ($w[0] eq "tableau")
	{
		# get all current matches
	
		my $round = $self->tableau($w[1],1);

		foreach my $m (keys %$round)
		{
			next unless $m =~ /^\d+$/;
			next unless ($round->{$m}->{idA} && $round->{$m}->{idB});

			print STDERR "DEBUG: piste_status(): match = " . Dumper(\$round->{$m}) if $DEBUGGING > 1;

			my $pn = $round->{$m}->{'piste'} || "unknown";

			print STDERR "DEBUG: piste_status(): pn = [$pn]\n" if $DEBUGGING > 1;

			$out->{$pn}->{'count'} += 1;
			$out->{$pn}->{'what'} = "tableau " . $round->nom;

			# get earliest start
			unless (defined $out->{$pn}->{'start_time'} && $out->{$pn}->{'start_time'} < $round->{$m}->{'start_time'})
			{
				$out->{$pn}->{'start_time'} = $round->{$m}->{'start_time'};
			}

			# and latest end
			unless (defined $out->{$pn}->{'end_time'} && $out->{$pn}->{'end_time'} > $round->{$m}->{'end_time'})
			{
				$out->{$pn}->{'end_time'} = $round->{$m}->{'end_time'};
			}

			$out->{$pn}->{'status'} = $out->{$pn}->{'end_time'} < $now ? "late" : "ok";
		}
	}
	else
	{
	}
	return $out;
}


############################################################################
# Debug output
############################################################################

sub debug
{
	my $level = shift;
	my $text = shift || "";
	
	print STDERR "DEBUG($level): $text\n" if ($level le $Engarde::DEBUGGING);
}


1;

__END__

