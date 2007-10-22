package Engarde::Tableau;

use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

# Tableaux need a custom load method
sub load
{
	my $self = shift;
	my $level = $self->{level};

	open IN, $self->{file} || die $!;
	my $unparsed;

	<IN>; # discard [nom aXX]
	<IN>; # discard [taille XX]
# 	<IN>; # discard [etat XXX]

	my $etat = <IN>;

	chomp $etat;

	# print "etat = [$etat]\n";

	$etat =~ s/\[etat[ \t]*//;

	# print "etat = [$etat]\n";
	
	$etat =~ s/\]//;

	$self->{etat} = substr($etat,1);

	while (<IN>)
	{
		chomp;
		$unparsed .= $_;
	}

	close IN;

	my @matches = split /[\]\} ]*\{\[match /, $unparsed;

	# print Dumper(\@matches);

	my $i;
	my @eliminated;

	for ($i=1;$i<=$level/2;$i++)
	{
		my $item = {};

		# '(160 212 () () () 1 32)' OR '(160 212 15 14 160 1 32)' OR '(160 212 15 5 160 1 32)] [piste_no 1] [heure "~11:00"',
		# OR '(160 212 15 5 160 1 32)] [piste_no 1] [imprime vrai] [heure "~11:00"',
		
		($item->{'fencerA'},$item->{'fencerB'},$item->{'scoreA'},$item->{'scoreB'},$item->{'winner'},$item->{'seedA'},$item->{'seedB'})
			= $matches[$i] =~ m/^\((.*) (.*) (.*) (.*) (.*) ([0-9]*) ([0-9]*)\)/;

		($item->{'piste'}, $item->{'time'}) = $matches[$i] =~ m/.*\[piste_no (.*)\].*\[heure "~(.*)\"/;

		# remove [imprime vrai
		$item->{'piste'} =~ s/\].*$// if $item->{'piste'};

		# remove "
		$item->{'piste'} =~ s/\"//g if $item->{'piste'};

		# print "$item->{'piste'}\n";

		if ($item->{'scoreA'} eq "()")
		{
			if ($item->{'scoreB'} eq "()")
			{
				$item->{'scoreA'} = "";
				$item->{'scoreB'} = "";
			}
			else
			{
				$item->{'scoreA'} = 0;
			}
		}

		if ($item->{'scoreB'} eq "()")
		{
			$item->{'scoreB'} = 0;
		}

		$item->{'winner'} = "" if ($item->{'winner'} eq "()" || $item->{'winner'} eq " ");

		if ($item->{'winner'})
		{
			# push loser
			my $id = $item->{'winner'} eq $item->{'fencerA'} ? $item->{'fencerB'} : $item->{'fencerA'};

			my $level = $self->level;

			# print "level = $level, id = $id\n";
			push @eliminated, $id unless $id eq "nobody";
		}

		bless $item, "Engarde::Match";
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
sub match
{
	my $self = shift;
	my $match = shift;

	# print "MATCH: self = $self, match = $match\n";

	return $self->{$match} || undef;

}


1;


__END__

