Nonlin - explanation of the release files
Austin Tate, <a.tate@ed.ac.uk>
Updated: Thu Feb  9 22:26:09 2006
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

There you are you should just have solved the
Sussman anomaly block stacking problem.

Now try house1 and plan action {build house};

For other domains and the kinds of task/plan you can state
look at the contents of nonlin/tf directory

Documentation
-------------

Nonlin and its algorithms are documented in the following paper:

     Tate, A. (1977) "Generating Project Networks", Proceedings of the
     Fifth International Joint Conference on Artificial Intelligence
     (IJCAI-77) pp. 888-893, Boston, Mass. USA, August 1977. Reprinted in
     "Readings in Planning", Morgan-Kaufmann, 1990.

Read the help text (nonlin/nonlintxt) for recent additions and syntax
changes.  See the sample tf files for some examples.  You can also
read University D.A.I. Memo 25 which contains implementation details.
A review of Nonlin by Subbarao Kambhampati is included at the end of
this readme.

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

    ... then do
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


PROCEDURE TO CREATE A SAVED IMAGE OF NONLIN
-------------------------------------------

This may not be necessary nowadays as compilation is so fast.

1.  create 3 directories   poplib    nonlin     nonlin/tf
    nonlin/tf  will be used for demonstration tf and can be held anywhere.
    poplib and nonlin are both used during system build and nonlin is
    used at run time to pick up help and alert texts and a critical path
    method package (it does this by using a full file path name that you
    can specify during system build).

    After you save a Nonlin image,  Nonlin should run from anywhere
    and will look for a file in the current working directory called nonlin/tf
    for tf files.  Change the tf macro in the nonlin.p source if you want
    tf picked up from somewhere else.

2.  copy in the files with names as on the tape to the given directories.
    You will realise any mistakes on placement as a single compile of
    nonlin/nonlin.p is used to compile the main part of the system.

3.  To help locate files correctly,
       only nonlin.p (the main file)
                    tfinfo.p (a replacement user interface)
                    nonlincpm
                    nonlintxt
                and nonlininfo     go under nonlin

    All files that end in .tf go into the nonlin/tf directory.  The others
    go under poplib.

4.  alter  poplib/clear.p   to be a suitable clear for your terminals.

5. The file load_nonlin.p defines some global variables at the top
specifying path names. These can be altered if necessary: the defaults
assume that you run the programs in the directory containing the file.

E.g. you may wish to give a full path name for the nonlin directory to
be used to pick up the help, alert and critical path method package
files at run-time.

6. To compile nonlin cd to the top level nonlin directory, then run
pop11 and compile the load_nonlin.p file, i.e.

    cd <directory>

    pop11

    compile('load_nonlin.p');

7. If you wish to create a saved image Do not compile the Critical Path
Package.   Do not view the help text.

8.  If you want the alternative user interface (the one used at Edinburgh)
    compile('nonlin/tfinfo.p');    and do
    nonmac tfinfo -> nonmac prinfo;

9.  To prepare to make a saved image:

    compile('poplib/saver.p');

10. Then type

    saver nonlin.psv     or whatever you want to call the saved image.

11. This will take you to command level.  run Nonlin with POP11 +nonlin
    This should be posssible from a directory other than the one in which
    you created the system

Some Useful System Functions
----------------------------

pwd
current_directory =>
cd <directory>
$dir
sysexit

Review of Nonlin
----------------

From: Subbarao Kambhampati <rao@asu.edu> 
Date: Tue, 26 Nov 2002 11:53:08 -0700 
To: planning@asu.edu 
Subject: Rao's "Reminiscences of Influential Papers in Planning" 

Paper:  Austin Tate: Generating Project Networks. IJCAI 1977: 888-893

Also the companion TR:
Austin Tate "Project Planning using Hieararchic Nonlinear Planner" Research
Report 25. Dept of AI. Edinburgh Univeristy. 1976.  

The time was 1988. David Chapman's cassandric predictions about death
of planning was among the AIJ best sellers. Drew McDermott, having
pretty much solved all the problems of planning from expressiveness
point of view, has turned his attention to "critiques" of pure
reason. David Smith was co-publishing possible (world) papers here and
there. Dan Weld was singing praises of exaggeration.  Hector was still
in grad(e) school working hard towards his eventual ascension to
planning.  David Wilkins was working on SIPE. The Timberline workshop
on planning just got concluded, and Austin is writing papers on
"Clouds" (I am not kidding--there are actual pictures of clouds in
his Timberline paper). 

I was a (not so) young but impressionable graduate student at UMD,
angling for a dissertation in EBL (the big fad then in learning
community), while JimH was trying to steer me into planning (these
were his pre-OILy days). After several marathon meetings, I have
already made significant progress towards the dissertation in that we
hammered out a name for the plan-reuse system I was going to
write. With a name like "PRIAR" there was clearly no turning back and
I had to actually implement it. Having got exclusive rights to an
explorer lisp machine over at the SRC, I was all set to write my plan
reuse system, when I realized that in order to do reuse, I actually
have to have a planner that can support from-scratch planning.

Not to worry. There are tons of planning systems out there, I was
sure, and I just had to pick one and get going. My obvious first
choice was David Chapman's TWEAK--which is on prime-time planning news
those days. Oh those NP-hardness proofs, that hi-fi jargon
--"white-knights valiantly saving damsels in distress by posting
non-codesignation constraints"--it is clearly *the* planner to base
your work on. Plus the whole TWEAK project got started becaused David
Chapman had trouble running NOAH on non-published examples and clearly
TWEAK will be a blazingly fast portable user-friendly planner. So I
wrote to David Chapman, who despite being an obvious celebrity,
replied promptly, and explained to me, in effect, that he "proved" the
planner to be complete and slow, but didn't actually have a
distributable implementation. The way he phrased his mail, I wasn't
sure if there ever was a TWEAK in non-vaporware form (some 8 years
later, brother Qiang Yang repaired the situation by implementing not
only Tweak, but also AbTweak).

What to do now? NOAH was already in soup, and TWEAK is apparently
vaporware. JimH then told me to look up Nonlin--a planner written by
Tate circa 1977. Yeah sure, I thought.. imagine anything written a
decade back making anysense. Being a dutiful graduate student I did go
and copy the 6-page paper from IJCAI 1977 proceedings--and it turned
out to be so different from all the narrative-style planning papers
that I had read until that point.

Review:

Tate's 1977 paper is about the NONLIN implementation. It clearly
states the problem of reasoning about truth of conditions over
partially ordered actions. It provides a procedure (innovatively
called the Q&A procedure) that can tell you whether or not a
precondition will hold at some point over partially ordered sequence
of actions. Q&A operates on GOST--Goal Structure Table--which is
Nonlin's way of capturing causal structure of a partially ordered
plan. It also provides, as part of this process, the constraints that
can be added to _make_ the condition hold (if it does not already
hold). Although it wasn't proven to be so, the procedure is complete,
and not only shows that both promotion and demotion are to be
considered (in contrast to NOAH's airy--"oh just pick one and be done
with it" recipe), but even handles the "white-knight" clause (10 years
before the colorful phrase got introduced into our jargon).  It then
shows how the Q&A procedure is used as the backbone for plan synthesis
in Nonlin.

The companion technical report (Edinburgh TR # 25) provides a
thorough--algorithmic/data-structure level--description of how Nonlin
is implemented around the Q&A procedure. Among other things, it gives
a clear syntactic description of the task reduction schemas, and
brings out several problematic issues that need to be handled when a
partial plan is being refined both by reduction and by task addition
(years before colorful terms such as "Hierarchical Promiscuity" were
used to describe these problems). 

The TR description is thorough enough to allow me to _reimplement_
Nonlin in lisp (which I believe is still distributed as UM-NONLIN
http://www.cs.umd.edu/projects/plus/Nonlin ). About the only part that
didn't get proper coverage was the control of backtracking (original
nonlin used a language that has support for context switching--which
made chronological backtracking easy to implement) and lack of search
control. The latter, while a gaping hole, was pretty much standard
fare until the post-Graphplan/UnPOP era. As McDermott remarked with his
customary turn of phrase in his UnPOP paper:  "Search is usually given
little attention in this field, relegated to a footnote about how
"Backtracking was used when the heuristics didn't work"" 

I sometimes think that a lot of planning work could have taken quite a
different tack if these two papers were paid more attention. If you
read Tate's 1977 paper, Chapman's 1987 paper seems much less novel and
hardly ominous (replace Q&A for MTC, and you will see what I mean).
If you knew Tate's 1977 paper, McAllester's 1991 paper will just be a
textbook summary of partial order planning (a sub-part of the HTN
planning that Nonlin already almost cleanly explains), rather than the
beginning of partial order planning (as has become its de facto
current status).  In particular the causal links that everyone seems
to be so smitten with are but GOSTs (I mean GOST--Goal Structure
Tables) from Nonlin. If you knew Nonlin, you will see Tom Dean's later
work on reasoning with event databases as a worthy continuation rather
than a completely new beginning on reasoning over partially ordered
events. If you knew Nonlin, you will at least empathize (if not
sympathize) with the criticisms sometimes levelled by some old-timers,
during the boom-days of "Propositional planning", that planning
community may be watering down the problem to make it easy to solve.

Being someone who not only knew, but scribbled the heck out of his
copies of the paper and TR, and spent many a cozy night staring into
the TI explorer and cursing Tate for his devious algorithms, I was
clearly influenced by that work.  The influence shows through in the
PRIAR work, the multi-contributor causal structures work, the
foundations of refinement planning work, as well as the much more
recent RePOP work (which came *this* close to being ReNonlin--we had to
abandon it as I couldn't find the nifty graphic for ReNonlin--plus it
sounded suspiciously like Ritalin).
