# clpm - Command Line Project Manager

## Overview
    z  - this listing
    f  - manage files
         edit file 1, 3, and L: $ f 13L
         add file to the list : $ f , /tmp/a.dmb /etc/hosts /etc/passwd
         remove file 1, 3, L  : $ f -13L
    x  - manage commands (same basic format as f)
         show list of cmds:     $ x
         run cmd 1, 3, and L:   $ x 13L
         edit cmd 1, 3, and L:  $ x .13L
         add cmd to the list :  $ x , 'echo hey' 'Optional Label'
            NOTE: surround command with quotes
         add cmd with label L:  $ x L 'echo howdy; echo there' 'Optional Label'
         remove cmd 1, 3, L  :  $ x -13L
    p  - change project/view list of projects
         switch to project:     $ p myproj
         remove project:        $ p -myproj

## Synopsis

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
specified below in "INSTALLATION". Otherwise you can try `. v`

    $ v # assign all projects files to shell variables in the current shell
    v=/home/dbradford/.vimrc
    c=/home/dbradford/.vim/colors/vividchalk.vim

    $ cat $c >>$v # use shell commands to work with this set of files

Note: if the set of files changes you will need to run `v` again.

## Description

Command Line Project Manager (clpm) is designed to make managing sets of files easier. Files can be grouped into projects and then each file can be edited with a simple command: f \[space\]\[letter representing file\] \[ENTER\]

## Installation

Put "p" in your `$PATH` and then create these links to p in the same directory:

    f     # file edit
    fa    # edit all files
    x     # execute command
    xa    # execute all commands
    z     # get help
    zdir  # get directory of file

Separate scripts, put somewhere in `$PATH`

    af    # find and add files
    d     # change to file directory
    v     # set shell variables for file shortcuts

Add the following lines to your `.bash_profile`:

    alias d='. d'
    alias v='. v'

## Author

David M. Bradford, [davembradford@gmail.com](mailto:davembradford@gmail.com)

Copyright (C) 2014, 2015 David M. Bradford

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/ .

## Todo
1. add additional functionality in documentation: p cp, p mv, af, p ?search, f -, f multiple
1. INSTALLER!!

