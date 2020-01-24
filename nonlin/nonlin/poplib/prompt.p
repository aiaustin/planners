comment '[PROMPT]
         Austin Tate, 12-Jan-84';

section sec_prompt => prompt matchresponse uppercase ord char;

define ord x -> i; comment 'get character code of 1st item in x';
  if isword(x) then subscrw(1,x) -> i
  elseif isstring(x) then subscrs(1,x) -> i
  else comment 'return large negative number as failure';
       -2e9 -> i
  endif;
enddefine;

define char i -> ch;
  if i>=0 and i<=255 then consword(i,1) -> ch
  else comment 'NUL on error'; consword(0,1) -> ch
  endif;
enddefine;

define uppercase ch1 -> ch2;
  if islowercode(ch1) then (ch1-ord('a'))+ord('A') -> ch2 else ch1 -> ch2 endif;
enddefine;

define charset l fn;
  maplist(l, procedure x;
               if isword(x) then subscrw(1,x)
               elseif isstring(x) then subscrs(1,x)
               elseif isinteger(x) then
                 if x<10 then x+ord('0') else x endif;
               else comment 'remove from list';
               endif;
             endprocedure pdcomp fn);
enddefine;

comment 'e.g. [A a b C %' ', char(8)% 1 2 3 13   27  ] with fn=uppercase
         gives A   B C <sp>  <bs>     1 2 3 <cr> <esc> ';

define matchresponse l fn -> ch; comment 'fn is uppercase or identfn normally';
  sysflush(popdevout);
  charset(l,fn) -> l;
  fn(rawcharin()) -> ch;
  while not(member(ch,l)) do fn(rawcharin()) -> ch endwhile;
enddefine;

define prompt p cset -> ch;
  p.pr;
  matchresponse(cset,uppercase) -> ch;
  if ch>31 then pr(char(ch)) endif;
  1.nl;
enddefine;

endsection;

'[PROMPT] ready'.pr; 1.nl;
