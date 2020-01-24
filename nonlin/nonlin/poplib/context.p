comment '[CONTEXT] 24-Aug-84 pr in prctxt altered to syspr
         UPDATED 29/3/76 - RR
         updated for PopLog  4-Oct-83 A.Tate' ;

section sec_context => ctxtnum consctxt prectxt succtxts ctxtcount
                       globalctxt cuctxt isctxt newctxt pushctxt popctxt
                       inctxt accinctxt updinctxt delcm1 delcm
                       contextfns prctxt;

recordclass ctxt ctxtnum prectxt succtxts;
comment 'also creates isctxt, consctxt and destctxt';
cancel destctxt;

vars ctxtcount globalctxt cuctxt;

0->ctxtcount;
consctxt(0,undef,nil)->globalctxt;
globalctxt->cuctxt;

recordclass cm cmctxt cmnext cmval;
comment 'also creates iscm conscm and destcm';
cancel destcm;

define newctxt c -> n;
 ctxtcount+1->ctxtcount;
 consctxt(ctxtcount,c,nil)->n;
  if c.isctxt then
    n::succtxts(c)->succtxts(c) endif;
enddefine;

define pushctxt; newctxt(cuctxt)->cuctxt enddefine;

define popctxt; 
  prectxt(cuctxt)->cuctxt;
enddefine;

define inctxt cuctxt; .apply enddefine;

procedure cuctxt; .updater.apply endprocedure->updater(inctxt);

define accinctxt l s;
 vars n c;
    s(l)->l;
    if l.iscm.not then l; return endif;
     cuctxt->c;
loop0: if c.isctxt.not then undef; return endif;
       c.ctxtnum->n;
loop1: if l.iscm.not then undef
       elseif l.cmctxt.ctxtnum>n then l.cmnext->l; goto loop1
       elseif l.cmctxt=c then l.cmval
       else c.prectxt->c; goto loop0 endif;
enddefine;

define updinctxt t s;
 vars n v l c;
  s(t)->l; ->v;
  cuctxt->c; c.ctxtnum->n;
  if l.iscm.not then
    conscm(globalctxt,undef,l)->l; l->s(t);
    if cmval(l)=undef then c->l.cmctxt endif;
  endif;
 loop: if l.cmctxt=c then
         v->l.cmval
       elseif l.cmctxt.ctxtnum<n then
         copy(l)->l.cmnext;
         c->l.cmctxt; v->l.cmval;
       elseif l.cmnext.iscm.not then
         conscm(c,undef,v)->l.cmnext;
       else l.cmnext->l; goto loop endif;
enddefine;

updinctxt->updater(accinctxt);

define delcm1 t c s;
 vars n l x;
  c.ctxtnum->n; s(t)->l;
  if l.iscm.not then return
  elseif l.cmctxt=c then l.cmnext->s(t); return endif;
loop: l.cmnext->x;
      if x.iscm.not or x.cmctxt.ctxtnum<n then return
      elseif x.cmctxt.ctxtnum>n then x->l; goto loop 
      else x.cmnext->l.cmnext endif;
enddefine;

define delcm t c s;
 delcm1(t,c,s);
 applist(succtxts(c),procedure c; delcm(t,c,s) endprocedure);
enddefine;

define contextfns s;
  delcm(%s%),
  accinctxt(%s%)
enddefine;

define prctxt c;
  '<context '.syspr; c.ctxtnum.syspr; ">".syspr;
enddefine;

endsection;

'[CONTEXT] ready'.pr; 1.nl;
