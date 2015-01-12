
use strict;
use warnings;

use Data::Dumper;
use Test::More tests => 1;

my $Z_RE = Z_RE();

my $project_file      = '.pdump_test';
my $project_file_path = "$ENV{HOME}/$project_file";
unlink $project_file_path;
if ( -f $project_file_path ) {
    die "unlink $project_file_path failed";
}
$ENV{PDUMP} = $project_file_path;
$ENV{EDITOR} = '/usr/bin/cat';

my $proj_output = `z`;
like(
    $proj_output,
    $Z_RE,
    'z'
);

sub Z_RE {
    return qr{
        Help[ ]commands
        .*
        Organization[ ]commands
    }xs;
}

