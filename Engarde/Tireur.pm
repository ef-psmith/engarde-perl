package Engarde::Tireur;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use Fcntl qw(:flock :DEFAULT);
#use HTML::Entities;

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
	my $max = $self->{max} || 0;
	my $present = $self->{present} || 0;
	my $absent = $self->{absent} || 0;

	my @elements = split /[ \]]*\[/, $in;


	my @keywords1 = qw/nom prenom licence mobile licence_fie mode date_nais/;
   	my @keywords2 = qw/club1 nation1 presence serie cle sexe paiement/;

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

	$max = $cle if $cle > $max;

	if ($item->{presence} eq "present")
	{
		$present += 1;
	}
	else
	{
		$absent += 1;
	}

	bless $item, "Engarde::Tireur";
	$self->{$cle} = $item;

	$self->{max} = $max;
	$self->{present} = $present;
	$self->{absent} = $absent;

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


sub to_text
{
	my $self = shift;
	my $file = $self->{file};
	
	open my $FH, "> $file" . ".tmp";
	flock($FH, LOCK_EX) || return undef;
	
	open my $FH2, "+< $file";
	flock($FH2, LOCK_EX) || return undef;

	my $seq = 1;
	
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "ALEXANDER"]
	#	[prenom "Kevin"] [serie 290] [club1 3] [licence "31529"] [points 0.00] [cle 55]}
	#
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "APCAR"]
	#	[prenom "Saka"] [points 0.00] [cle 54] [serie 999] [date_nais "~1962"] [licence
	#	"123456"] [licence_fie "201301015"] [mobile "07802 312401"] [paiement 9.98] [mode
	#	"mode"]}

	# {[classe tireur] [presence present] [sexe feminin] [status normal] [nom "ARMSTRONG"]
	#	[prenom "Neil"] [club1 12] [licence "103878"] [points 0.00] [cle 53] [date_nais
	#	"~1/2/1975"]}
	#
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MINIMAL"]
	# [prenom "Minimal"] [cle 56]}
	#
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MONTY"]
	# [prenom "Full"] [serie 123] [club1 29] [nation1 1] [date_nais "~27/12/1962"] [licence
	# "100123"] [licence_fie "1995120501"] [mobile "07802 312401"] [points 4.00] [dossard
	# 888] [paiement 9.99] [mode "mode string"] [cle 57]}
	
	foreach my $id (sort {$a <=> $b} grep /\d+/,keys %$self)
	{
		# print "$id: " . Dumper($self->{$id});
		
		# First line - space after the new line is deliberate
		print $FH "{[classe tireur] [presence " . $self->{$id}->{presence} . "] [sexe " . $self->{$id}->{sexe} . "] ";
		print $FH "[status normal] [nom \"" . $self->{$id}->{nom} . "\"\n " ;
		
		
		print $FH "[prenom \"$self->{$id}->{prenom}\"] [cle $id] [points 0.00] ";
		print $FH "[serie " . $self->{$id}->{serie} . "] " if defined $self->{$id}->{serie};
		
		print $FH "[licence \"" . $self->{$id}->{licence} . "\"] " if defined $self->{$id}->{licence};
		print $FH "[mobile \"" . $self->{$id}->{mobile} . "\"] " if defined $self->{$id}->{mobile};
		print $FH "[paiement " . $self->{$id}->{paiement} . "] " if defined $self->{$id}->{paiement};
		print $FH "[mode \"" . $self->{$id}->{mode} . "\"] " if defined $self->{$id}->{mode};
		
		print $FH "}\n";
	}
	
}

1;


__END__

