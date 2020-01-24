;;; Austin Tate - NONLIN bits to add on to Harry Barrow's HBASE.
;;;
;;; HBASE with actors and contexts. Also provided is a
;;; facility for placing actor restrictions on variables and a
;;; @* semi-open variable.
;;; The system incorporates a facility for indicating which actors are
;;; instantiable - i.e. respond correctly to an attempt to match ===
;;;
;;; ensure that hbase, hbcontext and hbactor are in;
;;;
;;; macros to aid in writing HBASE code

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

;;; Restriction facilities for variables in HBASE - also @*

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

;;; ******************************* end of HBASE extensions ***********

