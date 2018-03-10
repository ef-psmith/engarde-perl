package DT::Cyrano;
use 5.018;
use warnings;
use IO::Socket;
# autoflush
$| = 1;


my $sock = new IO::Socket::INET(
	# LocalAddr => '192.168.0.138',
	PeerAddr => '255.255.255.255',
	PeerPort => '50101', # Port the udp server listens on
	Proto => 'udp',
	Broadcast => 1 # Not sure if this is needed, I know the sockopt is
	) || die "[ERROR] $!\n";

	$sock->sockopt(SO_BROADCAST, 1);

my $int = 0;

my $fencers = {
				1 => { name => 'SMITH Peter', nation => 'GBR' },
				2 => { name => 'SMITH Oliver', nation => 'GBR' },
				3 => { name => 'GAROZZO Daniele', nation => 'ITA' },
				4 => { name => 'KRUSE Richard', nation => 'GBR' },
				5 => { name => 'MASSIALAS Alexander', nation => 'USA' },
				6 => { name => 'SAFIN Timur', nation => 'RUS' },
				7 => { name => 'HA Taegyu', nation => 'KOR' },
				9 => { name => 'LE PECHOUX Erwann', nation => 'FRA' },
				10 => { name => 'SAITO Toshiya', nation => 'JPN' },
				11 => { name => 'CHEUNG Ka Long', nation => 'HKG' },
				12 => { name => 'ABOUELKASSEM Alaaeldin', nation => 'EGY' },
				13 => { name => 'CHOUPENITCH Alexander', nation => 'CZE' },
				14 => { name => 'AVOLA Giorgio', nation => 'ITA' },
				15 => { name => 'JOPPICH Peter', nation => 'GER' },
				16 => { name => 'ZHEREBCHENKO Dmitry', nation => 'RUS' },
	};

#while(1)
#{
#	print $sock "test $int";
#	$int++;
#}

#my @result;
#push @result, splice @list, rand @list, 1 while @result < $n;

sub create_match
{
	# create a match between 2 random fencers
	
	my $info = {
	};

	my $fA = get_random_fencer();
	my $fB = get_random_fencer();

	while (no winner)
	{
		info();	# send full info message - response to fake HELLO	
		start_clock(); 
		idle(rand);	# idle for a random period
		info(event);	# send an info message with the event (score / light / etc) - also stop the clock
		isWinner(); # loop check
		sleep_if_NextPeriod();
	}

}


sub _info
{
	my $args = shift;

	printf "|EFP1|INFO|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|", 
		$args->{piste},
		$args->{comp} || "cyrano",
		$args->{phase} || 1,
		$args->{number},				# pool number or tableau name (1, A32, etc)
		$args->{match},					# match number 0-999
		$args->{round},					# round number 0-99
		$args->{time},					# hh:mm 
		$args->{stopwatch},				# time remaining [m]m:ss
		$args->{type} || "I",			# I(ndividual) or T(eam)
		$args->{weapon},				# F E S 
		$args->{priority} || "N",		# N(one) L(eft) R(ight)
		$args->{state},					# F(encing) H(alt) P(ause) W(aiting) E(nding)
		$args->{refid},					
		$args->{refname},					
		$args->{refant},					
		
		
		
	;

}

sub _fencer_msg
{
	my $struct = {
		1 => 'id',					# chr(8)
		2 => 'name',				# chr(20)
		3 => 'nat',					# chr(3)
		4 => 'score',				# int 0-99
		5 => 'status',				# [U V D A E] = [Undefined Victory Defeat Abandon Exclusion]
		6 => 'yelow',				# int 0 or 1
		7 => 'red',					# int 0-9
		8 => 'coloured_light',		# int 0 or 1
		9 => 'white_light',			# int 0 or 1
		10 => 'medical',			# int 0 or 1
		11 => 'reserve',			# [N R] = [None Reserve]
	};

	printf "", $struct->{1};
}


sub _syrano_msg
{
	my $general = shift;
	my $right = shift;
	my $left = shift;

	my $msg = "|EFP1|" . $general . "|%|" . $right . "|%|" . $left;
}
