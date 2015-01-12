# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Foo-Bar.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use File::Copy;
use IO::File;
use Data::Dumper;
use Test::More tests => 10;

my $tmp_dir = "$ENV{HOME}/tmp";
if ( !-d $tmp_dir ) {
    mkdir $tmp_dir or die "mkdir $tmp_dir failed: $!";
}

my $BLANK_PROJECTS_LIST                = BLANK_PROJECTS_LIST();
my $FIRST_PROJECT                      = FIRST_PROJECT();
my $FIRST_PROJECT_LIST                 = FIRST_PROJECT_LIST();
my $FIRST_PROJECT_FILES_RE             = FIRST_PROJECT_FILES_RE();
my $FIRST_PROJECT_FILES_MINUS_ONE_RE   = FIRST_PROJECT_FILES_MINUS_ONE_RE();
my $FIRST_PROJECT_FILES_MINUS_TWO_RE   = FIRST_PROJECT_FILES_MINUS_TWO_RE();
my $FIRST_PROJECT_FILES_MINUS_THREE_RE = FIRST_PROJECT_FILES_MINUS_THREE_RE();

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
is( $proj_output, $BLANK_PROJECTS_LIST, 'Blank projects list' );
$proj_output = `p apple banana`;
is( $proj_output, $FIRST_PROJECT, 'First project' );
$proj_output = `p`;
is( $proj_output, $FIRST_PROJECT_LIST, 'First project list' );

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
like( $proj_output, $FIRST_PROJECT_FILES_RE, 'First project files' );
$proj_output = `fa`;
like( $proj_output, qr/contents_papaya/,     'Edit all files 1' );
like( $proj_output, qr/contents_raspberry/,  'Edit all files 2' );
like( $proj_output, qr/contents_strawberry/, 'Edit all files 3' );

my $letter = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_ONE_RE,
    'First project files minus one'
);

$letter      = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_TWO_RE,
    'First project files minus two'
);

$letter      = shift @remove_files;
$proj_output = `f -$letter`;
$proj_output = `f`;
like(
    $proj_output,
    $FIRST_PROJECT_FILES_MINUS_THREE_RE,
    'First project files minus three'
);

$proj_output = `p orange starfruit`;
$proj_output = `p`;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub make_test_files {
    my @tf = qw(papaya raspberry strawberry);
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
        ^
        Project:[ ]apple[ ]\(banana\)
        \s+
        Current[ ]files:
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
        $
    }x;
}

