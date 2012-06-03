package Engarde::Twitter;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde Net::Twitter::Lite);

use Data::Dumper;

use Net::Twitter::Lite qw(update);

# This module really does need some additional error / status checking but this is version 0.1 
# so I'm just adding a tweet method to get the workflow sorted out 


sub new 
{
	my $class = shift;

	# not sure the auth keys should be in here but as it's got to be in svn anyway, 
	# it seems a bit moot for now

	my $self = Net::Twitter::Lite->new(
		traits   => [qw/OAuth API::REST/],
		consumer_key        => "Slsj4N6aLPBdMrSl5aRAQ",
		consumer_secret     => "Syk9lPdgqP9XDzV3hfKgqRTvRy6myB1L8TESw5KAzk",
		access_token        => "566661701-fOkoLSgx1UlITx2vgHPIF4qY1dJs5cof5Hh50PnQ",
		access_token_secret => "bheV3UHgeDlfIuIVnOtFPlY9Vg3F63LlOwOAuEVsg",
		);

	bless $self, $class;
	return $self;
}

sub tweet 
{
	my $self = shift;
	my $result = $self->update(@_);
};

1;
