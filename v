#!/bin/bash
# purpose: get variables from "p" project files
PERL=perl

#    Copyright (C) 2014  David M. Bradford
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your u_option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see https://www.gnu.org/licenses/gpl.txt
#
#    The author, David M. Bradford, can be contacted at:
#    davembradford@gmail.com

u_do_init() {
    u_VERSION=0.1.0
    u_PROG=v
    u_EXIT=
    u_ERR_EXIT=2
}

u_do_cleanup() {
    unset u_VERSION
    unset u_PROG
    unset u_EXIT
    unset u_ERR_EXIT
    unset u_EXIT_STATUS
    unset u_OPTS

    unset -f u_do_cleanup
    unset -f u_do_exit
    unset -f u_do_init
    unset -f u_do_short_usage
    unset -f u_errout
    unset -f u_short_usage
    unset -f u_usage
    unset -f u_usage_top
    unset -f u_version
}

u_do_exit() {
    u_do_cleanup
    u_EXIT=1
    return $u_EXIT_STATUS
}

u_usage_top()   {
    echo "Usage: $u_PROG " >&2
}

u_short_usage() {
    u_usage_top
    echo "Try '$u_PROG --help' for more information." >&2
}

u_errout() {
    echo "$u_PROG: $*" >&2
    u_short_usage
    u_EXIT_STATUS=$u_ERR_EXIT
    u_do_exit
}

u_do_init

u_usage() {

    u_usage_top
    cat <<EOF_usage >&2
get variables from "p" project files
Example: $u_PROG 

  -h, --help    display this help text and exit
  -v, --version display version information and exit

EOF_usage

}

u_do_short_usage() {
    u_short_usage
    u_EXIT_STATUS=$u_ERR_EXIT
    u_do_exit
}

u_version() {
   echo "$u_PROG $u_VERSION" >&2
}

parsed_ops=$(
  $PERL -MGetopt::Long -le '
    Getopt::Long::Configure ("bundling");

    my @options = (
        "help",
        "version",

    );

    # Explicitly add single letter version of each option to allow bundling
    my @temp = @options;
    for my $letter (@temp) {
        $letter =~ s/(\w)\w*/$1/;
        next if $letter eq q{h};
        push @options, $letter;
    }
    # Fix-ups from previous routine
    push @options, q{h};

    Getopt::Long::Configure "bundling";
    $q = "'\''";
    GetOptions(@options) or exit 1;
    for ( map /(\w+)/, @options ) {
        eval "\$o=\$opt_$_";
        $o =~ s/$q/$q\\$q$q/g;
        print "u_opt_$_=$q$o$q";
    }' -- "$@"
) || u_do_exit
eval "$parsed_ops"

if [ -n "$u_opt_h" ]; then
    u_do_short_usage
fi

if [ -n "$u_opt_help" ]; then
    u_usage
    u_do_exit
fi

if [ -n "$u_opt_v$u_opt_version" ]; then
    u_version
    u_do_exit
fi

if [ -n "$u_EXIT" ]; then
    return $u_EXIT_STATUS
fi

source ~/.penv

