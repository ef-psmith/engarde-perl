#perl -w
use Engarde;
use Engarde::Control;
use Engarde::DB;
use strict;
use Data::Dumper;

my $data = {};

$data = config_read();

print "data = " . Dumper(\$data);
