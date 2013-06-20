package Engarde::Tireur;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use Fcntl qw(:flock);
#use HTML::Entities;

$VERSION=2.01;

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
	my $scratch = $self->{scratch} || 0;

	my @elements = split /[ \]]*\[/, $in;

	my @keywords1 = qw/nom prenom licence mobile licence_fie mode date_nais/;
   	my @keywords2 = qw/club1 nation1 presence serie cle sexe paiement/;

	# print Dumper(@elements);

	foreach (@elements)
	{
		# print "TIREUR 1: $_\n";

		foreach my $key (@keywords1)
		{
			# print STDERR "TIREUR 2: key 1 = $key\n";

			if (/^$key /)
			{
				s/^$key \"//;
				s/\".*$//;

				$item->{$key} = $_;
				# print STDERR "TIREUR 3: $_\n" if $key eq "date_nais";
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

	_demode($item);
	
	$item->{category} = _age_cat($item->{date_nais});

	Engarde::debug(3,"Tiruer::decode: item = " . Dumper(\$item));
	
	# print "TIREUR 6: cle = " . $item->{cle} . "\n\n\n";

	$cle = $item->{cle};

	$max = $cle if $cle > $max;

	if ($item->{presence} && $item->{presence} eq "present")
	{
		$present += 1;
	}
	else
	{
		$absent += 1;
	}

	$scratch += 1 if $item->{scratched};

	bless $item, "Engarde::Tireur";
	$self->{$cle} = $item;

	$self->{max} = $max;
	$self->{present} = $present;
	$self->{absent} = $absent;
	$self->{scratch} = $scratch;
	$self->{entries} = scalar grep (/\d+/, keys %$self);
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


sub dob
{
	my $self = shift;
	return undef unless $self->{date_nais};
	
	$self->{date_nais} =~ s/~//g;
	
	return $self->{date_nais};
	
	#my @parts = split /\//, $self->{date_nais};
	
	#@parts = reverse @parts;
	
	# @parts will now how either y, y/m or y/m/d...  
	
	#return "$parts[2]/$parts[1]/$parts[0]" if ($#parts == 3);
	#return "$parts[1]/$parts[0]" if ($#parts == 2);
	#return "$parts[0]" if ($#parts == 1);
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


sub _age_cat
{
	my $dob = shift;
	return "" unless $dob;
	$dob =~ s/~//g;
	
	my @parts = split /\//, $dob;
	
	# last part will be the year
	my $yob = $parts[-1];
	
    my ($month, $year) = (localtime)[4..5];
    $year += 1900;

    my $age = $year - $yob - 1;
    $age++ if $month > 9;
	
	return "U9" if $age < 9;
	return "U11" if $age < 11;
	return "U13" if $age < 13;
	return "V" if $age >= 40;			# veteran is 40+ on 1st Jan
	return "S" unless $age <20;			# Senior is most of the rest
	return "J" if $age >= 17;			# Junior is 17-19 on 1st Jan
	return "C" if $age <= 17;			# Cadet is 13 to 16 on 1st Jan
}

sub to_text
{
	my $self = shift;
	my $file = $self->{file};
	
	my $dir = $self->{dir};
	
	# the caller must ensure that engarde is not running since we don't 
	# want a multiple writer conflict and linux doesn't like multiple locks on the 
	# same file
	
	# open ETAT, "+< $dir/etat.txt";
	# flock(ETAT, LOCK_EX) || return undef;
	
	open (my $FH, ">",  "$file.tmp") or do
	{	
		Engarde::debug(1,"open failed on $file.tmp $!");
		return undef;
	};
	
	flock($FH, LOCK_EX) or do
	{
		Engarde::debug(1,"lock failed on $file.tmp $!");
		return undef;
	};
	
	open (my $FH2, "+<", $file) or do
	{	
		Engarde::debug(1,"open failed on $file $!");
		return undef;
	};
	
	flock($FH2, LOCK_EX) or do
	{
		Engarde::debug(1,"lock failed on $file $!");
		return undef;
	};

	my $seq = 1;
	
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MINIMAL"]
	# [prenom "Minimal"] [cle 56]}
	#
	# {[classe tireur] [presence present] [sexe masculin] [status normal] [nom "MONTY"]
	# [prenom "Full"] [serie 123] [club1 29] [nation1 1] [date_nais "~27/12/1962"] [licence
	# "100123"] [licence_fie "1995120501"] [mobile "07802 312401"] [points 4.00] [dossard
	# 888] [paiement 9.99] [mode "mode string"] [cle 57]}
	
	my @keywords1 = qw/nom prenom licence mobile licence_fie mode date_nais/;
   	my @keywords2 = qw/club1 nation1 presence serie cle sexe paiement/;
	
	foreach my $id (sort {$self->{$a}->{nom} cmp $self->{$b}->{nom}} grep /\d+/,keys %$self)
	{
		Engarde::debug(3,"tireur: to_text(): processing id $id");

		# if (defined $self->{$id}->{comment})
		#{
		
		$self->{$id}->{mode} = $self->{$id}->{comment} || "";
		
		$self->{$id}->{mode} .= "|exp" if $self->{$id}->{expired};
		$self->{$id}->{mode} .= "|scr" if $self->{$id}->{scratched};
		
		#}
		
		my $out;	
		$out = "{[classe tireur] [status normal] [points 0.00]";
		
		foreach my $key (@keywords1)
		{
			$out .= " [$key \"" . $self->{$id}->{$key} . "\"]" if $self->{$id}->{$key};
			
			if (length($out) > 60)
			{
				print $FH $out . "\r";
				$out = "";
			}
		}
		
		foreach my $key (@keywords2)
		{
			$out .= " [$key $self->{$id}->{$key}]" if $self->{$id}->{$key};
			
			if (length($out) > 80)
			{
				print $FH $out . "\r";
				$out = "";
			}
		}
		
		$out .= "}\r";
		
		Engarde::debug(3,"tireur: to_text(): id $id = $out");
		
		print $FH $out;
	}
	
	close $FH;
	close $FH2;
	
	# flock($ETAT, LOCK_UN); 
	# close $ETAT;
	
	rename "$file.tmp", $file or die("rename failed: $!");
}

sub add_edit
{
	# really this should do a lock check and pass the lock to to_text() but 
	# I don't have the time to work this out and Win32 seems to hate 
	# regranting an exlusive lock so for now, the race condition will
	# have to be on the TODO list
	
	my $self = shift;
	my $new = shift;
	
	Engarde::debug(2,"add_edit(): new (start) = " . Dumper($new));
	
	my @required = qw/nom prenom/;
	
	foreach (@required)
	{
		return undef unless $new->{$_};
	}
	
	$new->{cle} = $self->{max} + 1 unless $new->{cle} > 0;
	$self->{$new->{cle}} = $new;
	
	Engarde::debug(2,"add_edit(): new (end) = " . Dumper($new));
	Engarde::debug(3,"add_edit(): self = " . Dumper($self));
	
	$self->to_text;
	
	return $self->{cle};
}


sub _demode 
{
	my $f = shift;
	my $m = $f->{mode} || "";
	
	# set defaults
	$f->{scratched} = "";
	$f->{expired} = "";
	
	# return unless $m;
	
	my @m = split /\|/, $m;
	
	$f->{comment} = shift @m;
	
	foreach (@m)
	{
		if ($_ =~ /^exp.*/i)
		{
			$f->{expired} = $_;
		}
		elsif($_ =~ /^scr.*/i)
		{
			$f->{scratched} = $_;
		}
	}
}

1;


__END__
