# vim: ts=4 sw=4 noet:
package Engarde::Tableau;

use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

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
	$taille =~ s///g;

	$self->{taille} = substr($taille,1);

	my $max = $taille / 2;

	my $etat = <IN>;

	chomp $etat;
	$etat =~ s///g;

	# print "etat = [$etat]\n";

	$etat =~ s/\[etat[ \t]*//;

	# print "etat = [$etat]\n";
	
	$etat =~ s/\]//;

	$self->{etat} = substr($etat,1);

	while (<IN>)
	{
		chomp;
		s///g;
		$unparsed .= $_;
	}

	close IN;

	my @matches = split /[\]\} ]*\{\[match /, $unparsed;

	print STDERR "DEBUG: Tableau::decode(): matches = " . Dumper(\@matches) if $Engarde::DEBUGGING > 2;

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
		print STDERR "DEBUG: Tableau::decode(): match $i = " . Dumper(\$matches[$i]) if $Engarde::DEBUGGING > 2;
		
		($item->{'fencerA'},$item->{'fencerB'},$item->{'scoreA'},$item->{'scoreB'},$item->{'winner'},$item->{'seedA'},$item->{'seedB'})
			= $matches[$i] =~ m/^\((.*) (.*) (.*) (.*) (.*) ([0-9]*) ([0-9]*)\)/;

		$item->{'fencerA'} = "" if $item->{'fencerA'} =~ /\(\)/;
		$item->{'fencerB'} = "" if $item->{'fencerB'} =~ /\(\)/;

		if ($matches[$i] =~ /heure/)
		{
			($item->{'piste'}, $item->{'time'}) = $matches[$i] =~ m/.*\[piste_no (.*)\]*.*\[heure "~(.*)\"/;
		}
		else
		{
			($item->{'piste'}) = $matches[$i] =~ m/.*\[piste_no (.*).*/;
		}

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

		if ($item->{'winner'})
		{
			# print STDERR "winner = [$item->{'winner'}]\n";
			$item->{'winner'} = "" if ($item->{'winner'} eq "()" || $item->{'winner'} eq " ");
			# print STDERR "winner2 = [$item->{'winner'}]\n";

			# push loser
			my $id = $item->{'winner'} eq $item->{'fencerA'} ? $item->{'fencerB'} : $item->{'fencerA'};

			# $level = $self->level;

			# print STDERR "id = $id\n";
			push @eliminated, $id unless ($id eq "nobody" || $id eq "");
		}

		bless $item, "Engarde::Match";

		# print STDERR "item = " . Dumper(\$item);
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


1;


__END__

