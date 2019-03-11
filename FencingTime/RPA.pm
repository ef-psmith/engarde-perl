package FencingTime::RPA;
use 5.018;

use Types::Standard -types;
use Types::XSD qw(DateTime);
use Moo;

has RefName => ( is => 'lazy', isa => Str );
has TableName => ( is => 'lazy', isa => Str );
has Comp1Name => ( is => 'lazy', isa => Str );
has PoolNum => ( is => 'lazy', isa => Int );
has Comp2Name => ( is => 'lazy', isa => Str );
has StripNum => ( is => 'lazy', isa => Str );

has StartTime => ( is => 'lazy', isa => DateTime );

has Video => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);

has Assist => ( is => 'lazy', isa => Bool->plus_coercions(Any, q{ !!$_ }), coerce => 1);

#has Event => ( 	is => 'lazy', isa => Events_type, coerce => 1 );

1;

