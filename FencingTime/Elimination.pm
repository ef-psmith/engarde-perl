package FencingTime::Elimination;
use 5.018;

use Types::Standard -types;
use Type::Utils -all;
use DT::Log;
use Data::Dumper::Concise;
use Moo;

#### TYPES ####
my $Tableau_type = class_type { class => "FencingTime::Tableau" };
my $Tableau_list = ArrayRef[InstanceOf[$Tableau_type->plus_coercions(Any, \&_coerce_tableau)]];

has ElimType => ( is => 'lazy', isa => Str);

has Tableaus => ( 	is 	=> 'lazy',
					isa	=> $Tableau_list,
					coerce => 1,
);


sub _coerce_tableau
{
	my $in = shift; 
	FencingTime::Tableau->new($in);
}

sub matchlist
{
	my $self=shift;
	my $t = ${$self->Tableaus}[0];
	INFO("fetching matchlist for default Tableau");
	my $out = $t->matchlist(shift);
	TRACE( sub { Dumper(\$out) });
	$out;
}

sub tableau
{
	my $self = shift;
	my $t = $self->Tableaus;
	TRACE( sub { Dumper(\$t) } );
	${$t}[0]->tableau(shift);
}


sub active
{
	my $self = shift;
	my $t = ${$self->Tableaus}[0];

	my @out;

	foreach my $x (sort { $b->Size <=> $a->Size } @{$t->Tables})
	{
		TRACE(sub { Dumper(\$x) });

		next if $x->isComplete;
		next unless $x->NumCreated;

		push @out, $x->suitename;
	}

	DEBUG("out = @out");
	@out;
}

package FencingTime::Tableau;
use Types::Standard -types;
use Type::Utils -all;
use Data::Dumper::Concise;
use Hash::Merge qw(merge);
use DT::Log;
use Moo;


#### TYPES ####
my $Table_type = class_type { class => "FencingTime::Table" };
my $Table_list = ArrayRef[InstanceOf[$Table_type->plus_coercions(Any, \&_coerce_table)]];

has StartSize => ( is => 'lazy', isa => Int);
has EndSize => ( is => 'lazy', isa => Int);

has Tables => (		is => 'lazy',
					isa => $Table_list,
					coerce => 1,
);

sub _coerce_table
{
	my $in = shift; 
	FencingTime::Table->new($in);
}

sub fpp
{
	my $self = shift;
	my @out;

	foreach (@{$self->Tables})
	{
		my @fpp = $_->fpp;
		push @out, @fpp if @fpp;
	}

	@out;
}

sub matchlist
{
	my $self = shift;
	my $out = {};

	foreach (sort { $b->Size <=> $a->Size } @{$self->Tables})
	{
		INFO("fetching matchlist for " . $_->Size);
		my $m = $_->matchlist;
		ERROR($_->Size . " has " . $m->{unfinished_matches} . " unfinished");
		# next unless $m->{unfinished_matches};
		next if $m->{blank_matches} eq $_->Size /2 ;
		DEBUG(sub { Dumper(\$m) });
		$out->{$_->suitename} = $m;
	}

	TRACE( sub { Dumper(\$out) });
	$out;	
}

sub tableau
{
	my $self = shift;
	my $name = shift;

	foreach (@{$self->Tables})
	{
		return $_ if $_->Name eq $name;
		return $_ if $_->Size eq $name;
		return $_ if $_->suitename eq $name;
	}

	undef;
}


package FencingTime::Table;
use Types::Standard -types;
use Type::Utils -all;
use Moo;
use Data::Dumper::Concise;
use DT::Log;

#### TYPES ####
my $Bout_type = class_type { class => "FencingTime::Bout" };
my $Bout_list = ArrayRef[InstanceOf[$Bout_type->plus_coercions(Any, \&_coerce_bout)]];

has Name => ( is => 'lazy', isa => Str);
has Size => ( is => 'lazy', isa => Int);
has NumParts => ( is => 'lazy', isa => Int);

has Bouts => ( is => 'lazy',
					isa => $Bout_list,
					coerce => 1,
);

has NumComplete => ( is => 'lazy', isa => Int, default => sub { 
	my $b = shift->Bouts;
	my $sum = 0;
	$sum += $_->Finished for @$b; 
	$sum; 
});

# number of matches which exist, even if only one fencer is known
has NumCreated => ( is => 'lazy', isa => Maybe[Int], default => sub { 
	my $b = shift->Bouts;
	my $sum = 0;
	$sum += ($_->TopCompetitor->Name || $_->BottomCompetitor->Name) ? 1 : 0 for @$b; 
	$sum; 
});

has suitename => ( is => 'lazy', isa => Str, default => sub { "A" . shift->Size } );

sub isComplete
{
	my $self = shift;
	return 0 unless $self->NumComplete;
	return 1 if $self->NumComplete eq $self->Size / 2;
	DEBUG("suitename = " . $self->suitename);
	DEBUG("complete = " . $self->NumComplete);
	DEBUG("size = " . $self->Size);
	0;
}

sub _coerce_bout
{
	my $in = shift; 
	FencingTime::Bout->new($in);
}

sub fpp
{
	my $self = shift;
	my @out;

	foreach (@{$self->Bouts})
	{
		next if $_->WinnerSeed;

		if ($_->TopCompetitor->Name)
		{
			push @out, { 	name => $_->TopCompetitor->Name, 
							time => $_->StartTime, 
							round => $self->Name, 
							piste => $_->Strip, 
						};
		}

		if ($_->BottomCompetitor->Name)
		{
			push @out, { 	name => $_->BottomCompetitor->Name, 
							time => $_->StartTime, 
							round => $self->Name, 
							piste => $_->Strip, 
						};
		}
	}

	@out;
}

sub matchlist
{
	my $self = shift;
	my $out = {};
	my $sequence = 0;

	TRACE("start");
	
	my $size = $self->Size;

	$out->{name} = $self->suitename;;
	$out->{count} = $size / 2;
	$out->{title} = $self->Name;
	$out->{total_matches} = 0;
	$out->{blank_matches} = 0;
	$out->{unfinished_matches} = 0;
	$out->{match} = [];

	# add sort by bout number
	foreach my $m (sort { $a->BoutNum cmp $b->BoutNum } @{$self->Bouts})
	{
		# my $p = $m->Strip || -1;

		# TRACE(ref $m . " $p");

		$out->{total_matches} += 1;
		$out->{start_time} = $m->StartTime unless $out->{start_time};
		# $out->{start_time} = $m->StartTime if $m->StartTime < $out->{start_time};

		# next if $m->WinnerSeed;

		unless ($m->Finished)
		{
			$out->{unfinished_matches} += 1;
			$out->{blank_matches} += 1 unless ($m->TopCompetitor->Name || $m->BottomCompetitor->Name);
			TRACE( "unfinished match " . $out->{unfinished_matches});
			TRACE( sub { Dumper(\$m) } );
		}

		#	'time' => '0:00',
		#	'status' => 'late',
		#	'end_time' => 1518222000,
		#	'categoryA' => '',
		#	'categoryB' => ''
	
		my $match = { 
					number => $m->BoutNum,
					# winnername => $m->Winner->Name,
					winnerid => $m->Winner->ID,
					scoreA	=>	$m->ScoreA,
					scoreB => $m->ScoreB,
					piste => $m->Strip,
					fencerA => 	{	name => $m->TopCompetitor->Name, 
									affiliation => $m->TopCompetitor->ClubAbbr, 
									club => $m->TopCompetitor->ClubAbbr, 
									# nation => $m->TopCompetitor->Nation, 
									id => $m->TopCompetitor->ID, 
									seed => $m->TopSeed 
								}, 
					fencerB => 	{	name => $m->BottomCompetitor->Name, 
									affiliation => $m->BottomCompetitor->ClubAbbr, 
									club => $m->BottomCompetitor->ClubAbbr, 
									# nation => $m->BottomCompetitor->Nation, 
									id => $m->BottomCompetitor->ID, 
									seed => $m->BottomSeed 
								},
					# check format
					start_time => $m->StartTime,
				#	end_time => time in HH:mm format,
					#idA => $m->TopCompetitor->ID,
					#idB => $m->BottomCompetitor->ID,
				#	categoryA => category ?,
				# 	categoryB => category ?,
					#fencerA => $m->TopCompetitor->Name,
					#fencerB => $m->BottomCompetitor->Name,
					#fencerA_court => substr($m->TopCompetitor->Name,0,16),
					#fencerB_court => substr($m->BottomCompetitor->Name,0,16),
					#seedA => $m->TopSeed,
					#seedA => $m->BottomSeed,
				};

		
		push @{$out->{match}}, $match;

	}


	TRACE( sub { Dumper(\$out) });
	$out;
}

sub nom_etendu
{
	shift->Name;
}

sub taille
{
	shift->Size;
}



package FencingTime::Bout;
use Types::Standard -types;
use Type::Utils -all;
use DT::Log;
use Data::Dumper::Concise;
use Moo;

#### TYPES ####
my $Comp_type = class_type { class => "FencingTime::BoutCompetitor" };
my $Comp = InstanceOf[$Comp_type->plus_coercions(Any, \&_coerce_comp)];

has BoutID => ( is => 'lazy', isa => Int);
has BoutNum => ( is => 'lazy', isa => Int);
has TableSize => ( is => 'lazy', isa => Int);
has Strip => ( is => 'lazy', isa => Str);
has Score => ( is => 'lazy', isa => Str);
# NumEncounters is always set to 3 which is wrong!
#has NumEncounters => ( is => 'lazy', isa => Int);
has TopSeed => ( is => 'lazy', isa => Str);
has BottomSeed => ( is => 'lazy', isa => Str);
has WinnerBye => ( is => 'lazy', isa => Bool);
has WinnerSeed => ( is => 'lazy', isa => Str, default => '');
has TeamMatchID => ( is => 'lazy', isa => Int);
has TopBye => ( is => 'lazy', isa => Bool);
has BottomBye => ( is => 'lazy', isa => Bool);
has StartTime => ( is => 'lazy', isa => Str);

has TopCompetitor => ( is => 'lazy', isa => $Comp, coerce => 1);
has BottomCompetitor => ( is => 'lazy', isa => $Comp, coerce => 1);
has Winner => ( is => 'lazy', isa => $Comp, default => sub { {}; }, coerce => 1);

has Finished => ( is => 'lazy', isa => Bool, default => sub { my $self=shift; $self->WinnerSeed ? 1 : 0 } );

sub ScoreA 
{ 
	my @s = split /\s-\s/, shift->Score;
	$s[0];
}

sub ScoreB 
{ 
	my @s = split /\s-\s/, shift->Score;
	$s[1];
}

sub _coerce_comp
{
	my $in = shift; 
	FencingTime::BoutCompetitor->new($in);
}

sub _build_TopCompetitor
{
	my $in = shift;
	FencingTime::BoutCompetitor->new({});
}

sub _build_BottomCompetitor
{
	my $in = shift;
	FencingTime::BoutCompetitor->new({});
}

package FencingTime::BoutCompetitor;
use Types::Standard -types;
use Moo;

has ID => ( is => 'lazy', isa => Int);
has Position => ( is => 'lazy', isa => Int);
has CountryAbbr => ( is => 'lazy', isa => Str, default => '');
has ClubAbbr => ( is => 'lazy', isa => Str, default => '');
has Name => ( is => 'lazy', isa => Str, default => '');
has Rating => ( is => 'lazy', isa => Str);
has DivAbbr => ( is => 'lazy', isa => Str);
has IsLeftHanded => ( is => 'lazy', isa => Bool);

sub _build_Name
{
	'';
}

sub _build_ID
{
	-1;
}

1;
