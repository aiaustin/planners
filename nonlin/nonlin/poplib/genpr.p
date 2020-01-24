comment [lib genpr], 24-Aug-84
        updated 8-7-76, converted to WonderPOP 29-5-79
        updated to PopLog  7-Oct-83, A.Tate
        corrected for going too deep 11-Oct-84, A.Tate
        hash table lookup of printer added 3-Apr-85, A.Tate;
        
section sec_genpr => genpr genpraux genprsequence genpruserproc
                     genpr_printer
                     genprdepth genprlength;

vars genpr_printer;

constant genpr_printer_table_size; 20 -> genpr_printer_table_size;
newproperty([], genpr_printer_table_size, false, true) -> genpr_printer;
;;; no initial associations, default value of false and permanent storage

vars genprdepth genprlength currdepth;
vars genpraux;  comment 'genpraux is forward declared';

10->genprdepth; 10->genprlength;
genprdepth->currdepth; comment 'in case genpraux or genprsequence used alone';

define genpruserproc x; vars p;
  genpr_printer(dataword(x)) -> p;
  if p.isprocedure then p(x); true else false endif;
enddefine;

define genpr x; vars genpr; genpraux -> genpr; comment 'for recursive calls';
  genprdepth->currdepth;
  genpraux(x);
enddefine;

define genprsequence x; vars i;
  0 -> i;   ;;; used to recognise first of a sequence i=0
            ;;; and when to stop (and print ...) i>genprlength;
  appdata(x,procedure x;
              ;;; do nothing if i>genprlength
              if i=genprlength then ' ...'.syspr
              elseif i<genprlength then
                if i/=0 then 1.sp; endif;
                genpraux(x);
              endif;
              i+1 -> i;
            endprocedure);
enddefine;

define genpraux x;
vars l dep first;
  currdepth-1->currdepth;  comment 'currdepth is set in the caller';
  if currdepth<1 then
    if x.isword or x.isword or x.isboolean or x.isprocedure or
       x.isstring or x=termin then syspr(x)
    else "<".syspr; syspr(dataword(x)); ">".syspr;
    endif
  elseif (currdepth->dep; genpruserproc(x); dep -> currdepth) then
    comment 'was printed within user proc - dep reset so user protected';
  elseif x.isword or x.isnumber or x.isprocedure or x.isstring or x=termin then
    x.syspr
  elseif x.isboolean then
    if x then '<true>'.syspr else '<false>'.syspr endif
  elseif x=nil then '[]'.syspr
  elseif x.isvector then
    "{".syspr; genprsequence(x); "}".syspr
  elseif x.ispair then
    "[".syspr; genprlength->l;
     true->first;
     loop: if first then false->first
           else 1.sp
           endif;
           x.front.genpraux;
           x.back->x; l-1->l;
           if x.atom.not then
             if l>0 then goto loop
             else ' ...'.syspr
             endif
           elseif x/=nil then
             '|'.syspr; x.genpraux
           endif;
    "]".syspr
  else
    "<".syspr; x.dataword.genpraux;
    if x.isundef then 1.sp; genpraux(undefword(x))
    else 1.sp; genprsequence(x)
    endif;
    ">".syspr
  endif;
  currdepth+1->currdepth
enddefine;

endsection;

'[GENPR] ready'.pr; 1.nl;
