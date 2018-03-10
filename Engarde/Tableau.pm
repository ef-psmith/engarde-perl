# vim: ts=4 sw=4 noet:
package Engarde::Tableau;

use strict;
no warnings 'io';

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DT::Log;

# Tableaux need a custom load method
sub load
{
	my $self = shift;

	# my $level = $self->{level};

	# $level =~ s/[a-z]//;

	# print "Level = $level\n";


	open IN, $self->{file} || die $!;
	my $unparsed;

	<IN>; # discard [nom aXX]

	my $taille = <IN>;

	chomp $taille;
	$taille =~ s/\]//;
	$taille =~ s/\[taille[ \t]*//;
	$taille =~ s/\R//g;

	$self->{taille} = substr($taille,1);

	my $max = $taille / 2;

	my $etat = <IN>;

	chomp $etat;
	$etat =~ s/\R//g;

	# print "etat = [$etat]\n";

	$etat =~ s/\[etat[ \t]*//;

	# print "etat = [$etat]\n";
	
	$etat =~ s/\]//;

	$self->{etat} = substr($etat,1);

	while (<IN>)
	{
		chomp;
		s/\R//g;
		$unparsed .= $_;
	}

	close IN;

	my @matches = split /[\]\} ]*\{\[match /, $unparsed;

	#TRACE( sub { "matches = " . Dumper(\@matches) });

	my $i;
	my @eliminated;

	for ($i=1;$i<=$max;$i++)
	{
		my $item = {};

		# '(160 212 () () () 1 32)' OR '(160 212 15 14 160 1 32)' OR '(160 212 15 5 160 1 32)] [piste_no 1] [heure "~11:00"',
		# OR '(160 212 15 5 160 1 32)] [piste_no 1] [imprime vrai] [heure "~11:00"',
		#
 		# [les_matches ({[match (96 nobody () () 96 1 128)] [piste_no 1]} {[match (121 40 () () () 65 64)]
 		# [piste_no 1]} {[match (25 nobody () () 25 33 96)] [piste_no 1]} {[match (nobody
 		# 101 () () 101 97 32)] [piste_no 1]} {[match (78 nobody () () 78 17 112)] [piste_no
 		# 1]} {[match (65 118 () () () 81 48)] [piste_no 1]} {[match (34 39 () () () 49 80)]
		# 
		
		$matches[$i] =~ s/\R//g;
		
		# Engarde::debug(3, "tableau::decode(): match $i = " . Dumper(\$matches[$i]));
		
		($item->{'idA'},$item->{'idB'},$item->{'scoreA'},$item->{'scoreB'},$item->{'winnerid'},$item->{'seedA'},$item->{'seedB'})
			= $matches[$i] =~ m/^\((.*) (.*) (.*) (.*) (.*) ([0-9]*) ([0-9]*)\)/;

		$item->{'idA'} = "" if $item->{'idA'} =~ /\(\)/;
		$item->{'idB'} = "" if $item->{'idB'} =~ /\(\)/;

		if ($matches[$i] =~ /heure/)
		{
			#($item->{'piste'}, $item->{'time'}) = $matches[$i] =~ m/.*\[piste_no (.*)\]*.*\[heure \"~(.*)\"/;
			($item->{'time'}) = $matches[$i] =~ m/.*\[heure \"~(.*)\".*/;
			# Engarde::debug(3, "tableau::load: $i time $item->{time} set from heure");
			
		}
		
		if ($matches[$i] =~ /piste_no/)
		{
			($item->{'piste'}) = $matches[$i] =~ m/.*\[piste_no (.*).*/;
		}

		# Engarde::debug(3,"tableau::decode(): item $i = " . Dumper(\$item));
		
		# remove [imprime vrai
		$item->{'piste'} =~ s/\].*$// if $item->{'piste'};

		# remove "
		$item->{'piste'} =~ s/\"//g if $item->{'piste'};

		# print "$item->{'piste'}\n";

		if ($item->{'scoreA'} && $item->{'scoreA'} eq "()")
		{
			if ($item->{'scoreB'} && $item->{'scoreB'} eq "()")
			{
				$item->{'scoreA'} = "";
				$item->{'scoreB'} = "";
			}
			else
			{
				$item->{'scoreA'} = 0;
			}
		}

		if ($item->{'scoreB'} && $item->{'scoreB'} eq "()")
		{
			$item->{'scoreB'} = 0;
		}

		if ($item->{'winnerid'})
		{
			# print STDERR "winner = [$item->{'winnerid'}]\n";
			$item->{'winnerid'} = "" if ($item->{'winnerid'} eq "()" || $item->{'winnerid'} eq " ");
			# print STDERR "winner2 = [$item->{'winnerid'}]\n";

			# push loser
			my $id = $item->{'winnerid'} eq $item->{'idA'} ? $item->{'idB'} : $item->{'idA'};

			# $level = $self->level;

			# print STDERR "id = $id\n";
			push @eliminated, $id unless ($id eq "nobody" || $id eq "");
		}

		bless $item, "Engarde::Match";

		#print STDERR "item = " . Dumper(\$item);
		$self->{$i} = $item;

		$self->{'eliminated'} = \@eliminated;
	}
}



###########################################################
#
# accessor methods
#
###########################################################

# match returns a ref to an Engarde::Comptition::Match object
#
# Required to override the AUTOLOAD version 
sub match
{
	my $self = shift;
	my $match = shift;

	# print "MATCH: self = $self, match = $match\n";

	return $self->{$match} || undef;

}


###########################################################
#
#  returns the next tableau name
#
#  this is for convenience and readability mainly
#  as it allows you to call $tableau->next rather than $comp->next_tableau($tableau->level)
#
###########################################################

sub next 
{
	my $self = shift;
	my $comp = $self->parent;
	return $comp->next_tableau($self->level);
}


sub next_in_suite 
{
	my $self = shift;
	my $comp = $self->parent;
	return $comp->next_tableau_in_suite($self->level);
}



############################################################################
# Process a tableau into a match structure
############################################################################

sub matches
{
	my $t = shift;
	my $aff = shift;
	
	my @list;
	
	my $numbouts = $t->{taille} / 2;

	DEBUG("Number of bouts: $numbouts");

	foreach my $m (1..$numbouts)
	{	
		# print "do_tableau: calling match\n";
		my $match = $t->match($m);

		# push @winners, ($match->{winnerid} || undef ) if $col eq 1;

		my $fa = { id => $match->{idA} || "", name => $match->{fencerA} || "", seed => $match->{seedA} || "", affiliation => $match->{$aff . 'A'} || "", category => $match->{categoryA} || ""};
		my $fb = { id => $match->{idB} || "", name => $match->{fencerB} || "", seed => $match->{seedB} || "", affiliation => $match->{$aff . 'B'} || "", category => $match->{categoryB} || ""};

		#$fa->{name} = $winners[($m * 2) - 1] unless $fa->{name};
		#$fb->{name} = $winners[$m * 2] unless $fb->{name};

		my $score = "$match->{scoreA} / $match->{scoreB}";

		$score = "by exclusion" if $score =~ /exclusion/;
		$score = "by abandonment" if $score =~ /abandon/;
		$score = "by penalty" if $score =~ /forfait/;
		$score = "" if $score eq " / ";

		push @list, { 	number => $m, 
						time => $match->{time} || "",  
						piste => $match->{piste} || "",
						fencerA => $fa,
						fencerB => $fb,
						winnername => $match->{winnername} || "",
						winnerid => $match->{winnerid} || "",
						score => $score
					};
	};

	return @list;
}
	

__END__

