#perl -w
use Engarde::DB;
use strict;
use Data::Dumper;

my $data = {};

Engarde::DB::config_read($data);

print Dumper($data);
