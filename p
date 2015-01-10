#!/usr/bin/perl

#------------------------------------------------------------------------------
#    clpm: Command Line Project Manager (see: p, f, fa, x, xa, z, zdir)
#    Copyright (C) 2014 David M. Bradford
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

# TODO
# add additional functionality in documentation:
# p cp, p mv, af, p ?search, f -, f multiple
# z  - this listing
# f  - manage files
#     edit file 1, 3, and L: $ f 13L
#     add file to the list : $ f , /tmp/a.dmb /etc/hosts /etc/passwd
#     remove file 1, 3, L  : $ f -13L
# x  - manage commands (same basic format as f)
#     show list of cmds:     $ x
#     run cmd 1, 3, and L:   $ x 13L
#     edit cmd 1, 3, and L:  $ x .13L
#     add cmd to the list :  $ x , 'echo hey' 'Optional Label'
#         NOTE: surround command with quotes
#     add cmd with label L:  $ x L 'echo howdy; echo there' 'Optional Label'
#     remove cmd 1, 3, L  :  $ x -13L
# p  - change project/view list of projects
#     switch to project:     $ p myproj
#     remove project:        $ p -myproj

# purpose: clpm: Command Line Project Manager (see: p, f, fa, x, xa, z, zdir)

# Command Line Project Manager (clpm)

=head1 SYNOPSIS

    $ p d "My Vimfiles" # create a new project with shortcut "d" called "My Vimfiles"
    $ p                 # list all projects
    Projects:
    * d          My Vimfiles

    $ f v .vimrc                     # add .vimrc to this project with shortcut "v"
    $ f c .vim/colors/vividchalk.vim # add this file with shortcut "c"
    $ f                              # list all files in the current project
    Project: d (My Vimfiles)
    Current files:
    v .vimrc                                             /home/dbradford
    c vividchalk.vim                                     /home/dbradford/.vim/colors

    $ f b # edit file assigned to "b" with vim

    $ fa  # edit all files in project with vim

    $ d t # cd to directory containing file with shortcut "t"

    $ x t ". d m;make test" # add command with shortcut "t"
    $ x t                   # execute command assigned to shortcut "t"
    t/DMB.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.05 usr  0.02 sys +  0.05 cusr
    0.03 csys =  0.14 CPU)
    Result: PASS

Note: for this next command to work as-is, alias must be set for "v" as
specified below in L</"INSTALLATION">. Otherwise you can try C<. v>

    $ v # assign all projects files to shell variables in the current shell
    v=/home/dbradford/.vimrc
    c=/home/dbradford/.vim/colors/vividchalk.vim

    $ cat $c >>$v # use shell commands to work with this set of files

Note: if the set of files changes you will need to run C<v> again.

=head1 DESCRIPTION

Command Line Project Manager (clpm) is designed to make managing sets of files easier. Files can be grouped into projects and then each file can be edited with a simple command: f [space][letter representing file] [ENTER]

=head1 INSTALLATION

Put "p" in your C<$PATH> and then create these links to p in the same directory:

  f     # file edit
  fa    # edit all files
  x     # execute command
  xa    # execute all commands
  z     # get help
  zdir  # get directory of file

Separate scripts, put somewhere in C<$PATH>

  af    # find and add files
  d     # change to file directory
  v     # set shell variables for file shortcuts

Add the following lines to your C<.bash_profile>:

  alias d='. d'
  alias v='. v'

=head1 AUTHOR

David M. Bradford, E<lt>davembradford@gmail.comE<gt>

Copyright (C) 2014 David M. Bradford

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut

use strict;
use warnings FATAL => 'all';

use Carp;
use Cwd;
use Data::Dumper;
use File::Basename;
use Hash::Util qw(lock_keys);
use IO::File;
use Storable qw(dclone);
use Storable;

my $separator = "%%%\n";
my $g;

our $VERSION = '1.0';
our $VAR1;

my $max_prev_projects = 50;

exit main( $0, @ARGV );

sub set_current_project {
    my ($to) = @_;
    push @{$g->{data}->{previous}}, $g->{data}->{current};
    while ( scalar @{$g->{data}->{previous}} > $max_prev_projects ) {
        shift @{$g->{data}->{previous}};
    }
    $g->{data}->{current} = $to;
}

sub unset_current_project {
    $g->{data}->{current} = '';
}

sub is_valid_project {
    my ($project) = @_;
    if ( exists $g->{data}->{projects}->{$project} ) {
        return 1;
    }
    return;
}

sub go_previous_project {
    my $prev = pop @{$g->{data}->{previous}};
    while (defined $prev) {
        if ( is_valid_project($prev) ) {
            set_current_project($prev);
            return;
        }
        $prev = pop @{$g->{data}->{previous}};
    }

    for my $project (keys %{$g->{data}->{projects}}) {
        if ( is_valid_project($project) ) {
            set_current_project($project);
            return;
        }
    }

    unset_current_project();
    return;
}

sub pfreeze {
    envwrite();
    dump_write();
    return;
}

sub dump_read {
    my $ifh = IO::File->new($g->{infile}, '<');
    croak if (!defined $ifh);

    my $contents = do { local $/; <$ifh> };
    $ifh->close;

    $g->{data} = eval $contents; ## no critic
    if ( !defined $g->{data} ) {
        croak "failed eval of dump";
    }
    return;
}

sub dump_write {
    my $ofh = IO::File->new($g->{infile}, '>');
    croak if (!defined $ofh);

    print $ofh Dumper($g->{data});
    $ofh->close;
    return;
}

sub envwrite {
    my $ofh = IO::File->new( "$ENV{HOME}/.penv", '>' );
    croak if ( !defined $ofh );

    for ( "a" .. "z", "A" .. "Z" ) {
        my $file = $g->{files}->{$_};
        $file //= '';
        print $ofh "export $_=$file\n";
    }

    for ( keys %{ $g->{files} } ) {
        my $file = $g->{files}->{$_};
        $file //= '';
        print $ofh qq{echo "$_=$file"\n};
    }

    $ofh->close;
    return;
}

sub fix {
    my ($n,$i) = @_;
    my $spaces = ' ' x $n;
    for ($i) {
        s/\n$//m;
        s/^$spaces//mg;
    }
    return $i;
}

# structure of data
#################################################################
#$VAR1 = { 'current' => 't',
#          'projects' => { 'pa' => { 'files' => { 'a' => '/home/dbradford/t3s/api_test.pl',
#                                                 'o' => '/home/dbradford/bin/onetime',
#                                                 'U' => '/opt/manfred/lib/Manfred/SimmCreate.pm' },
#                                    'commands' => { 'a' => { 'cmd' => '/home/dbradford/t3s/api_test.sh',
#                                                             'label' => '' },
#                                                    't' => { 'cmd' => './api_post.sh',
#                                                             'label' => '' } },
#                                    'label' => 'Manfred Test Gauntlet (TM)'
#                                  },
#                          'pad' => {etc},
#                        }
#        };

sub init {
    my $current = $g->{data}->{current};
    $g->{current} = $current;
    if ( $current ) {
        if ( !$g->{data}->{projects}->{ $g->{current} }->{files} ) {
            $g->{data}->{projects}->{ $g->{current} }->{files} = {};
        }
        if ( !$g->{data}->{projects}->{ $g->{current} }->{commands} ) {
            $g->{data}->{projects}->{ $g->{current} }->{commands} = {};
        }
        $g->{files} = $g->{data}->{projects}->{ $g->{current} }->{files};
        $g->{cmds}  = $g->{data}->{projects}->{ $g->{current} }->{commands};
    }
    return;
}

sub del {
    my ( $ar, $dr ) = @_;
    for ( @{$ar} ) {
        delete $dr->{$_};
    }
    pfreeze();
    return;
}

sub fullpath {
    my @files = @_;
    my $pwd   = cwd();
    my $nwd;
    for (@files) {
        if (m!(.*)/(.*)!) {
            chdir $1 or next;
            $nwd = cwd();
            $_   = "$nwd/$2";
            chdir $pwd or croak "Couldn't change dir back to $pwd.";
        }
        else {
            $_ = "$pwd/$_";
        }
    }
    chdir $pwd or croak "Couldn't change dir back to $pwd.";
    return @files;
}

sub derange {
    my ( $pattern, $hashref ) = @_;

    return if !defined $pattern;

    return $pattern if ( $pattern !~ /-/ );

    $pattern =~ s/(.)-(.)/&{
        sub {
            my @b = @_;
            my $a;
            for ( $b[0]..$b[1] ) {
                $a .= $_ if $hashref->{$_};
            }
            return $a
        }
    }($1,$2)/eg;

    return $pattern;
}

sub pcopy {
    my ( $delete_flag ) = @_;
    my ( $from, $to ) = @{ $g->{args} };
    my $projects = $g->{data}->{projects};

    $projects->{$to} = dclone( $projects->{$from} );
    if ($delete_flag) {
        delete $projects->{$from};
    }
    set_current_project($to);
    init();
    pfreeze();
    list_files();
    return;
}

sub zdir {
    my $key = $g->{args}->[0];

    return if ( !$key );

    my $file = $g->{files}->{$key};

    if ( !$file ) {
        print STDERR fix(8,<<"        EOF"), "\n";
        Can't make sense of $key
        It is a file you don't have read permission on,
        or labels that don't have associated files.
        EOF
        return;
    }

    print dirname($file);
    return;
}

sub list_projects {
    my $projects = $g->{data}->{projects};
    print "Projects:\n";
    for ( sort keys %{ $projects } ) {
        my $asterisk = ( $_ eq $g->{current} ) ? '*' : ' ';
        my $label = $projects->{$_}->{label};
        $label //= '';
        printf "$asterisk %-10s %-15s\n", $_, $label;
    }
}

sub search {
    my $arg = $g->{args}->[0];
    $arg //= '';
    my $projects = $g->{data}->{projects};
    my $output = "Projects:\n";
    my @found;
    OUTER:
    for ( sort keys %{ $projects } ) {
        my $asterisk = ( $_ eq $g->{current} ) ? '*' : ' ';
        my $label = $projects->{$_}->{label};
        $label //= '';
        my $project_text = "$_, $label";
        for (@{$g->{args}}) {
            if ( $project_text !~ /$_/i ) {
                next OUTER;
            }
        }
        $output .= sprintf "$asterisk %-10s %-15s\n", $_, $label;
        push @found, $_;
    }
    if ( @found == 1 ) {
        set_current_project($found[0]);
        init();
        pfreeze();
        list_files();
    }
    else {
        print $output;
    }
}

sub func_p {
    my $arg = $g->{args}->[0];
    $arg //= '';
    my $projects = $g->{data}->{projects};

    my ( $cmd, $proj ) = ( $arg =~ /(.)(.*)/ );
    if ( defined $cmd && $cmd eq '?' ) {
        $g->{args}->[0] =~ s/^.//;
        search();
    }
    elsif ( defined $cmd && $cmd eq '-' ) {
        delete $projects->{$proj};
        if ( $proj eq $g->{current} ) {
            go_previous_project();
        }
        pfreeze();
    }
    elsif ( !$arg ) {
        list_projects();
    }
    else {
        set_current_project($arg);
        $projects->{$arg}->{label} = $g->{args}->[1]
          if ( $g->{args}->[1] );
        init();
        pfreeze();
        list_files();
    }
    return;
}

sub list_files {
    my @args = @_;
    if ( @args ) {
        print STDERR "Bad arguments.\n";
    }
    my $label = $g->{data}->{projects}->{ $g->{current} }->{label};
    $label //= '';
    print "Project: $g->{current} ($label)\n";
    print "Current files:\n";

    my %sorted;
    for ( keys %{ $g->{files} } ) {
        my ( $a, $b ) = ( $g->{files}->{$_} =~ m!(.*)/(.*)! );
        my $i = lc($b) . lc($a);
        ( $sorted{$i}->{path} ) = ( $a =~ /(.{1,70})/ );
        ( $sorted{$i}->{file} ) = ( $b =~ /(.{1,50})/ );
        $sorted{$i}->{let} = $_;
    }

    for ( sort keys %sorted ) {
        printf "%-1s %-50s %-70s\n", $sorted{$_}->{let},
            $sorted{$_}->{file}, $sorted{$_}->{path};
    }
    return;
}

sub func_f {
    if ( !$g->{current} ) {
        print "Must set current project first.\n";
        return;
    }

    my $na  = scalar @{ $g->{args} };
    my @x   = @{ $g->{args} };

    if ( $na == 1 or $g->{prog} eq 'fa' ) {
        my $f  = '';
        my $f1 = 0;

        my $tmp = derange( $x[0], $g->{files} );
        my @l = split //, ( defined($tmp) ? $tmp : '' );

        if ( $g->{prog} eq 'fa' ) { @l = keys %{ $g->{files} } }
        if ( $l[0] eq '-' ) {    # Delete labels
            shift @l;
            del( \@l, $g->{files} );
        }
        else {                   # Edit files
            for (@l) {
                if ( $g->{files}->{$_} ) {
                    $f .= "$g->{files}->{$_} ";
                }
                else { ++$f1 }
            }
            if ( !$f1 ) {
                exec "$ENV{EDITOR} $f";
            }
            else {
                print STDERR "Can't make sense of $x[0].\n";
                print STDERR
                  "It is a file you don't have read permission on, \n";
                print STDERR "or labels that don't have associated files.\n";
            }
        }
    }
    elsif ( $na == 2 and $x[0] ne ',' ) {    # Add file to specific label
        my ($file) = fullpath( $x[1] );
        if ( $g->{h_ident}->{ $x[0] } ) {
            if ( -r $file ) {
                $g->{files}->{ $x[0] } = $file;
                pfreeze();
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        else {
            print STDERR "Invalid identifier: $x[0]\n";
            print STDERR 'Use one of: ' . join( '', @{ $g->{a_ident} } ) . "\n";
        }
    }
    elsif ( defined $x[0] && $x[0] eq ',' ) {    # Add files to generic label
        shift @x;
        for (@x) {
            my ($file) = fullpath($_);
            if ( -r $file ) {
                for my $i ( @{ $g->{a_ident} } ) {
                    if ( !exists $g->{files}->{$i} ) {
                        $g->{files}->{$i} = $file;
                        last;
                    }
                }
            }
            else {
                print STDERR "Can't read: $file\n";
            }
        }
        pfreeze();
    }
    else {    # Error/Print list of files
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        list_files();
    }
    return;
}

sub func_x {
    if ( !$g->{current} ) {
        print "Must set current project first.\n";
        return;
    }

    my $na    = scalar @{ $g->{args} };
    my @a     = @{ $g->{args} };
    my $f1    = 0;
    my $f2    = 0;
    my $flist = '';

    my $tmp = derange( $a[0], $g->{cmds} );
    my @l = split //, ( defined($tmp) ? $tmp : '' );

    my $g_2 = defined( $l[0] ) ? $l[0] : '';
    if ( $g_2 eq '.' or $g_2 eq '-' ) { shift @l }

    for (@l) {
        if ( !$g->{cmds}->{$_} ) { ++$f1 }
    }
    $a[1] //= '';
    if ( $a[1] =~ /^-(.*)/ ) {
        $flist = $1;
    }

    if ( $na == 1 or $g->{prog} eq 'xa' or $flist ) {
        if ( $g->{prog} eq 'xa' ) { @l = keys %{ $g->{cmds} } }
        if ( $g_2 eq '-' ) {    # Delete labels
            del( \@l, $g->{cmds} );
        }
        elsif ( $g_2 eq '.' ) {    # Edit commands
            my $f = '';
            my $temp;
            if ( !$f1 ) {
                for (@l) {
                    $temp = "/tmp/c.$$.$_";
                    my $ofh = IO::File->new( $temp, '>' );
                    croak if ( !defined $ofh );

                    print $ofh
                      "$g->{cmds}->{$_}->{label}: $g->{cmds}->{$_}->{cmd}\n";
                    print $ofh
"# The label precedes the colon above and my be edited freely\n";
                    print $ofh "# As long as the colon is left intact.\n";
                    print $ofh
"# Only the first line is read. Don't add more lines to this file.\n";
                    $f .= "$temp ";

                    $ofh->close;
                }

                system("$ENV{EDITOR} $f");
                for (@l) {
                    my $m;
                    $temp = "/tmp/c.$$.$_";
                    my $ifh = IO::File->new( $temp, '<' );
                    croak if ( !defined $ifh );
                    chomp( $m = <$ifh> );
                    if ( $m =~ /(.*):\s*(.*)/ ) {
                        $g->{cmds}->{$_}->{label} = $1;
                        $g->{cmds}->{$_}->{cmd}   = $2;
                    }
                    else {
                        print STDERR
                          "Bad format on file for command labeled $_\n";
                    }
                    $ifh->close;
                    unlink $temp;
                }
                pfreeze();

            }
            else {
                print STDERR "Bad labels in $a[0].\n";
            }
        }
        else {    # Run commands
            my $f = '';
            if ($flist) {

                my @m = split //, derange( $flist, $g->{files} );
                for (@m) {
                    if ( $g->{files}->{$_} ) {
                        $f .= "$g->{files}->{$_} ";
                    }
                    else { ++$f2 }
                }
            }
            if ($f2) {
                print STDERR "Can't make sense of $flist.\n";
                print STDERR
                  "It is a file you don't have read permission on, \n";
                print STDERR "or labels that don't have associated files.\n";
            }
            elsif ( !$f1 ) {
                for (@l) {
                    print "$g->{cmds}->{$_}->{cmd} $f\n";
                    if ( system("/bin/sh -c '$g->{cmds}->{$_}->{cmd} $f'") ) {
                        print STDERR
"An error occurred while running: $g->{cmds}->{$_}->{cmd}\n";
                        last;
                    }
                }
            }
            else {
                print STDERR "Bad labels in $a[0].\n";
            }
        }
    }
    elsif ( $na == 2 or $na == 3 ) {
        if ( $g->{h_ident}->{ $a[0] } ) {    # Add command to specific label
            $g->{cmds}->{ $a[0] }->{cmd} = $a[1];
            $g->{cmds}->{ $a[0] }->{label} = $a[2] || '';
            pfreeze();
        }
        elsif ( $a[0] eq ',' ) {             # Add command to generic label
            for my $i ( @{ $g->{a_ident} } ) {
                if ( !exists $g->{cmds}->{$i}->{cmd} ) {
                    $g->{cmds}->{$i}->{cmd} = $a[1];
                    $g->{cmds}->{$i}->{label} = $a[2] || '';
                    last;
                }
            }
            pfreeze();
        }
        else {                               # Error
            print STDERR "Invalid identifier: $a[0]\n";
            print STDERR 'Use one of: ' . join( '', @{ $g->{a_ident} } ) . "\n";
        }
    }
    else {                                   # Print list of commands
        if ( $na != 0 ) {
            print STDERR "Bad arguments.\n";
        }
        print "Project: $g->{current}\n";
        print "Current commands:\n";
        for (
            sort { lc($a) cmp lc($b) || $b cmp $a } keys %{ $g->{cmds} }
          )
        {
            printf "%1s: %-20s %-15s\n", $_, $g->{cmds}->{$_}->{label},
              $g->{cmds}->{$_}->{cmd};
        }
    }
    return;
}

sub func_z {
    print fix(4,<<"    EOF"), "\n";
    Command Line Program Managers (clpm) v$VERSION
    Help commands:
                z  - this listing
    Organization commands:
                f  - manage files
                    examples:
                    show list of files:    \$ f
                    edit file 1, 3, and L: \$ f 13L
                    edit all files:        \$ fa
                    add file to the list : \$ f , /tmp/a.dmb /etc/hosts /etc/passwd
                    add file with label L: \$ f L /tmp/a.dmb
                    remove file 1, 3, L  : \$ f -13L
                x  - manage commands (same basic format as f)
                    examples:
                    show list of cmds:     \$ x
                    run cmd 1, 3, and L:   \$ x 13L
                    edit cmd 1, 3, and L:  \$ x .13L
                    edit all cmds:         \$ xa
                    add cmd to the list :  \$ x , 'echo hey' 'Optional Label'
                        NOTE: surround command with quotes
                    add cmd with label L:  \$ x L 'echo howdy; echo there' 'Optional Label'
                    remove cmd 1, 3, L  :  \$ x -13L
                p  - change project/view list of projects
                    show project list:     \$ p
                    switch to project:     \$ p myproj
                    remove project:        \$ p -myproj
    Current project: $g->{data}->{current}
    EOF
    return;
}


sub usage {
    return <<EOF;
Usage: note [OPTION]... PATTERN...
Add or retrieve a note
Example: note lawnmower

-l [library], --library=[library] Search a specific library
-1, --1         use notefile #1
-2, --2         use notefile #2
-a, --add       Add a note
-t, --title     Search title only
-w, --word      Only find if PATTERN is a word
-e, --edit      Edit the notes file
-v, --verbose   Show additional information about entries matched / not matched
EOF
}


sub main {
    my ( $prog, @args ) = @_;

    $g = {};
    my @g_keys = qw(
      a_ident
      args
      cmds
      current
      data
      files
      h_ident
      infile
      legacy_infile
      prog
    );

    lock_keys( %{$g}, @g_keys );

    $g->{args}          = \@args;
    $g->{legacy_infile} = "$ENV{HOME}/.prc";
    $g->{infile}        = $ENV{PDUMP} || "$ENV{HOME}/.pdump";

    my @ident = ( 0 .. 9, 'a' .. 'z', 'A' .. 'Z' );

    my %ident;

    @ident{@ident} = (1) x @ident;

    $g->{a_ident} = \@ident;
    $g->{h_ident} = \%ident;

    ($prog) = ( $prog =~ m!.*/(.*)! );

    if ( defined $args[0] ) {
        if ( $args[0] eq '--help' ) {
            $prog = 'z';
        }
        elsif ( $prog eq 'p' ) {
            if ( $args[0] eq 'cp' or $args[0] eq 'mv' ) {
                $prog = shift @args;
            }
        }
    }
    $g->{prog} = $prog;

    if ( -e $g->{infile} ) {
        dump_read();
    }
    elsif ( -r $g->{legacy_infile} ) {
        $g->{data} = retrieve( $g->{legacy_infile} );
    }
    else {
        $g->{data} = {
            'current'  => '',
            'projects' => {},
        };
    }
    init();

    if ( $g->{prog} eq 'cp' ) {
        pcopy( );
    }

    if ( $g->{prog} eq 'mv' ) {
        my $delete_flag = 1;
        pcopy( $delete_flag );
    }

    if ( $g->{prog} eq 'zdir' ) { zdir() }

    if ( $g->{prog} eq 'p' ) { func_p() }

    if ( $g->{prog} eq 'f' or $g->{prog} eq 'fa' ) { func_f() }

    if ( $g->{prog} eq 'x' or $g->{prog} eq 'xa' ) { func_x() }

    if ( $g->{prog} eq 'z' ) { func_z() }

    return 0;
}
