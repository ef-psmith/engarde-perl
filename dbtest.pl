#perl -w
use Engarde;
use Engarde::Control;
use Engarde::DB;
use strict;
use Data::Dumper;
use JSON;
use XML::Simple;

# my $data = {};

# $data = config_read();

$Engarde::DEBUGGING=2;

# print "data = " . Dumper(\$data);
# print XMLout($data, KeyAttr=>'id', AttrIndent=>1, SuppressEmpty => undef, RootName=>'config');


Engarde::DB::checkin_list_json(1);

exit(0);

# my $weapons = $data->{competition};


foreach my $cid (sort { $b <=> $a } keys %$weapons) 
{
	
	print "====================\n";
	my $w = $weapons->{$cid};
	# print Dumper(\$w);
	# next unless $w->{enabled} eq "true";

	# my $state = $w->{'state'};

	# next unless $state eq "check-in";

	my ($name, $path);
	
	$name = $w->{'titre_ligne'};
	$path = $w->{'source'};

	my $t = Engarde::DB::tireur($cid);

	print Dumper(\$t);
	
	print "$cid - $name - $path" ;
	print "\n--------------------\n\n";

	# print encode_json $t;

	#print "key dump start\n";
	#print Dumper(grep /\d+/, keys %$t);
	#print "key dump end\n";

	#my %out = map { {$t->{$_}->{presence}}->{$_} => $t->{$_} } grep /\d+/, keys %$t;
	
	my $out = {};

	$out->{absent}->{count} = $t->{absent} || 0;
	$out->{present}->{count} = $t->{present} || 0;
	$out->{scratched}->{count} = $t->{scratched} || 0;

	foreach my $k (grep /\d+/, keys %$t)
	{
		print "$k $t->{$k}->{presence}\n";
		my $p = $t->{$k}->{presence};
		my $v = $t->{$k};
		print Dumper($v);

		$out->{$p}->{$k} = $v;	
	}

	print Dumper($out);

	print encode_json $out;
	
	print "\n====================\n\n";
}


# weapon_add("/path/to/comp/file", "test for comp add");
