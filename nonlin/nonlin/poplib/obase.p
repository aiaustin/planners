comment OBase - (c) Copyright 1984, Austin Tate
                based on HBase by Harry Barrow

        Do not recompile a second time in the same POPLOG image as items
        will be left scattered in meanings of words leading to errors;

compile('poplib/genpr.p');

cancel match; ;;; as this is an old withdrawn pop11 routine name

section obase genpr genpraux genprsequence genpr_printer genprlength genprdepth 
               => ob_version
                 ;;; input and output
                 itread # @ ? ?? genpr_item_prefix genpr_full
                 set_pr_length set_pr_depth
                 ;;; item related and storage format
                 isitem itemof itemid itemlength clearitems makeactor
                 subitem supitems nosupitem relspec_default
                 ;;; usual functional interface
                 instance general_instance match value
                 get_one find_all get_next
                 ;;; match specification actors
                 hassupitem property any all eval contains has type bound
                 ;;; context related externals
                 newctxt pushctxt popctxt getctxt putctxt
                 prectxt succctxts killctxt accinctxt
                 ;;; vars
                 open_var_trans abort_var_trans commit_var_trans
                 review_var_trans alist_for_var_trans append_ remove_
                 concat_words unique_word unique_base_number
                 alist_remove_locals alist_rename_locals
                 find_all_vars is_var_info var_value var_restrict
                 pr_var pr_vars;

vars ob_version; '3.14 14-Jun-85' -> ob_version;

comment  17-Aug-84 Started, Austin Tate.
         12-Sep-84 one file made from original hbase bits
;

comment HBASE-like with actors and contexts. Also provided are:
        - logical variable with actor restrictions
        - context layered values and restrictions for variables
        - result generators
;

compile('poplib/context.p');

define modvector s f -> s;
 vars n;
  s.datalength->n;
  while n>0 do
    f(subscrv(n,s))->subscrv(n,s);
    n-1->n
  endwhile
enddefine;

recordclass item itemid itemrels itemval;
            comment 'also creates isitem consitem destitem';

            cancel destitem;

vars items var_items subitem supitems ?? ;

define isvar x;
  (x.isword and subscrw(1,x)=95)
enddefine;

vars instance apptovector itemof addsupitem;  comment declared forward;

define newitem x -> t;
 if x.isvector then instance(x)->x; endif;
 consitem(x,undef,undef)->t;

 if x.isvar then cons(t,var_items) -> var_items
 else cons(t,items)->items;
 endif;

 if x.isword then t->meaning(x)
 elseif x.isvector then
   modvector(x,itemof)->itemid(t);
   apptovector(t,addsupitem)
 endif;
enddefine;

nil -> items; nil -> var_items; "??"-> ??;

comment 'dummy routines to allow definition of match, itread
         to account for actors if compiled';

vars isactor practor applyact;

comment [item utilities];

define lmemb x l f;
  while l.ispair do
    if f(x,l.hd) then l; return endif;
    l.tl->l
  endwhile;
  false
enddefine;

vars is_var_info var_value; comment defined forward;

vars varval; comment defined forward;

vars subact itemof; comment defined forward;

define instance x; vars v id;
  if x.isitem then itemid(x) -> x; endif;
  if x.isvector then modvector(x.copy,instance)
  elseif x.ispair then cons(instance(x.hd),instance(x.tl))
  else comment all the rest is to deal with variables.  otherwise return x;
    (if x.isactor and subact(1,x)="given" then subact(2,x) else x endif) -> id;
    if id.isword and subscrw(1,id)=95 then
      varval(id) -> v;
      if v/=undef and not(v.isactor) then instance(v)
      else id
      endif;
    else x
    endif;
  endif;
enddefine;

define general_instance x; vars v;
  if x.isitem then itemid(x) -> x; endif;
  if x.isvector then modvector(x.copy,general_instance)
  elseif x.ispair then cons(instance(x.hd),general_instance(x.tl))
  else
    if x.isactor and subact(1,x)="given" then subact(2,x) -> x; endif;
    if x.isword and subscrw(1,x)=95 then
      varval(x)->v;
      if v/=undef and not(v.isactor) then general_instance(v)
      else ??
      endif;
    elseif x.isactor then ??
    else x
    endif;
  endif;
enddefine;

vars match;

define itemlength t;
 if t.isitem then t.itemid->t endif;
 if t.isvector then t.datalength else 0 endif;
enddefine;

vars minshort; 2->minshort;

define getashort x;
 vars i y l l0 l1 s;
  if x.isitem then [%x%]
  elseif x= ?? or x.isactor then items
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
 elseif x= ?? then
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
  elseif x= ?? then applist(items,f)
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

vars clearlocals remsupitem;

define clearitems;
 while items.ispair do
  if items.hd.itemid.isword then
     undef->items.hd.itemid.meaning endif;
  items.tl->items
 endwhile;
 while var_items.ispair do
  if var_items.hd.itemid.isword then
     undef->var_items.hd.itemid.meaning
  else 'inappropriate item on list of variables'.pr;
  endif;
  var_items.tl->var_items
 endwhile;
 .clearlocals;
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

comment relspec defaults and item specific overrides;

vars relspec_template; {% [],[],[],[],[] %} -> relspec_template;

define relspec_default v; vars len;
  if v.isvector then datalength(v) -> len; if len>5 then 5 -> len endif;
    for i from 1 to len do
      if subscrv(i,v)="yes" then [] -> subscrv(i,v)
      elseif subscrv(i,v)="no" then "nosupitems" -> subscrv(i,v)
      else
        if subscrv(i,v)/="??" then
          1.nl; pr('Relspec default: only yes, no or ?? allowed');
        endif;
      endif;
    endfor
  else 1.nl; pr('Relspec default: give a vector with yes, no or ?? entries');
  endif;
enddefine;

define relspec x;
  copy(relspec_template);
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

vars value;   comment forward declared;
vars s v;     comment globals in appitems routines;

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

define clearlocals;
  undef->f; undef->i; undef->l; undef->l0; undef->l1;
  undef->n; undef->s; undef->t; undef->v; undef->x; undef->y;
enddefine;

.clearlocals;

cancel f i l l0 l1 n s t v x y auxget auxapp;

comment [actor definitions];

vars temp_key subact initact isactor consact;

conskey("actor","full") -> temp_key;
class_init(temp_key) -> initact;
class_subscr(temp_key) -> subact;
class_recognise(temp_key) -> isactor;
class_cons(temp_key) -> consact;

define eval;
 .applyact.match
enddefine;

define has t s v;
  v,t,s.applyact.match
enddefine;

define non; comment used for not;
  .match.not
enddefine;

define et s x y; comment used for and;
  (match(s,x) and match(s,y))
enddefine;

define vel s x y; comment used for or;
  (match(s,x) or match(s,y))
enddefine;

define all t l;
loop: if l.null then true
      elseif match(t,l.hd) then l.tl->l; goto loop
      else false endif;
enddefine;

define any t l;
loop: if l.null then false
      elseif match(t,l.hd) then true
      else l.tl->l; goto loop endif;
enddefine;

define contains l x;
 while l.ispair do
   l.dest->l;
   if x.match then true; return endif;
 endwhile;
 false
enddefine;

define hassupitem x n s v;
  getitlist(supitems(n,x),s,v)
enddefine;

define property s p v;
  hassupitem(s,2,{%p,"??"%},v)
enddefine;

define type s t;
  getitem({% "type",s %},t)
enddefine;

vars var_value new_var_value var_in_alist trans_setvars; comment declared forward;

define bound x; vars v l;
  if x.isactor then false
  else
    if x.isitem then x.itemid -> x endif;
    if x.isword and subscrw(1,x)=95 then
      lmemb(x,trans_setvars,var_in_alist) -> l;
      ((if l/=false then new_var_value(hd(l))
        elseif meaning(x).isitem then
          value(meaning(x)) -> v;
          if v=undef then v else var_value(v) endif;
        else undef endif)/=undef)
    else true
    endif
  endif
enddefine;

define makeactor v;
  v.destvector.consact
enddefine;

vars given;  ;;; forward reference

define applyact s;
 vars i n;
 while (s.isword) or (s.isactor) do
  (if s.isword then  comment dereference - but syntax words cannot be used;
     if s="and" then et
     elseif s="or" then vel
     elseif s="not" then non
     elseif s="given" then given
     else s.valof
     endif
   elseif s.isactor then
     s.datalength->n; 2->i;
     while i<=n do subact(i,s); i+1->i endwhile;
     subact(1,s)
   endif) -> s;
 endwhile;
 .s
enddefine;

vars var_value var_restrict trans_setvars var_back_trail;

recordclass _var_info var_value var_restrict;

recordclass vtransrec var_name old_var_value old_var_restrict
                               new_var_value new_var_restrict;
            comment also created isvtransrec consvtransrec destvtransrec;

comment trans_setvars is a list of variables accessed since the previous
        open_var_trans.  It is used as a lookup cache and to keep
        altered variable values until a commit.  Its format is

        [ <vtransrec var_name orig_var_value orig_var_restrict
                              new_var_value  new_var_restrict> ... ]

        var_back_trail in use is local to match.  It keeps the vtransrec
        of any variable altered together with the value and restriction
        before the alteration.  It can be used to roll back after a no
        match.
;

define var_in_alist name elem;
  (var_name(elem)=name)
enddefine;
  
define varval x; vars l trec iv;
  if x.isword and subscrw(1,x)=95 then
    lmemb(x,trans_setvars,var_in_alist) -> l;
    (if l=false then
       x,(meaning(x) -> x;
          if x.isitem then accinctxt(x,itemval) -> iv;
            if iv/=undef then iv.dest_var_info,iv.dest_var_info
            else undef,undef,undef,undef endif
          else undef,undef,undef,undef endif).consvtransrec
       ::trans_setvars -> trans_setvars; hd(trans_setvars)
     else hd(l) endif) -> trec;
   
    if trec.new_var_value/=undef then trec.new_var_value
    else trec.new_var_restrict endif
   
  else 1.nl; 'Incorrect param to varval - '; genpr(x); undef endif;
enddefine;

define commit_vars; vars name oldv oldr newv newr it;
  while trans_setvars.ispair do
    trans_setvars.dest -> trans_setvars;
    .destvtransrec -> newr -> newv -> oldr -> oldv -> name;
    if oldv/=newv or oldr/=newr then meaning(name) -> it;
      if it.isitem.not then newitem(name) -> it endif;
      updinctxt(cons_var_info(newv,newr),it,itemval);
    endif;
  endwhile
enddefine;

procedure v x; vars l trec;
  if x.isword and subscrw(1,x)=95 then
    lmemb(x,trans_setvars,var_in_alist) -> l;
    if l=false then 1.nl; 'update of var before access not possible! - '.pr;
      genpr(x); return
    else hd(l) -> trec;
      [%trec.new_var_restrict,trec.new_var_value,trec%] ncjoin var_back_trail
          -> var_back_trail;
      if v.isactor then v -> trec.new_var_restrict
      else v -> trec.new_var_value endif;
    endif;

  else 1.nl; 'Incorrect param to updater of varval - '; genpr(x);
  endif;
endprocedure -> updater(varval);

define given s x; vars i iv res;

  comment may need to separate out "?name" and ?{not ?name} and handle
          specially to ensure no cyclic recursion on matching - could
          keep same and not-same lists in varval specification;
   
  define mergeactors a1 a2;
    if a2.isactor and subact(1,a2)="all" then
      if subact(1,a1)="all" then subact(2,a1)<>subact(2,a2)
      else a1::subact(2,a2)
      endif
    else
      if subact(1,a1)="all" then subact(2,a1)<>[% a2 %]
      else [%a1,a2%]
      endif
    endif
  enddefine;

  if s= ?? then true; return endif;

  varval(x) -> i;
 
  if s.isactor and subact(1,s)="and" then
     "all", [%subact(2,s),subact(3,s)%], 2.consact -> s;
  endif;

  if i=undef or i.isactor then
      
     if i.isactor then
        comment keep restrictions in order given;
        if s.isactor then
          "all", mergeactors(i,s),2.consact -> varval(x);
        else if applyact(s,i) then comment s passes current restriction;
               s -> varval(x);
             else false; return;
             endif;
        endif
     else comment i is undef so s defines;
          s -> varval(x);
     endif;
     true
  else comment i has a definite value - so check s matches this;
    match(s,i) -> res;
    if res and s.isactor then
      comment now add s as a further restriction on var;
      lmemb(x,trans_setvars,var_in_alist) -> l;
      if l=false then 1.nl; 'update of var before access not possible! - '.pr;
        genpr(x); false
      else hd(l) -> trec;
        (if trec.new_var_restrict=undef then s
         else "all",mergeactors(trec.new_var_restrict,s),2.consact
         endif) -> trec.new_var_restrict;
      endif;
    endif;
    res
  endif
enddefine;

cancel i l n s t v x y initact;

comment [context related definitions];

define value t;
  if t.isitem.not then t.getaitem->t endif;
  if t.isitem then accinctxt(t,itemval)
  else undef endif;
enddefine;

procedure v t;
  if t.isitem.not then itemof(t)->t endif;
  updinctxt(v,t,itemval);
endprocedure->updater(value);

define hbase_killctxt c;
  applist(items,procedure t; delcm(t,c,itemval) endprocedure);
  applist(var_items,procedure t; delcm(t,c,itemval) endprocedure);
  if c.prectxt.isctxt then
    ncdelete(c,succtxts(prectxt(c)),nonop =)->succtxts(prectxt(c));
  endif;
enddefine;

vars var_update_allowed trans_setvars;

[] -> trans_setvars; false -> var_update_allowed;

define smatch s t; vars i n; ;;; order critical to deal with _name variables
loop:
   if s=t or s= ?? or t= ?? then true
   elseif t.isitem then t.itemid->t; goto loop
   elseif s.isitem then s.itemid->s; goto loop
   elseif s.isactor then
      if t.isactor then
        if subact(1,s)="given" and subact(1,t)="given" then
          'Cannot match 2 variables at present'.pr; false
        elseif subact(1,s)="given" then applyact(t,s)
        elseif subact(1,t)="given" then applyact(s,t)
        else
           1.nl; 'Cannot match 2 non-variable actors '.pr;
           s.genpr; ' and '.pr; t.genpr; false
        endif
      else applyact(t,s)
      endif
   elseif t.isactor then comment s is known not to be an actor here;
      applyact(s,t)
   elseif (dataword(s)/=dataword(t)) then false
   elseif s.isvector then
      s.datalength -> n;
      if n/=(t.datalength) then false
      else
        1 -> i;
        while (i<=n) and match(subscrv(i,s),subscrv(i,t)) do
          i+1 -> i
        endwhile;
        i>n
      endif
   elseif s.atom.not and match(s.dest->s,t.dest->t) then goto loop
   else false endif;
enddefine;

define match; vars match res var_back_trail trec;
   nil -> var_back_trail;
   smatch -> match;
   match() -> res;
   if not(res) or not(var_update_allowed) then
     while var_back_trail.ispair do
       var_back_trail.dest.dest.dest -> var_back_trail;
       -> trec; -> new_var_value(trec); -> new_var_restrict(trec);
     endwhile;
   endif;
   res
enddefine;

comment result generators and retrieval in obase;

recordclass gen gen_id gen_val gen_possl;

cancel destgen; comment also creates consgen and isgen;

define find_all p v;
  consgen(p,v,getashort(p))
enddefine;

define get_next g; vars possl x v;
  if g.isgen and (gen_possl(g)->possl; possl.ispair) then
    while possl.ispair do possl.dest -> possl -> x;
      value(x) -> v;
      if v/=undef and match(v,gen_val(g)) and match(x,gen_id(g)) then
        possl -> gen_possl(g); x; return
      endif;
    endwhile;
  endif;
  [] -> gen_possl(g); termin
enddefine;

define get_one p v; vars g;
  find_all(p,v) -> g;
  get_next(g);
enddefine;

define find_all_vars ();
  if var_update_allowed then
    pr('find_all_vars only allowed outside of a variable transaction'); 1.nl;
    undef
  else consgen(??,??,var_items)
  endif;
enddefine;

define itread;
 vars x y i;
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
     {%while (.itread->x; x/="}") do x endwhile%}

  comment "?" macro performs function of following 6 lines
          replace these if macro has to be removed for any reason;

  ;;; elseif x="?" then
  ;;;    if proglist.hd="{" then .itread.makeactor
  ;;;    elseif proglist.hd.isword then
  ;;;        "given",((95,(.itread.destword) ->i; i+1).consword),2.consact
  ;;;    else x
  ;;;    endif

  elseif x.isword then
    if x="true" then true
    elseif x="false" then false
    else x
    endif;
  else x
  endif;
enddefine;

define macro @;
 .itread.itemof
enddefine;

define macro #;
 .itread
enddefine;

define macro ? ; vars i;
  if hd(proglist)="{" then .itread.makeactor
  elseif proglist.hd.isword then
      "given",((95,(.itread.destword) ->i; i+1).consword),2.consact
  else "?"
  endif;
enddefine;

vars genpr_item_prefix genpr_full nested_prvar;
'@' -> genpr_item_prefix;
true -> genpr_full; false -> nested_prvar;

define set_pr_depth (i);
  if i.isnumber and i>=1 and i<=99 then i -> genprdepth
  else 1.nl; i.genpr; ' is not suitable for set_pr_depth'.pr;
  endif;
enddefine;

define set_pr_length (i);
  if i.isnumber and i>=1 and i<=99 then i -> genprlength
  else 1.nl; i.genpr; ' is not suitable for set_pr_length'.pr;
  endif;
enddefine;

define pr_a_var x; vars i l;
  if x.isitem then itemid(x) -> x; endif;
  if x.isword and subscrw(1,x)=95 then
    "?".syspr; datalength(x) -> l;
    for i from 2 to l do cucharout(subscrw(i,x)) endfor;
  else 1.nl; 'Var printing fails on - '.pr; genpr(x);
  endif;
enddefine;

define pritem x; vars id v; itemid(x) -> id;
  if genpr_full then genpraux(genpr_item_prefix); endif;
  genpraux(id);
  if genpr_full and not(nested_prvar) and id.isvar and
     (varval(id)->v; v/=undef) then
    true -> nested_prvar; syspr('='); genpraux(v); false -> nested_prvar;
  endif;
enddefine;

define practor x; vars v;
  if subact(1,x)="given" then
   pr_a_var(subact(2,x));
 else
   '?{'.syspr; genprsequence(x); "}".syspr
 endif;
enddefine;

;;;define genpruserproc x;
;;;  if x.isitem then x.pritem; true
;;;  elseif x.isactor then x.practor; true
;;;  elseif x.isctxt then x.prctxt; true
;;;  else false
;;;  endif
;;;enddefine;

pritem -> genpr_printer("item");
practor -> genpr_printer("actor");
prctxt -> genpr_printer("ctxt");

vars vars_locals;  comment declared forward;

define pr_var(var_name); vars val v r;
  pr_a_var(var_name); pr('=');
  value(var_name).dest_var_info -> r -> v;
  if v/=undef then genpr(v) elseif r/=undef then genpr(r) else pr("??") endif;
enddefine;

define pr_vars (); vars nested_prvar l trec v r nam;
  true -> nested_prvar; comment no nested variables to be printed here;

  trans_setvars -> l;
  while l.ispair do l.dest -> l -> trec;
    new_var_value(trec) -> v; new_var_restrict(trec) -> r; var_name(trec) -> nam;
    if v/=undef or r/=undef or member(nam,vars_locals) then
      1.nl; pr_a_var(var_name(trec)); tabs(1); pr(' = ');
      if v/=undef then genpr(v) else genpr(r) endif;
    endif;
  endwhile;

  applist(var_items,
    procedure x; vars l v r;
      lmemb(itemid(x),trans_setvars,var_in_alist) -> l;
      if l=false then
        value(x).dest_var_info -> r -> v;
        if v/=undef or r/=undef then
          1.nl; pr_a_var(x); tabs(1); pr(' = ');
          if v/=undef then genpr(v) else genpr(r) endif;
        endif;
      endif; comment else was printed from trans_setvars already;
    endprocedure);
  1.nl;
enddefine;

comment var transactions
        These could be done with extra pushctxt, popctxt, etc but these
        provide an extra level of barrier only for vars where appropriate;

comment LOCAL variables can be nominated to open.  They must start with _ .
        An initial restriction actor or undef is given for each.  It is the
        users responsibility to keep local and global names separate.
        Where there is a name clash locals override globals.
        These to be kept on a list so that locals could be distinguished
        from globals.  Otherwise locals and globals wuld behave same;

vars vars_locals; nil -> vars_locals;

define open_var_trans (locals); vars len nam val; nil -> vars_locals;
  if var_update_allowed then 1.nl; 'Transaction already in progress'.pr
  else true -> var_update_allowed;
       [%while locals.ispair do
           locals.dest.dest -> locals -> val -> nam;
           if not(nam.isword and subscrw(1,nam)=95) then
             1.nl; genpr(nam); pr(' must be a word starting with _ for locals');
           endif;
           nam::vars_locals -> vars_locals;
           consvtransrec(nam,undef,undef,
                             (if val=undef or val="??" or val.isactor
                              then undef else val endif),
                             val)
         endwhile %] -> trans_setvars;
  endif;
enddefine;

define append_ wd; vars len;
  95; wd.destword -> len; len+1; .consword
enddefine;

define remove_ -> res; vars len;
  .destword -> len; len-1; .consword -> res; .erase;
enddefine;

define concat_words(w1,w2); vars len;
  w1.destword -> len; w2.destword; len, nonop + ; .apply; .consword
enddefine;

vars unique_base_number; 0 -> unique_base_number;
;;; this is made external to allow it to be reset (eg as contexts are changed)

define unique_word(wd); vars len_num len_wd;
  unique_base_number+1 -> unique_base_number;
  (if unique_base_number>0 and unique_base_number<10 then 1
   elseif unique_base_number<100 then 2
   elseif unique_base_number<1000 then 3
   elseif unique_base_number<10000 then 4
   elseif unique_base_number<100000 then 5
   else pr('unique_words limit reached'); 1.nl;
        1 -> unique_base_number; 1
   endif) -> len_num;
  destword(wd) -> len_wd;
  applist(unpackitem(unique_base_number),nonop + (%48%));
  (len_wd+len_num).consword;
enddefine;

define commit_var_trans;
  if not(var_update_allowed) then 1.nl; 'Transaction not in progress'.pr
  else commit_vars();
    false -> var_update_allowed;
  endif
enddefine;

define abort_var_trans;
  if not(var_update_allowed) then 1.nl; 'Transaction not in progress'.pr
  else false -> var_update_allowed;
    comment set variables back to their values when the transaction started.
            done simply by setting trans_setvars to nil;
    [] -> trans_setvars;
  endif;
enddefine;

define alist_for_var_trans (); vars locval locres globval globres l trec n v;
  comment note that EVERY local is returned but only globals that alter value;
  nil -> locval; nil -> locres; nil -> globval; nil -> globres;
  if not(var_update_allowed) then 1.nl; 'Transaction not in progress'.pr
  else
    trans_setvars -> l;
    while l.ispair do
      l.dest -> l -> trec;
      new_var_value(trec) -> v; var_name(trec) -> n;
      if member(n,vars_locals) then
        if v/=undef then n::(v::locval) -> locval
        else n::(new_var_restrict(trec)::locres) -> locres
        endif;
      else
        if v/=undef then
          if old_var_value(trec)/= v then n::(v::globval) -> globval endif;
        else
          new_var_restrict(trec) -> v;
          if old_var_restrict(trec)/=v then n::(v::globres) -> globres endif;
        endif;
      endif;
    endwhile;
  endif;
  locval,locres,globval,globres
enddefine;
    
define alist_remove_locals (locals); vars trec;
  comment assumes that locals named are all real locals;
  [% (while trans_setvars.ispair do
        trans_setvars.dest -> trans_setvars -> trec;
        if not(member(var_name(trec),locals)) then trec endif;
      endwhile
     ) %] -> trans_setvars;
enddefine;

define alist_rename_locals (repairs); vars nam ren l done;
  comment repairs is a list of pairs of old (front) and new (back) names.
          old should be on locals list named at open. new should start with _ ;
  while locals.ispair do
    locals.dest -> repairs -> ren; front(ren) -> nam;
    if member(nam,vars_locals) then
      trans_setvars -> l; false -> done;
      while l.ispair and not(done) do
        if var_name(hd(l))=nam then back(ren) -> var_name(hd(l)) endif; 
        tl(l) -> l;
      endwhile; comment will always find the value - ie done is true;
      if not(done) then 
        1.nl; pr('illegal trans_setvars in alist_rename_locals');
      endif;
    else 1.nl; genpr(nam); pr(' is not a local - so cannot be renamed.');
    endif;
  endwhile;
enddefine;

define review_var_trans; vars l x trec nam; trans_setvars -> l;
  1.nl; 'In context '.pr; pr(ctxtnum(cuctxt)); '.  '.pr;
  if var_update_allowed then pr('Variable transaction in progress');
    if trans_setvars/=[] then pr(' - vars set are:');
      while l.ispair do 1.nl; tabs(1); l.dest -> l -> trec;
        var_name(trec) -> nam; genpr(nam); tabs(1);
        if member(nam,vars_locals) then pr(' local ') else pr(' global') endif;
        ' was = '.pr; trec.old_var_value.genpr; '/'.pr;
        trec.old_var_restrict.genpr;
        ' now = '.pr; trec.new_var_value.genpr; '/'.pr;
        trec.new_var_restrict.genpr;
      endwhile;
    else pr(' - no vars changes');
    endif;
  else pr('No var transaction in progress');
  endif;
  1.nl;
enddefine;

comment the following  would have advantage that ANY db changes would
        also be reflected in the transaction structure.

        open_var_trans     pushctxt()
        abort_var_trans    popctxt()
        commit_var_trans   nothing

        But leave in the note on var_update_allowed to ensure that
        such var transactions are not nested;

vars hbase_newctxt hbase_pushctxt hbase_popctxt hbase_prectxt hbase_succtxts;
newctxt -> hbase_newctxt; pushctxt -> hbase_pushctxt;
popctxt -> hbase_popctxt; prectxt -> hbase_prectxt; succtxts -> hbase_succtxts;

cancel prectxt newctxt succtxts pushctxt popctxt;
comment to ensure hbase self use works;

comment should not allow obase user to access globalctxt to ensure
        newctxt always gives an empty context not contaminated by
        values given in globalctxt;

hbase_newctxt(undef) -> cuctxt;

define getctxt () -> c;
  cuctxt -> c;
enddefine;

define putctxt (c);
  if c.isctxt then
    if var_update_allowed then
      1.nl; 'Variable transaction was in progress - it was aborted'.pr;
      abort_var_trans();
    endif;
    c -> cuctxt;
  else 1.nl; 'putctxt parameter is not a context - '.pr; c.genpr;
  endif;
enddefine;

define newctxt ();
  if var_update_allowed then
    1.nl; 'Variable transaction was in progress - it was aborted'.pr;
    abort_var_trans();
  endif;
  hbase_newctxt(globalctxt) -> cuctxt;
enddefine;

define pushctxt ();
  if var_update_allowed then
    1.nl; 'Variable transaction was in progress - it was aborted'.pr;
    abort_var_trans();
  endif;
  hbase_pushctxt();
enddefine;

define popctxt ();
  if hbase_prectxt(cuctxt)/=globalctxt and hbase_prectxt(cuctxt)/=undef then
    if var_update_allowed then
      1.nl; 'Variable transaction was in progress - it was aborted'.pr;
      abort_var_trans();
    endif;
    hbase_popctxt();
  else 1.nl; 'Cannot popctxt from a root context'.pr;
  endif;
enddefine;

define prectxt ();
  hbase_prectxt(cuctxt);
enddefine;

define succctxts ();
  hbase_succtxts(cuctxt);
enddefine;

define killctxt (c);
  if c=cuctxt then 1.nl; 'Cannot kill current context'.pr;
  else hbase_killctxt(c)
  endif;
enddefine;

endsection;

1.nl; 'Obase version - '.pr; ob_version.pr; 1.nl;

'@' -> genpr_item_prefix;
true -> genpr_full;

define testmatch (); vars alist p1 p2;
  until false do
    1.nl; pr('Give 1st pattern (end to stop)'); itread() -> p1;
    if p1="end" then return; endif;
    pr('Give 2nd pattern              '); itread() -> p2;
    pr('Matching '); genpr(p1); pr(' and '); genpr(p2);
    1.nl; pr('Result is '); genpr(match(p1,p2)); 1.nl;
  enduntil
enddefine;

define teststore (); vars p v;
  1.nl; pr('To Finish type end for pattern'); 1.nl;
  until false do
    1.nl; pr('Give pattern'); .itread -> p;
    if p="end" then return; endif;
    pr('Give value  '); .itread -> v;
    v -> value(p);
  enduntil
enddefine;

define testdb (); vars p v g res;
  1.nl; pr('To Finish type end for pattern'); 1.nl;
  until false do
    1.nl; pr('Give pattern spec'); .itread -> p;
    if p="end" then return; endif;
    pr('Give value   spec'); .itread -> v;
    find_all(p,v) -> g;
    while (get_next(g)->res; res/=termin) do
      1.nl; tabs(1); genpr(res); pr(' = '); genpr(value(res));
    endwhile; 1.nl;
  enduntil
enddefine;

define title ();
  sysobey('clear');
        'OBase - version '.pr; ob_version.pr;
  1.nl; '-----------------------------------------------------------------------'.pr;
  2.nl; 'Use teststore(); to set up a data base'.pr;
  1.nl; '    testdb();    to try data base retrievals or'.pr;
  1.nl; '    testmatch(); to try out matches'.pr;
  2.nl;
enddefine;
