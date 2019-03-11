package FencingTime::Event;
use 5.018;
use warnings;
use Types::Standard -types;
use Types::XSD qw(DateTime);
use Type::Utils -all;
use Data::Dumper::Concise;
# use Hash::Merge qw(merge);
use FencingTime::Fencer;
use FencingTime::Pool;
use FencingTime::Elimination;
use DT::Log;
use Moo;


#### CONSTRUCTOR MODIFIERS ####
sub BUILD 
{
	# since Event objects are now re-blessed from EventStub objects, 
	# this won't get called
	my $self = shift;
	$self->expand;
	#my $t = $self->ft->tournament($self->TournamentID);

	#$t->add_event($self);
}

#### TYPES ####
my $Fencer_type = class_type { class => "FencingTime::Fencer" };
my $Fencer_list = ArrayRef[InstanceOf[$Fencer_type->plus_coercions(Any, \&_coerce_fencer)]];

my $Pool_type = class_type { class => "FencingTime::Pool" };
my $Pool_list = Maybe[ArrayRef[InstanceOf[$Pool_type->plus_coercions(Any, \&_coerce_pool)]]];

my $Elim_type = class_type { class => "FencingTime::Elimination" };
my $Elim_list = Maybe[InstanceOf[$Elim_type->plus_coercions(Any, \&_coerce_elim)]];

#### ATTRIBUTES ####

has ft => (		is => 'lazy',
				default => sub { FencingTime->instance },
);

# Seeding refers to the current round, whatever that is
has Seeding => ( 	is => 'lazy',
					isa => $Fencer_list,
					coerce => 1,
					clearer => 1,
);

# Pools refers to the current round, whatever that is
has Pools => ( 	is => 'lazy',
				isa => $Pool_list,
				coerce => 1,
				clearer => 1,
);

# ResultsSoFar will not include the eventual winner
has ResultsSoFar => ( 	is => 'lazy',
						isa => $Fencer_list,
						coerce => 1,
						clearer => 1,
);


has Results => ( 	is => 'lazy',
					isa => $Fencer_list,
					coerce => 1,
					clearer => 1,
);

has Competitors => ( 	is => 'lazy',
						isa => $Fencer_list,
						coerce => 1,
						clearer => 1,
);

has Elimination => (	is => 'lazy',
						isa => $Elim_list,
						coerce => 1,
						clearer => 1,
);

# is there a  /event/{id}/rounds API
# !!!! NO !!!
has Rounds => ( is => 'lazy' );

has MinsSinceRoundStart => (is => 'lazy', isa => Int);

has State => (is => 'rw', isa => Str);
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
has ID => (is => 'lazy', isa => Int, default => sub { shift->EventID });
has NumCompetitors => (is => 'lazy', isa => Int);
has IsTeamEvent => (is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);

# these are returned from the .../events/{eid} end point
has TournamentID => ( is => 'rwp', isa => Int);
has EventType => ( is => 'lazy', isa => Str);
has Wheelchair => ( is => 'lazy', isa => Str);
has PointList1Abbr => ( is => 'lazy', isa => Str);
has IsStarted => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);

has RegOpenTime => ( is => 'lazy', isa => DateTime );
has RatingLevel => ( is => 'lazy', isa => Str );
has CurRoundNum => ( is => 'lazy', isa => Int );
has EntryFee => ( is => 'lazy', isa => Num );
has RegCloseTime => ( is => 'lazy', isa => DateTime);
has Weapon => ( is => 'rwp', isa => Str);
has AltName => ( is => 'lazy', isa => Str);
has IsQualifier => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);
has AgeLimit => ( is => 'rwp', isa => Str );
has PointList2Abbr => ( is => 'lazy', isa => Str );
has IsFinished => ( is => 'rwp', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);
has GenderMix => ( is => 'rwp', isa => Str );
has RankType => ( is => 'lazy', isa => Str );

has name => ( is => 'lazy', default => sub { my $self = shift; $self->AgeLimit . " " .  $self->GenderMix . " " . $self->Weapon } );

has numPools => ( is => 'rwp', default => 0 );
has numCompleted => ( is => 'rwp', default => 0 );

has FeedState => ( is => 'rwp', default => 0 );

has last_fetch => ( is => 'lazy', isa => Int, default => sub { time }, clearer => 1);

#has entry_list => ( is => 'lazy', default => 

#### METHODS ####

before qw(entry_list ranking) => sub {
	my $self = shift;
	my $age = time - $self->last_fetch;

	if ($age gt $self->ft->timeout)
	{
		$self->clear_Competitors;
		$self->clear_Pools;
		$self->clear_Elimination;
		$self->clear_last_fetch;
	
		TRACE ( sub { "event data cleared - age = $age" } );
	}
};

#### Engarde COMPATIBLE DATA ACCESS METHODS ####

sub domaine_compe
{
	"international";
}

sub etat
{
	my $self = shift;

	# 1 = check in open
	# 3 = check in closed, event not started
	# 4 = check in closed, event started, first round not published
	# 5 = pools running, no results in
	# 6 = pools running, some results in
	# 7 = tableau drawn, not published
	# 8 = tableau in progress, no results
	# 10 = tableau in progress, some results
	# 11 = tableau finished - set to termine to get tableau to display
	# 12 = event finished
	# 14
	# 15 - no idea what these mean in detail bu they're tableau!

	# check 12 and 14 - have they changed in 4.3?
	my $translate = {
		0 => 'debut',
		1 => 'debut',
		2 => 'debut',
		3 => 'debut',
		4 => 'debut',
		5 => 'poules',
		6 => 'poules',
		7 => 'poules',
		8 => 'tableau',
		9 => 'tableau',
		10 => 'tableau',
		11 => 'tableau',
		12 => 'termine',
		14 => 'tableau',
		15 => 'tableau',
	};

	DEBUG("state = " . $self->State);
	$translate->{$self->State};
}

sub entry_list 
{
	my $self = shift;	
	my $list = {};
	my @lout;

	my $sequence = 1;
	my $absent = 0;
	my $present = 0;
	my $scratch = 0;

	foreach my $e (sort {$a->Name cmp $b->Name } @{$self->Competitors})
	{
		push @lout, {   name => $e->Name,
						affiliation => $e->affiliation,
						seed => $e->Rank,
						id => $e->FencerID ,
						category => "category",
						presence => _presence($e->CheckInStatus), 
						sequence => $sequence};

		$present++ if $e->CheckInStatus eq 'Checked-In';
		$absent++ if $e->CheckInStatus eq 'Absent';
		$scratch++ if $e->CheckInStatus eq 'Scratched';
		$sequence++;
	}

	my $entries = $present + $absent + $scratch;

	$list->{fencer} = [@lout];
	$list->{count} = @lout;
	$list->{name} = 'entry';
	$list->{present} = $present;
	$list->{absent} = $absent;
	$list->{scratch} = $scratch;
	$list->{entries} = $entries;

	$list;
}

sub fpp
{
	my $self = shift;
	my $out = {};
	my $sequence = 1;

	# $out->{fpp}->{fencer} = [{},{},{}]
	# $out->{fpp}->{count} = Int

	# empty list if pools haven't been issued
	DEBUG ($self->State);
	return $out if $self->State < 4;

	my $p = $self->strips;

	DEBUG( sub { Dumper(\$p) } );

	foreach my $e (sort { $a->{Name} cmp $b->{Name} } @$p)
	{
		push @{$out->{fencer}}, {   
						name => $e->{Name},
                        #affiliation => substr($e->affiliation,0,16),
                        piste => $e->{StripNum} || ' ',
                        poule => $e->{PoolNum} || '',
                        id => $e->{FencerID} || '',
						time => $e->{StartTime},
						round => $self->RoundNum,
                        sequence => $sequence
					};
        $sequence++;
   
	}

	$out->{count} = scalar @{$out->{fencer}};

	$out;
}

sub elim_bouts
{
	my $self = shift;

	# regular DE will only have one Tableaus object so assume it's the first one for now
	my $e = ${$self->Elimination->Tableaus}[0];

	my @fpp = $e->fpp;

	#TRACE( sub { Dumper(\@fpp) } );
	DEBUG(@fpp . " piste assignements found");
}

sub matchlist
{
	my $self = shift;
	my $e = $self->Elimination;
	return undef unless $e;
	my $matchlist = $e->matchlist;

	$matchlist;

}

sub tableau_with_matches
{
	my $self = shift;

	my $out = $self->matchlist;

	# DEBUG( sub { Dumper(\$out) });

	$out;
}

sub nombre_poules
{
	my $self=shift;

	return [$self->numPools];
	
	my $p = $self->Pools;

	# TRACE( sub { Dumper(\$p) } );
	scalar @$p;	
}

sub poolsRemaining 
{ 
	my $self = shift;

	my @out;

	my @p = $self->Pools;

	# DEBUG( sub { Dumper(\@p) });

	return @out unless $self->Pools;

	foreach (values @{$self->Pools})
	{
		push @out, $_->PoolNum unless $_->IsCompleted;
	}

	DEBUG( sub { Dumper(\@out) });
	@out;
} 

sub poules_list
{
	my $self = shift;

	my $p = $self->Pools;
	my $out = {};

#  <pools count="16" round="1">
#    <pool heure="0:00" number="1" piste="N/A" size="7">
#      <fencers count="7">
#        <fencer name="SHILLINGFORD Jason" affiliation="PLYMOUTH" fencerid="47" hs="11" id="1" ind="-19" pl="7" vm="0/6">
#          <result id="1" score="" />
#          <result id="2" score="1" />
#          <result id="3" score="2" />
#          <result id="4" score="3" />
#          <result id="5" score="0" />
#          <result id="6" score="4" />
#          <result id="7" score="1" />
#        </fencer>
#
#			etc

	my @pout;
	foreach my $pool (@$p)
	{
		push @pout, {
			number => $pool->PoolNum,
			piste => $pool->StripNum,
			heure => $pool->PoolTime,
			size => $pool->Size,
			fencers => $pool->grid,
		};

	}

	$out->{pools}->{count} = @pout;
	$out->{pools}->{pool} = [@pout];

	my $round = $self->RoundNum;
	$round-- if $self->State == 7;
	$out->{pools}->{round} = $round;

	WARN( sub { Dumper(\$out) });
	$out;
}

sub ranking
{
	my $self = shift;
	my $type = shift || "f";

	my $poolres = {};
	my $out = {};
	my @elim;

	if ($self->State == 6)
	{
		foreach (@{$self->temppoolres})
		{
			my $id = $self->IsTeamEvent ? $_->{TeamID} : $_->{FencerID};

			$out->{$id}->{v} = $_->{Victories};
			$out->{$id}->{hs} = $_->{TouchesScored};
			$out->{$id}->{hr} = $_->{TouchesReceived};
			$out->{$id}->{ind} = $_->{Indicator};
			$out->{$id}->{vm} = sprintf "%.3f", $_->{WinPercentage};

			my $place = $_->{Place};
			$place =~ s/T//g;

			$out->{$id}->{seed} = $place;
			$out->{$id}->{place} = $place;
			$out->{$id}->{nom} = $_->{Name};
			$out->{$id}->{nom_court} = $_->{Name};
			$out->{$id}->{nation} = $_->{CountryAbbr};
			$out->{$id}->{club} = $_->{PrimaryClubAbbr};
			$out->{$id}->{affiliation} = $_->{CountryAbbr} || $_->{PrimaryClubAbbr};

			# $out->{$id}->{group} = $_->{} eq "Advanced" ? "elim_none" : "elim_p";
		}

		return $out;
	}
	elsif ($self->LastRoundID)
	{
		foreach (@{$self->Seeding})
		{	
			my $id = $self->IsTeamEvent ? $_->{TeamID} : $_->{FencerID};
			$poolres->{$id} = $_;	
		}
	}

	if ($type eq "p")
	{
		@elim = values %{$poolres};
	}
	else
	{
		@elim = $self->IsFinished ? @{$self->Results} : @{$self->ResultsSoFar};

		# TRACE( sub { Dumper(\@elim) } );
		# @elim = @{$self->Results};
	}

	# TRACE( sub { Dumper(\@elim) } );

	# can't determine group here - maybe assume based on position?
	# my $group = "elim_" . $self->Size;


	#DEBUG( sub { Dumper(\$poolres) });

	foreach my $f (@elim)
	{
		my $place = $type eq "p" ? $f->Seed : $f->FinalPlace;

		TRACE("place = $place");

		$place =~ s/T//g;

		$place = 999 if $place eq "DNF";

		TRACE ( sub { Dumper(\$f) } );

		my $pf = $poolres->{$f->FencerID};

		next unless $pf;

		if ($pf->HasPoolResults)
		{
			$out->{$f->FencerID}->{v} = $pf->PoolVictories;
			$out->{$f->FencerID}->{hs} = $pf->PoolTouchesScored;
			$out->{$f->FencerID}->{hr} = $pf->PoolTouchesReceived;
			$out->{$f->FencerID}->{ind} = $pf->PoolIndicator;
			$out->{$f->FencerID}->{vm} = sprintf "%.3f", $pf->PoolWinPercentage;

			if ($pf->Status eq "Advanced")
			{
				if ($type eq "p")
				{
					$out->{$f->FencerID}->{group} = "elim_none";
				}
			}
			else
			{
				$out->{$f->FencerID}->{group} = "elim_p"; 
			}
	
		}


		$out->{$f->FencerID}->{seed} = $place;
		$out->{$f->FencerID}->{place} = $place;
		$out->{$f->FencerID}->{nom} = $f->Name;
		$out->{$f->FencerID}->{nom_court} = $f->Name;
		$out->{$f->FencerID}->{nation} = $f->CountryAbbr;
		$out->{$f->FencerID}->{club} = $f->PrimaryClubAbbr;
		$out->{$f->FencerID}->{affiliation} = $f->CountryAbbr || $f->PrimaryClubAbbr;

		$out->{$f->FencerID}->{group} = "elim_none" unless $place;


		# TRACE ( sub { Dumper ($out->{$f->FencerID}) } )
	}


	# TRACE("**********************");

	# TRACE( sub { Dumper(\$out) } );

	$out;
}

sub tableau
{
	my $self=shift;
	my $t = shift;
	# TRACE($t);

	$self->Elimination->tableau($t);
}

sub tableaux
{
	# return a list of all tableaux
	my $self = shift;
	my @out;

	my $e = ${$self->Elimination->Tableaus}[0];

	foreach my $t ( sort { $b->Size <=> $a->Size } @{$e->Tables})
	{
		push @out, $t->Name;
	}

	# TRACE( sub { Dumper(\@out) } );
	@out;
}

sub tableaux_en_cours
{
	# return a list of active tableaux
	my $self = shift;
	my @out;

	my $e = ${$self->Elimination->Tableaus}[0];

	foreach my $t ( sort { $b->Size <=> $a->Size } @{$e->Tables})
	{
		push @out, $t->suitename if $t->NumComplete lt $t->Size;
	}

	# TRACE( sub { Dumper(\@out) } );
}

sub tireurs
{
	# convert array of fencer objects to hashref

    #CheckInStatus => "Checked-In",
    #CountryAbbr => "GBR",
    #CountryID => 32772,
    #FencerID => 393227,
    #Name => "LLLL Lll",
    #PrimaryClubAbbr => "",
    #PrimaryClubID => 0,
    #Rank => "",
	
	#$output->{$id} = { nom=>$nom, club=>$club, serie=>$serie, nation=>$nation, presence=>$presence };

	#$output->{scratch} = $t->{scratch};
	#$output->{present} = $t->{present};
	#$output->{absent} = $t->{absent};
	#$output->{entries} = $t->{entries};

	my $out = {};

	my $c = shift->Competitors;

	foreach my $f (@$c)
	{
		# TRACE("f = " . Dumper($f));

		$out->{$f->FencerID} = 
			{ 
				nom => $f->Name, 
				club => $f->PrimaryClubAbbr, 
				serie => 1, 
				nation => $f->CountryAbbr, 
				presence => _presence($f->CheckInStatus), 
			};
	}

	$out;
}

sub titre_ligne
{
	my $self = shift;

	# my $type = $self->IsTeamEvent ? " Team" : " Individual";

	my $name = $self->name;

	$name =~ s/Saber/Sabre/;

	# $name . $type;
	$name;
}

sub whereami
{
	my $self = shift;

	my $out = $self->etat;

	#say $self->numPools;
	#say $self->numCompleted;

	if ($out eq "poules")
	{
		my $round = $self->RoundNum;

		$round-- if $self->State == 7;
		$out .= " " . $round;
		
		if ($self->poolsRemaining)
		{
			$out .= " " . $self->poolsRemaining;
		}
		else
		{
			$out .= " finished";
		}
	}
	elsif ($out eq "tableau")
	{
		my @active = $self->Elimination->active;

		TRACE ( sub { Dumper(\@active) } );

		unless (@active)
		{
			TRACE ( "Forcing tableau to A4/A2" );
			@active = qw(A4 A2);
		}

		
		$out = "$out @active";
	}
	
	$out;
}

#### NATIVE DATA ACCESS METHODS ####

sub fencers
{
	my $self = shift;
	$self->ft->fetch("events", $self->EventID, "fencers");
}

sub temppoolres
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "temppoolres");
}

sub elimination
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "elimination");
}

sub resultssofar
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "resultssofar");
}

sub strips
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "strips");
}

sub expand
{
	my $self = shift;
	my $data = $self->ft->fetch("events", $self->ID);

	# TRACE( sub { Dumper(\$data) } );

	$self->_set_AgeLimit($data->{AgeLimit});
	$self->_set_GenderMix($data->{GenderMix});
	$self->_set_Weapon($data->{Weapon});
	$self->_set_TournamentID($data->{TournamentID});
	$self->_set_IsFinished($data->{IsFinished});
}


#### PRIVATE METHODS ####

sub _build_Seeding
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "seeding");
}

sub _build_Pools
{
	# WARNING: this assumes that there is only one phase in the tableau
	# and will probably break badly for other event types
	my $self = shift;

	my $etat = $self->etat;	
	my $round = ($etat eq "tableau" || $self->State == 7) ? $self->LastRoundID : $self->RoundID;
	my $p = $self->ft->fetch("rounds", $round, "pools");
	if (defined $p)
	{
		$self->_set_numPools(scalar @$p);
	}
	$p;
}

sub _build_numCompleted
{
	my $self = shift;

	my $done = 0;
	foreach (values @{$self->Pools})
	{
		$done++ if $_->IsCompleted;
	}

	$done;
}

sub _build_ResultsSoFar
{
	my $self = shift;
	$self->ft->fetch("rounds", $self->RoundID, "resultssofar");
}

sub _build_Results
{
	my $self = shift;
	$self->ft->fetch("events", $self->EventID, "results");
}

sub _build_Competitors
{
	my $self = shift;
	$self->ft->fetch("events", $self->EventID, "competitors");
}

sub _build_Elimination
{
	my $self = shift;
	my $round = $self->RoundID;
	$round = $self->LastRoundID if $self->State == 12;
	#return {} if ($self->State < 7 || $self->State == 12);

	$self->ft->fetch("rounds", $round, "elimination");
}

sub _build_Rounds
{
	my $self = shift;
	$self->ft->fetch("rounds");
}
sub _coerce_fencer
{
	my $in = shift;
	FencingTime::Fencer->new($in);
}

sub _coerce_pool
{
	my $in = shift;
	FencingTime::Pool->new($in);
}

sub _coerce_elim
{
	my $in = shift;
	FencingTime::Elimination->new($in);
}


sub _presence
{
	# convert CheckInStatus to Engarde presence

	my $state = shift;

	return "present" if $state eq "Checked-In";
	return "scratched" if $state eq "Scratched";
	return "absent";
}


1;
