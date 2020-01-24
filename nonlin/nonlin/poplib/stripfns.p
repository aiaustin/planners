comment  '[LIB STRIPFNS]
          updated for POP-2.10 RHR 2-7-79
          updated for PopLog,  4-Oct-83, A.Tate.
          Use {   ...   } instead of << ... >>
          and { % ... % } instead of </ ... />';
                  
section sec_stripfns => constrip listtostrip modstrip itread;
                                              
vars itread;
itemread->itread;

define modstrip s f -> s;
 vars n;
  s.datalength->n;
  while n>0 do
    f(subscrv(n,s))->subscrv(n,s);
    n-1->n
  endwhile
enddefine;

define constrip n -> s;
  initv(n)->s;
  while n>0 do ->subscrv(n,s); n-1->n endwhile
enddefine;

define listtostrip l;
 l.dl,l.length.constrip; comment 'dl stacks all top level elements of list';
enddefine;
 
endsection;

'[STRIPFNS] ready'.pr; 1.nl;
