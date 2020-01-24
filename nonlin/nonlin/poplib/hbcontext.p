comment '[HBCONTEXT] - contexts for HBASE.
         INSERTED MARCH 1975 - RR
         7-Jan-85 libprefix and libpostfix added, A.Tate
         Updated for PopLog 26-Oct-83, A.Tate' ;

cucharout; erase->cucharout;
compile(libprefix><'context'><libpostfix);
->cucharout;

define value t;
  if t.isitem.not then t.getaitem->t endif;
  if t.isitem then accinctxt(t,itemval)
  else undef endif;
enddefine;

procedure v t;
  if t.isitem.not then itemof(t)->t endif;
  updinctxt(v,t,itemval);
endprocedure->updater(value);

define killctxt c;
  applist(items,procedure t; delcm(t,c,itemval) endprocedure);
  if c.prectxt.isctxt then
    ncdelete(c,succtxts(prectxt(c)),nonop =)->succtxts(prectxt(c));
  endif;
enddefine;

comment 'requires ACTOR package to be in';

define genpruserproc x;
  if x.isitem then x.pritem; true
  elseif x.isactor then x.practor; true
  elseif x.isctxt then x.prctxt; true
  else false
  endif
enddefine;

'[HBCONTEXT] ready'.pr; 1.nl;
