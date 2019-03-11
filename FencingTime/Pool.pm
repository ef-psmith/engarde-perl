package FencingTime::Pool;
use 5.018;

use Types::Standard -types;
use Type::Utils -all;
use Moo;
use DT::Log;
use Data::Dumper::Concise;

#### TYPES ####
my $Competitor_type = class_type { class => "FencingTime::PoolCompetitor" };
my $Competitor_list = ArrayRef[InstanceOf[$Competitor_type->plus_coercions(Any, \&_coerce_competitor)]];

has IsCompleted => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1); 

has StripNum => (is => 'lazy', isa => Str);
has Size => (is => 'lazy', isa => Int);
has ID => (is => 'lazy', isa => Int);
has PoolNum => (is => 'lazy', isa => Int);
has PoolTime => (is => 'lazy', isa => Str);

has Competitors => ( 	is 	=> 'lazy',
						isa	=> $Competitor_list,
						coerce => 1,
) ;

# has Referees => () ;

sub _coerce_competitor
{
	my $in = shift; 
	FencingTime::PoolCompetitor->new($in);
}

sub grid
{
	my $self = shift;
	
	my $out;
	my $sequence = 1; 

	foreach my $line (@{$self->Competitors})
	{
		DEBUG( sub { Dumper(\$line) });

		my @s;
		my $id = 1;
		push @s, { id => $id++, score => $_ } for @{$line->Scores};

		my $f = { 	id => $sequence,
					name => $line->Name,
					affiliation => $line->CountryAbbr . " " . $line->ClubAbbr,
					result => [@s],
					vm => $line->WinPercent,
					hs => $line->TouchesScored,
					ind => $line->Indicator,
					pl => $line->Place,
					fencerid => $line->ID,
				};

		push @{$out->{fencer}}, $f;  
		$sequence++;
	}

	$out->{count} = @{$out->{fencer}};

	TRACE( sub { Dumper(\$out) });
	$out;
}


package FencingTime::PoolCompetitor;
use Types::Standard -types;
use Moo;


has Name => (is => 'lazy', isa => Str);
has ID => (is => 'lazy', isa => Int);
has Rating => (is => 'lazy', isa => Str);
has Indicator => (is => 'lazy', isa => Str);
has ClubAbbr => (is => 'lazy', isa => Str);
has Scores => ( is => 'lazy');	# Array of Str
has DivAbbr => (is => 'lazy', isa => Str);
has WinPercent => (is => 'lazy', isa => Str);
has Victories => (is => 'lazy', isa => Str);
has Position => (is => 'lazy', isa => Int);
has CountryAbbr => (is => 'lazy', isa => Str);
has Place => (is => 'lazy', isa => Str);
has TouchesReceived => (is => 'lazy', isa => Str);
has TouchesScored => (is => 'lazy', isa => Str);


1;
