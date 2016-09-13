
# Tests Functionality:
# 1. create a project
# 2. add 3 files
# 3. edit all files
# 4. remove each file from project

use strict;
use warnings;

use File::Copy;
use IO::File;
use Data::Dumper;
use Test::More tests => 16;

my $tmp_dir = "$ENV{HOME}/tmp";
if ( !-d $tmp_dir ) {
    mkdir $tmp_dir or die "mkdir $tmp_dir failed: $!";
}

my $first_header = q{
        ^
        Project:[ ]apple[ ]\(banana\)
        \s+
        Current[ ]files:
        \s+
};

my $BLANK_PROJECTS_LIST                = BLANK_PROJECTS_LIST();
my $FIRST_PROJECT                      = FIRST_PROJECT();
my $FIRST_PROJECT_LIST                 = FIRST_PROJECT_LIST();
my $FIRST_PROJECT_FILES_RE             = FIRST_PROJECT_FILES_RE();
my $SECOND_PROJECT_FILES_RE            = SECOND_PROJECT_FILES_RE();
my $FIRST_PROJECT_FILES_MINUS_ONE_RE   = FIRST_PROJECT_FILES_MINUS_ONE_RE();
my $FIRST_PROJECT_FILES_MINUS_TWO_RE   = FIRST_PROJECT_FILES_MINUS_TWO_RE();
my $FIRST_PROJECT_FILES_MINUS_THREE_RE = FIRST_PROJECT_FILES_MINUS_THREE_RE();
my $Z_RE                               = Z_RE();
my $TWO_PROJECTS                       = TWO_PROJECTS();

my $project_file      = '.pdump_test';
my $project_file_path = "$ENV{HOME}/$project_file";
unlink $project_file_path;
if ( -f $project_file_path ) {
    die "unlink $project_file_path failed";
}
$ENV{PDUMP} = $project_file_path;
$ENV{EDITOR} = '/usr/bin/cat';

my @test_files = make_test_files();

my $proj_output = `p`;
is( $proj_output, $BLANK_PROJECTS_LIST, 'Blank projects list' );           #001
$proj_output = `p apple banana`;
is( $proj_output, $FIRST_PROJECT, 'First project' );                       #002
$proj_output = `p`;
is( $proj_output, $FIRST_PROJECT_LIST, 'First project list' );             #003

my @remove_files;
for my $file (@test_files) {
    my $letter;
    if ( $file =~ m{/([^/])[^/]*$} ) {
        $letter = $1;
    }
    $proj_output = `f $letter $file`;
    push @remove_files, $letter;
}
$proj_output = `f`;
like( $proj_output, $FIRST_PROJECT_FILES_RE, 'First project files' );      #004
$proj_output = `fa`;
like( $proj_output, qr/contents_papaya/,     'Edit all files 1' );         #005
like( $proj_output, qr/contents_raspberry/,  'Edit all files 2' );         #006
like( $proj_output, qr/contents_strawberry/, 'Edit all files 3' );         #007

my $letter = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(                                                                      #008
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_ONE_RE,
    'First project files minus one'
);

$letter      = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(                                                                      #009
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_TWO_RE,
    'First project files minus two'
);

$letter      = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(                                                                      #010
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_THREE_RE,
    'First project files minus three'
);

$proj_output = `z`;
like(                                                                      #011
    $proj_output,
    $Z_RE,
    'z'
);

$proj_output = `p orange starfruit`;
$proj_output = `p`;

like(                                                                      #012
    $proj_output,
    $TWO_PROJECTS,
    'Two projects'
);

for my $file (@test_files) {
    my $letter;
    if ( $file =~ m{/([^/])[^/]*$} ) {
        $letter = $1;
    }
    $proj_output = `f $letter $file`;
    push @remove_files, $letter;
}
$proj_output = `f`;
like( $proj_output, $SECOND_PROJECT_FILES_RE, 'Second project files' );    #013
$proj_output = `fa`;
like( $proj_output, qr/contents_papaya/,     'Edit all files 2.1' );       #014
like( $proj_output, qr/contents_raspberry/,  'Edit all files 2.2' );       #015
like( $proj_output, qr/contents_strawberry/, 'Edit all files 2.3' );       #016

sub make_test_files {
    my @tf = qw(papaya raspberry strawberry date elderberry fig);
    my @retval;
    for (@tf) {
        my $test_file = "$tmp_dir/$_";
        push @retval, $test_file;
        my $ofh = IO::File->new( $test_file, '>' );
        die "couldn't create test file $test_file" if ( !defined $ofh );
        print $ofh qq{contents_$_};
        $ofh->close;
    }
    return @retval;
}

sub fruits_list {
    return qw(
      apple apricot avocado banana breadfruit bilberry blackberry
      blackcurrant blueberry boysenberry cantaloupe currant cherry cherimoya
      cloudberry coconut cranberry cucumber damson date dragonfruit durian
      eggplant elderberry feijoa fig gojiberry gooseberry grape raisin
      grapefruit guava huckleberry honeydew jackfruit jambul jujube
      kiwifruit kumquat lemon lime loquat lychee mango marionberry melon
      cantaloupe honeydew watermelon rockmelon miraclefruit mulberry
      nectarine nut olive orange clementine mandarine bloodorange tangerine
      papaya passionfruit peach pepper chilipepper bellpepper pear persimmon
      physalis plum pineapple pomegranate pomelo purplemangosteen quince
      raspberry rambutan redcurrant salalberry salmonberry satsuma starfruit
      strawberry tamarillo tomato uglifruit watermelon
    );
}

sub BLANK_PROJECTS_LIST {
    return q{Projects:
};
}

sub FIRST_PROJECT {
    return q{Project: apple (banana)
Current files:
};
}

sub FIRST_PROJECT_LIST {
    return q{Projects:
* apple      banana         } . q{
};
}

sub FIRST_PROJECT_FILES_RE {
    return qr{
        $first_header
        d[ ]date\s+$tmp_dir
        \s+
        e[ ]elderberry\s+$tmp_dir
        \s+
        f[ ]fig\s+$tmp_dir
        \s+
        p[ ]papaya\s+$tmp_dir
        \s+
        r[ ]raspberry\s+$tmp_dir
        \s+
        s[ ]strawberry\s+$tmp_dir
        \s+
        $
    }x;
}

sub SECOND_PROJECT_FILES_RE {
    return qr{
        ^
        Project:[ ]orange[ ]\(starfruit\)
        \s+
        Current[ ]files:
        \s+
        d[ ]date\s+$tmp_dir
        \s+
        e[ ]elderberry\s+$tmp_dir
        \s+
        f[ ]fig\s+$tmp_dir
        \s+
        p[ ]papaya\s+$tmp_dir
        \s+
        r[ ]raspberry\s+$tmp_dir
        \s+
        s[ ]strawberry\s+$tmp_dir
        \s+
        $
    }x;
}

sub FIRST_PROJECT_FILES_MINUS_ONE_RE {
    return qr{
        ^
        Project:[ ]apple[ ]\(banana\)
        \s+
        Current[ ]files:
        \s+
        d[ ]date\s+$tmp_dir
        \s+
        e[ ]elderberry\s+$tmp_dir
        \s+
        f[ ]fig\s+$tmp_dir
        \s+
        r[ ]raspberry\s+$tmp_dir
        \s+
        s[ ]strawberry\s+$tmp_dir
        \s+
        $
    }x;
}

sub FIRST_PROJECT_FILES_MINUS_TWO_RE {
    return qr{
        ^
        Project:[ ]apple[ ]\(banana\)
        \s+
        Current[ ]files:
        \s+
        d[ ]date\s+$tmp_dir
        \s+
        e[ ]elderberry\s+$tmp_dir
        \s+
        f[ ]fig\s+$tmp_dir
        \s+
        s[ ]strawberry\s+$tmp_dir
        \s+
        $
    }x;
}

sub FIRST_PROJECT_FILES_MINUS_THREE_RE {
    return qr{
        ^
        Project:[ ]apple[ ]\(banana\)
        \s+
        Current[ ]files:
        \s+
        d[ ]date\s+$tmp_dir
        \s+
        e[ ]elderberry\s+$tmp_dir
        \s+
        f[ ]fig\s+$tmp_dir
        \s+
        $
    }x;
}

sub TWO_PROJECTS {
    return qr{
        ^
        .*
        Projects:
        .*
        apple\s+banana
        .*
        \*[ ]orange\s+starfruit
        .*
        $
    }xs;
}

sub Z_RE {
    return qr{
        Help[ ]commands
        .*
        Organization[ ]commands
    }xs;
}

