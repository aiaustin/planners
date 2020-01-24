comment  '[LIB WPOP]
          created for PopLog,  26-Oct-83, A.Tate';
                 
section sec_wpop => stripfns samedata;
                    
define stripfns type size;
vars key;
  if size=0 then "full" -> size endif;
  conskey(type,size)->key;
  class_init(key);
  class_subscr(key);
enddefine;

define samedata x y;
  datakey(x)=datakey(y);
enddefine;

define islink l;
  ispair(l) and (not(isprocedure(l.back)) or l.front/=false)
enddefine;

comment 'halfpi, logand, logshift and jumpout definitions can also be got
         from the WonderPOP compile package by Dave Corner';

endsection;

'[WPOP] ready'.pr; 1.nl;
