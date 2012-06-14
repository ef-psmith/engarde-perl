package Engarde::Nation;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

sub decode
{
	my $self = shift;
	my $in = shift;
	my $max = $self->{max} || 0;

	# {[classe nation] [nom "GBR"] [nom_etendu "Grande-Bretagne"] [cle 1]}	
	my $item = {};
	my $cle;

	my @elements = split /[ \]]*\[/, $in;

	foreach (@elements)
	{
		if (/^nom /)
		{
			s/^nom \"//;
			s/\"$//;

			$item->{nom} = $_;
		}

		if (/^nom_etendu /)
		{
			s/^nom_etendu \"//;
			s/\"$//;

			$item->{nom_etendu} = $_;
		}

		if (/^cle/)
		{
			s/^cle //;
			s/\]\}$//;

			$cle = $_;
		}
	}

	$max = $cle if $cle > $max;

	bless $item, "Engarde::Nation";
	$self->{$cle} = $item;
	$self->{max} = $max;
}


1;


__END__

