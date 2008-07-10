package Engarde::Arbitre;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

sub decode
{
	my $self = shift;
	my $in = shift;

	print "in = $in\n";

	$in =~ s/^{//;
	$in =~ s/}$//;

	print "in = $in\n";

	# {[classe arbitre] [titre &arbitre] [presence present] [nom "EINSTEIN"] [prenom "Albert"]
 	# [cle 1] [sexe masculin] [categorie "A"] [date_nais "~27/12/1962"] [licence_fie "12345"]
 	# [club1 42]}

	my $item = {};
	my $cle;

	my @elements = split /[\s\]]*\[/, $in;

	my @keywords = qw/nom prenom cle sexe categorie date_nais licence_fie club1 nation1/;

	# print Dumper(@elements);

	foreach (@elements)
	{
		print "element = $_\n";

		foreach my $key (@keywords)
		{
			if (/^$key /)
			{
				s/^$key //;
				s/^\"//;
				s/^\~//;
				s/\"$//;
				s/\]$//;

				$item->{$key} = $_;
			}
		}
	}


	bless $item, "Engarde::Arbitre";
	$self->{$item->{cle}} = $item;
}


1;


__END__

