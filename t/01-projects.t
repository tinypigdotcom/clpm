
# Tests Functionality:
# 1. create a project
# 2. add 3 files
# 3. edit all files
# 4. remove each file from project
# Missing:
# test multiple projects: 1 2 3 4, 3 2 1 just like files
# search
# copy
# move
# LATER
# z, d, v, af
# [ ] Command Line Program Managers (clpm) v1.0
# [X] Help commands:
# [X]             z  - this listing
# [X] Organization commands:
#                 f  - manage files
#                     examples:
# [X]                 show list of files:    $ f
# [ ]                 edit file 1, 3, and L: $ f 13L
# [X]                 edit all files:        $ fa
# [ ]                 add file to the list : $ f , /tmp/a.dmb /etc/hosts /etc/passwd
# [X]                 add file with label L: $ f L /tmp/a.dmb
# [ ]                 remove file 1, 3, L  : $ f -13L
#                 x  - manage commands (same basic format as f)
#                     examples:
# [ ]                 show list of cmds:     $ x
# [ ]                 run cmd 1, 3, and L:   $ x 13L
# [ ]                 edit cmd 1, 3, and L:  $ x .13L
# [ ]                 edit all cmds:         $ xa
# [ ]                 add cmd to the list :  $ x , 'echo hey' 'Optional Label'
#                         NOTE: surround command with quotes
# [ ]                 add cmd with label L:  $ x L 'echo howdy; echo there' 'Optional Label'
# [ ]                 remove cmd 1, 3, L  :  $ x -13L
#                 p  - change project/view list of projects
# [X]                 show project list:     $ p
# [ ]                 switch to project:     $ p myproj
# [ ]                 remove project:        $ p -myproj
# [ ] Current project: orange

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

$proj_output = `z`;
like(
    $proj_output,
    $Z_RE,
    'z'
);

$proj_output = `p orange starfruit`;
$proj_output = `p`;

like(
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
like( $proj_output, $SECOND_PROJECT_FILES_RE, 'Second project files' );
$proj_output = `fa`;
like( $proj_output, qr/contents_papaya/,     'Edit all files 2.1' );
like( $proj_output, qr/contents_raspberry/,  'Edit all files 2.2' );
like( $proj_output, qr/contents_strawberry/, 'Edit all files 2.3' );

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

sub SECOND_PROJECT_FILES_RE {
    return qr{
        ^
        Project:[ ]orange[ ]\(starfruit\)
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

