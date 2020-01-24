comment '[HBACTOR] - actors for HBASE - 24-Aug-84
         UPDATED JUNE 1975 - RR
         Updated for PopLog - 26-Oct-83, A.Tate
         hassupit changed to hassupitem - 12-Dec-83, A.Tate
         libprefix and libpostfix added -  7-Jan-85, A.Tate
         pr in practor altered to syspr - 24-Aug-84, A.Tate';

cucharout; erase -> cucharout;
compile(libprefix><'actor'><libpostfix);
-> cucharout;

define instance x;
 if x.isactor then instact(x)
 elseif x.isvector then modstrip(x.copy,instance)
 elseif x.ispair then cons(instance(x.hd),instance(x.tl))
 else x endif
enddefine;

define getvalue s x;
 if s= === then value(x)
 else match(s,value(x)) endif
enddefine;

define setvalue s x;
 if s.isactor then s.instact->s endif;
 s->value(x);
 true
enddefine;

define macro @@@; <| "getvalue", .itread |> enddefine;

define macro @@>; <| "setvalue", .itread |> enddefine;

define hassupitem x n s v;
  getitlist(supitems(n,x),s,v)
enddefine;

define practor x;
 if subact(1,x)="getval" then
   "@@".syspr; subact(2,x).genpraux
 elseif subact(1,x)="setval" then
   "@>".syspr; subact(2,x).genpraux
 elseif subact(1,x)="getvalue" then
   "@@@".syspr; subact(2,x).genpraux
 elseif subact(1,x)="setvalue" then
   "@@>".syspr; subact(2,x).genpraux
 else
   "<:".syspr; genprsequence(x); ":>".syspr
 endif;
enddefine;

cancel i l n s t v x y initact;

'[HBACTOR] ready'.pr; 1.nl;
