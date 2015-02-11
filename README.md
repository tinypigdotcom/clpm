# clpm - Command Line Project Manager

Command Line Project Manager (clpm) is designed to make managing sets of files easier.

Watch the [demo](http://youtu.be/SL2ugsr6lik).

## Features

* Organize files and commands into projects and recall them with just a few keystrokes
* Access full filename path with simple shell variables, ex: `grep apples $j`
* Access all files at once, ex: `svn commit $all`

## Synopsis

    $ p v "My Vimfiles" # create a new project with shortcut "v" called "My Vimfiles"
    $ p                 # list all projects
    Projects:
    * v          My Vimfiles

    $ f r .vimrc                     # add .vimrc to this project with shortcut "r"
    $ f c .vim/colors/vividchalk.vim # add this file with shortcut "c"
    $ f                              # list all files in the current project
    Project: v (My Vimfiles)
    Current files:
    r .vimrc                                             /home/dbradford
    c vividchalk.vim                                     /home/dbradford/.vim/colors

    $ export EDITOR=vim
    $ f c # edit file assigned to "c" with $EDITOR

    $ fa  # edit all files in project with $EDITOR

    $ . d t # cd to directory containing file with shortcut "t"
            # you can do it without the '.' if you set up alias d='. d'

    $ x t ". d m;make test" # add command with shortcut "t"
    $ x t                   # execute command assigned to shortcut "t"
    t/DMB.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.05 usr  0.02 sys +  0.05 cusr
    0.03 csys =  0.14 CPU)
    Result: PASS

    $ . v # assign all projects files to shell variables in the current shell
          # you can do it without the '.' if you set up alias v='. v'
    r=/home/dbradford/.vimrc
    c=/home/dbradford/.vim/colors/vividchalk.vim

    $ cat $c >>$r # use shell commands to work with this set of files

Note: if the set of files changes you will need to run `v` again.

## Installation

Put "p" in your `$PATH` and then create these links to p in the same directory:

    f     # edit file
    fa    # edit all files
    x     # execute command
    xa    # execute all commands
    z     # get help
    zdir  # get directory of file (typically not used directly by user)

Separate scripts, put somewhere in `$PATH`

    af    # find and add files
    d     # change to directory of specified file
    v     # set shell variables for file shortcuts

Add the following lines to your `.cshrc` file (for csh and tcsh), `.profile`
(for sh and ksh), or `.bash_profile` (for bash):

    alias d='. d'
    alias v='. v'

## Author

David M. Bradford, [davembradford@gmail.com](mailto:davembradford@gmail.com)

## License

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

1. Add tests to cover all functionality
1. Create installer
1. Docs should cover same material between 'p --help' and 'README.md'
1. Create video documenting use
1. Create blog post based on documentation
1. further improvements to code, if nothing else, then via Perl::Critic

## Technical Notes
1. `clpm` uses `Data::Dumper` and `eval` for persistance. It used `Storable` initially, but after two separate instances of data corruption, that was abandoned in favor of `YAML`, which in turn wasn't available in many environments, thus `Data::Dumper`.

## Detailed Usage

### Get help

    $ z # or p --help or f --help or x --help etc
    Command Line Program Managers (clpm) v1.0.1
    Help commands:
                z  - this listing
    Organization commands:
                f  - manage files
                    examples:
                    show list of files:    $ f
                    edit file 1, 3, and L: $ f 13L
                    edit all files:        $ fa
                    add file to the list : $ f , /tmp/a.dmb /etc/hosts /etc/passwd
                    add file with label L: $ f L /tmp/a.dmb
                    remove file 1, 3, L  : $ f -13L
                x  - manage commands (same basic format as f)
                    examples:
                    show list of cmds:     $ x
                    run cmd 1, 3, and L:   $ x 13L
                    edit cmd 1, 3, and L:  $ x .13L
                    edit all cmds:         $ xa
                    add cmd to the list :  $ x , 'echo hey' 'Optional Label'
                        NOTE: surround command with quotes
                    add cmd with label L:  $ x L 'echo howdy; echo there' 'Optional Label'
                    remove cmd 1, 3, L  :  $ x -13L
                p  - change project/view list of projects
                    show project list:     $ p
                    switch to project:     $ p myproj
                    remove project:        $ p -myproj
    Current project: sst


### Get project listing

    $ p
    Projects:
      f          rpg fight simulator
      go         getopts experiment
    * sst        shell script template


### Create a new project

    $ p s 'Shopping Cart'
    Project: s (Shopping Cart)
    Current files:

    $ p
    Projects:
      f          rpg fight simulator
      go         getopts experiment
    * s          Shopping Cart
      sst        shell script template


### Add some files

    $ find .
    .
    ./ShoppingCart
    ./ShoppingCart/Changes
    ./ShoppingCart/lib
    ./ShoppingCart/lib/ShoppingCart.pm
    ./ShoppingCart/Makefile.PL
    ./ShoppingCart/MANIFEST
    ./ShoppingCart/README
    ./ShoppingCart/t
    ./ShoppingCart/t/ShoppingCart.t
    ./www
    ./www/page
    ./www/page/items.html
    ./www/page/login.html
    ./www/page/shopping_cart.html
    ./www/script
    ./www/script/cartItems.js
    ./www/style
    ./www/style/home.css

    $ cd ShoppingCart/

    $ ls -l
    total 7
    -rw-rw-r--  1 dbradford None  157 Jan 17 16:34 Changes
    drwxrwxr-x+ 1 dbradford None    0 Jan 17 16:34 lib
    -rw-rw-r--  1 dbradford None  564 Jan 17 16:34 Makefile.PL
    -rw-rw-r--  1 dbradford None   73 Jan 17 16:34 MANIFEST
    -rw-rw-r--  1 dbradford None 1191 Jan 17 16:34 README
    drwxrwxr-x+ 1 dbradford None    0 Jan 17 16:34 t

    $ f m Makefile.PL

    $ f t t/ShoppingCart.t

    $ f s lib/ShoppingCart.pm

    $ f
    Project: s (Shopping Cart)
    Current files:
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Add some more files (note case sensitivity)

    $ f C Changes

    $ f M MANIFEST

    $ f R README

    $ f
    Project: s (Shopping Cart)
    Current files:
    C Changes                           /home/dbradford/shopping_cart/ShoppingCart
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    M MANIFEST                          /home/dbradford/shopping_cart/ShoppingCart
    R README                            /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Edit a couple files

    $ f st
    2 files to edit


### Edit all files

    $ fa
    6 files to edit


### Remove one file, then remove two others

    $ f -R

    $ f -CM

    $ f
    Project: s (Shopping Cart)
    Current files:
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Add a command, then run it

    $ x p 'perl Makefile.PL'

    $ x p
    perl Makefile.PL
    Checking if your kit is complete...
    Looks good
    Writing Makefile for ShoppingCart
    Writing MYMETA.yml and MYMETA.json


### Add more commands, then run them

    $ x t 'make test'

    $ x t
    make test
    cp lib/ShoppingCart.pm blib/lib/ShoppingCart.pm
    PERL_DL_NONLAZY=1 /usr/bin/perl.exe "-MExtUtils::Command::MM" "-e"
    "test_harness(0, 'blib/lib', 'blib/arch')" t/*.t
    t/ShoppingCart.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.03 usr  0.05 sys +  0.03 cusr  0.12 csys =  0.23 CPU)
    Result: PASS

    $ x c
    make clean
    rm -f \
      tmon.out ShoppingCart.def \
      MYMETA.yml perl \
      mon.out blibdirs.ts \
      perlmain.c *perl.core \
      so_locations MYMETA.json \
      blib/arch/auto/ShoppingCart/extralibs.all core.*perl.*.? \
      *.a blib/arch/auto/ShoppingCart/extralibs.ld \
      *.o pm_to_blib.ts \
      core.[0-9][0-9][0-9][0-9][0-9] core.[0-9][0-9][0-9][0-9] \
      core.[0-9] ShoppingCart.bso \
      libShoppingCart.def core.[0-9][0-9][0-9] \
      ShoppingCart.x Makefile.aperl \
      core ShoppingCart.exp \
       pm_to_blib \
      perl.exe core.[0-9][0-9] \
      perl.exe
    rm -rf \
      blib
    mv Makefile Makefile.old > /dev/null 2>&1

    $ x C 'make realclean'

    $ x C
    make realclean
    rm -f \
      ShoppingCart.x libShoppingCart.def \
      ShoppingCart.bso Makefile.aperl \
      *.o ShoppingCart.def \
      so_locations mon.out \
      perlmain.c core.[0-9][0-9][0-9][0-9] \
      MYMETA.yml core.[0-9][0-9] \
      core.*perl.*.? blib/arch/auto/ShoppingCart/extralibs.all \
      *.a core \
      core.[0-9][0-9][0-9][0-9][0-9] core.[0-9] \
      perl.exe pm_to_blib.ts \
      tmon.out core.[0-9][0-9][0-9] \
      *perl.core MYMETA.json \
      perl.exe blib/arch/auto/ShoppingCart/extralibs.ld \
      pm_to_blib ShoppingCart.exp \
       blibdirs.ts \
      perl
    rm -rf \
      blib
    mv Makefile Makefile.old > /dev/null 2>&1
    rm -f \
      Makefile.old Makefile
    rm -rf \
      ShoppingCart-0.01


### Run two commands in sequence

    $ x pt
    perl Makefile.PL
    Checking if your kit is complete...
    Looks good
    Writing Makefile for ShoppingCart
    Writing MYMETA.yml and MYMETA.json
    make test
    cp lib/ShoppingCart.pm blib/lib/ShoppingCart.pm
    PERL_DL_NONLAZY=1 /usr/bin/perl.exe "-MExtUtils::Command::MM" "-e"
    "test_harness(0, 'blib/lib', 'blib/arch')" t/*.t
    t/ShoppingCart.t .. ok
    All tests successful.
    Files=1, Tests=1,  0 wallclock secs ( 0.03 usr  0.02 sys +  0.03 cusr  0.05 csys =  0.12 CPU)
    Result: PASS


### xa (run all commands) exists, may not be helpful depending on command order


### Add more files in other directories

    $ pwd
    /home/dbradford/shopping_cart/ShoppingCart

    $ cd ..

    $ ls
    ShoppingCart  www

    $ cd www

    $ ls page/
    items.html          login.html          shopping_cart.html

    $ f h page/shopping_cart.html

    $ f j script/cartItems.js

    $ f c style/home.css

    $ f
    Project: s (Shopping Cart)
    Current files:
    j cartItems.js                      /home/dbradford/shopping_cart/www/script
    c home.css                          /home/dbradford/shopping_cart/www/style
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    h shopping_cart.html                /home/dbradford/shopping_cart/www/page
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Change to the directory of a given file

    $ . d s # you can do it without the '.' if you set up alias d='. d'

    $ pwd
    /home/dbradford/shopping_cart/ShoppingCart/lib

    $ . d c

    $ pwd
    /home/dbradford/shopping_cart/www/style


### Use af to locate and add more files

    $ pwd
    /home/dbradford/shopping_cart

    $ export AF_DIR=`pwd`

    $ af html
    0 ./www/page/items.html
    1 ./www/page/login.html
    2 ./www/page/shopping_cart.html


### Use v to assign full file paths to shell variables

    $ . v # you can do it without the '.' if you set up alias v='. v'
    j=/home/dbradford/shopping_cart/www/script/cartItems.js
    t=/home/dbradford/shopping_cart/ShoppingCart/t/ShoppingCart.t
    h=/home/dbradford/shopping_cart/www/page/shopping_cart.html
    s=/home/dbradford/shopping_cart/ShoppingCart/lib/ShoppingCart.pm
    c=/home/dbradford/shopping_cart/www/style/home.css
    m=/home/dbradford/shopping_cart/ShoppingCart/Makefile.PL
    l=/home/dbradford/shopping_cart/www/page/login.html

    $ cp $l $l.sv

    $ cp $s $l

    $ less $l


### Copy projects with 'p cp'

    $ p
    Projects:
      f          rpg fight simulator
      go         getopts experiment
      sst        shell script template
    * s          Shopping Cart

    $ p cp s sw
    Project: sw (Shopping Cart)
    Current files:
    j cartItems.js                      /home/dbradford/shopping_cart/www/script
    c home.css                          /home/dbradford/shopping_cart/www/style
    l login.html                        /home/dbradford/shopping_cart/www/page
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Then rename the new project

    $ p sw 'Shopping Cart (rework)'
    Project: sw (Shopping Cart (rework))
    Current files:
    j cartItems.js                      /home/dbradford/shopping_cart/www/script
    c home.css                          /home/dbradford/shopping_cart/www/style
    l login.html                        /home/dbradford/shopping_cart/www/page
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Move projects with 'p mv'

    $ p mv sw rw
    Project: rw (Shopping Cart (rework))
    Current files:
    j cartItems.js                      /home/dbradford/shopping_cart/www/script
    c home.css                          /home/dbradford/shopping_cart/www/style
    l login.html                        /home/dbradford/shopping_cart/www/page
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t


### Search projects with 'p \?text'

    $ p \?shop
    Projects:
      rw         Shopping Cart (rework)
      s          Shopping Cart

    $ p ?rework
    Project: rw (Shopping Cart (rework))
    Current files:
    j cartItems.js                      /home/dbradford/shopping_cart/www/script
    c home.css                          /home/dbradford/shopping_cart/www/style
    l login.html                        /home/dbradford/shopping_cart/www/page
    m Makefile.PL                       /home/dbradford/shopping_cart/ShoppingCart
    s ShoppingCart.pm                   /home/dbradford/shopping_cart/ShoppingCart/lib
    t ShoppingCart.t                    /home/dbradford/shopping_cart/ShoppingCart/t

