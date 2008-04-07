# (c) Copyright Oliver Smith 2007 
# oliver_rps@yahoo.co.uk

use strict;
use DBI;
use Engarde;
use Data::Dumper;


##################################################################################
# cleanDatabase
##################################################################################
sub cleanDatabase {

	my $dbh = $_[0];
	my $ compKey = $_[1];
	
	
	# Get rid of the old matches
	print "Deleting matches for competition\n";
	$dbh->do("DELETE FROM matches WHERE compkey=$compKey");
	
	# Get rid of the old tableaus
	print "Deleting tableaus for competition\n";
	$dbh->do("DELETE FROM tableaus WHERE compkey=$compKey");
	
	# Get rid of the old poule rankings
	print "Deleting poule results for competition\n";
	$dbh->do("DELETE FROM seeding WHERE compkey=$compKey");
	
	# Get rid of the old Fencers
	print "Deleting Fencers for competition\n";
	$dbh->do("DELETE FROM fencers WHERE compkey=$compKey");
	
	# Get rid of the old competition
	print "Deleting Competition\n";
	$dbh->do("DELETE FROM competitions WHERE key=$compKey");
}


##################################################################################
# competitionsTable
##################################################################################
sub competitionsTable {

	my $dbh = $_[0];
	my $engardeFile = $_[1];
	my $compKey = $_[2];
	my $comp = $_[3];
	
	
	print "Adding Competition\n";
	# Now insert a new one
	my $insertQuery = "INSERT INTO Competitions VALUES (?,?,?,?)";
	my $sth = $dbh->prepare($insertQuery);
	
	$sth->execute($comp->titre_ligne(),$comp->titre_reduit(),$engardeFile,$compKey);
		

#CREATE TABLE "competitions"
#(
#  "name" text, -- The name of the competition
#  "shortname" text, -- The shortened name of the competition (derived from the engarde file)
#  "engardefile" text, -- The filename (local to the web server) of the Engarde File for the competition.
#  "key" integer NOT NULL,
#  CONSTRAINT "competitionkey" PRIMARY KEY (key)
#)
#WITH (OIDS=FALSE);
#ALTER TABLE "competitions" OWNER TO postgres;
#COMMENT ON COLUMN "competitions"."name" IS 'The name of the competition';
#COMMENT ON COLUMN "competitions"."shortname" IS 'The shortened name of the competition (derived from the engarde file)';
#COMMENT ON COLUMN "competitions"."engardefile" IS 'The filename (local to the web server) of the Engarde File for the competition.';

}


##################################################################################
# fencersTable
##################################################################################
sub fencersTable {

	my $dbh = $_[0];
	my $compKey = $_[1];
	my $comp = $_[2];
		
	print "Adding Fencers\n";
	# Now insert a new one
	my $insertQuery = "INSERT INTO fencers VALUES (?,?,?,?,?,?,$compKey)";
	my $sth = $dbh->prepare($insertQuery);
	
	my $entrylist = $comp->fpp();
	#print Dumper(%$entrylist);
	my $count = 0;
	
	foreach my $fencerkey (keys %$entrylist) {
		
		$count++;
		my $fencer = ${$entrylist}{$fencerkey};
		#print "Fencer ($count:$fencerkey) = ${$fencer}{'nom'}\n";
		$sth->execute(${$fencer}{'nom'}, ${$fencer}{'club'}, ${$fencer}{'serie'}, ${$fencer}{'poule'}, ${$fencer}{'piste_no'}, $fencerkey);
	}
						
#CREATE TABLE "fencers"
#(
#  "name" text NOT NULL, -- Full name <LAST First> of the fencer
#  "club" text, -- The fencer's club
#  "initrank" integer NOT NULL, -- National ranking for determining poules
#  "poule" integer NOT NULL, -- The Poule number of the next round
#  "piste" integer, -- The Piste where the fencer will be fencing
#  "key" integer NOT NULL, -- The FencerKey
#  "compkey" integer NOT NULL, -- The key for the competition the fencer is in
#  CONSTRAINT "fencerkey" PRIMARY KEY (key),
#  CONSTRAINT "compkey" FOREIGN KEY ("compkey")
#      REFERENCES "competitions" ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION
#)
#WITH (OIDS=FALSE);
#ALTER TABLE "fencers" OWNER TO postgres;
#COMMENT ON COLUMN "fencers"."name" IS 'Full name <LAST First> of the fencer';
#COMMENT ON COLUMN "fencers"."club" IS 'The fencer''s club';
#COMMENT ON COLUMN "fencers"."initrank" IS 'National ranking for determining poules';
#COMMENT ON COLUMN "fencers"."poule" IS 'The Poule number of the next round';
#COMMENT ON COLUMN "fencers"."piste" IS 'The Piste where the fencer will be fencing';
#COMMENT ON COLUMN "fencers"."key" IS 'The FencerKey';
#COMMENT ON COLUMN "fencers"."compkey" IS 'The key for the competition the fencer is in';
}


##################################################################################
# seedingTable
##################################################################################
sub seedingTable {

	my $dbh = $_[0];
	my $compKey = $_[1];
	my $comp = $_[2];
	
	# We are going to do all the rounds of poules here.  At the moment only one.
	
	my $seedings = $comp->ranking("p");
	
	
	print "Adding Seedings\n";
	# Now insert a new one
	my $insertQuery = "INSERT INTO seeding VALUES (?,?,?,?,?,?,$compKey)";
	my $sth = $dbh->prepare($insertQuery);
	
	#print Dumper(%$seedings);
	my $count = 0;
	
	foreach my $fencerkey (keys %$seedings) {
		
		$count++;
		my $fencer = ${$seedings}{$fencerkey};
		#print "Seeding ($count:$fencerkey) = ${$fencer}{'seed'} ${$fencer}{'nom'}\n" . Dumper($fencer);
		my $voverm = "${$fencer}{'v'} / ${$fencer}{'m'}";
		$sth->execute(${$fencer}{'seed'}, $voverm, ${$fencer}{'ind'}, ${$fencer}{'hs'}, 'A', $fencerkey);
	}
	
#CREATE TABLE seeding
#(
#  seed integer NOT NULL, -- Seed after the poules
#  "v-over-m" text NOT NULL, -- Victories/matches - primary indicator
#  ind integer NOT NULL, -- hs-hr secondary indicator
#  hs integer NOT NULL, -- hits scored - tertiary indicator
#  round text NOT NULL, -- The round of poules
#  fencerkey integer NOT NULL, -- Foreign key for fencer
#  compkey integer NOT NULL, -- Foreign key for competition
#  CONSTRAINT "SeedingKey" PRIMARY KEY (compkey, round, fencerkey),
#  CONSTRAINT "CompKey" FOREIGN KEY (compkey)
#      REFERENCES competitions ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION,
#  CONSTRAINT "FencerKey" FOREIGN KEY (fencerkey)
#      REFERENCES fencers ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION
#)
#WITH (OIDS=FALSE);
#ALTER TABLE seeding OWNER TO postgres;
#COMMENT ON TABLE seeding IS 'Seeding after the poules';
#COMMENT ON COLUMN seeding.seed IS 'Seed after the poules';
#COMMENT ON COLUMN seeding."v-over-m" IS 'Victories/matches - primary indicator';
#COMMENT ON COLUMN seeding.ind IS 'hs-hr secondary indicator';
#COMMENT ON COLUMN seeding.hs IS 'hits scored - tertiary indicator';
#COMMENT ON COLUMN seeding.round IS 'The round of poules';
#COMMENT ON COLUMN seeding.fencerkey IS 'Foreign key for fencer';
#COMMENT ON COLUMN seeding.compkey IS 'Foreign key for competition';

}

##################################################################################
# matchesTable
##################################################################################
sub matchesTable {

	my $dbh = $_[0];
	my $compKey = $_[1];
	my $comp = $_[2];
	
	# TODO - Work out which tableaus are active
	
  
	my $tableaukey = 'a';
	
	# Now work out which rounds are active
    my $rounditer = 2;
    
    
    my $roundsize; #  = undef;
	while (!defined($roundsize)) {
		# PRS - modified to use fully decoded version of tableau ()
		print "createRoundTableaus: getting tableau data for round $rounditer\n";
		my $tab = $comp->tableau($tableaukey.$rounditer, 1);
		
		if (defined($tab)) {
			my $tabstate = $tab->{etat};
			print "Tableau $rounditer state: $tabstate\n";
			if (!defined($tabstate) || $tabstate =~ /termine/) {
				$roundsize = $rounditer/2;
			}			
		}
		else {
			$roundsize = $rounditer/2;
		}
		$rounditer *= 2;
	}
	my $displayround = $roundsize;
	if ($roundsize < 4) {
    	$displayround = 4;
	}
	print "Round used: $roundsize ($displayround)\n";
	
	print "INSERT INTO tableaus VALUES ($roundsize,$displayround, \"$tableaukey\", $compKey)\n";
	
	$dbh->do("INSERT INTO tableaus VALUES ($roundsize,$displayround,'$tableaukey', $compKey)");
	
#	CREATE TABLE tableaus
#(
#  lastcompleteround integer NOT NULL, -- The last round in which all the matches are complete
#  displayround integer NOT NULL, -- The round to place at the left hand side of the 3 column tableau view.
#  tableauprefix text NOT NULL, -- The prefix for Engarde for this tableau
#  compkey integer NOT NULL, -- The key for the competition
#  CONSTRAINT tableaukey PRIMARY KEY (tableauprefix, compkey),
#  CONSTRAINT compkey FOREIGN KEY (compkey)
#      REFERENCES competitions ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION
#)
#WITH (OIDS=FALSE);
#ALTER TABLE tableaus OWNER TO postgres;
#COMMENT ON COLUMN tableaus.lastcompleteround IS 'The last round in which all the matches are complete';
#COMMENT ON COLUMN tableaus.displayround IS 'The round to place at the left hand side of the 3 column tableau view.';
#COMMENT ON COLUMN tableaus.tableauprefix IS 'The prefix for Engarde for this tableau';
#COMMENT ON COLUMN tableaus.compkey IS 'The key for the competition';
	
	
	#Now the matches
	my $firstround = $comp->tableau($tableaukey.$displayround, 1);
	#print Dumper($firstround);
	
	# Now insert a new one
	my $insertQuery = "INSERT INTO matches VALUES (?,?,?,?,?,?,$compKey,?,?)";
	my $sth = $dbh->prepare($insertQuery);
	
	my %lastFinished;
	my %firstActive;
	
	my %activeRounds = %{$comp->tableauxactifs};
	
	# Go through all the active rounds extracting the state, suite and size.  
	# We are storing the earliest we find against the suite and the latest with the state "termine"
	foreach my $roundkey (keys %activeRounds) {
		#print "Round: $roundkey\n";
		# First sort out whether this is the earliest round or latest completed round
		my $thisRoundDef = $activeRounds{$roundkey};
		
		my $roundNumber = ${$thisRoundDef}{'taille'};
		my $suite = ${$thisRoundDef}{'suite'};
		
		# Is this the earliest round for this suite (the highest number of competitors)?
		if ($firstActive{$suite} < $roundNumber) {
			$firstActive{$suite} = $roundNumber;
		}
		
		my $round = $comp->tableau($roundkey, 1);
		
		print "Round Number: $roundNumber ,State: ${$round}{'etat'}\n";
		if (${$round}{'etat'} =~ /termine/) {
			# This round has finished so update the last finished round
			if ($lastFinished{$suite} > $roundNumber) {
				$lastFinished{$suite} = $roundNumber;
			}
		}
		print Dumper($round);
		
		for (my $matchIter = 1; $matchIter <= $roundNumber / 2; $matchIter++) {
			my $match = ${$round}{$matchIter};
			print Dumper($match);
			$sth->execute(${$match}{'idA'}, ${$match}{'idB'}, ${$match}{'scoreA'}, ${$match}{'scoreB'},0,${$match}{'piste'}, $matchIter, $suite);
		}
		# There should be
		#print Dumper($round);
		#if ($
	}
	
#	CREATE TABLE matches
#(
#  fencera integer NOT NULL, -- The first fencer
#  fencerb integer NOT NULL, -- The second fencer
#  scorea integer NOT NULL DEFAULT 0, -- The number of hits fencera has scored
#  scoreb integer NOT NULL DEFAULT 0, -- The number of hits fencer B has scored
#  "time" integer, -- The number of seconds remaining.
#  piste integer, -- The piste number where the match is taking place
#  compkey integer NOT NULL, -- The key for the competition
#  round integer NOT NULL, -- The round, i.e.16 for last 16 etc
#  "match" integer NOT NULL, -- The match number within this round of this tableau
#  tableau text NOT NULL, -- The prefix for the tableau
#  CONSTRAINT matchkey PRIMARY KEY (match, compkey, round, tableau),
#  CONSTRAINT compkey FOREIGN KEY (compkey)
#      REFERENCES competitions ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION,
#  CONSTRAINT "fencerA" FOREIGN KEY (fencera)
#      REFERENCES fencers ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION,
#  CONSTRAINT "fencerB" FOREIGN KEY (fencerb)
#      REFERENCES fencers ("key") MATCH SIMPLE
#      ON UPDATE NO ACTION ON DELETE NO ACTION
#)
#WITH (OIDS=FALSE);
#ALTER TABLE matches OWNER TO postgres;
#COMMENT ON COLUMN matches.fencera IS 'The first fencer';
#COMMENT ON COLUMN matches.fencerb IS 'The second fencer';
#COMMENT ON COLUMN matches.scorea IS 'The number of hits fencera has scored';
#COMMENT ON COLUMN matches.scoreb IS 'The number of hits fencer B has scored';
#COMMENT ON COLUMN matches."time" IS 'The number of seconds remaining.  ';
#COMMENT ON COLUMN matches.piste IS 'The piste number where the match is taking place';
#COMMENT ON COLUMN matches.compkey IS 'The key for the competition';
#COMMENT ON COLUMN matches.round IS 'The round, i.e.16 for last 16 etc';
#COMMENT ON COLUMN matches."match" IS 'The match number within this round of this tableau';
#COMMENT ON COLUMN matches.tableau IS 'The prefix for the tableau';
}

##################################################################################
# Main starts here
##################################################################################
{

	my $engardeFile = "";
	my $compKey = -1;			
	if (1 < @ARGV) {
		$engardeFile = $ARGV[0];
		$compKey = $ARGV[1];
	} else {die "Need an EngardeFile and competition Key."}
	
	print "$engardeFile $compKey\n";

	my $comp = Engarde->new($engardeFile);
	
	# initialise the competition
	$comp->initialise;

	# Connect to the database.
	my $dbh = DBI->connect("DBI:PgPP:database=live-fencing;host=localhost",
                             "postgres", "admin",
                           {'RaiseError' => 1});
                         
    cleanDatabase($dbh, $compKey);  
    competitionsTable($dbh, $engardeFile, $compKey, $comp);
    
    fencersTable($dbh,  $compKey, $comp);
    seedingTable($dbh,  $compKey, $comp);
    matchesTable($dbh,  $compKey, $comp);

}
			
