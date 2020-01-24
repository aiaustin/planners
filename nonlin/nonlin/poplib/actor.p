comment '[ACTOR]
         INSERTED 16/1/75, RR
         Converted to PopLog - 26-Oct-83, A.Tate
         needs WPOP for stripfns and samedata
         needs STRIPFNS for itread';

vars subact initact isactor unlist;

stripfns("actor","full")->subact->initact;

samedata(%initact(0)%)->isactor;

define consact n -> s;
  initact(n)->s;
  while n>0 do ->subact(n,s); n-1->n endwhile;
enddefine;

define listtoact l;
  l.dl,l.length.consact
enddefine;

define applyact s;
 vars i n;
 while (s.isword) or (s.isactor) do
   if s.isword then s.valof->s;  comment 'dereference';
   elseif s.isactor then
     s.datalength->n; 2->i;
     while i<=n do subact(i,s); i+1->i endwhile;
     subact(1,s)->s
   endif;
 endwhile;
 .s
enddefine;

define instact s;
  "===",s.applyact
enddefine;

define macro <: ;
  vars x n;
  0->n;
  while(.itread->x; x/=":>") do x; n+1->n endwhile;
  n.consact;
enddefine;

vars macro ( <|  |> );

[% "[","%" %] -> nonmac <|;

[% "%","]",".","listtoact" %] -> nonmac |>;

define eval;
 .applyact.match
enddefine;

define has t s v;
  v,t,s.applyact.match
enddefine;

define getval s x;
  if s="===" then x.valof
  else match(s,x.valof) endif
enddefine;

define setval s x;
 if s.isactor then s.instact->s endif;
 s->valof(x);
 true
enddefine;

define non;
  .match.not
enddefine;

define et s x y;
  (match(s,x) and match(s,y))
enddefine;

define vel s x y;
  (match(s,x) or match(s,y))
enddefine;

define allof t l;
loop: if l.null then true
      elseif match(t,l.hd) then l.tl->l; goto loop
      else false endif;
enddefine;

define oneof t l;
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

define macro @@; <| "getval", .itread |> enddefine;

define macro @>; <| "setval", .itread |> enddefine;

'[ACTOR] ready.'.pr; 1.nl;
