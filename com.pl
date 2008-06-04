#!perl -w

use strict;
use Data::Dumper;

use Win32::SerialPort;

my $ob;

# Constructor

unless ($ob = Win32::SerialPort->new ('com8')) 
{
    printf "could not open port COM1\n";
    exit 1;
}

$ob->baudrate(9600)		|| die "bad baudrate";
$ob->parity('none')		|| die "bad parity";
$ob->databits(8)		|| die "bad databits";
$ob->stopbits(1)		|| die "bad stopbits";

$ob->write_settings		|| undef $ob;
unless ($ob)			{ die "couldn't write_settings"; }

print "write_settings done\n";
$ob->handshake("rts")		|| die "bad handshake";

my $score_l = 0;
my $score_r = 0;
my $tm = 0;
my $ts = 0;


my $SOH = "01";
my $DC3 = "13";
my $EOT = "04";

# open( PORT, "+>COM8" ) or die "Can't open COM8: $!";
# open( PORT, "COM8" ) or die "Can't open COM8: $!";

# not sure if this works or not!
# binmode PORT;

my $in;

my $buf;
# local $/ = 0x01;
while (sysread(PORT, $in, 55))
# while (<PORT>)
{
	$buf .= ascii_to_hex($in);

	# print "TOP: buf = $buf\n";

	my $start = index($buf, "$SOH ");

	# print "TOP: start = $start\n";

	$buf = substr($buf, $start) if $start > 0;

	my $end = index($buf, "$EOT ");
   
	while ($start >= 0 && $end > 0)
	{
		# print "start = $start\n";
		# print "buf = $buf, end = $end\n";
		
		my $msg = substr($buf, 3, $end-3);
		$buf = substr($buf, $end + 3);


		my $id = substr($msg,0,2);
		my $type = substr($msg,3,2);

		if ($id eq $DC3)
		{
			# standard message type

			if ($type eq "53")
			{
				# Score
				
				my $sr = hex_to_ascii(substr($msg, 6,2) . substr($msg, 9,2));
				my $sl = hex_to_ascii(substr($msg, 15,2) . substr($msg, 18,2));

				# print "Score L = $sl, R = $sr\n";

				# print "Score L = " .  hex_to_ascii($sl) . "\n";
				if ($score_l ne $sl || $score_r ne $sr)
				{
					print "Score: $sl:$sr\n";
					$score_l = $sl;
					$score_r = $sr;
				}
			}

			if ($type eq "4c")
			{
				# Lights - not used here but just out of interest...

				my %state = ( 	30=>'Off',
				   				31=>'On'
							);

				# print "msg = $msg\n";

				my ($r, $g, $W, $w) = $msg =~ m/.*52 ([0-9][0-9]) 47 ([0-9][0-9]) 57 ([0-9][0-9]) 77 ([0-9][0-9]).*/;

				# print "Lights: [$r] [$W] [$w] [$g]\n";
				print "Lights: $state{$r} $state{$W} $state{$w} $state{$g}\n";

			}

			if ($type eq "50")
			{
				# print "msg = $msg\n";

				my $p = hex_to_ascii(substr($msg, 6,2));

				print "Priority: $p\n";
			}

		}
		else
		{
			# print "msg = $msg\n"; 
		}

		$start = index($buf, "$SOH ");
		$end = index($buf, "$EOT ", $start);
		# print "buf = $buf\n";
	}


}

sub ascii_to_hex
{
	## Convert each ASCII character to a two-digit hex number.
	(my $str = shift) =~ s/(.|\n)/sprintf("%02lx ", ord $1)/eg;
	return $str;
}

sub hex_to_ascii
{
	## Convert each two-digit hex number back to an ASCII character.
	(my $str = shift) =~ s/([a-fA-F0-9]{2})/chr(hex $1)/eg;
	return $str;
}

