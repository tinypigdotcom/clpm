
# Tests Functionality:
# test multiple projects: 1 2 3 4, 3 2 1 just like files

use strict;
use warnings;

use File::Copy;
use IO::File;
use Data::Dumper;
use Test::More tests => 9;

my $tmp_dir = "$ENV{HOME}/tmp";
if ( !-d $tmp_dir ) {
    mkdir $tmp_dir or die "mkdir $tmp_dir failed: $!";
}

my $BLANK_PROJECTS_LIST = BLANK_PROJECTS_LIST();
my $FIRST_PROJECT       = FIRST_PROJECT();
my $FIRST_PROJECT_LIST  = FIRST_PROJECT_LIST();
my $SECOND_PROJECT      = SECOND_PROJECT();
my $SECOND_PROJECT_LIST = SECOND_PROJECT_LIST();
my $THIRD_PROJECT       = THIRD_PROJECT();
my $THIRD_PROJECT_LIST  = THIRD_PROJECT_LIST();

my $project_file      = '.pdump_test';
my $project_file_path = "$ENV{HOME}/$project_file";
unlink $project_file_path;
if ( -f $project_file_path ) {
    die "unlink $project_file_path failed";
}
$ENV{PDUMP} = $project_file_path;
$ENV{EDITOR} = '/usr/bin/cat';

my $proj_output = `p`;
is( $proj_output, $BLANK_PROJECTS_LIST, 'Blank projects list' );           #001
$proj_output = `p apple banana`;
is( $proj_output, $FIRST_PROJECT, 'First project' );                       #002
$proj_output = `p`;
is( $proj_output, $FIRST_PROJECT_LIST, 'First project list' );             #003

$proj_output = `p blackberry apricot`;
is( $proj_output, $SECOND_PROJECT, 'Second project' );                     #004
$proj_output = `p`;
like(                                                                      #005
    $proj_output,
    $SECOND_PROJECT_LIST,
    'Second project list'
);

$proj_output = `p cherry date`;
is( $proj_output, $THIRD_PROJECT, 'Third project' );                       #006
$proj_output = `p`;
like(                                                                      #007
    $proj_output,
    $THIRD_PROJECT_LIST,
    'Third project list'
);

$proj_output = `p -cherry; p`;
like(                                                                      #008
    $proj_output,
    $SECOND_PROJECT_LIST,
    'Return to second'
);

$proj_output = `p -blackberry; p`;
is( $proj_output, $FIRST_PROJECT_LIST, 'Back to first' );                  #009

# avocado breadfruit bilberry blackcurrant blueberry boysenberry cantaloupe currant cherry cherimoya

sub BLANK_PROJECTS_LIST {
    return q{Projects:
};
}

sub FIRST_PROJECT {
    return q{Project: apple (banana)
Current files:
};
}

sub SECOND_PROJECT {
    return q{Project: blackberry (apricot)
Current files:
};
}

sub THIRD_PROJECT {
    return q{Project: cherry (date)
Current files:
};
}

sub THIRD_PROJECT_LIST {
    return qr{
        ^
        .*
        Projects:
        .*
        apple\s+banana
        .*
        blackberry\s+apricot
        .*
        \*[ ]cherry\s+date
        .*
        $
    }xs;
}

sub FIRST_PROJECT_LIST {
    return q{Projects:
* apple      banana         } . q{
};
}

sub SECOND_PROJECT_LIST {
    return qr{
        ^
        .*
        Projects:
        .*
        apple\s+banana
        .*
        \*[ ]blackberry\s+apricot
        .*
        $
    }xs;
}

sub fruits_list {
    return qw(
      apple apricot avocado banana breadfruit bilberry blackberry blackcurrant blueberry boysenberry cantaloupe currant cherry cherimoya cloudberry coconut cranberry cucumber damson date dragonfruit durian eggplant elderberry feijoa fig gojiberry gooseberry grape raisin grapefruit guava huckleberry honeydew jackfruit jambul jujube kiwifruit kumquat lemon lime loquat lychee mango marionberry melon cantaloupe honeydew watermelon rockmelon miraclefruit mulberry nectarine nut olive orange clementine mandarine bloodorange tangerine papaya passionfruit peach pepper chilipepper bellpepper pear persimmon physalis plum pineapple pomegranate pomelo purplemangosteen quince raspberry rambutan redcurrant salalberry salmonberry satsuma starfruit strawberry tamarillo tomato uglifruit watermelon
    );
}

