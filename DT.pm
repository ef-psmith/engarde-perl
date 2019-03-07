#!/usr/bin/perl
use 5.018;
use warnings;

package DT;
use Data::Dumper;
use Types::Standard -types;
use Type::Utils -all;
use FencingTime;
use Engarde;
use Moo;


#my $Tournament_type = class_type { class => 'FencingTime::Tournament' };
#my $Tournaments = ArrayRef[$Tournament_type->plus_coercions(Any, \&_coerce_tournament)];

#sub _coerce_tournament
#{
		#my $in = shift;
		#FencingTime::Tournament->new($in);
#}

## ATTRIBUTES ##


has ft => ( is => 'lazy', default => sub { FencingTime->instance } );


## METHODS ##

sub tournament
{
	my $self = shift;
	my $t_name = shift;

	return undef unless $t_name;

	foreach my $t (@{$self->Tournaments})
	{
		return $t if $t->Name eq $t_name;
		return $t if $t->ID eq $t_name;
	}

	return undef;
}

sub tournaments
{
	my $self = shift;

	my $out;
	
	foreach my $t (@{$self->Tournaments})
	{
		$out->{$t->ID} = $t->Name;
	}

	$out;
}


sub find_comp
{
	my $self = shift;
	my $t = $self->Tournaments;

	say Dumper(\$t);
}

sub fetch
{
	my $self = shift;
	my $type = shift;
	my $id = shift;
	my $subtype = shift;

	$self->{host} = "http://" . $self->{host} unless $self->{host} =~ /^http/;

	my $uri = $self->host . $self->base . $type;

	$uri .= "/$id" if defined $id;
	$uri .= "/$subtype" if defined $subtype;
	
	say "Fetching: " . $uri;

	my $data = $self->ua->get($uri);

	# say $data->code;
	# say Dumper($data->decoded_content);

	if ($data->content_length)
	{
		return decode_json($data->decoded_content);
	}
	
	undef;
}

sub post
{
	my $self = shift;
	my $path = shift;
	my $content = shift;
	my $uri = $self->host . $self->base . $path;

	say "Posting to $uri";

	my $r = $self->ua->post($uri, Content => $content);

	# say Dumper(\$r);
}


## PRIVATE METHODS AND BUILDERS ##

sub _build_Tournaments
{
	my $self = shift;
	return $self->fetch('tournaments');
}


1;

