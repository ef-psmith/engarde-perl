package Engarde::Nation;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;

sub decode
{
	my $self = shift;
	my $in = shift;
	my $max = $self->{max} || 0;

	# {[classe nation] [nom "GBR"] [nom_etendu "Grande-Bretagne"] [cle 1]}	
	my $item = {};
	my $cle;

	my @elements = split /[ \]]*\[/, $in;

	foreach (@elements)
	{
		if (/^nom /)
		{
			s/^nom \"//;
			s/\"$//;

			$item->{nom} = $_;
		}

		if (/^nom_etendu /)
		{
			s/^nom_etendu \"//;
			s/\"$//;

			$item->{nom_etendu} = $_;
		}

		if (/^cle/)
		{
			s/^cle //;
			s/\]\}$//;

			$cle = $_;
		}
	}

	$max = $cle if $cle > $max;

	bless $item, "Engarde::Nation";
	$self->{$cle} = $item;
	$self->{max} = $max;
}


sub default
{
	my $self = shift;
	
	my %def = (	'AFG' => "AFGHANISTAN",	'ALB' => "ALBANIA",	'ALG' => "ALGERIA",	'ANT' => "ANTIGUA AND BARBUDA",
				'ARG' => "ARGENTINA",	'ARM' => "ARMENIA",	'ARU' => "ARUBA",	'AUS' => "AUSTRALIA",
				'AUT' => "AUSTRIA",		'AZE' => "AZERBAIJAN",	'BAH' => "BAHAMAS",	'BRN' => "BAHRAIN",
				'BAN' => "BANGLADESH",	'BAR' => "BARBADOS", 'BLR' => "BELARUS", 'BEL' => "BELGIUM",
				'BIZ' => "BELIZE", 'BEN' => "BENIN", 'BER' => "BERMUDA", 'BOL' => "BOLIVIA",
				'BOT' => "BOTSWANA", 'BRA' => "BRAZIL", 'BRU' => "BRUNEI DARUSSALAM",
				'BUL' => "BULGARIA", 'BUR' => "BURKINA FASO", 'CAM' => "CAMBODIA", 'CMR' => "CAMEROON",
				'CAN' => "CANADA", 'CHI' => "CHILE", 'CHN' => "CHINA", 'TPE' => "CHINESE TAIPEI", 
				'COL' => "COLOMBIA", 'CGO' => "CONGO", 'CRC' => "COSTA RICA", 'CIV' => "COTE D'IVOIRE",
				'CRO' => "CROATIA", 'CUB' => "CUBA", 'CYP' => "CYPRUS", 'CZE' => "CZECH REPUBLIC",
				'COD' => "DEMOCRATIC REPUBLIC OF CONGO", 'DEN' => "DENMARK", 'DMA' => "DOMINICA",
				'DOM' => "DOMINICAN REPUBLIC", 'ECU' => "ECUADOR", 'EGY' => "EGYPT",
				'ESA' => "EL SALVADOR", 'GEQ' => "EQUATORIAL GUINEA", 'EST' => "ESTONIA",
				'FIE' => "FIE", 'FIN' => "FINLAND", 'FRA' => "FRANCE", 'GAB' => "GABON", 'GEO' => "GEORGIA", 
				'GER' => "GERMANY", 'GHA' => "GHANA", 'GBR' => "GREAT BRITAIN", 'GRE' => "GREECE",
				'GUM' => "GUAM", 'GUA' => "GUATEMALA", 'GUI' => "GUINEA", 'GUY' => "GUYANA", 
				'HON' => "HONDURAS", 'HKG' => "HONG KONG", 'HUN' => "HUNGARY", 'ISL' => "ICELAND", 
				'IND' => "INDIA", 'INA' => "INDONESIA", 'IRI' => "IRAN", 'IRQ' => "IRAQ", 'IRL' => "IRELAND",
				'ISR' => "ISRAEL", 'ITA' => "ITALY", 'JAM' => "JAMAICA", 'JPN' => "JAPAN",
				'JOR' => "JORDAN", 'KAZ' => "KAZAKHSTAN", 'KOR' => "KOREA", 'KUW' => "KUWAIT",
				'KGZ' => "KYRGYZSTAN", 'LAT' => "LATVIA", 'LIB' => "LEBANON", 'LBA' => "LIBYA",
				'LTU' => "LITHUANIA", 'LUX' => "LUXEMBOURG", 'MAC' => "MACAO", 'MAD' => "MADAGASCAR",
				'MAS' => "MALAYSIA", 'MLI' => "MALI", 'MLT' => "MALTA", 'MTN' => "MAURITANIA",
				'MRI' => "MAURITIUS", 'MEX' => "MEXICO", 'MDA' => "MOLDOVA", 'MON' => "MONACO",
				'MGL' => "MONGOLIA", 'MAR' => "MOROCCO", 'MYA' => "MYANMAR", 'NAM' => "NAMIBIA",
				'NEP' => "NEPAL", 'NED' => "NETHERLANDS", 'NZL' => "NEW ZEALAND", 'NCA' => "NICARAGUA",
				'NIG' => "NIGER", 'NGR' => "NIGERIA", 'PRK' => "NORTH KOREA", 'NOR' => "NORWAY",
				'PLE' => "PALESTINE", 'PAN' => "PANAMA", 'PAR' => "PARAGUAY", 'PER' => "PERU",
				'PHI' => "PHILIPPINES", 'POL' => "POLAND", 'POR' => "Portugal", 'PUR' => "PUERTO RICO",
				'QAT' => "QATAR", 'ROU' => "ROMANIA", 'RUS' => "RUSSIA", 'RWA' => "RWANDA",
				'SMR' => "SAN MARINO", 'KSA' => "SAUDI ARABIA", 'SEN' => "SENEGAL",
				'SRB' => "SERBIA", 'SLE' => "SIERRA LEONE", 'SIN' => "SINGAPORE", 'SVK' => "SLOVAKIAN REPUBLIC",
				'SLO' => "SLOVENIA", 'SOM' => "SOMALIA", 'RSA' => "SOUTH AFRICA", 'ESP' => "SPAIN",
				'SRI' => "SRI LANKA", 'SWE' => "SWEDEN", 'SUI' => "SWITZERLAND", 'SYR' => "SYRIAN ARAB REPUBLIC",
				'TJK' => "TAJIKISTAN", 'THA' => "THAILAND", 'MKD' => "THE FORMER YUGOSLAV REPUBLIC OF MACEDONIA",
				'TOG' => "TOGO", 'TUN' => "TUNISIA", 'TUR' => "TURKEY", 'TKM' => "TURKMENISTAN",
				'UKR' => "UKRAINE", 'UAE' => "UNITED ARAB EMIRATES", 'URU' => "URUGUAY",
				'USA' => "USA", 'UZB' => "UZBEKISTAN", 'VEN' => "VENEZUELA", 'VIE' => "VIETNAM",
				'ISV' => "VIRGIN ISLANDS", 'YEM' => "YEMEN" );

	my $seq = 1;
	
	foreach (sort keys %def)
	{
		$self->{$seq}->{nom} = $_;
		$self->{$seq}->{nom_etendu} = $def{$_};
		$self->{$seq}->{cle} = $seq;
		
		$seq++;
	}
	
	# probably need to bless $self->{$seq}
	
	$self->to_text;

}

sub to_text
{
	use Fcntl qw(:flock :DEFAULT);

	# {[classe nation] [nom "ISL"] [cle 1]}
	# {[classe nation] [nom "FRA"] [cle 2]}
	# {[classe nation] [nom "GBR"] [cle 3]}
	# {[classe nation] [nom "USA"] [cle 4]}
	
	my $self = shift;
	my $file = $self->{file};
	my $dir = $self->{dir};
	
	# the caller must ensure that engarde is not running since we don't 
	# want a multiple writer conflict and linux doesn't like multiple locks on the 
	# same file
	
	# open ETAT, "+< $dir/etat.txt";
	# flock(ETAT, LOCK_EX) || return undef;
	
	open my $FH, "> $file" . ".tmp";
	flock($FH, LOCK_EX) || return undef;
	
	if (-f $file)
	{
		open my $FH2, "+< $file";
		flock($FH2, LOCK_EX) || return undef;
	}

	my $seq = 1;
	my $out;
	
	foreach my $id (sort {$a <=> $b} grep /\d+/,keys %$self)
	{
		$out .= "{[classe nation] [nom \"$self->{$id}->{nom}\"] [nom_etendu \"$self->{$id}->{nom_etendu}\"] [cle $id]}\n";
	}
	
	print $FH $out;
	close $FH;
	close $FH2;
	
	rename "$file.tmp", $file or die("rename failed: $!");
}

1;


__END__

