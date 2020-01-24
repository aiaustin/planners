comment 'Critical Path Method package for Nonlin.
         20-Feb-90: only change to 26-Oct-83 version is declaration of local
                    variable i in routine rcp.
         26-Oct-83: original version';

comment 'cpm cpmnewlink cpmchnet cpmrecomp efin prcpdata
         are declared and used in Nonlin';

comment 'cancel other variables to be used to prevent global name clashes';
cancel p s last change d chsuc ef earlf chpred lf latf next m marked;
vars   p s last change d chsuc ef earlf chpred lf latf next m marked;

comment 'DURATION, EARLY AND LATE FINISH TIMES ARE PACKED
         INTO THE NODECOST COMPONENT OF A NODE.  THIS
         WILL BE INITIALIZED BY THE SYSTEM TO THE DURATION.  SO UNLESS
         THESE ALGORITHMS HAVE BEEN RUN ON A NODE THE NODECOST COMPONENT
         WILL BE A NUMBER ONLY (THE DURATION).';

recordclass cpm dur efin lfin;
            comment 'also creates conscpm destcpm iscpm';

define ef x; efin(nodecost(node(x))) enddefine;
procedure x y; x -> efin(nodecost(node(y))) endprocedure -> updater(ef);
define lf x; lfin(nodecost(node(x))) enddefine;
procedure x y; x -> lfin(nodecost(node(y))) endprocedure -> updater(lf);
define d x; dur(nodecost(node(x))) enddefine;
procedure x y; x -> dur(nodecost(node(y))) endprocedure -> updater(d);

define m x; nodemark(node(x)) enddefine;
procedure x y; x -> nodemark(node(y)) endprocedure -> updater(m);

procedure; .node.prenodes endprocedure -> p;
procedure; .node.succnodes endprocedure -> s;

define chnet n t;
vars x;
  (t-d(n)) -> x;
  change(n,x);
enddefine;

define changesuccs n;
vars l x;
  chsuc(n,[])->l;
  while l.ispair then
    (l.dest)->l->x;
    chsuc(x,l)->l;
  endwhile;
enddefine;

define chsuc x l -> r;
vars sl y z;
  l->r;
  (x.s)->sl;
  if (sl.null) then return; endif;
  while sl.ispair then
    (sl.dest)->sl->y;
    y.earlf->z;
    if z/=ef(y) then
      z->ef(y);
      cons(y,r)->r;
    endif;
  endwhile;
enddefine;

define earlf y;
vars dmax l x;
  0->dmax;
  (y.p)->l;
  while l.ispair then
    (l.dest)->l->x;
    if ef(x)>dmax then ef(x)->dmax; endif;
  endwhile;
  (d(y))+dmax;
enddefine;

define changepreds n;
vars l x;
  chpred(n,[])->l;
  while (l.ispair) then
    (l.dest)->l->x;
    chpred(x,l)->l;
  endwhile;
enddefine;

define chpred x l -> r;
vars pl y;
  l->r;
  (x.p)->pl;
  while pl.ispair then
    (pl.dest)->pl->y;
    y.latf->z;
    if z/=lf(y) then
      z->lf(y);
      cons(y,r)->r;
    endif;
  endwhile;
enddefine;

define latf y;
vars dmin l x z;
  (last.ef)->dmin;
  (y.s)->l;
  while (l.ispair) then
    (l.dest)->l->x;
    if (lf(x)-d(x))<dmin then (lf(x)-d(x))->dmin; endif;
  endwhile;
  dmin;
enddefine;

define change n x;
vars time z duration ;
  (last.ef)->time;
  d(n)+x->d(n);
  ef(n)+x->ef(n);
  n.changesuccs;
  n.changepreds;
  (last.ef)->duration;
  duration-time->z;
  if z/=0 then
    for i from 1 by 1 to numnodes do (lf(i)+z)->lf(i); endfor;
  endif;
enddefine;

define newlink i j;
vars time duration z;
  (i.ef)+d(j)->z;
  (last.ef)->time;
  if z>ef(j) then
    z->ef(j);
    j.changesuccs;
  endif;
  lf(j)-d(j)->z;
  if z<lf(i) then
    z->lf(i);
    i.changepreds;
  endif;
  last.ef->duration;
  duration-time->z;
  if z/=0 then
    for i from 1 by 1 to numnodes do lf(i)+z->lf(i); endfor;
  endif;
enddefine;

define removelink i j;
vars x k z time duration;
  (last.ef)->time;
  if ef(j)>(ef(i)+d(j)) then goto label1;
  else j.earlf->x;
    if x=ef(j) then goto label1;
    else x->ef(j);
      j.changesuccs;
    endif;
  endif;
label1: if lf(i)<(lf(j)-d(j)) then goto label2;
        else i.latf->x;
          if x=lf(i) then goto label2;
          else x->lf(i);
            i.changepreds;
          endif;
        endif;
label2: last.ef->duration;
        duration-time->z;
        if z/=0 then
          for k from 1 by 1 to numnodes do z+lf(k)->lf(k); endfor;
        endif;
enddefine;

define rcp n start last;
vars x l i;
  for i from 1 by 1 to n do 0->m(i); endfor;
  cons(start,nil)->l;
  while l.ispair then
    l.dest->l->x;
    x.earlf->ef(x);
    1->m(x);
    next(x,l,s,p)->l;
  endwhile;
  for i from 1 by 1 to n do 0->m(i); endfor;
  cons(last,nil)->l;
  while l.ispair then
    l.dest->l->x;
    x.latf->lf(x);
    1->m(x);
    next(x,l,p,s)->l;
  endwhile;
enddefine;

define next x l s p;
vars y z;
  x.s->y;
  while y.ispair then
    y.dest->y->z;
    if ((z.p).marked) then cons(z,l)->l; endif;
  endwhile;
  l;
enddefine;

define marked x;
vars y;
  while x.ispair then
    x.dest->x->y;
    if y.m=0 then
      false;
      return;
    endif;
  endwhile;
  true;
enddefine;

define nodesin allnodes; vars n dmax;
  datalength(allnodes) -> dmax; 0 -> n;
  while n<dmax and subscrv(n+1,allnodes)/=undef then n+1 -> n endwhile;
  n
enddefine;

define cpm allnodes finish;
  appdata(allnodes,procedure x;
     if x/=undef then
       conscpm(nodecost(x),0,0) -> nodecost(x); endif
    endprocedure);
  rcp(nodesin(allnodes),1,finish);
enddefine;

define cpmrecomp oldn relocnum;
  vars parent es recomper;
  parentnode(node(oldn)) -> parent;
  efin(nodecost(parent))-dur(nodecost(parent)) -> es;
  lfin(nodecost(parent))-lf(oldn) -> recomper;

  ef(oldn)+es -> ef(oldn); lf(oldn)+recomper -> lf(oldn);
  while relocnum<numnodes then relocnum+1 -> relocnum;
    ef(relocnum)+es -> ef(relocnum); lf(relocnum)+recomper -> lf(relocnum)
  endwhile;
enddefine;

define cpmchnet; 2 -> last; .chnet enddefine;
define cpmnewlink; 2 -> last; .newlink enddefine;

comment '***************************************** input facilities ********';

define macro cost; vars patt num alist; comment 'replaces original cost macro';
  [%while ((.itread)->patt;(patt/=";" and patt/="end")) then
      .numberread -> num;
      applist(allfns,
        procedure x;
          appdata(opexpansion(x),
            procedure y;
              if dur(nodecost(y))/=0 then return endif;
              comment 'leave present value if an estimate given in a schema';
              copy1(varslist(x)) -> alist;
              if match(patt,pattern(y)) then num -> dur(nodecost(y)) endif
            endprocedure)
        endprocedure);
      patt,num
    endwhile%]<>costlist -> costlist;
enddefine;

comment '**************************************** output facilities ********';

define prcpdata;
  '   No. '.pr; tabs(1); 'dur  ef  lf'.pr; tabs(1); 'Pattern'.pr; 1.nl;
  appdata(allnodes,procedure x;
    if x/=undef then 1.nl;
      comment '** if on critical path';
      if efin(nodecost(x))=lfin(nodecost(x)) then '**  '.pr else 4.sp endif;
      pr(nodenum(x));
      tabs(1); sp(1); pr(dur(nodecost(x)));
      sp(3); pr(efin(nodecost(x)));
      sp(3); pr(lfin(nodecost(x)));
      tabs(1); genpr(pattern(x));
    endif; endprocedure);
    1.nl;
enddefine;

'Critical Path Method facilities available'.pr; 1.nl;

