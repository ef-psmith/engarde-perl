package FencingTime::Result;
use 5.018;

use Types::Standard -types;
use Moo;


has TouchesReceived => (is => 'lazy', isa => Int);
has WDXReason => (is => 'lazy', isa => Str);
has Victories => (is => 'lazy', isa => Bool);
has SecondaryClubAbbr => (is => 'lazy', isa => Str);
has BoutsFenced => (is => 'lazy', isa => Int);
has TeamID => (is => 'lazy', isa => => Int);
has Prediction => (is => 'lazy', isa => Str);
has PrimaryClubID => (is => 'lazy', isa => Int);
has CountryID => (is => 'lazy', isa => Int);
has TouchesScored => (is => 'lazy', isa => Int);
has PrimaryClubAbbr => (is => 'lazy', isa => Str);
has SecondaryClubID => (is => 'lazy', isa => Int);
has FencerID => (is => 'lazy', isa => Int);
has Name => (is => 'lazy', isa => Str);
has DivisionAbbr => (is => 'lazy', isa => Str,);
has CountryAbbr => (is => 'lazy', isa => Str);
has WinPercentage => (is => 'lazy', isa => Num);
has DivisionID => (is => 'lazy', isa => Int);
has Indicator => (is => 'lazy', isa => Int);


1;
