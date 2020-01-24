comment time a routine
        Austin Tate   AIAI, Edinburgh   20-Dec-84;

section sec_time => time untime sum_time time_trace;

vars indent time_trace; 0 -> indent; true -> time_trace;

;;; set time trace true to get a time printed on each call, set false otherwise
;;; get totals since the the last time macro call with sum_time

define timer fn name sum;
  vars init_time diff_time;
  indent+2 -> indent;
  systime() -> init_time;
  .fn;
  (systime()-init_time)/100 -> diff_time;
  indent-2 -> indent;
  if time_trace then
    1.nl; sp(indent); pr('Time for ');
    pr(name); pr (' = '); pr(diff_time);
    pr(' secs.');
  endif;
  frozval(3,valof(name))+diff_time -> frozval(3,valof(name));
enddefine;

define macro time; vars fn_name fn;
  while (.itemread -> fn_name; fn_name/=";") do
    1.nl; pr('Timing '); pr(fn_name);
    timer(%fn_name.valof,fn_name,0%) -> valof(fn_name);
  endwhile;
  1.nl;
enddefine;

define macro untime; vars fn_name fn;
  while (.itemread -> fn_name; fn_name/=";") do
    1.nl; pr('Untiming '); pr(fn_name);
    frozval(1,valof(fn_name)) -> valof(fn_name);
  endwhile;
  1.nl;
enddefine;

define macro sum_time; vars fn_name fn;
  while (.itemread -> fn_name; fn_name/=";") do
    1.nl; pr('Sum of times for '); pr(fn_name);
    pr(' = '); pr(frozval(3,valof(fn_name)));
  endwhile;
  1.nl;
enddefine;

endsection;
