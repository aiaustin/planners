comment '[HBASE]  7-Jan-85 libprefix and libpostfix use added
                 30-Aug-84 apptovector cancel at end removed.
                 27-Aug-84 if x.isvector added to prevent instantiation
                           of words in newitem (to allow for variables)
                 24-Aug-84 genpr in pritem altered to genpraux
         UPDATED JANUARY 1977 - RR
         updated for PopLog - 26-Oct-83, A.Tate' ;

cucharout; erase->cucharout;
compile(libprefix><'wpop'><libpostfix);
compile(libprefix><'genpr'><libpostfix);
compile(libprefix><'stripfns'><libpostfix);
->cucharout;

recordclass item itemid itemrels itemval;
            comment 'also creates isitem consitem destitem';
            cancel destitem;

vars newitem items subitem supitems;

vars === ; "==="-> ===;

comment 'dummy routines to allow definition of match, itread and genpruserproc
         to account for actors if compiled';

vars isactor practor applyact listtoact;

procedure x; false endprocedure->isactor;

comment [item utilities];

define lmemb x l f;
  while l.ispair do
    if f(x,l.hd) then l; return endif;
    l.tl->l
  endwhile;
  false
enddefine;

define itread;
 vars x y;
  .itemread->x;
  if x="+" and proglist.hd.isnumber then .numberread
  elseif x="-" and proglist.hd.isnumber then -(.numberread)
  elseif x="[" then
    nil->y;
    [%while (.itread->x; ((x=".") or (x="|") or (x/="]"))) do
         if (x=".") or (x="|") then .itread->y
         elseif x/="]" then x
         endif
      endwhile%] ncjoin y
  elseif x="{" then
     [%while (.itread->x; x/="}") do x endwhile%].listtostrip
  elseif x="<:" then
     [%while (.itread->x; x/=":>") do x endwhile%].listtoact
  else x endif;
enddefine;

cancel &&;
define macro &; .itread enddefine;
define macro &&; .listread enddefine;
define macro &&&; .listread.popval enddefine;

comment [item itemof];


cancel match;

define match s t;
  vars i n;
loop:
 if s=t or s= === or t= === then true
 elseif s.isitem and t.isitem then false
 elseif s.isactor then applyact(t,s)
 elseif t.isactor then applyact(s,t)
 elseif t.isitem then t.itemid->t; goto loop
 elseif s.isitem then s.itemid->s; goto loop
 elseif not(samedata(s,t)) then false
 elseif s.isvector then
  s.datalength->n;
  if n/=t.datalength then false; return endif;
  1->i;
  while i<=n and (match(subscrv(i,s),subscrv(i,t))) do i+1->i endwhile;
  i>n
 elseif s.atom.not and (match(s.dest->s,t.dest->t)) then goto loop 
 else false endif;
enddefine;

define instance x;
 if x.isvector then modstrip(x.copy,instance)
 elseif x.ispair then cons(instance(x.hd),instance(x.tl))
 else x endif
enddefine;

define itemlength t;
 if t.isitem then t.itemid->t endif;
 if t.isvector then t.datalength else 0 endif;
enddefine;

vars minshort; 2->minshort;

define getashort x;
 vars i y l l0 l1 s;
  if x.isitem then [%x%]
  elseif x= === or x.isactor then items
  elseif x.isword then
    x.meaning->x;
    if x.isitem then [%x%] else nil endif;
  elseif x.isvector then
    items ->l; 2.1e9->l0; comment 'large number';
    x.datalength->i; 
    while i/=0 and l0>minshort do
      subscrv(i,x)->y;
      if y.isword then y.meaning->y endif;
      if y.isitem then
        supitems(i,y)->s;
        if s.islist then
          s.length->l1;
          if l1<l0 then s->l; l1->l0 endif;
        endif;
      endif;
    i-1->i
    endwhile;
    l
  else nil endif;
enddefine;

define getaitlist l x;
 lmemb(x,l,match)->l;
 if not(l) then false else l.hd endif
enddefine;

define getaitem x;
 if x.isitem then x
 elseif x= === then
  if items.ispair then items.hd else false endif;
 elseif x.isword then
  if x.meaning.isitem then x.meaning else false endif;
 elseif x.isvector or x.isactor then getaitlist(getashort(x),x)
 else false endif
enddefine;

define appaitlist l x f;
 vars appgoon; true->appgoon;
 while appgoon and (lmemb(x,l,match)->l; l.ispair) do f(l.dest->l) endwhile
enddefine;

define appaitems x f;
  if x.isitem then f(x)
  elseif x= === then applist(items,f)
  elseif x.isword then
    x.meaning->x;
    if x.isitem then f(x) endif
  else appaitlist(getashort(x),x,f) endif
enddefine;

define appsubitems x f;
 vars t;
 getaitem(x)->t;
 if t/=false then t.itemid->x endif;
 if x.isvector then appdata(x,f) endif;
enddefine;

define itemof x;
 vars t;
  x.getaitem->t;
  if t/=false then t
  elseif x.isword or x.isvector then
    newitem(x)
  else x endif;
enddefine;

define macro @;
 .itread.itemof
enddefine;

define value t;
 getaitem(t)->t;
 if t.isitem then t.itemval else undef endif;
enddefine;

procedure x;
  x -> .itemof.itemval
endprocedure->updater(value);

comment [item newitem];

vars clearlocals addsupitem remsupitem;

vars items; nil->items;

define clearitems;
 while items.ispair do
  if items.hd.itemid.isword then
     undef->items.hd.itemid.meaning endif;
  items.tl->items
 endwhile;
 .clearlocals;
enddefine;

define relspec x;
  nil,nil,nil,nil,nil,5.constrip
enddefine;

define apptovector t f;
 vars s i ;
  t.itemid->s;
  if s.isvector.not then return; endif;
  s.datalength->i;
  while i/=0 do
   f(t,i,subscrv(i,s));
   i-1->i;
  endwhile;
enddefine;

define newitem x -> t;
 if x.isvector then instance(x)->x; endif;
 consitem(x,undef,undef)->t;
 cons(t,items)->items;
 if x.isword then t->x.meaning
 elseif x.isvector then
   modstrip(x,itemof)->itemid(t);
   apptovector(t,addsupitem)
 endif;
enddefine;

define killitem t;
 t.getaitem->t;
 ncdelete(t,items,match)->items;
  if t.itemid.isword then
    undef->meaning(itemid(t))
  else apptovector(t,remsupitem) endif
enddefine;

define supitems i s;
 vars l;
  s.getaitem->s;
  if s.not then nil; return endif;
  s.itemrels->s;
  if s.isvector then
    if i/=0 then subscrv(min(i,s.datalength),s)
    else nil->l;
      s.datalength->i;
      while i/=0 do
       subscrv(i,s)<>l->l;
       i-1->i
      endwhile;
      l
    endif;
  elseif s=undef then nil
  else s endif;
enddefine;

define setsupitems v i x f;
 vars s;
  x.itemof->x;
  if x.isitem.not then return endif;
  if i=0 or i=false then v->itemrels(x); return endif;
  x.itemrels->s;
  if s=undef then relspec(x)->s; s->itemrels(x) endif;
  if s.isvector then min(i,s.datalength)->i;
    subscrv(i,s)->x;
    if x.islist then f(v,x)->subscrv(i,s) endif;
  endif;
enddefine;

setsupitems(%ncdelete(%nonop = %) %)->remsupitem;
setsupitems(%cons%)->addsupitem;

define nosupitem n t; setsupitems("nosupitem",n,t,erase) enddefine;

define subitem n t;
 t.itemof.itemid->t;
 if n=0 or n=false then t else subscrv(n,t) endif;
enddefine;

procedure x n t;
 t.itemof->t; x.itemof->x;
 if n/=0 then
    remsupitem(t,n,subscrv(n,t.itemid));
    x->subscrv(n,t.itemid);
    addsupitem(t,n,x)
  else
    if t.itemid.isword then
      undef->t.itemid.meaning else apptovector(t,remsupitem) endif;
    x.itemid->t.itemid;
    x.killitem;
    if t.itemid.isword then t->t.itemid.meaning
     else apptovector(t,addsupitem) endif
  endif;
endprocedure->updater(subitem);


comment [item appitems];

vars s v;

define auxget x;
 value(x)->y;
 if y/=undef and (match(v,y)) then
    false->appgoon; x->s endif;
enddefine;

define getitlist l t v -> s;
 vars y; false->s;
  appaitlist(l,t,auxget)
enddefine;

define getitem t v -> s;
 vars y; false->s;
  appaitems(t,auxget)
enddefine;

define auxapp x;
 value(x)->y;
 if y/=undef and (match(v,y)) then s(x) endif;
enddefine;

define appitlist l t v s;
 vars y;
  appaitlist(l,t,auxapp)
enddefine;

define appitems t v s;
 vars y;
  appaitems(t,auxapp)
enddefine;

comment [item genpr];

define pritem x;
  "@".syspr; x.itemid.genpraux
enddefine;

define genpruserproc x;
 if x.isitem then x.pritem; true
 elseif x.isactor then x.practor; true
 else false endif
enddefine;

define clearlocals;
  undef->f; undef->i; undef->l; undef->l0; undef->l1;
  undef->n; undef->s; undef->t; undef->v; undef->x; undef->y;
enddefine;

.clearlocals;

cancel f i l l0 l1 n s t v x y auxget auxapp;

'[HBASE] ready'.pr; 1.nl;
