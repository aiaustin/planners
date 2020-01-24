;;; Discarded old nonlin.p, which used to compile this under another name,
;;; because the relevant work is done by load_nonlin.p in the super-directory
;;; Also changed all pop11 files to have .p suffix (makes the editor behave
;;; more sensibly when viewing/editing them.
;;; Got rid of questions about unix/vms, etc. and the file prefix.
;;; Had to set compile_mode :pop11 +oldvar; to make all this compile properly.
;;; Aaron Sloman: 27 Oct 2002

;;; Austin Tate Updated: Sun Dec 01 19:46:01 2002
;;; Correct capitalisaton of Nonlin used.

comment 'changes made, 19-6-91:
            add draw_flag, drawnet for AutoCAD interface.
            modify prnet and prreducenet to call drawnet if draw_flag true.
         only changes to  7-Jan-85 version are
         1. tf files picked up from nonlin/tf/... rather than tf/...
         only changes to 11-Oct-84 version are
         1. VMS file name handling added
         only changes to 25-Jun-84 version are
         1. slight improvements to hbase and genpr
         2. prnet and prreducenet put out number of nodes for graph drawing.
         3. when reading prefix for nonlin files, a / may be added.
         and to 28-Feb-84 version are
         1. alterations to library reading and use of a nonlin prefix
            to allow saved image to run away from directory of creation.
         and to 27-Jan-84 version are
         1. dereference item to itemid before passing to a COMPUTE function
            in rechoce
         and to 14-Dec-83 version are
         1. achlist is now in form of a vector of 5 entries each a list of
            pairs with a pattern and schema.  Changes to
            a) newdomain
            b) choosexp
            c) review
         and to 31-Oct-83 version are
         1. better message on Cannot match 2 non-instantiable actors in smatch
         2. and nodetype(n)/="phantom" in netlevel
         3. changes to record schemas in order given and to keep schemas
            with actor restrictions on the pattern variables together
            (needs a new routine generalinstance) in review
         4. change to chooseexp to get ALL matching schemas, not the first such
            list on achlist
         5. qaone(...)=true check in qaall
        ';

comment 'This is Nonlin.
         (c) Copyright 1976-2002, Austin Tate.

         It is documented in Austin Tate DAI Research Memo 25-Aug-76.

         Updated to WonderPOP - 12-June-83, Austin Tate
         Updated to PopLog - 30-Sep-83, Austin Tate';

;;; these are declared and given values in load_nonlin.p
vars libprefix libpostfix
     nonlinprefix nonlinpostfix
     tfprefix tfpostfix;


/*
No longer needed: see load_nonlin.p

procedure; vars x i ch path;
  comment 'cannot even use prompt at this point';
	[nlversion ^nlversion] =>
  1.nl; pr('System type: U(nix, V(ax VMS:');
  sysflush(popdevout);
  rawcharin() -> x; comment 'now test for U u V or v';
  while not(member(x,[ 85 117 68 118])) do rawcharin() -> x endwhile;
  2.nl;
  pr('Give a prefix for Nonlin files (may be null):');
  sysflush(popdevout);
  0 -> i;
  while (rawcharin() -> ch; (ch/=13 and ch/=10)) do
    if (ch=8) or (ch=127) then
      if i>0 then i-1 -> i; .erase; charout(8); charout(32); charout(8); endif;
    else charout(ch); i+1 -> i; ch;
    endif;
    sysflush(popdevout);
  endwhile;
  1.nl;
  if x=85 or x=117 then
    'Unix ' ><nlversion -> nlversion;
	[nlversion ^nlversion] =>
    if i>1 then
      -> ch; ch;
     if ch/=`/` then i+1 -> i; `/` endif;
    endif;
    i.consstring><'nonlin/' -> nonlinprefix; '' -> nonlinpostfix;
    'poplib/' -> libprefix;                  '.p' -> libpostfix;
    'nonlin/tf/' -> tfprefix;                       '.tf' -> tfpostfix;
    pr('Unix');
  else
    'Vax VMS ' ><nlversion -> nlversion;
    if i>1 then
      -> ch;
      if ch=`]` then i-1 -> i else ch endif;
    endif;
    if i>1 and ch/=`.` then i+1 -> i; `.`  endif;
    if i=0 then `[`; 1 -> i; endif;
    i.consstring><'NONLIN]' -> nonlinprefix;  '' -> nonlinpostfix;
    '[POPLIB]' -> libprefix;                  '' -> libpostfix;
    '[TF]' -> tfprefix;                       '' -> tfpostfix;
    pr('Vax VMS');
  endif;
  pr(' file prefixes and postfixes set up');
  1.nl; pr('Prefix to be used is "'); pr(nonlinprefix); pr('"'); 2.nl;
endprocedure.apply;

*/

define nllibrary t;
  comment 'get a filename or character repeater for the nonlin
           support library file with name t';
  libprefix><t><libpostfix;
enddefine;

;;; cucharout; erase -> cucharout;
compile(nllibrary('clear'));
compile(nllibrary('prompt'));
;;; -> cucharout;

comment '*************************************************************'
        'HBASE with actors and contexts. Also provided is a
         facility for placing actor restrictions on variables and a
         @* semi-open variable.'
        'The system incorporates a facility for indicating which actors are
         instantiable - i.e. respond correctly to an attempt to match ===';

compile(nllibrary('hbase'));
compile(nllibrary('hbactor'));
compile(nllibrary('hbcontext'));

comment 'macros to aid in writing HBASE code';

define undefval x; undef -> value(x) enddefine;

define macro assert; vars x;
   while (.itread -> x; x/=";") do
       "true", "->", "value", "(", x, ")", ";"  endwhile;
enddefine;

define macro deny; vars x;
   while (.itread -> x; x/=";") do
      "false", "->", "value", "(", x, ")", ";" endwhile;
enddefine;

define macro unbind; vars x;
  while (.itread -> x; x/=";") do
      "appitems", "(", x, ",", ===, ",", undefval, ")", ";"
  endwhile;
enddefine;

cancel x;

define instact s;
   if pdprops(valof(subact(1,s)))="instance" then ===,s.applyact
   else s endif
enddefine;

define macro inst; vars x;
  while (.itread->x; x/=";") do "instance" -> pdprops(valof(x)) endwhile
enddefine;

define instant x; comment 'IS X AN INSTANTIABLE ACTOR';
  (pdprops(valof(subact(1,x)))="instance")
enddefine;

comment 'Restriction facilities for variables in HBASE - also @* ';

vars setvars varval; valof -> varval;

define smatch s t; vars i n;
loop:
   if s=t then true
   elseif s.isitem and t.isitem then false
   elseif s.isactor and t.isactor.not then applyact(t,s)
   elseif t.isactor then
      if s.isactor and not(instant(t)) then
         1.nl; 'Cannot match 2 non-instantiable actors '.pr;
         s.genpr; ' and '.pr; t.genpr; false; return endif;
      applyact(s,t)
   elseif s="===" or t="===" then true
   elseif t.isitem then t.itemid->t; goto loop
   elseif s.isitem then s.itemid->s; goto loop
   elseif not(samedata(s,t)) then false
   elseif s.isvector then
      s.datalength -> n;
      if n/=t.datalength then false; return endif;
      1 -> i;
      while i<=n and match(subscrv(i,s),subscrv(i,t)) do
        i+1 -> i
      endwhile;
      i>n
   elseif s.atom.not and match(s.dest->s,t.dest->t) then goto loop
   else false endif;
enddefine;

define given s x; vars i; varval(x) -> i;
   if s= === then
      if i=undef then === else i endif; return
   endif;
   if i/=undef and not(i.isactor) then match(s,i)
   else if s.isactor then s.instact -> s; endif;
      if s= === or s=undef then true; return endif;
      i::(x::setvars) -> setvars;
      if i.isactor then
         if s.isactor then "et",i,s,3.consact -> varval(x); true; return endif;
         if applyact(s,i) then else false; return endif;
      endif;
      s -> varval(x); true
   endif
enddefine;

define macro @*; <| "given", .itread |> enddefine;

define match; vars setvars match;
   nil -> setvars; smatch -> match;
   if match() then true; return endif;
   while setvars.ispair do
      (setvars.dest -> setvars) -> varval(setvars.dest -> setvars)
   endwhile; false
enddefine;

define macro restrict; vars i;
   while(.itread -> i; i/=";") do .itread -> varval(i) endwhile
enddefine;

inst getval getvalue given;

cancel x s i smatch setvars;

'Actor restriction on variables, @*, Inst and Nice facilities ready'.pr; 1.nl;

comment '******************************* end of HBASE extensions ***********';

define neterror; .setpop enddefine;

comment 'make @* a logical variable with values set in a local alist';

vars alist;

define varval x; vars l;
  if alist.ispair then alist -> l;
    while l.ispair do
      if x=(l.dest->l) then l.hd; return endif;
      l.tl -> l
    endwhile;
  endif;
  1.nl; pr('Variable non-existant - '); pr(x); .neterror
enddefine;

procedure y x; vars l;
  if alist.ispair then alist -> l endif;
  while l.ispair do
    if x=(l.dest->l) then y -> l.hd; return endif; l.tl -> l
  endwhile;
  1.nl; pr('Variable non-existant - '); pr(x); .neterror
endprocedure -> updater(varval);

comment '*********data structures and auxillary routines for Nonlin********';

vars allnodes maxnodes numnodes incrnodes netmarked tome gost
     initctxt alwayctxt

     achlist allfns mainefflist levellist primlist costlist

     sometoexpand changenet suggest newsuggest identnet
     choicepts interact currnode

     opchoice linchoice instchoice

     bugexpand interint unsuperint condint undefnum

     copy1 ismember iscondtype oppvalue dummyfn2

     inter clearscreen

     initopsch initmain initnode dummynode

     cpm cpmchnet cpmnewlink cpmrecomp efin prcpdata;

comment 'CPM VARIABLES ARE 6 definitions PROVIDED IN THE CRITICAL PATH
         ANALYSIS PACKAGE - THEY ARE INITIALIZED TO DUMMY definitions';

procedure x y; endprocedure -> dummyfn2;

dummyfn2 -> cpm;        dummyfn2 -> cpmchnet;
dummyfn2 -> cpmnewlink; dummyfn2 -> cpmrecomp;
identfn -> efin;
procedure; endprocedure -> prcpdata;

maplist(%identfn%) -> copy1;
lmemb(%nonop = %) -> ismember;
not -> oppvalue;

10 -> opchoice;  15-> linchoice;  20 -> instchoice;

undef -> undefnum; comment 'undef assigned where a number should be';
                   comment 'aids in error finding if used incorrectly';

recordclass opsch opschname oppattern addlist denylist undeflist
                  opexpansion opconditions varslist onachlist;
            comment 'also creates isopsch consopsch destopsch';
            cancel destopsch;

recordclass main mainpatt mainadd maindeny mainundef mainvars;
            comment 'also creates ismain consmain destmain';
            cancel destmain ismain;

consopsch(undef,undef,nil,nil,nil,undef,nil,nil,undef) -> initopsch;
consmain(undef,nil,nil,nil,nil) -> initmain;

recordclass choice choicenum choicetype choise choicenet
                   choiceint choicenode;
            comment 'also creates ischoice conschoice destchoice';

recordclass inter intnode intactors intpatt intvalue;
            comment 'also creates isinter consinter destinter';

comment '*******************************************************************
    A NODE NEED ONLY BE COPIED AT THE TOP LEVEL.  WHENEVER A CHANGE IS MADE
    TO A COMPONENT ENSURE A COPY IS MADE OF COMPONENT THEN. COPY ON CHANGE
         *******************************************************************';

recordclass node nodenum nodemark nodelevel nodecost nodetype pattern
                 nodectxt expansion expanconds parentnode prenodes
                 succnodes nodevars;
            comment 'also creates isnode consnode and destnode';

consnode(0,0,0,0,undef,undef,undef,undef,undef,undef,nil,
     nil,undef) -> initnode;
consnode(0,0,0,0,"dummy",consword(' '),undef,nil,nil,undef,nil,
     nil,undef) -> dummynode;
     comment 'consword is a space';

comment 'a version of appdata that does not apply to undef';

define nlappdata nlappdatax nlappdataf;
  if nlappdatax/=undef then appdata(nlappdatax,nlappdataf) endif
enddefine;

comment '***************************************************************
    THE NETWORK IS REPRESENTED BY A FLEXIBLE STRIP (ALLNODES) OF NODES
    WITH CURRENT SIZE MAXNODES.  THE NUMBER OF NODES IN THE STRIP IS
    NUMNODES.'  '  THE INCREMENT FOR INCREASING THE STRIP SIZE AS NEEDED IS
    INCRNODES.  PRENODES AND SUCCNODES ARE LISTS OF NUMBERS OF NODES
    DIRECTLY CONNECTED TO THE CURRENT ONE.'  '
    WHEN COPYING A NETWORK IT IS NECESSARY TO KEEP A COPY OF ALLNODES AND
    NUMNODES.  THEN TAKE A COPY OF TOME AND GOST BY PUSHING THE CONTEXT.
    The values for maxnodes and incrnodes are initialised in the
    newdomain define macro.
    *****************************************************************';

define node n;
  if n>maxnodes then undef else subscrv(n,allnodes) endif;
enddefine;

procedure x n; vars alln i;
  if n>maxnodes then maxnodes -> i;
    maxnodes+incrnodes -> maxnodes;
    initv(maxnodes) -> alln;
    while i/=0 do subscrv(i,allnodes) -> subscrv(i,alln); i-1 -> i endwhile;
    alln -> allnodes;
  endif;
  x -> subscrv(n,allnodes)
endprocedure -> updater(node);

define copyalln; vars x i;
  copy(allnodes) -> x; numnodes -> i;
  while i/=0 do copy(subscrv(i,allnodes)) -> subscrv(i,x); i-1 -> i endwhile; x
enddefine;

define copynet; vars cuctxt;
  comment 'COPY IS OLD VERSION, VARIABLES SET TO NEW (DEPENDENT) VERSION';
  [% allnodes,numnodes,tome,gost,initctxt %]; copyalln() -> allnodes;
  tome -> cuctxt; pushctxt(); cuctxt -> tome;
  gost -> cuctxt; pushctxt(); cuctxt -> gost;
  initctxt -> cuctxt; pushctxt(); cuctxt -> initctxt;
enddefine;

define restore;
  .dest.dest.dest.dest.hd -> initctxt -> gost -> tome -> numnodes -> allnodes
enddefine;

define pushnet; vars cuctxt; .restore;
  datalength(allnodes) -> maxnodes;
  tome -> cuctxt; pushctxt(); cuctxt -> tome;
  gost -> cuctxt; pushctxt(); cuctxt -> gost;
  initctxt -> cuctxt; pushctxt(); cuctxt -> initctxt
enddefine;

define clearmarks n;
  while n/=0 do 0 -> nodemark(node(n)); n-1 -> n endwhile;
  0 -> netmarked; comment '0 means net unmarked';
enddefine;

define qamark n fn i; vars l; n.fn -> l; undefnum -> netmarked;
  while l.ispair do l.dest -> l; .node -> n;
    if nodemark(n)=0 then i -> nodemark(n); l<>n.fn -> l endif
  endwhile
enddefine;

define remmemb x l; vars y;
  [%while l.ispair do l.dest -> l -> y;
      if x/=y then y endif; endwhile%]
enddefine;

define remredundant numx numy; vars l n num x y;
  node(numx) -> x; node(numy) -> y;
  comment 'REMOVE REDUNDANT LINKS TO Y BEFORE LINKING X TO Y';
  if netmarked/=x then
    clearmarks(numnodes); qamark(x,prenodes,"before") endif;
  prenodes(y) -> l;
  [% (while l.ispair do l.dest -> l -> num; node(num) -> n;
       if nodemark(n)="before" then comment 'N BEFORE X SO REDUNDANT LINK TO Y';
          remmemb(numy,succnodes(n)) -> succnodes(n)
        else num endif
      endwhile) %] -> prenodes(y);
  clearmarks(numnodes); qamark(y,succnodes,"after");
  succnodes(x) -> l;
  [% (while l.ispair do l.dest -> l -> num; node(num) -> n;
        if nodemark(n)="after" then comment 'N AFTER Y SO REDUNDANT LINK FROM X';
          remmemb(numx,prenodes(n)) -> prenodes(n)
        else num endif
      endwhile) %] -> succnodes(x);
enddefine;

define link x y allnodes; vars nx ny; comment 'X AND Y ARE NODENUMS';
  node(x) -> nx; node(y) -> ny;
  remredundant(x,y);
  y::succnodes(nx) -> succnodes(nx); x::prenodes(ny) -> prenodes(ny);
  cpmnewlink(x,y);
enddefine;

comment '************************************************************
    ENTRIES IN INITCTXT AND ALL NODECTXTS CAN BE FOUND THROUGH ANY PATTERN.
    TOME AND GOST ENTRIES CAN BE FOUND THROUGH THE APPROPRIATE SUPITEM
    OF ANY PATTERN.' '
    INITCTXT AND NODECTXTS   0  <PATTERN>  <VALUE>
    TOME                     1  { <PATTERN> <NODENUM> }  <VALUE>
    GOST                     2  { <CONDTYPE> <PATTERN> <VALUE> <NODENUM> }
                                                  [<LIST OF CONTRIBUTORS>]
    ****************************************************************';

comment '************QA System and Network Structured Context Package********';

define nodevalue p n; vars cuctxt;
  if n.isinteger then node(n) -> n endif;
  nodectxt(n) -> cuctxt; value(p)
enddefine;

define newnodectxt; vars cuctxt;
  globalctxt -> cuctxt; pushctxt(); cuctxt
enddefine;

define before n1 n2; vars n; node(n2) -> n;
  if netmarked/=n then clearmarks(numnodes); qamark(n,prenodes,"before") endif;
  (nodemark(node(n1))="before")
enddefine;

define marklinks n;
  comment 'FOR EASE OF DETERMINING POSITION OF ANY NODE WITH RESPECT TO
           N, ALL PREDECESSORS ARE MARKED "BEFORE", ALL SUCCESSORS "AFTER",
           THE NODE ITSELF "NODE", AND ALL IN PARALLEL 0';
  if netmarked/=0 then clearmarks(numnodes) endif;
  qamark(n,prenodes,"before");
  qamark(n,succnodes,"after");
  "node" -> nodemark(n); n -> netmarked
enddefine;

define getsupitems i p v; vars it;
  comment 'ONLY WORKING FOR I=1 AND ITEMS OF LENGTH 2';
  if i/=1 and datalength(p)/=2 then
    'getsupitems limitation exceeded'.pr; 1.nl; endif;
  p, === ,2.constrip -> it;
  [%appitems(it,v,identfn)%]
enddefine;

define altergost p; vars cuctxt; gost -> cuctxt;
  comment 'ALTER ALL -1 ENTRIES TO 1 IN GOST';
  applist(supitems(2,p),procedure x;
    if value(x)/=undef then [1] -> value(x) endif endprocedure);
enddefine;

define getpurposes p v num; vars cuctxt; gost -> cuctxt;
  [%(applist(supitems(2,p),procedure x; vars y;
      if subitem(3,x)/=v then return endif;
      value(x) -> y; if y=undef then return endif;
      if ismember(num,y) then x,y endif
     endprocedure))%]
enddefine;

procedure v p n; vars num l y cuctxt;
  if n.isinteger then node(n) -> n endif; itemof(p) -> p;
  if inctxt(p,value,alwayctxt)/=undef or inctxt(p,value,nodectxt(n))/=undef
  then return endif;
  initctxt -> cuctxt; value(p) -> y;
  if y/=undef then undef -> value(p); y -> nodevalue(p,node(1));
    altergost(p);
  comment 'ANY MENTION OF PATTERN IN INITCTXT REMOVED AND VALUE PUT IN PLANHEAD';
  endif;
  if netmarked/=n then marklinks(n) endif;
  [%(comment 'GET INTERACTING PARALLEL NODES';
    tome -> cuctxt;
    applist(supitems(1,p),procedure x; vars y num; value(x) -> y;
        if y=undef or y=v then
        else subscrv(2,itemid(x)) -> num;
          if nodemark(node(num))=0 then num,getpurposes(p,oppvalue(v),num) endif
        endif
      endprocedure);
    comment 'GET NODES WHICH HAVE A PURPOSE SUCH THAT PERIOD FOR WHICH P MUST
      HAVE VALUE NOT(V) OVERLAPS PERIOD FOR WHICH P HAS VALUE V AT NODE N';
    gost -> cuctxt;
    applist(supitems(2,p),procedure x; vars l contri n pmark nmark;
        value(x) -> contri;
        if contri=undef or subitem(3,x)=v then return endif; contri -> l;
        nodemark(node(subitem(4,x))) -> pmark;
        if pmark="node" then
          comment 'PURPOSE IS INTERACTING NODE - IGNORE'; return endif;
        while l.ispair do l.dest -> l -> n; nodemark(node(n)) -> nmark;
          if nmark=pmark and nmark/=0 and pmark/=0
          then
          elseif nmark/=0 then comment 'IF NMARK=0 INTERACTION GOT FROM TOME';
            n,[%x,contri%]
          endif;
        endwhile;
      endprocedure))%] -> l;
  tome -> cuctxt;
  nodenum(n) -> num; v -> value(constrip(p,num,2));
  if l.ispair then comment 'INTERACTION INTRODUCED';
    consinter(num,l,p,v)::interact -> interact;
  endif;
  nodectxt(n) -> cuctxt; v -> value(p);
endprocedure -> updater(nodevalue);

define qaback p n; vars i l2 x l contri;
  prenodes(n) -> l; nil -> contri; undefnum -> netmarked;
  while l.ispair do l.dest -> l; .node -> n;
    if nodemark(n)/=0 then comment 'THIS BRANCH MARKED';
    else "before" -> nodemark(n);
      nodevalue(p,n) -> x;
      if x/=undef then conspair(x,nodenum(n))::contri -> contri;
        prenodes(n) -> l2;
        while l2.ispair do l2.dest -> l2 -> x;
          comment 'NEXT 2 LINES ARE A CHECK FOR REDUNDANT LINKS IN NET';
          lmemb(x,contri,procedure x y; x=back(y) endprocedure) -> i;
          if i/=false then (-5) -> back(hd(i)); endif; x.node -> x;
          if nodemark(x)=0 then "before" -> nodemark(x);
            l2<>prenodes(x) -> l2; endif
        endwhile;
      else l<>prenodes(n) -> l; comment ' BREADTH FIRST';
      endif
    endif
  endwhile;
  comment 'CONTRI NOW HOLDS PAIRS OF VALUES FOUND AND NODENUMS OF NODES THEY
          WERE FOUND AT. -5 FOR A NODENUM INDICATES THAT A REDUNDANT
          LINK WAS FOUND. IGNORE THE ENTRY AS IT WAS NOT A CONTRIBUTOR';
  contri
enddefine;

define vandnot l v; vars num vl vnotl x;
  nil -> vl; nil -> vnotl;
  while l.ispair do l.dest -> l -> x;
    back(x) -> num;
    if num/=(-5) then
      if front(x)=v then num::vl -> vl
      else num::vnotl -> vnotl endif;
    endif;
  endwhile; vnotl,vl
enddefine;

define qaparallel p; vars cuctxt num l x v n; tome -> cuctxt;
  supitems(1,p) -> l; nodenum(netmarked) -> num;
  comment 'DO NOT RETURN NODES WITH A 0 MARK IF THEY ARE SAME NUMBER AS
          NETMARKED - ALLOWS FOR USE OF QAONE IN ADDCONDITIONS FOR USEWHENS';
  [% (while l.ispair do l.dest -> l -> x;
        value(x) -> v;
        if v/=undef then subscrv(2,itemid(x)) -> n;
          comment 'NODENUM OF NODE IN PARALLEL WITH N WHICH AFFECTS P';
          if n<=numnodes and n/=num and nodemark(node(n))=0 then
            conspair(value(x),n) endif
        endif
      endwhile) %]
enddefine;

comment '0 AND -1 ARE USED AS NODENUMS IN THE GOST TO REPRESENT THAT A
         CONDITION IS ESTABLISHED IN THE ALWAYCTXT OR THE INITCTXT RESPECTIVELY';

define qaone p v n type; vars vl vnotl parvl parvnotl;
  comment 'DOES P HAVE VALUE V BEFORE NODE N - N IS NOT INCLUDED AS A
           POSSIBLE CONTRIBUTOR.
           TYPES ALLOWED ARE LINK OR NOLINK TO SAY WHETHER THE 4 CRITICAL
           NODE LISTS SHOULD BE RETURNED TO ALLOW THE LATER SUGGESTION OF
           LINEARIZATIONS OR NOT';
  itemof(p) -> p;
  inctxt(p,value,alwayctxt) -> vl;
  if vl/=undef then
    if vl=v then true,[% 0 %] else false,nil endif;
    return
  endif;
  inctxt(p,value,initctxt) -> vl;
  if vl/=undef then
    if vl=v then true,[% (-1) %] else false,nil endif;
    return
  endif;

  if n.isinteger then node(n) -> n endif;
  if netmarked/=0 then clearmarks(numnodes) endif;
  vandnot(qaback(p,n),v) -> vl -> vnotl;
  qamark(n,succnodes,"after"); "node" -> nodemark(n); n -> netmarked;
  comment 'ALL NODES IN PARALLEL WITH N NOW UNMARKED (0) IN ALLNODES';
  vandnot(qaparallel(p),v) -> parvl -> parvnotl;

  if vl.null and parvl.null then
    if vnotl.ispair then false,nil; return endif;
    comment 'NEVER ADDED'; undef,nil; return
  elseif vnotl.null and parvnotl.null and vl.ispair then true,vl;
         return
  endif;
  "unknown",(if type="link" then [%vl,parvl,vnotl,parvnotl%]
              else nil endif)
enddefine;

comment 'ALWAYCTXT,INITCTXT AND TOME ENTRIES ARE DISJOINT.
         NO REPEAT PATTERNS ARE POSSIBLE BY CONTRUCTION.  INITCTXT IS A COPY
         OF INITIAL CONTEXT GIVEN FOR PROBLEM BY USER. A PUSHCTXT IS
         MADE OF IT AND ALL ENTRIES ALREADY MENTIONED IN ALWAYCTXT ARE REMOVED';

define qaall p v n; vars l repl cuctxt x contri; p.instance -> p;
  comment 'ONLY FOR CHECKING WHAT IS TRUE WITHOUT INSERTING LINKS';
  [% (alwayctxt -> cuctxt;
      appitems(p,v,procedure; (0)::nil endprocedure); comment 'leaves p on stack';

      initctxt -> cuctxt;
      appitems(p,v,procedure; (-1)::nil endprocedure); comment 'leaves p on stack';

      tome -> cuctxt;
      nil -> repl; clearmarks(numnodes);
      qamark(n,prenodes,"before");
      applist(getsupitems(1,p,v),procedure x; vars y;
          subitem(2,x) -> y;
          if y>numnodes or nodemark(node(y))/="before" then
              comment 'EFFECT IS NOT BEFORE NODE N'; return endif;
          subitem(1,x) -> x;
          if not(ismember(x,repl)) and ((qaone(x,v,n,"nolink")->contri)=true)
          then x::repl -> repl; x,contri endif;
       endprocedure)) %]
enddefine;

comment '******************************* choice routines for Nonlin ********

OR-CHOICE MECHANISM IS A SIMPLE LIST OF CHOICES ORDERED BY A CHOICENUM
COMPONENT.  LOWER NUMBERS ARE BETTER CHOICES. CHOICENUMS ARE
       OPERATOR CHOICE              OPCHOICE   (DEFAULT 10)
       ALTERNATIVE LINEARIZATION    LINCHOICE  (DEFAULT 15)
       ALTERNATIVE INSTANTIATION    INSTCHOICE (DEFAULT 20)  (USEWHEN)
***************************************************************';

define insertchoice x; vars i l;
     1.nl; '    +++ choice added '.pr; pr(choicetype(x));
  if choicepts.null then x::nil -> choicepts; return endif;
  choicenum(x) -> i; choicepts -> l;
 loop: if choicenum(hd(l))>=i then
       l.copy -> l.tl; x -> l.hd; return endif;
       if l.tl.ispair then l.tl -> l; goto loop endif;
  x::nil -> l.tl
enddefine;

define addchoices chnum type num l;
  insertchoice(conschoice(chnum,type,l,copynet(),interact,num));
enddefine;

comment 'CURRNODE MAY BE USEFUL FOR INTERROGATION IN COMPUTE definitions';

define rechoice type l num;
  comment 'routine to restart after making a choice';
  vars p possl alist opsch l2 cpatt x savex cuctxt copyalist n
       cval ctype carg v mpatt opconds expconds anarg;
  if type="altlinear" then comment 'GO AHEAD'; true; return endif;
  node(num) -> n; n -> currnode;
  if type="usewhen" then
    nlappdata(l,identfn) -> possl -> alist -> opsch -> expconds -> opconds;
    nil -> l; copy1(alist) -> copyalist;
    hd(opconds) -> x; subscrv(2,x) -> cpatt; goto tryuw
  endif;
  l.dest -> l -> p;
 loop: if l.ispair then l.dest -> l -> opsch;
         copy1(varslist(opsch)) -> alist;
         if not(match(p,oppattern(opsch))) then goto loop endif;
         opconditions(opsch) -> opconds; nil -> expconds;
     ok: if opconds.ispair then hd(opconds) -> x;
           subscrv(1,x) -> ctype; subscrv(2,x) -> cpatt; subscrv(3,x) -> cval;
           if ctype="compute" then hd(cpatt) -> mpatt;
             dest(tl(tl(cpatt))) -> carg; .instance -> cpatt;
             alwayctxt -> cuctxt; value(cpatt) -> v;
             if v= undef then
               if cpatt.isword and isprocedure(valof(cpatt)) then
                 (while carg.ispair do carg.dest->carg->anarg;
                    if anarg.isitem then anarg.itemid else anarg endif;
                    comment 'should actually dereference recursively';
                    .instance
                  endwhile);
                 apply(valof(cpatt)) -> v;
               endif;
             endif;
             if v=undef then
               pr('Compute condition undefined - ');
               genpr(cpatt); .neterror; return
             endif;
             if match(mpatt,v)/=cval then
               comment 'NO NEED TO RESET VARS AS DONE ANYWAY';
               goto loop
             endif;
             tl(tl(opconds)) -> opconds; goto ok;
           elseif ctype="usewhen" then qaall(cpatt,cval,n) -> possl;
             if possl.null then goto loop endif;
             copy1(alist) -> copyalist;
         tryuw: possl.dest.dest -> possl -> contri -> mpatt;
                if match(mpatt,cpatt) then
                  if possl.ispair then
                    addchoices(instchoice,"usewhen",num,
                      constrip(opconds,expconds,opsch,copyalist,possl,5))
                  endif;
                  copy(x) -> savex; mpatt -> subscrv(2,savex);
                  contri::(savex::expconds) -> expconds;
                elseif possl.ispair then goto tryuw
                else goto loop endif;
            tl(tl(opconds)) -> opconds; goto ok;
           endif;
         endif;
         comment 'L IS REMAINING CHOICES OF OP TO ACHIEVE P';
         if l.ispair then addchoices(opchoice,"operator",num,p::l) endif;
         node(num) -> n;
         nodectxt(n) -> cuctxt; pushctxt(); cuctxt -> nodectxt(n);
         undeflist(opsch) -> l2;
         while l2.ispair do undef -> nodevalue((l2.dest->l2),n) endwhile;
         denylist(opsch) -> l2;
         while l2.ispair do false -> nodevalue((l2.dest->l2),n) endwhile;
         addlist(opsch) -> l2;
         while l2.ispair do true -> nodevalue((l2.dest->l2),n) endwhile;
         alist -> nodevars(n);
         opexpansion(opsch) -> expansion(n);
         rev(expconds)<>opconds -> expanconds(n); true
       else false
     endif
enddefine;

define netlevel alln; vars n level i x;
  999999 -> level; numnodes -> i;
  while i/=0 do node(i) -> n; nodelevel(n) -> x;
    comment 'must check expansion not nil and nodetype not phantom
             as these will be skipped when selecting a node to expand';
    if x>=0 and x<level and expansion(n)/=nil and nodetype(n)/="phantom" then
      x -> level endif; i-1 -> i
  endwhile; level
enddefine;

define choosalt; vars num x l netl type node cuctxt;
  while choicepts.ispair do dest(choicepts) -> choicepts -> x;
    1.nl; '    --- choice taken '.pr;
    x.destchoice -> num -> interact -> netl -> l -> type; .erase; type.pr;
    pushnet(netl);
    if rechoice(type,l,num) then
      if interact.ispair then inter() endif; true -> changenet;
      return
    endif;
  endwhile; 1.nl; pr('No way to proceed'); .neterror
enddefine;

define choosexp p num; vars l choosexpreply possops len oneop;
  comment 'P FULLY INSTANTIATED SO ALIST NOT NEEDED FOR MATCH';
again: if lmemb(p,primlist,match)/=false then
          nil -> expansion(node(num)); true; return
       endif;

  p.datalength -> len; if len>5 then 5 -> len endif;
  subscrv(len,achlist) -> l; comment ' scan list for matching patterns';
  [% while l.ispair do l.dest -> l -> oneop;
       if match(p,front(oneop)) then back(oneop) endif;
     endwhile %] -> possops;
  if possops/=nil then
    rechoice("operator",p::possops,num)
  else 1.nl; 'An expansion is not given for '.pr; genpr(p);
    ' at node '.pr; pr(num); 1.nl;
    prompt('A(bort, C(arry on, D(efine extra TF forms:',[A C D])
      -> choosexpreply;
    if choosexpreply=ord('A') then .setpop
    elseif choosexpreply=ord('D') then
          .popready;
          goto again;
    endif; false
  endif;
enddefine;

comment '***********************TOME and GOST routines for Nonlin*********';

define existcond c;
  comment 'false IF NO EXISTING CONDITION';
  copy(c) -> c; === -> subscrv(1,c); getitem(c,===);
enddefine;

define relocate l num top relocnum;
  maplist(l,(procedure x; if x=top then num
                          else x+relocnum endif
             endprocedure))
enddefine;

define addconditions conds alist i top relocnum;
  vars contri c oldctype ctype oldcond num cuctxt;
  if condint then 1.nl; 'condint'.pr; .popready endif;
  gost -> cuctxt;
loop:
  while conds.ispair do
    conds.dest.dest -> conds -> contri -> c;
    subscrv(1,c) -> ctype;
    if ctype="compute" then goto loop endif;
    subscrv(4,c) -> num;
    (if num=top then i else num+relocnum endif) -> num;
    copy(c) -> c; num -> subscrv(4,c);
    c.instance -> c;
    comment 'CHECK IF A GOST ENTRY WITH HIGHER OR LOWER TYPE FOR THIS CONDITION';
    existcond(c) -> oldcond;
    if oldcond then itemid(subscrv(1,itemid(oldcond))) -> oldctype;
      if ctype=oldctype then goto loop;
      elseif ctype="supervised" then undef -> value(oldcond);
      elseif ctype="usewhen" and oldctype="unsupervised" then
        undef -> value(oldcond);
      else goto loop
      endif;
      1.nl; tabs(1); genpr(oldctype); ' replaced by '.pr; genpr(ctype);
      ' for '.pr; genpr(itemid(subscrv(2,itemid(oldcond))));
    endif;

    if ctype="supervised" then comment 'RELOCATE CONTRIBUTORS';
      relocate(contri,i,top,relocnum) -> contri;
    elseif ctype="usewhen" then
      comment 'ENSURE THAT A -1 CONTRI IS ALTERED TO 1 IF PATTERN WAS
               GIVEN A VALUE IN THE MEANTIME IN THE NET';
      if ismember((-1),contri) then
        1::remmemb((-1),contri) -> contri endif;
    endif;
    contri -> value(c);
    comment 'should actually now see if further interactions introduced
             this is not done in the present implementation  - so some
             rather uncommon interactions will be missed.' ' These are
             especially concerned with expansions in which MAINEFFECTS
             of a node cause the interaction with a SUPERVISED condition
             just being introduced - this is due to the ordering of
             the FILLEFFECTS and ADDCONDITIONS statements in EXPAND';
  endwhile;
enddefine;

comment '*************************** interaction routines for Nonlin********';

define linear n p opp popp; vars alln;
  comment 'removes interactions in list interact from net';
  if n=p and opp=popp then
    comment 'NEITHER NODE HAS A PURPOSE - SO IGNORE INTERACTION';
    if not(identnet) then
      [%copyalln(),numnodes,tome,gost,initctxt%]::newsuggest -> newsuggest;
      hd(newsuggest) -> identnet;
    else 1.nl; pr("identnet"); .popready
    endif;
    return
  endif;
  if not(before(opp,p)) then comment 'CAN PUT VRANGE BEFORE -VRANGE';
    copyalln() -> alln;
    if not(before(p,opp)) then link(p,opp,alln) endif;
    [%alln,numnodes,tome,gost,initctxt%]::newsuggest -> newsuggest
  endif;
  if not(before(n,popp)) then comment 'CAN PUT -VRANGE BEFORE VRANGE';
    copyalln() -> alln;
    if not(before(popp,n)) then link(popp,n,alln) endif;
    [%alln,numnodes,tome,gost,initctxt%]::newsuggest -> newsuggest
  endif
enddefine;

define remmembun x l; remmemb(x,l) -> l;
  if l.null then
    comment 'ALL CONTRIBUTORS OF A PHANTOM REMOVED IN SOME LINEARIZATION.
             phantogoal will be called to change phantom to goal';
    undef
  else l endif
enddefine;

define phantogoal pg;
  if bugexpand then
    1.nl; tabs(1); genprsequence(pg); ' reverts to goal'.pr;
    1.nl; tabs(1); comment 'put back where message should appear';
  endif;
  "goal" -> nodetype(node(subitem(4,pg)));
  true -> changenet;
enddefine;

define auxinter net interact chnum;
  vars cuctxt suggest newsuggest oldgost patt v n pl p pgost pcontri pctype
       opp oppl poppl popp poppgost poppcontri poppctype intlength tempv;
  length(interact) -> intlength;
  if intlength=0 then
    conschoice(chnum,"altlinear",undef,net,interact,undefnum)::nil;
    return;
  endif;
  1.nl; '    === '.pr; pr(intlength); ' interaction'.pr;
  if intlength>1 then 's '.pr else '  '.pr endif;
  if interint then 1.nl; 'interint'.pr; popready(); endif;
  net::nil -> suggest;
  while interact.ispair do interact.dest -> interact;
    .destinter -> v -> patt -> oppl -> n;
    if (n.isnode.not) and (n.isinteger.not) then .popready endif;
    getpurposes(patt,v,n) -> pl;
    if pl.null then [%undef,(n::nil)%] -> pl endif;
    while pl.ispair do pl.dest.dest -> pl -> pcontri -> pgost;
      if pgost=undef then n -> p;
      else subitem(4,pgost) -> p; itemid(subitem(1,pgost)) -> pctype;
      endif;
      while oppl.ispair do oppl.dest.dest -> oppl -> poppl -> opp;
        if poppl.null then [%undef,(opp::nil)%] -> poppl endif;
        while poppl.ispair do poppl.dest.dest -> poppl
                                      -> poppcontri -> poppgost;
         if poppgost=undef then opp -> popp;
         else subitem(4,poppgost) -> popp;
           itemid(subitem(1,poppgost)) -> poppctype;
         endif;
         if p/=n or opp/=popp then comment '1 NODE HAS A PURPOSE';
          nil -> newsuggest;
          while suggest.ispair do suggest.dest -> suggest; .restore;
            comment 'MAXNODES DOES NOT ALTER ANYWHERE IN INTER';
            false -> identnet;
            linear(n,p,opp,popp);                             comment  1 ;
            if length(poppcontri)>1 or poppctype="phantom" then
              gost -> oldgost; gost -> cuctxt; pushctxt(); cuctxt -> gost;
              remmembun(opp,poppcontri) -> tempv; tempv -> value(poppgost);
              if tempv=undef then phantogoal(itemid(poppgost)) endif;
              linear(n,p,opp,opp);                            comment  2 ;
              oldgost -> gost;
            endif;
            if length(pcontri)>1 or pctype="phantom" then
              gost -> cuctxt; pushctxt(); cuctxt -> gost;
              remmembun(n,pcontri) -> tempv; tempv -> value(pgost);
              if tempv=undef then phantogoal(itemid(pgost)) endif;
              linear(p,p,opp,popp);                           comment  3 ;
              if not(identnet) then
                if length(poppcontri)>1 or poppctype="phantom" then
                  gost -> cuctxt; pushctxt(); cuctxt -> gost;
                  remmembun(opp,poppcontri)  -> tempv; tempv -> value(poppgost);
                  if tempv=undef then phantogoal(itemid(poppgost)) endif;
                  comment 'NO INTERACTION AS NEITHER NODE HAS A PURPOSE';
                  [%copyalln(),numnodes,tome,gost,initctxt%]::newsuggest
                     -> newsuggest;
                endif;
              else 1.nl; pr("identnet"); .popready
              endif;
            endif;
          endwhile;
          if newsuggest.ispair then newsuggest -> suggest
          else 'no way to remove'.pr; false;
               return
          endif;
         endif;
        endwhile;
      endwhile;
    endwhile;
  endwhile;
  comment 'NOW SUGGEST HOLDS A LIST OF POSSIBLE NETWORKS ALL OF WHICH
           DO NOT HAVE ANY OF THE INTERCTIONS INITIALLY IN INTERACT.
           In all cases where phantoms have reverted to goals the nodetypes
           have been chaned and in such a case changenet is now true';
  pr(length(suggest)); ' linearisation'.pr;
  if length(suggest)>1 then 's'.pr endif;
  [% (while suggest.ispair do
        conschoice(chnum,"altlinear",undef,
                   (dest(suggest)->suggest),interact,undefnum);
      endwhile) %];
enddefine;

define addbutone l;
  while length(l)>1 do insertchoice(dest(l)->l) endwhile;
  pushnet(choicenet(hd(l)))
enddefine;

define inter; vars l;
  auxinter([%allnodes,numnodes,tome,gost,initctxt%],interact,linchoice) -> l;
  if l.ispair then addbutone(l); nil -> interact;
  else choosalt() endif;
enddefine;

define newgostentry cuctxt i v; pushctxt(); v -> value(i);
  comment 'RETURNS MODIFIED GOST'; cuctxt
enddefine;

define linkout p v  purp suggest l chnum; vars cuctxt alln vl vrange newl;
  comment 'RETURN LIST OF CHOICES OR NULL';
  nil -> newl;
  while suggest.ispair do suggest.dest -> suggest;
    .dest.dest.hd -> cuctxt -> alln -> vl;
    [%while vl.ispair do vl.dest-> vl;[%purp,value(purp)%] endwhile%] -> vrange;
    [%while l.ispair do consinter((l.dest->l),vrange,p,oppvalue(v)) endwhile%]
      -> interact;
    auxinter([%alln,numnodes,tome,cuctxt,initctxt%],interact,chnum)
      ncjoin newl -> newl;
  endwhile; newl
enddefine;

define qalink p v n ctype critical chnum;
  vars suggest alln x vl parvl purp;
  comment 'NOTE THAT INTRODUCING EXTRA LINKS INTO A NETWORK CANNOT INTRODUCE
    ANY INTERACTION TO EXISTING PURPOSES SO LONG AS NONE EXISTED AT FIRST';
  if interact.ispair then inter() endif;
  if n.isnode then nodenum(n) -> n endif;
  1.nl; '    <-> make '.pr; genpr(p); ' = '.pr;
  pr(v); ' at '.pr; pr(n);
  critical.dest.dest -> critical -> parvl -> vl;
  itemof(constrip(ctype,p,v,n,4)) -> purp;
  if vl.ispair then [%vl,allnodes,newgostentry(gost,purp,vl)%]::nil -> suggest;
  else nil -> suggest;
    while parvl.ispair do copyalln() -> alln; parvl.dest -> parvl -> x;
      link(x,n,alln); x::nil -> x;
      [%x,alln,newgostentry(gost,purp,x)%]::suggest -> suggest;
    endwhile;
  endif;
  comment 'SUGGEST NOW HOLDS ALLNODES AND GOST ENTRIES FOR SUGGESTED
    NETWORKS IN WHICH A CERTAIN CONTRIBUTOR(S) ARE SUGGESTED TO GIVE P A
    VALUE V AT NODE N';
  linkout(p,v,purp,suggest,(critical.tl.hd ncjoin critical.hd),chnum)
enddefine;

define linkunsupervised;
  vars p v n l suggest newsuggest cuctxt it critical;
  conschoice(0,undef,undef,[%allnodes,numnodes,tome,gost,initctxt%],
             undef,undef)::nil -> suggest;
  gost -> cuctxt;
  [%appitems(===,"unsuper",identfn)%] -> l;
  if l.ispair then 1.nl;
    'Try to satisfy unsupervised conditions'.pr;
    if unsuperint then .popready endif;
  endif;

  while l.ispair do comment 'TRY TO SATISFY NEXT UNSUPERVISED CONDITION';
    l.dest -> l -> it; nil -> newsuggest;
    subitem(2,it) -> p; subitem(3,it) -> v; subitem(4,it) -> n;
    while suggest.ispair do suggest.dest -> suggest; .choicenet.restore;
      qaone(p,v,n,"link") -> critical -> x;
      comment 'could have a mode where unsupervised conditions which could
              not be satisfied were simply marked as such.  The handling
              would be the same as if they were ALREADY TRUE - see below -
              except that "outstanding" rather than the critical list would
              be assigned to the value of the GOST entry';
      if x=false or x=undef then 1.nl;
        'Unsupervised condition not satisfied at node '.pr; pr(n);
        1.nl; genpr(p); false; return endif;
      if x="unknown" then
        qalink(p,v,n,"unsupervised",critical,0)<>newsuggest -> newsuggest;
      else comment 'ALREADY TRUE';
        gost -> cuctxt; critical -> value(it);
        conschoice(0,undef,undef,
              [%allnodes,numnodes,tome,gost,initctxt%],undef,undef)
            ::newsuggest -> newsuggest;
      endif;
    endwhile;
    if newsuggest.null then false; return endif;
    while newsuggest.tl.ispair do
      insertchoice(dest(newsuggest)-> newsuggest) endwhile;
    newsuggest -> suggest;
  endwhile;
  addbutone(suggest); true
enddefine;

comment '***************************** expansion routines for nodes ********';

define makemaineffects n; vars alist l main;
  if nodetype(n)="goal" then true -> nodevalue(pattern(n),n) endif;
  comment 'PATTERN(N) FULLY INSTANTIATED SO ALIST NOT NEEDED FOR MATCH';
  lmemb(pattern(n),mainefflist,match) -> l;
  if l=false then return endif; l.tl.hd -> main;
  mainvars(main) -> alist;
  if match(pattern(n),mainpatt(main)) then
    applist(mainundef(main),procedure x; undef -> nodevalue(x,n) endprocedure);
    applist(maindeny(main),procedure x; false -> nodevalue(x,n) endprocedure);
    applist(mainadd(main), procedure x; true  -> nodevalue(x,n) endprocedure);
  endif
enddefine;

define filleffects i j k;
  while i<=j do makemaineffects(node(i)); i+1 -> i endwhile;
  if k.isinteger then makemaineffects(node(k)) endif;
enddefine;

define makenode n;
  -> succnodes(n) -> prenodes(n) -> parentnode(n) -> nodectxt(n)
  -> pattern(n) -> nodenum(n); n -> node(nodenum(n))
enddefine;

define expand num;
  vars alist type p expan n l x net relocnum top i cuctxt newn;
  if interact.ispair then true -> sometoexpand; inter(); return endif;
  node(num) -> n; nodetype(n) -> type; pattern(n) -> p;
  if bugexpand then 1.nl; tabs(1); pr('expand '); pr(num); 1.sp;
    pr(type); 1.sp; genpr(p); sysflush(popdevout); endif;
  nodevars(n) -> alist;
  comment 'leave in the next check though it is not used at present as
           we never try to expand a phantom - unless it reverts to goal';
  if type="phantom" then
    if erase(qaone(p,true,n,"nolink")) then return endif;
    "goal" -> nodetype(n); "goal" -> type;
  endif;
  if type="goal" then
    qaone(p,true,n,"link") -> l -> x;
    if x=true then gost -> cuctxt;
      l -> value(constrip("phantom",p,true,num,4));
      "phantom" -> nodetype(n); return endif;
    if expansion(n)/=undef then goto doexpan; endif;
    if x="unknown" then comment 'TRY LINKING TO MAKE TRUE';
      copynet() -> net;
      "linked" -> expansion(subscrv(num,hd(net)));
      insertchoice(conschoice(linchoice,"altlinear",undef,
            net,interact,undefnum));
      node(num) -> n; "phantom" -> nodetype(n); "notset" -> alist;
      qalink(p,true,n,"phantom",l,linchoice) -> l;
      if l.ispair then addbutone(l) else choosalt() endif;
      return
    endif;
  endif;

 doexpan: expansion(n) -> expan;
     if expan=undef or expan="linked" then
       comment 'CHOOSE A SCHEMA TO EXPAND PATTERN OF NODE';
       if choosexp(p,num) then
         node(num) -> n; expansion(n) -> expan; nodevars(n) -> alist;
       else comment 'MUST NOW CHOOSE AN ALTERNATIVE WAY TO PROCEED';
         choosalt();
         return
       endif;
     endif;
     if expan=nil then
       if type/="action" then
         pr('Null expansion on illegal type - '); pr(type); .neterror; return
       endif;
       if interact.ispair then inter() endif;
       return
     endif;

     if type="action" and datalength(expan)=1 and
        nodetype(subscrv(1,expan))="dummy"
     then nil -> expansion(n);
       addconditions(expanconds(n),alist,num,1,"notset");
       if interact.ispair then inter() endif;
       return
     endif;

  true -> sometoexpand; numnodes -> relocnum; undefnum -> netmarked;
  datalength(expan) -> top;
  cpmchnet(num,efin(nodecost(subscrv(top,expan))));
  if top/=1 then
     prenodes(n) -> l;
     while l.ispair do l.dest -> l -> x; node(x) -> x;
       maplist(succnodes(x),procedure y;
             if y=num then relocnum+1 else y endif endprocedure)
         -> succnodes(x);
     endwhile;
  endif;
  if top>1 then copy(subscrv(1,expan)) -> newn;
    makenode(relocnum+1,instance(pattern(newn)),newnodectxt(),n,prenodes(n),
             relocate(succnodes(newn),num,top,relocnum),newn);
    2 -> i;
    while i<top do copy(subscrv(i,expan)) -> newn;
      makenode(i+relocnum,instance(pattern(newn)),newnodectxt(),n,
               relocate(prenodes(newn),num,top,relocnum),
               relocate(succnodes(newn),num,top,relocnum),newn);
      i+1 -> i;
    endwhile;
  endif;
  copy(subscrv(top,expan)) -> newn;
  makenode(num,instance(pattern(newn)),nodectxt(n),n,
           relocate(prenodes(newn),num,top,relocnum),succnodes(n),newn);
  if top=1 then prenodes(n) -> prenodes(newn) endif;
  (numnodes+top)-1 -> numnodes;
  if top>1 then
    gost -> cuctxt;
    applist(items,procedure x; vars i v;
          value(x) -> v;
          if v=undef then return endif;
          itemid(x) -> i;
          if i.isvector and datalength(i)=4 and subscrv(4,i)=num
          then undef -> value(x);
               copy(i) -> i; numnodes -> subscrv(4,i); v -> value(i) endif
      endprocedure);
  endif;
  filleffects(relocnum+1,numnodes,num);
  addconditions(expanconds(n),nodevars(n),num,top,relocnum);
  comment 'RELOCATE THE CRITICAL PATH DATA FOR THE EXPAN BEING INSERTED';
  cpmrecomp(num,relocnum);
  if interact.ispair then inter() endif;
enddefine;

comment '****************************** top level driver for Nonlin ********
         Can only reenter if INITCTXT and ALWAYCTXT untouched';

define doplan num; vars cuctxt t top i n level;
  systime() -> t; undefnum -> netmarked;
  if num=undef then
    if initctxt.isctxt.not then 1.nl;
      'Cannot re-enter when alwayctxt or initctxt altered'.pr;
      return;
    endif;
    choosalt();
    netlevel(allnodes) -> level; "notset" -> cuctxt;
  else
    nil -> interact;
    0 -> level;
    cpm(allnodes,num);
    expand(num);
  endif;

ploop: netlevel(allnodes) -> level;
    if level/=999999 then
     if bugexpand then 1.nl; 'Level '.pr; level.pr; 2.sp; endif;
     false -> sometoexpand; false -> changenet;
     numnodes -> top; 1 -> i;
     while i<=top do node(i) -> n;
       if (expansion(n)/=nil and nodetype(n)/="phantom") then
         if nodelevel(node(i))>level then true -> sometoexpand
         else expand(i);
           if changenet then goto ploop endif;
         endif;
       endif;
       i+1 -> i
     endwhile;
     if sometoexpand then goto ploop endif;
    endif;
    comment 'NOW SATISFY UNSUPERVISED CONDITIONS';
    if not(linkunsupervised()) then choosalt(); goto ploop endif;
    1.nl;
    'Nonlin - problem solved.  CPU time = '.pr; pr((systime()-t)/100);
    1.sp; "secs".pr; 1.nl;
    'Plan has '.pr; numnodes.pr; ' nodes. Type PRINFO to view results'.pr;
    1.nl;
enddefine;

cancel p s;

comment '************************************* debugging information ********';

comment 'debugging switches';
false -> unsuperint; comment 'interrupt before satisfying unsupervised conds';
false -> condint;    comment 'interrupt before adding any condition';
false -> interint;   comment 'interrupt before correcting for any interaction';
true  -> bugexpand;  comment 'print trace of nodes being expanded';

comment '===> ia a debugging aid - not used in Nonlin itself';

define macro ===> ;
  ",",(.itemread),",",allnodes,".","link",";"
enddefine;

procedure;
  prmishap('Nonlin',[]); comment 'help track faults by printing a stack trace';
  popready();
end -> interrupt;

comment 'use above interrupt replacement while debugging Nonlin.
         Use setpop setting (as below) in normal use';

setpop -> interrupt;

comment '********************************** TF and input definitions ********';

vars autocond; true -> autocond;
comment 'flag to fill in supervised conditions from a goal to a following action';

comment 'OPERATOR SCHEMAS AND MACROS TO CONTRUCT THEM FOR NONLIN';

define macro opschema; vars opsch; .itemread -> opsch;
  "vars",opsch,";", copy(initopsch),"->",opsch,";",
  """,opsch,""","->","opschname","(",opsch,")",";",
  opsch,"::","allfns","->","allfns",";",
  "review",opsch
enddefine;

vars macro actschema; nonmac opschema -> nonmac actschema;

vars iscondtype;

lmemb(%[supervised usewhen unsupervised compute auto nonauto],nonop = %)
  -> iscondtype;

define readcond saves; vars x s;
  if hd(proglist)="compute" then .itemread.erase;
    (if hd(proglist)="not" then .itemread.erase; false else true endif) -> x;
    "compute",.itread,x,3.constrip,undef; return
  endif;
  .itemread;
  if (.itread->x;x="not") then .itread,false else x,true endif;
  .itemread -> x;
  if x/="at" then
    1.nl; pr('AT clause of condition not specified');
    .neterror; return
  endif;
  if hd(proglist)="self" then 1 -> hd(proglist) endif;
  (nodemark(subscrv(.itemread,saves)),4.constrip) -> s;
  (if hd(proglist)="from" then .itemread.erase;
     maplist((if hd(proglist)="[" then .listread else .itemread::nil endif),
             procedure y; nodemark(subscrv(y,saves)) endprocedure);
   elseif subscrv(1,s)="unsupervised" then "unsuper"
   else undef endif) -> x;
  comment 'NOW WE HAVE CONDITION (GOST LIKE) ENTRY S AND A LIST OF CONTRIBUTORS
          X (unsuper if unsupervised or UNDEF IF simply not defined ).
          CHECK FOR USER ERRORS';
  if subscrv(1,s)="supervised" then
    if x=undef then
      1.nl; pr('FROM clause not specified for a SUPERVISED condition');
      .neterror; return
    endif;
  else if x.ispair then
     1.nl;
     pr('FROM clause cannot be given for a condition other than SUPERVISED');
    .neterror; return endif;
  endif;
  s,x
enddefine;

define findnum p l alist;
  lmemb(p,l,match) -> l;
  if l/=false then l.tl.hd else 0 endif
enddefine;

define macro sequence; vars x y;
  .itemread -> x; .itemread.erase; .itemread -> y;
  (while x<y do x,"--->"; x+1 -> x; x; endwhile)
enddefine;

define readexpan autocond;
  vars n num saves i l1 l2 l s x y maxnodes numnodes cpmnewlink;
  comment 'should V be a local variable - was not in original';
  if hd(proglist)="conditions" then
    constrip(copy(dummynode),1) -> s; s -> saves;
    1 -> nodemark(subscrv(1,s)); goto conds
  endif;
  0 -> num;
  constrip((nodes: if isnumber(hd(proglist)) then .itemread.erase endif;
          hd(proglist) -> x;
          if x="action" or x="goal" or x="dummy" then num+1 -> num;
            if x="dummy" then .itemread.erase; copy(dummynode) -> n
            else copy(initnode) -> n;
              .itemread -> x; x -> nodetype(n); .itread -> pattern(n);
              if hd(proglist)=":" then tl(proglist) -> proglist;
                .numberread -> nodecost(n)
              endif;
            endif;
            n; goto nodes;
          endif),num) -> s;
  if num=0 then
    1.nl; pr('No expansion given - '); genpr(hd(proglist));
    pr(' ends the expansion'); .neterror; return
  endif;

  num-> maxnodes; 0 -> numnodes;
  if hd(proglist)="orderings" then .itemread.erase;
    comment 'MAKE CPMNEWLINK A DUMMY - CPM DATA FILLED IN ALL AT ONCE';
    dummyfn2 -> cpmnewlink;
    while isinteger(hd(proglist)) or hd(proglist)="sequence" do .itemread -> x;
      .itemread.erase; .itemread -> y; comment 'X ---> Y READ IN';
      link(x,y,s);
    endwhile;
  endif;
  comment 'CHECK THAT A SINGLE START AND END NODE AND REORDER TO PUT
           START NODE AS NODE 1 AND END NODE AS LAST IN THE vector';
  nil-> l1; nil -> l2; 1 -> i;
  nlappdata(s,procedure x;
              if null(prenodes(x)) then x::l1 -> l1 endif;
              if null(succnodes(x)) then x::l2 -> l2 endif;
              i -> nodemark(x); i+1 -> i;
            endprocedure);
  if length(l2)>1 then datalength(s)+1 -> i;
    copy(dummynode) -> n; maplist(l2,nodemark) -> prenodes(n);
    while l2.ispair do i::nil -> succnodes(l2.dest->l2) endwhile;
    n -> l2;
    constrip(nlappdata(s,identfn),n,i) -> s;
  else hd(l2) -> l2
  endif;
  if length(l1)>1 then datalength(s)+1 -> i;
    copy(dummynode) -> n; maplist(l1,nodemark) -> succnodes(n);
    while l1.ispair do i::nil -> prenodes(l1.dest->l1) endwhile;
    n -> l1;
    constrip(nlappdata(s,identfn),n,i) -> s;
  else hd(l1) -> l1
  endif;
  s -> saves;
  if l1/=l2 then
    constrip(l1, nlappdata(s,procedure x;
                    if x=l1 or x=l2 then return endif; x
                  endprocedure),l2,datalength(s)) -> s;
    1 -> i;
    nlappdata(s,procedure x; i -> nodemark(x); i+1 -> i endprocedure);
    comment 'REPLACE PRENODES AND SUCCNODES BY UPDATED ONES GIVEN BY
             NODEMARK(subscrv(OLD NUMBER,SAVES))';
    nlappdata(s,procedure x;
                maplist(prenodes(x),procedure y; nodemark(subscrv(y,saves))
                                    endprocedure) -> prenodes(x);
                maplist(succnodes(x),procedure y; nodemark(subscrv(y,saves))
                                     endprocedure) -> succnodes(x);
              endprocedure);
  endif;

conds:
  if hd(proglist)="conditions" then .itemread.erase;
    comment 'KEEP CONDITIONS AS A LIST OF ENTRIES OF SAME FORMAT AS GOST
             ENTRIES FOLLOWED FOR EACH ENTRY BY A VALUE (CONTRIBUTORS)
             WHICH WILL BE UNDEF EXCEPT FOR A SUPERVISED CONDITION.
             USER REFERENCES TO NODENUMS WILL BE TO OLD NUMBERS FOUND IN SAVES';
    [%(while (hd(proglist)->x;(x.iscondtype or x=";")) do
         if x="auto" then .itemread.erase; true -> autocond;
         elseif x="nonauto" then .itemread.erase; false -> autocond;
         elseif x=";" then .itemread.erase;
         else readcond(saves)
         endif
       endwhile)%] -> x;
  else nil -> x;
  endif;

  if autocond then datalength(s) -> i;
    if nodetype(subscrv(i,s))="goal" then
      constrip(nlappdata(s,identfn),copy(dummynode),(i+1)) -> s;
      (i+1)::nil -> succnodes(subscrv(i,s));
      i::nil -> prenodes(subscrv(i+1,s));
    endif;
    1 -> i;
    x<>[%(nlappdata(s,procedure x; vars c l c1;
           if nodetype(x)="goal" then
             constrip("supervised",pattern(x),true,===,4) -> c;
             succnodes(x) -> l;
             while l.ispair do copy(c) -> c1;
               l.dest -> l -> subscrv(4,c1); c1,i::nil
             endwhile;
           endif; i+1 -> i
         endprocedure))%] -> x;
  endif;
  comment 'REORDER TO PUT ALL USEWHEN AND COMPUTE CONDITIONS AT FRONT IN ORDER';
  nil -> l;
  [%(while x.ispair do x.dest.dest -> x -> v -> y;
       if subscrv(1,y)="usewhen" or subscrv(1,y)="compute" then y,v
       else y::(v::l) -> l
       endif
    endwhile;
    applist(l,identfn))%] -> x;
  x,s;
enddefine;

define generalinstance p;
  if p.isactor then ===
  elseif p.isvector then {%appdata(p,generalinstance)%}
  else p
  endif;
enddefine;

define macro review; vars opsch name x l1 alist len; .itemread -> name;
  name.valof -> opsch;
  .itemread -> x;
 loop: if x=";" then .itemread -> x; endif; comment 'ignore extra semi-colons';
    if x="end" then
      if onachlist(opsch)/="achlist" then "achlist" -> onachlist(opsch);
        copy1(varslist(opsch)) -> alist;
        oppattern(opsch) -> x; x.generalinstance -> x;
        x.length -> len; if len>5 then 5 -> len endif;
        subscrv(len,achlist) ncjoin [% conspair(x,opsch) %]
          -> subscrv(len,achlist);
        nlappdata(opexpansion(opsch),procedure x; vars p; pattern(x) -> p;
            findnum(p,levellist,copy1(alist)) -> nodelevel(x);
            if nodecost(x)=0 then
              findnum(p,costlist,copy1(alist)) -> nodecost(x)
            endif;
          endprocedure);
        comment 'CPM IS A CALL TO COMPUTE CRITICAL PATH DATA TO BE KEPT IN NODECOST';
        cpm(opexpansion(opsch),datalength(opexpansion(opsch)));
      endif;
      return
    endif;

    if x="pattern" then
      if oppattern(opsch)/=undef then comment 'do not allow pattern change';
        'Cannot change pattern in schema at present'.pr; .setpop;
        comment 'to do this means that opsch should be taken off achlist now';
      endif;
      .itread -> x; x -> oppattern(opsch);
      .itemread -> x; goto loop;

    elseif x="effects" then
     eff: .itemread -> x;
          if x="+" then .itread::addlist(opsch) -> addlist(opsch)
          elseif x="-" then .itread::denylist(opsch) -> denylist(opsch)
          elseif x="+/-" then .itread::undeflist(opsch) -> undeflist(opsch)
          else goto loop endif; goto eff;

    elseif x="vars" then
      [%while (.itemread->x;(x/=";" and x/="end")) do x,.itread endwhile%] -> varslist(opsch);
      goto loop;

    elseif x="expansion" or x="conditions" then
      if x="conditions" then "conditions"::proglist -> proglist endif;
      readexpan(autocond) -> opexpansion(opsch) -> opconditions(opsch);
        .itemread -> x; goto loop;

    else 1.nl; pr('In schema '); pr(name); pr(' - ');
         genpr(x); pr(' is an incorrect form'); .neterror; return
    endif;
enddefine;

define macro maineffects; vars patt x main alist hp;
  copy(initmain) -> main; .itread -> patt; patt -> mainpatt(main);
loop: .itemread -> x;
   if x=";" then
   elseif x="vars" then
     [%(while (hd(proglist) -> hp; (hp/=";" and hp/="end")) do
          .itemread,.itread
     endwhile)%] -> mainvars(main);
   elseif x="+" then .itread::mainadd(main) -> mainadd(main);
   elseif x="-" then .itread::maindeny(main) -> maindeny(main);
   elseif x="+/-" then .itread::mainundef(main) -> mainundef(main);
   elseif x="end" then mainvars(main) -> alist;
     instance(patt)::(main::mainefflist) -> mainefflist; goto makeff;
   else 1.nl; pr('In MainEffects - ');
        genpr(x); pr(' is an incorrect form'); .neterror; return
   endif;
   goto loop;
makeff:
  comment 'SCHEMAS AND PRIMITIVES (WITH EFFECTS TOO) CAN BE DEFINED
           DURING PLANNING - SEE define CHOOSEXP.  HENCE WE MUST
           CHECK IF NET NEEDS UPDATING AFTER A maineffects DEFINITION';
  if allnodes.isvector and numnodes.isinteger then
    numnodes -> i;
    while i/=0 do pattern(node(i)) -> p;
      if lmemb(p,mainefflist,match)/=false then
        makemaineffects(node(i)) endif;
      i-1 -> i;
    endwhile;
  endif;
enddefine;

define macro primitive; vars patt alist i p x;
  [%while (.itread->patt;(patt/=";" and patt/="end")) do
      if hd(proglist)="with" then tl(tl(proglist)) -> proglist;
        popval([%";","maineffects",patt,
                 (while (hd(proglist)->x; (x="+" or x="-" or x="+/-")) do
                    .itemread,.itread
                  endwhile),"end",";"%]);
      endif;
      if hd(proglist)=":" then tl(proglist) -> proglist;
        popval([%";","cost",patt,.numberread,";"%]);
      endif;
      patt
  endwhile%]<>primlist -> primlist;
  comment 'the choosexp routine will find any new primitives';
enddefine;

define macro always; vars x cuctxt; alwayctxt -> cuctxt;
  while (.itread->x;(x/=";" and x/="end")) do true -> value(x) endwhile;
enddefine;

define macro initially; vars x;
  globalctxt -> cuctxt; pushctxt(); comment 'and leave globally visible';
  while (.itread->x;(x/=";" and x/="end")) do true -> value(x) endwhile;
enddefine;

define macro levels; vars patt num alist;
  [%while (.itread->patt;(patt/=";" and patt/="end")) do .itemread -> num;
      applist(allfns,procedure x;
        nlappdata(opexpansion(x),procedure y; copy1(varslist(x)) -> alist;
          if match(patt,pattern(y)) then num -> nodelevel(y) endif
        endprocedure)
      endprocedure);
      patt,num
    endwhile%]<>levellist -> levellist
enddefine;

define macro cost; vars patt num alist; comment 'replaced if cpm package used';
  [%(while (.itread->patt;(patt/=";" and patt/="end")) do
      .numberread -> num;
      applist(allfns,procedure x;
        nlappdata(opexpansion(x),procedure y; if nodecost(y)/=0 then return endif;
          copy1(varslist(x)) -> alist;
          if match(patt,pattern(y)) then num -> nodecost(y) endif
        endprocedure)
       endprocedure);
       patt,num
     endwhile)%]<>costlist -> costlist;
enddefine;

define macro plan; vars cuctxt alist i g;
  pushctxt(); cuctxt -> initctxt;
  [%inctxt(===,===,identfn,appitems,alwayctxt)%] -> l;
  while l.ispair do undef -> value(l.dest->l) endwhile;
  comment 'ANY ENTRIES MENTIONED IN ALWAYCTXT REMOVED FROM INITCTXT, SEE QAALL';
  globalctxt -> cuctxt; pushctxt(); cuctxt -> tome;
  globalctxt -> cuctxt; pushctxt(); cuctxt -> gost;
  "notset" -> cuctxt; nil -> choicepts;
  initv(maxnodes) -> allnodes; 2 -> numnodes;
  consnode(1,0,0,0,"planhead",consword(' '),newnodectxt(),
    nil,nil,undef,nil,2::nil,undef) -> node(1);
  comment 'consword is a space';
  makenode(2,"goal",1.constrip,newnodectxt(),undef,1::nil,nil,copy(initnode));
  node(2) -> g; "goal" -> nodetype(g);
  comment 'autocond set true to give desirable effect with goals';
  readexpan(true) -> expansion(g) -> expanconds(g);
  cpm(expansion(g),datalength(expansion(g)));

  if (.itemread="protect") then gost -> cuctxt;
    nil -> alist; comment 'protected conditions cannot refer to variables';
    node(2) -> i; 3 -> nodenum(i); i -> node(3);
    2::nil -> succnodes(i); 3::nil -> succnodes(node(1));
    1::nil -> prenodes(i); 3 -> numnodes;
    copy(dummynode) -> i; 2 -> nodenum(i); i -> node(2); 3::nil -> prenodes(i);
    .itread -> i;
    while (i/=";" and i/="end") do
      if not(inctxt(i,true,getitem,initctxt)) then
        1.nl; pr('A protected condition is not true initially');
        .neterror; return
      endif;
      ((-1)::nil) -> value(constrip("supervised",i,true,2,4));
      .itread -> i;
    endwhile;
    "notset" -> cuctxt;
    3
  else 2
  endif;
  .doplan;
enddefine;

define macro replan; doplan(undef) enddefine;

define macro newdomain; vars cuctxt;
  comment 'fast clear of ALL hbase items and contexts - including any USER ones';
  0 -> ctxtcount; .clearitems;
  {% nil,nil,nil,nil,nil %} -> achlist;
  nil -> allfns; nil -> mainefflist;
  nil -> levellist; nil -> primlist; nil -> costlist;
  globalctxt -> cuctxt; pushctxt(); cuctxt -> alwayctxt; undef -> initctxt;
  20 -> maxnodes; 5 -> incrnodes; 0 -> numnodes;
  comment 'THE FOLLOWING JUST TO RELEASE STORE ON NEXT GC';
  undef -> allnodes; undef -> gost; undef -> tome;
  undef -> interact; undef -> choicepts; undefnum -> netmarked;
  sysgarbage(); comment 'do GC';
enddefine;

newdomain; comment 'use a call to initialise all variables';

define stringread -> s;
vars x i l num;
  requestline('') -> l;
  comment 'leave character codes of each word on stack.  Remove length';
  [% while l.ispair do l.dest -> l; .destword.erase; endwhile %] -> l;
  0 -> num;
  while (l.ispair) do
    l.dest -> l -> x;
    comment 'ignore spaces';
    if x/=32 then num+1 -> num; x endif;
  endwhile;
  if num>0 then -> x;
    if x/=59 then x else num-1 -> num; endif;
    comment 'ignore trailing semi-colon';
  endif;
  inits(num) -> s;
  for i from num by -1 to 1 do -> subscrs(i,s); endfor;
enddefine;

define macro tf;
  vars s;
  stringread() -> s;
  if s/='' then
    tfprefix><s><tfpostfix -> s;
    clearscreen();
    'Loading TF file '.pr; s.pr; 1.nl;
    apply(nonmac newdomain);
    compile(s);
  else 'tf requires a filename argument'.pr; 1.nl;
  endif;
enddefine;

comment '**************************************** output definitions ********';

vars itemprint; false -> itemprint; comment 'suppress item prefix';

define pritem x;
  if itemprint then "@".pr; endif; x.itemid.genpraux;
enddefine;

define prcontext;
   pr("context"); 1.sp; pr(ctxtnum(cuctxt));
   appitems(===,===,
            procedure x; 1.nl; genpr(itemid(x)); tabs(1);
                 genpr(value(x)) endprocedure);
   1.nl;
enddefine;

define prnode x;
  if x.isinteger then node(x) -> x endif;
  1.nl; pr(nodenum(x)); 2.sp; pr(nodetype(x)); tabs(1);
  pr(prenodes(x)); sp(3); pr(succnodes(x)); tabs(1);
  genpr(pattern(x));
enddefine;

vars draw_flag drawnet; false -> draw_flag;
define drawnet (); comment 'null body'; enddefine;
comment 'above included for optional tfinfo interfaces';

define prnet; vars i; 1 -> i;
  1.nl; numnodes.pr;
  ':Type'.pr; tabs(1); 'Pre.  Succs.'.pr; tabs(1); 'Pattern'.pr;
  while i<=numnodes do prnode(i); i+1 -> i endwhile; 1.nl;
  if draw_flag then drawnet(); endif;
enddefine;

define reducenet;
  comment 'modifies allnodes and numnodes - so copy before use if needed later.
           Reduce numnodes in allnodes vector to actions only - but
           preserve node numbers of original.
           Leave in first and last nodes in all cases';

  define uniqueconcat oldl insl -> l;
    comment 'oldl assumed to have no repeats';
    vars x;
    oldl -> l;
    while insl.ispair do insl.dest -> insl -> x;
      if lmemb(x,l,nonop = )=false then
        comment 'should only insert if no link from existing members
                 of l to x';
        x::l -> l;
      endif;
    endwhile;
  enddefine;

  define nextreallinks x fn -> linkl;
    comment 'given a node number x return it (as a singleton list) if it
             is an action or last node in net - else return a list of next
             actions that can be found from that node traversing using fn';
    vars l nextn;
    node(x) -> n;
    if nodetype(n)="action" or fn(n)=nil then x::nil -> linkl
    else [] -> linkl;
      fn(n) -> l;
      while l.ispair do l.dest -> l -> nextn;
        uniqueconcat(linkl,nextreallinks(nextn,fn)) -> linkl
      endwhile;
    endif;
  enddefine;

  define changefnlist l fn;
    vars x fnl fnx newfnl;
    while l.ispair do l.dest -> l; .node -> x;
      fn(x) -> fnl;
      [] -> newfnl;
      while fnl.ispair do fnl.dest -> fnl -> fnx;
        uniqueconcat(newfnl,nextreallinks(fnx,fn)) -> newfnl;
      endwhile;
      newfnl -> fn(x);
      if newfnl.ispair then changefnlist(newfnl,fn); endif;
    endwhile;
  enddefine;

  changefnlist([1],succnodes);
  changefnlist([2],prenodes);
enddefine;

define collapsenet;
  comment 'modifies allnodes and numnodes - so copy before use of needed later
           collapse a previously reduced net to actions and 1 and 2 only';

  vars oldnodes; comment 'a top level copy of the node vector for old numbers';
  vars i oldi newi n;

  define collapsereloc l -> newl;
    maplist(l,procedure x;
                nodenum(subscrv(x,oldnodes))
              endprocedure) -> newl
  enddefine;

  copy(allnodes) -> oldnodes;
  3 -> oldi; 2 -> newi;
  while oldi<=numnodes do
    node(oldi) -> n;
    if nodetype(n)="action" then
      newi+1 -> newi;
      newi -> nodenum(n);
      n -> node(newi);
    endif;
    oldi+1 -> oldi;
  endwhile;
  newi -> numnodes;
  numnodes -> i;
  while i>0 do
    node(i) -> n;
    collapsereloc(succnodes(n)) -> succnodes(n);
    collapsereloc(prenodes(n)) -> prenodes(n);
    i-1 -> i;
  endwhile;
enddefine;

define tidynet;
  comment 'remove redundant links in network';

  define linked x y fn;
    comment 'is x linked to y via fn';
    vars l found;
    fn(node(x)) -> l;
    if l.null then false
    elseif lmemb(y,l,nonop =)/=false then true
    else
      false -> found;
      while (l.ispair and not(found)) do
        if linked(hd(l),y,fn) then true -> found
        else tl(l) -> l
        endif;
      endwhile;
      found
    endif
  enddefine;

  define anylinked l y fn;
    comment 'check if y is linked after any node in l';
    while l.ispair do
      if linked(hd(l),y,fn) then true; return
      else tl(l) -> l;
      endif;
    endwhile;
    false
  enddefine;

  define reversechecklinked x l fn -> newl;
    comment 'check if x is linked before any existing member of l.
      if so remove that entry from l.  return new list';
    vars y;
    nil -> newl;
    while l.ispair do
      l.dest -> l -> y;
      if not(linked(x,y,fn)) then y::newl -> newl; endif;
    endwhile;
  enddefine;

  define removeredundantlinks n fn;
    vars l newl x;
    fn(node(n)) -> l;
    if length(l)>1 then
      dest(l) -> l -> x; x::nil -> newl;
      while l.ispair do
        dest(l) -> l -> x;
        if not(anylinked(newl,x,fn)) then
          x::reversechecklinked(x,newl,fn) -> newl;
        endif;
      endwhile;
      newl -> fn(node(n));
    endif;
  enddefine;

  vars i;
  for i from 1 by 1 to numnodes do
    removeredundantlinks(i,succnodes);
    removeredundantlinks(i,prenodes);
  endfor;
enddefine;

define prreducenet allnodes numnodes; comment 'to protect real net';
  copyalln() -> allnodes;
  reducenet();
  collapsenet();
  tidynet();
  prnet();
  if draw_flag then drawnet(); endif;
enddefine;

define prnodectxt n; if n.isinteger then node(n) -> n endif;
  applist(qaall(===,true,n), procedure x; if x.ispair then return endif;
            1.nl; genpr(x); tabs(1); genpr(true); endprocedure);
  applist(qaall(===,false,n),procedure x; if x.ispair then return endif;
            1.nl; genpr(x); tabs(1); genpr(false); endprocedure);
  1.nl;
enddefine;

define prtome; vars cuctxt; tome -> cuctxt; .prcontext; enddefine;
define prgost; vars cuctxt; gost -> cuctxt; .prcontext; enddefine;

define prcon cuctxt; .prcontext; enddefine;

define macro prinfo; vars ch i;
  0 -> ch;
  while ch/=32 do
    clearscreen();
    'Do you want to print:-'.pr;
    1.nl; 1.tabs; '1  Network ('.pr; numnodes.pr; ' nodes)'.pr;
    1.nl; 1.tabs; '2  Actions in Network only'.pr;
    1.nl; 1.tabs; '3  Critical Path Data'.pr;
    1.nl; 1.tabs; '4  Goal Structure'.pr;
    1.nl; 1.tabs; '5  Table of Multiple Effects'.pr;
    1.nl; 1.tabs; '6  Always Context'.pr;
    1.nl; 1.tabs; '7  Full Initial Context'.pr;
    1.nl; 1.tabs; '8  Initial Context entries not altered in plan'.pr;
    1.nl; 1.tabs; '9  Context at a particular node'.pr;
    1.nl;
    prompt('Type 1 to 9, <space> for none:',
           [1 2 3 4 5 6 7 8 9 %char(32)%]) -> ch;
    if ch/=32 then clearscreen(); endif;
    if ch=ord('1') then prnet()
    elseif ch=ord('2') then prreducenet(allnodes,numnodes);
    elseif ch=ord('3') then prcpdata()
    elseif ch=ord('4') then prgost()
    elseif ch=ord('5') then prtome()
    elseif ch=ord('6') then prcon(alwayctxt)
    elseif ch=ord('7') then prcontext();
    elseif ch=ord('8') then prcon(initctxt)
    elseif ch=ord('9') then
      'Print context at which node (1 to '.pr; numnodes.pr;
      ', end with <return>)'.pr;
      while (.itemread -> i; not(i.isnumber and i>0 and i<=numnodes)) do
      endwhile;
      prnode(i); 1.nl;
      prnodectxt(i);
    endif;
    if ch/=32 then 1.nl;
      prompt('Type <space> to continue:',[%char(32)%]).erase;
    endif;
  endwhile;
enddefine;

comment '************************ file prefixes, postfixes and titles ********';


;;; Changed to use screenlength. A.S. 27 Oct 2002
define showfile t;
  	comment 'show a file to the screen - eventually use VED on full screen';
  	vars tcharin t statv;
  	initv(1) -> statv; comment check file exists;

	lvars count = 0;

	define lconstant newcucharout(char);
		cucharout(char);

		if char == `\n` then
			count + 1 -> count;
			if count >= screenlength then
				0 -> count;
				;;; pause
                                pr('Type <return> to continue');
                                readline() ->;
			endif;
		endif;
	enddefine;
		

  	if sys_file_stat(t,statv)/=false then
    	clearscreen();
    	discin(t) -> tcharin;
		
    	while (tcharin() -> ch; ch/=termin) do newcucharout(ch) endwhile;
  	endif;
enddefine;

define title; vars x;
  vars i;
  clearscreen();
  'Nonlin Planner             '.pr; nlversion.pr; 1.nl;
  '---------------------------'.pr;
  datalength(nlversion) -> i;
  for i from i by -1 to 1 do '-'.pr; endfor;
  1.nl;
  'This is a non-linear planning system which accepts'.pr; 1.nl;
  'domain descriptions written in Task Formalism (TF).'.pr; 1.nl;
  'The system is documented in D.A.I research memo 25.'.pr; 2.nl;

  ;;; removed showfile of nonlintxt - use tfinfo.p option 0 instead
  ;;; prompt('Do you want to view a help document (Y/N):',[Y N]) -> x;
  ;;; if x=ord('Y') then
  ;;; showfile(nonlinprefix><'nonlintxt'><nonlinpostfix) endif;

  prompt('Do you want the Critical Path Method package (Y/N):',[Y N]) -> x;
  if x=ord('Y') then
    compile(nonlinprefix><'nonlincpm.p'><nonlinpostfix) endif;
  1.nl;
  comment show an alert/info file;
  showfile(nonlinprefix><'nonlininfo'><nonlinpostfix);
enddefine;

title();
sysgarbage();
