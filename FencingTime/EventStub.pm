package FencingTime::EventStub;
use 5.018;
use warnings;
use Types::Standard -types;
use Types::XSD qw(DateTime);
use Type::Utils -all;
use Data::Dumper::Concise;
# use Hash::Merge qw(merge);
use Moo;


#### TYPES ####

#### ATTRIBUTES ####

has ft => (			is => 'lazy',
					default => sub { FencingTime->instance },
);


# is there a  /event/{id}/rounds API
# !!!! NO !!!
has Rounds => ( is => 'lazy' );

has MinsSinceRoundStart => (is => 'lazy', isa => Int);

has State => (is => 'lazy', isa => Int);
# 1 = check in open
# 3 = check in closed, event not started
# 4 = check in closed, event started, first round not published
# 5 = pools running, no results in
# 6 = pools running, some results in
# 7 = tableau drawn, not published
# 8 = tableau in progress, no results
# 10 = tableau in progress, some results
# 11 = tableau finished
# 12 = event finished


has LastRoundID => (is => 'lazy', isa => Int);
has RoundNum => (is => 'lazy', isa => Int);
has RoundID => (is => 'lazy', isa => Int);
has EventID => (is => 'lazy', isa => Int);
has NumCompetitors => (is => 'lazy', isa => Int);
has IsTeamEvent => (is => 'lazy', isa => Bool);

has name => ( is => 'lazy', default => sub { my $self = shift; $self->AgeLimit . " " .  $self->GenderMix . " " . $self->Weapon } );


1;
