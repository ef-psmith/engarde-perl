package Engarde::Tireur;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

sub decode
{
	my $self = shift;

	# print "in decode, self = " . Dumper(\$self);

	my $in = shift;

	# {[classe tireur] [presence present] [sexe feminin] [status normal] [nom "TOWERS"]
 	# [prenom "Natalie"] [nation1 1] [date_nais "~29/3/1993"] [licence "54425"] [licence_fie
 	# ""] [points 0.00] [dossard ""] [cle 200]}
	
	my $item = {};
	my $cle;

	my @elements = split /[ \]]*\[/, $in;


	my @keywords1 = qw/nom prenom licence/;
   	my @keywords2 = qw/club1 nation1 presence serie cle/;

	# print Dumper(@elements);

	foreach (@elements)
	{
		# print "TIREUR 1: $_\n";

		foreach my $key (@keywords1)
		{
			# print "TIREUR 2: key 1 = $key\n";

			if (/^$key /)
			{
				s/^$key \"//;
				s/\"$//;

				$item->{$key} = $_;
				# print "TIREUR 3: $_\n";
			}
		}

		foreach my $key (@keywords2)
		{
			# print "TIREUR 4: key 2 = $key\n";

			if (/^$key /)
			{
				s/^$key //;
				s/\].*//;

				$item->{$key} = $_;
				# print "TIREUR 5: $_\n";
			}
		}
	}

	# print "TIREUR 6: cle = " . $item->{cle} . "\n\n\n";

	$cle = $item->{cle};

	if ($item->{presence} eq "present")
	{
		bless $item, "Engarde::Tireur";
		$self->{$cle} = $item;
	}

}



########################################################
#
# class specific accessor methods
#
########################################################

sub nom
{
	my $self = shift;
	return "$self->{nom} $self->{prenom}";
}


sub nom_court
{
	my $self = shift;
	return "$self->{nom} " . substr($self->{prenom}, 0, 1);
}


sub club
{
	my $self = shift;
	return $self->{club1};
}

sub nation
{
	my $self = shift;
	return $self->{nation1};
}

sub rangpou
{
	my $self = shift;
	my $rang = shift;

	if ($rang)
	{
		$self->{rangpou} = $rang;
	}
	else
	{
		return $self->{rangpou};
	}
}

1;


__END__

