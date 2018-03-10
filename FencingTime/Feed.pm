package FencingTime::Feed;
use 5.018;
use Data::Dumper::Concise;

use Types::Standard -types;
use Type::Utils -all;
use Types::XSD qw(DateTime);
use FencingTime::EventStub;
use DT::Log;
use Moo;

#### TYPES ####
my $Event_type = class_type { class => 'FencingTime::EventStub' };
my $Events = ArrayRef[$Event_type->plus_coercions(Any, \&_coerce_event)];

sub _coerce_event
{
	# Don't access $ft->Tournaments here as it causes an infinite recursion
	FencingTime::EventStub->new(shift);
}

#### ATTRIBUTES ####
has ID => (is => 'lazy', isa => Int);
has OmittedItems => (is => 'lazy', isa => Int);
has AnnouncementMessage => ( is => 'lazy', isa => Str);
has Name => ( is => 'lazy', isa => Str);
has TournamentID => (is => 'lazy', isa => Int);
has DisplayOptions => (is => 'lazy', isa => Int);
has AnnouncementPriority => (is => 'lazy', isa => Int);
has AnnouncementOffTime  => (is => 'lazy', isa => DateTime);

has Events => (
				is => 'lazy', 
				isa => $Events,
				coerce => 1,
);

#### METHODS ####
sub event
{
	my $self = shift;
	my $name = shift || -1;

	return undef unless $name;

	foreach my $x (@{$self->Events})
	{
		return $x if $x->{EventID} || "" eq $name;
		return $x if $x->{name} || "" eq $name;
	}
}

sub events
{
    my $self = shift;

	my $out = {};

	foreach my $x (@{$self->Events})
	{
		$out->{$x->EventID} = 1;
	}

	$out;
}

sub _build_Events
{
	WARN("_build_Events - almost certainly an error!");
	TRACE(sub { Dumper($_) });
	return undef unless ref($_) eq "ARRAY";
	
	my @out;	
	foreach (@$_)
	{
		my $e = FencingTime::EventStub->new($_);

		if ($e->CurRoundNum > 0)
		{
			$e->expand;	
		}
		push @out, $e;
	}
	\@out;
}


1;
