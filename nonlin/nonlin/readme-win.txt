Nonlin - explanation of the release files
Austin Tate, <a.tate@ed.ac.uk>
Updated: Sun Dec 01 14:14:03 2002
---------------------------------------------------------------
Copyright (c) Austin Tate, 1976-2002
URL: http://www.aiai.ed.ac.uk/project/nonlin/

Nonlin is released as is for academic and research purposes.  It is a
research prototype created in the mid 1970s and released to people
interested in experimenting with an early AI planner.

Nonlin is subject to the same copyright notice as the Poplog copyright
notice at:
    http://www.cs.bham.ac.uk/research/poplog/copyright.html

Poplog is available via
    http://www.cs.bham.ac.uk/research/poplog/freepoplog.html
    http://www.poplog.org

Quick Start
-----------

I am a double click and wait for the instructions person these days:-)
So to get Nonlin up quickly do the following...

Start POP-11 on your system as usual.

pwd
cd <nonlin directory containing load_nonlin.p>
load 'load_nonlin.p';
tfinfo

choose option 1 to load a sample tf domain name:
       b0 for nonlin/tf/b0/tf for example:
choose option 2 to set up a task requirement
       plan goal {on a b} goal {on b c};

There you are you should just have solved the Sussman anomaly block
stacking problem.  Now try house1 and "plan action {build house};".
For other domains and the kinds of task/plan you can state look at the
contents of nonlin/tf directory

Tidy up the screen clearing for your chosen operating system by
editing nonlin/poplib/clear.p (or by renaming one of the clear_?.p
alternatives given).

Documentation
-------------

Nonlin and its algorithms are documented in the following paper:

     Tate, A. (1977) "Generating Project Networks", Proceedings of the
     Fifth International Joint Conference on Artificial Intelligence
     (IJCAI-77) pp. 888-893, Boston, Mass. USA, August 1977.
     Reprinted in "Readings in Planning" (eds. Allen, J., Hendler, J.
     and Tate, A.), Morgan-Kaufmann, 1990.

Read the help text (nonlin/nonlintxt) for recent additions and syntax
changes.  See the sample tf files for some examples.  You can also
read University D.A.I. Memo 25 which contains implementation details.

POPLOG VERSION 15
-----------------

The notes below have been prepared for Unix/Linux Poplog

Some problems have been noted in compiling Nonlin under V15 onwards
of POPLOG.

The following notes were made by Dave Moffat at Edinburgh DAI after
fixing the problems for V13, and then extended by Aaron Sloman and
Austin Tate for Poplog V15 or after.

When running nonlin in POP-11 the following commands are needed in order
to compile the nonlin code and libraries that it uses. These commands
are all made available in the file load_nonlin.p

So instead of giving these commands explained individually below you can do
    load 'load_nonlin.p';

Explanation:

    compile_mode :pop11 +oldvar;
        Needed because in some cases the nonlin code uses a
        global variable as an input local. This compile mode
        switch prevents input locals being interpreted as lvars,
        which is now the pop-11 default.

    true -> pop_longstrings;
        Because there are many places where strings extend
        over line breaks

    lib pop2;
        Compile a number of libraries to make pop11 compatible with
        code originally written for pop2, e.g. including the "comment"
        macro which reads and ignores everything up to the next
        semi-colon.

    sysunprotect("&&");
        In pop11 this is a bitwise "and" operator. As a system
        identifier it is protected. In poplib/hbase.p, used by Nonlin
        this identifier is cancelled and redefined. To enable this it
        has to be unprotected.

    global vars syntax ---> <: :> ;
        This stops autoloading of symbols used in TF files in Poplog 15.5.
        Otherwise you will get errors when loading TF thas the compile readitem
        function tries to look up automatic entries.

    compile('nonlin/nonlin.p');
        This will ask you some questions. Answer Y or N

    compile('nonlin/tfinfo.p');

    nonmac tfinfo -> nonmac prinfo;
        This makes the prinfo be the same as the tfinfo one

    false -> draw_flag;
    false -> context_flag;
        These turn off handling of AutCAD output file creation for a drawing
        interface created for Nonliin in the 1980s.  It has not been checked
        under Poplog 15.5

Some Useful System Functions
----------------------------

pwd
current_directory =>
cd <directory>
$dir
