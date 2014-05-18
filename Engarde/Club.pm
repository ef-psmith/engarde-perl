package Engarde::Club;

use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

$VERSION=1.25;

use Data::Dumper;
use Fcntl qw(:flock);

sub decode
{
	my $self = shift;
	my $in = shift;
	my $cle;
	my $max = $self->{max} || 0;

	chomp $in;

	$in =~ s/\R//g;

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

	$item->{cle} = $cle;
	$max = $cle if $cle > $max;

	bless $item, "Engarde::Club";
	$self->{$cle} = $item;
	$self->{max} = $max;
}


sub add_edit
{
	my $self = shift;
	my $new = shift;
	
	Engarde::debug(1,"club: add_edit(): new (start) = " . Dumper($new));
	
	my @required = qw/nom/;
	
	foreach (@required)
	{
		return undef unless $new->{$_};
	}
	
	$new->{cle} = $self->{max} + 1 unless $new->{cle} > 0;
	$self->{$new->{cle}} = $new;
	
	Engarde::debug(1,"club: add_edit(): new (end) = " . Dumper($new));
	Engarde::debug(3,"club: add_edit(): self = " . Dumper($self));
	
	$self->to_text;
	
	return $new->{cle};
}


sub to_text
{
	my $self = shift;
	my $file = $self->{file};
	
	my $dir = $self->{dir};

	open (my $FH, ">",  "$file.tmp") or do
	{	
		Engarde::debug(1,"club: to_text(): open failed on $file.tmp $!");
		return undef;
	};
	
	flock($FH, LOCK_EX) or do
	{
		Engarde::debug(1,"club: to_text(): lock failed on $file.tmp $!");
		return undef;
	};

	my $FH2;

	if ( -f $file)
	{	
		open (my $FH2, "+<", $file) or do
		{	
			Engarde::debug(1,"club: to_text(): open failed on $file $!");
			return undef;
		};
	
		flock($FH2, LOCK_EX) or do
		{
			Engarde::debug(1,"club: to_text(): lock failed on $file $!");
			return undef;
		};
	}

	my $seq = 1;
	
	# {[classe club] [nom "126"] [cle 23]}
	my $out = "";
	
	# Engarde saves clubs in alpha order rather than id order
	foreach my $id (sort {$self->{$a}->{nom} cmp $self->{$b}->{nom}} grep /\d+/,keys %$self)
	{
		Engarde::debug(3,"club: to_text(): processing id $id");
		$out .= "{[classe club] [nom \"$self->{$id}->{nom}\"] [cle $id]}\r\n";
		
		Engarde::debug(3,"club: to_text(): id $id = $out");
	}
	print $FH $out;
	close $FH;

	close $FH2 if defined $FH2;
	
	rename "$file.tmp", $file or die("rename failed: $!");
}

1;


__END__

