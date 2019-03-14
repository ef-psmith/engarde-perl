package FencingTime::Tournament;
use 5.018;
use Data::Dumper::Concise;
use Types::Standard -all;
use Type::Utils -all;
use Types::XSD qw(DateTime);
use FencingTime::Feed;
use FencingTime::RPA;
use FencingTime::Event;
use DT::Log;
use Moo;


#### TYPES ####
my $Feed_type = class_type { class => 'FencingTime::Feed' };
my $Feeds = ArrayRef[$Feed_type->plus_coercions(Any, \&_coerce_feed)];

my $Event_type = class_type { class => 'FencingTime::Event' };
my $Events = ArrayRef[$Event_type->plus_coercions(Any, \&_coerce_event)];
#my $Events = ArrayRef[$Event_type];

sub _coerce_feed
{
	my $in = shift;
	FencingTime::Feed->new($in);
}

sub _coerce_event
{
	my $in = shift;
	FencingTime::Event->new($in);
}

my $RPA_type = class_type { class => 'FencingTime::RPA' };
my $RPA = ArrayRef[$RPA_type->plus_coercions(Any, \&_coerce_rpa)];

sub _coerce_rpa
{
	my $in = shift;
	FencingTime::RPA->new($in);
}


#### CHILDREN ####

has Feeds => ( 	is => 'ro', 
				required => 1,
				isa => $Feeds,
				coerce => 1,
			);

has Events => (
				is => 'lazy', 
				isa => $Events,
				clearer => 1,
				# coerce => 1,
);

has refstrips => ( is => 'lazy', isa => $RPA, coerce => 1 );


#### ATTRIBUTES ####

has ID => (is => 'lazy', isa => Int);
has ft => ( is => 'lazy', default => sub { FencingTime->instance() });

has EndDate => ( is => 'lazy', isa => DateTime);
has StartDate => ( is => 'lazy', isa => DateTime);
has Name => ( is => 'lazy', isa => Str);
has RegFee => (is => 'lazy', isa => Int);
has Location => (is => 'lazy', isa => Str);
has AuthorityName => ( is => 'lazy', isa => Str);
has AuthorityAbbr => ( is => 'lazy', isa => Str);
has AllFinished => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);
has AllowRSE => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);

has last_fetch => ( is => 'lazy', isa => Int, default => sub { time }, clearer => 1);


#### METHODS ####

sub feed
{
    my $self = shift;
    my $f_name = shift;

    return undef unless $f_name;

    foreach my $f (@{$self->Feeds})
    {
        return $f if $f->Name eq $f_name;
        return $f if $f->ID eq $f_name;
    }

	return undef;
}

sub feeds
{
    my $self = shift;

	my $out = {};

    foreach my $f (@{$self->Feeds})
    {
		next if $f->Name eq 'Referee Piste Assignments';
        $out->{$f->ID} = $f->Name;
    }

	$out;
}


sub _build_refstrips
{
	my $self = shift;

	#my $ft = FencingTime->instance;
	
	$self->ft->fetch("tournaments",$self->ID,"refstrips");
}

before qw(event events) => sub {
	my $self = shift;
	my $age = time - $self->last_fetch;

	if ($age gt $self->ft->timeout)
	{
		foreach my $x (@{$self->Events})
		{
			$x->clear_Competitors;
			$x->clear_Pools;
			$x->clear_Elimination;
			$x->clear_Seeding;
			$x->clear_last_fetch;

			undef $x;
		}

		$self->clear_Events;
		$self->clear_last_fetch;

		$self->ft->_clear_instance;

		TRACE ( sub { "events cleared - age = $age" } );
	}
};

sub event
{
    my $self = shift;
    my $name = shift || -1;

    return undef unless $name;

    foreach my $x (@{$self->Events})
    {
        return $x if $x->EventID eq $name;
        return $x if $x->name eq $name;
    }

	return undef;

	# should never need this - if the event exists it will be 
	# fetched by the Events builder

	my $data = $self->ft->fetch("events", $name);

	TRACE( sub { Dumper(\$data) } );
	
	my $e = FencingTime::Event->new($data);

	push @{$self->Events}, $e;
	
	$e;
}

sub events
{
    my $self = shift;

	my $out = {};

    foreach my $x (@{$self->Events})
    {
		$out->{$x->EventID} = $x->name;

		# $out->{$x->EventID} .= $x->IsTeamEvent ? " Team" : " Individual";
    }

	$out;
}

sub add_event
{
	my $self = shift;
	my $e = shift;

	# if (ref $e eq "SCALAR")
	# {
		# $e = FencingTime::Event->new($e);
	# }
	
	foreach (@{$self->Events})
	{
		return 1 if $_ eq $e;
	}

	push @{$self->Events}, $e;	

	1;
}

sub _build_Events
{
	my $self = shift;

	my @out;
	my $seen = {};

	foreach my $f (@{$self->Feeds})
	{
		# TRACE( sub { Dumper($f->Events) });
		foreach my $e (@{$f->Events})
		{
			# TRACE(sub { Dumper($e) } );

			bless $e, 'FencingTime::Event';

			next if $seen->{$e->EventID};

			$seen->{$e->EventID} = 1;

			# TRACE("calling expand");
			$e->expand;	

			push @out, $e;
		}
	}

	# TRACE(sub { Dumper(\@out) } );

	\@out;
}


1;
