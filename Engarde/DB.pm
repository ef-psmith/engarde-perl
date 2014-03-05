package Engarde::DB;
use strict;

use vars qw($VERSION @ISA);
@ISA = qw(Engarde);

use Data::Dumper;
use DBI;

my $dbh;

$VERSION=0.02;

BEGIN 
{
	# print "begin block running\n";

	# connect to db
	my $dsn = "DBI:mysql:database=engarde";

    #$dbh = DBI->connect($dsn, "engarde", "engarde");

	$dbh = DBI->connect_cached("DBI:mysql:engarde:127.0.0.1",
				"engarde", "engarde", 
				{'RaiseError' => 1, AutoCommit => 1}
			) or die $DBI::errstr;
	
	print Dumper($dbh);
}



sub config_read
{
	my $data;
	
	my $sth = $dbh->prepare("select key, value from control");
	
	print Dumper(\$sth);
	
	print $DBI::errstr;

	$sth->execute();
				
	print $DBI::errstr;

	
	my ($key, $value);
	$sth->bind_columns(\$key, \$value);
	
	while ($sth->fetch)
	{
		$data->{$key} = $value;
	}
	
	print Dumper($data);
}


1;
