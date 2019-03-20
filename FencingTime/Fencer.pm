package FencingTime::Fencer;
use 5.018;
use Moo;
use Types::Standard -types;

has FencerID => (is => 'lazy', isa => Int);
has TeamID => (is => 'lazy', isa => Int);
has Seed => (is => 'lazy', default => '', isa => Str);
has Rank => (is => 'lazy', isa => Str);
has PrimaryClubAbbr => ( is => 'lazy', isa => Str);
has PrimaryClubID => (is => 'lazy', isa => Int);
has SecondaryClubAbbr => ( is => 'lazy', isa => Str);
has SecondaryClubID => (is => 'lazy', isa => Int);
has DivisionAbbr => ( is => 'lazy', isa => Str);
has DivisionID => (is => 'lazy', isa => Int);
has CountryAbbr => ( is => 'lazy', isa => Str);
has CountryID => (is => 'lazy', isa => Int);
has IsExcluded => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ $_ eq "false" ? 1 : 0 }), coerce => 1);
has IsNoShow => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ $_ eq "false" ? 1 : 0 }), coerce => 1);
has Status => (is => 'lazy', isa => Str);
has HasPoolResults => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !$_ eq "false" ? 1 : 0 }), coerce => 1);
 
has PoolVictories => (is => 'lazy', isa => Int);
has PoolWinPercentage => (is => 'lazy', isa => Num);
has PoolTouchesScored => (is => 'lazy', isa => Int);
has PoolTouchesReceived => (is => 'lazy', isa => Int);
has PoolIndicator => (is => 'lazy', isa => Int);
has Name => (is => 'lazy', isa => Str);

# added by resultssofar endpoint
#has Rating => (is => 'lazy', isa => Str);
has Rating => (is => 'lazy');
has FinalPlace => (is => 'lazy', isa => Str);
has QualifiedFor => (is => 'lazy', isa => Str);
#as EarnedRating => (is => 'lazy', isa => Str);
has EarnedRating => (is => 'lazy');


# added by competitors endpoint


has CheckInStatus => (is => 'lazy', isa => Str);
has TeamMembers => (is => 'lazy', isa => Str);
has TeamData => (is => 'lazy');


# Engarde attributes
has affiliation => ( is => 'lazy', default => sub { my $self=shift; $self->PrimaryClubID ? $self->PrimaryClubAbbr : $self->CountryAbbr } );

has presence => ( is => 'lazy', default => sub { my $self=shift; $self->CheckInStatus eq 'absent' ? 'absent' : 'present' });

has nom => ( is => 'lazy', default => sub { my $self=shift; $self->Name });

1;

