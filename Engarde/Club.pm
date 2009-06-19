package Engarde::Club;

use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

sub decode
{
	my $self = shift;
	my $in = shift;
	my $cle;

	# print "CLUB: in = $in\n";

	my $item = {};

	if ($in =~ /nation1/)
	{
		($item->{nom},$item->{nation},$cle) = $in =~ m/.*\[nom \"(.*)\"\] \[nation1 (.*)\] \[cle (.*)\]\}$/;
	}
	else
	{
		($item->{nom},$cle) = $in =~ m/.*\[nom \"(.*)\"\] \[cle (.*)\]\}$/;
	}

	bless $item, "Engarde::Club";
	$self->{$cle} = $item;
}



1;


__END__

