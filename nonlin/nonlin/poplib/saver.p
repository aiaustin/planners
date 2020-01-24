comment '[SAVER]
         20-Oct-83, Austin Tate';

define macro saver;

define islink l;
  ispair(l) and (not(isprocedure(l.back)) or l.front/=false)
enddefine;

define stringread -> s;
vars x i l num;
  requestline('') -> l;
  comment 'leave character codes of each word on stack.  Remove length';
  [% while l.islink do l.dest -> l; .destword.erase; endwhile %] -> l;
  0 -> num;
  while (l.islink) do
    l.dest -> l -> x;
    comment 'ignore spaces';
    if x/=32 then num+1 -> num; x endif;
  endwhile;
  if num>0 then -> x;
    if x/=59 then x else num-1 -> num; endif;
    comment 'ignore trailing semi-colon';
  endif;
  inits(num) -> s;
  for i from num by -1 to 1 do -> subscrs(i,s); endfor;
enddefine;

vars x oldcucharout;
stringread() -> x;
1.nl; pr('saving as '); pr(x);
1.nl;

if syssave(x) then comment 'true on stack after a startup with a saved image';
  cucharout -> oldcucharout; erase -> cucharout;
  comment 'see if any title procedure to call';
  if title.isundef then popval([%"cancel","title",";"%])
  elseif title.isprocedure then oldcucharout -> cucharout; title()
  endif;
  oldcucharout -> cucharout;
else sysexit();
endif;

enddefine;

