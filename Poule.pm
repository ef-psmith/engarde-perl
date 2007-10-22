package Engarde::Poule;
use strict;
use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

# Poules need a custom load method
sub load
{
	my $self = shift;

	open IN, $self->{file} || die $!;

	<IN>;	#	skip {[numero 1]
 	<IN>;	#	skip  [les_tir_cons (191 152 188 190 160 158 212)]

	my $tir = <IN>;	# [les_tir_feuille (212 188 191 190 158 152 160)]

	chomp $tir;

	$tir =~ s/\[les_tir_feuille \(//;
	$tir =~ s/\)\]$//;

	my @tir = split / /, substr($tir,1);
 
	<IN>;	#	skip  [ordre_des_matches odm7]
 	<IN>;	#	skip  [critere_placement nation]

	$self->{les_tir_cons} = \@tir;

	my @keywords1 = qw/les_tir_cons heure/;
	my @keywords2 = qw/piste_no/;
	
	while (<IN>)
	{
		chomp;

		# print "POULE: in = $_\n";

		foreach my $key (@keywords1)
		{
			# print "POULE: key = $key\n";

			if (/\[$key /)
			{
				s/\[$key \"//;
				s/\"\]//;
				s/\~//;

				$self->{$key} = substr($_,1);
				# print "POULE: value = $self->{$key}\n";
				last;
			}
		}


		foreach my $key (@keywords2)
		{
			# print "POULE: key = $key\n";

			if (/\[$key /)
			{
				s/\[$key //;
				s/\].*//;
				s/\"//g;		# Just in case...

				$self->{$key} = substr($_,1);
				# print "POULE: value = $self->{$key}\n";
				last;
			}
		}
	}

	close IN;
}


