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

	my %def = ( 'ALG'=>"Algeria", 'AHO'=>"Dutch Antilles", 'ARG'=>"Argentina",
				'ARM'=>"Armenia", 'ARU'=>"Aruba", 'AUS'=>"Australia",
				'AUT'=>"Autriche", 'AZE'=>"Azerbaijan", 'BEL'=>"Belgium",
				'BLR'=>"Bieloarussie", 'BOL'=>"Bolivie", 'BRA'=>"Brésil",
				'BRN'=>"Bahrein", 'BUL'=>"Bulgarie", 'CAN'=>"Canada",
				'CHI'=>"Chili", 'CHN'=>"Chine", 'COL'=>"Colombie",
				'CRC'=>"Costa Rica", 'CRO'=>"Croatie", 'CUB'=>"Cuba",
				'CYP'=>"Chypre", 'CZE'=>"République Tchèque", 'DEN'=>"Danemark",
				'ECU'=>"Equateur", 'EGY'=>"Egypte", 'ESA'=>"Salvador",
				'ESP'=>"Espagne", 'EST'=>"Estonie", 'FIN'=>"Finlande",
				'FRA'=>"France", 'GEO'=>"Géorgie", 'GBR'=>"Grande-Bretagne",
				'GER'=>"Allemagne", 'GRE'=>"Grèce", 'GUA'=>"Guatemala",
				'HKG'=>"Hong-Kong", 'HON'=>"Honduras", 'HUN'=>"Hongrie",
				'INA'=>"Indonésie", 'IND'=>"Inde", 'IRI'=>"Iran",
				'IRK'=>"Iraq", 'IRL'=>"Irlande", 'ISL'=>"Islande",
				'ISR'=>"Israël", 'ISV'=>"Iles Vierges", 'ITA'=>"Italie",
				'JOR'=>"Jordanie", 'JPN'=>"Japon", 'KAZ'=>"Kazakstan",
				'KGZ'=>"Kirghizistan", 'KOR'=>"Corée du Sud", 'KSA'=>"Arabie Saoudite",
				'KUW'=>"Koweit", 'LAT'=>"Lettonie", 'LIB'=>"Liban",
				'LTU'=>"Lituanie", 'LUX'=>"Luxembourg", 'MAR'=>"Maroc",
				'MAS'=>"Malaisie", 'MDA'=>"Moldavie", 'MEX'=>"Mexique",
				'MKD'=>"Macédoine", 'MLT'=>"Malte", 'MON'=>"Monaco",
				'NCA'=>"Nicaragua", 'NED'=>"Hollande", 'NOR'=>"Norvège",
				'NZL'=>"Nouvelle-Zélande", 'PAN'=>"Panama", 'PAR'=>"Paraguay",
				'PER'=>"Pérou", 'PHI'=>"Philippines", 'POL'=>"Pologne",
				'POR'=>"Portugal", 'PUR'=>"Porto Rico", 'PRK'=>"Corée du Nord",
				'ROM'=>"Roumanie", 'RSA'=>"Afrique du Sud", 'RUS'=>"Russie",
				'SEN'=>"Sénégal", 'SIN'=>"Singapour", 'SLO'=>"Slovénie",
				'SMR'=>"Saint-Martin", 'SUI'=>"Suisse", 'SVK'=>"Slovaquie",
				'SWE'=>"Suède", 'THA'=>"Thaïlande", 'TKM'=>"Turkménistan",
				'TPE'=>"Taipei", 'TUN'=>"Tunisie", 'TUR'=>"Turquie",
				'UKR'=>"Ukraine", 'URU'=>"Uruguay", 'USA'=>"Etats Unis",
				'UZB'=>"Ouzbékistan", 'VEN'=>"Vénézuéla", 'YUG'=>"Yougoslavie");

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

