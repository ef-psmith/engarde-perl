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
	my $max = $self->{max} || 0;

	chomp $in;

	$in =~ s///g;

	# print "CLUB: in = $in\n";

	my $item = {};

	if ($in =~ /nation1/)
	{
		($item->{nom},$item->{nation},$cle) = $in =~ m/.*\[nom \"(.*)\"\] \[nation1 (.*)\] \[cle (.*)\]\}$/;
		#print STDERR "DEBUG: Club::decode: item = " . Dumper(\$item);
	}
	else
	{
		#'{[classe club] [nom "BATH"] [modifie vrai] [cle 19]}';
		($item->{nom},$cle) = $in =~ m/.*\[nom \"(.*)\"\].*\[cle (.*)\]\}$/;
		# print STDERR "DEBUG: Club::decode: in = " . Dumper(\$in);
		# print STDERR "DEBUG: Club::decode: item = " . Dumper(\$item);
	}

	$max = $cle if $cle > $max;

	bless $item, "Engarde::Club";
	$self->{$cle} = $item;
	$self->{max} = $max;
}



1;


__END__

