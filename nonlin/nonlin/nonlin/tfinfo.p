comment ' 1-Dec-2002:added showfile menu option '0'.
          20-Feb-90:added print to file tfin.lsp in current directory of
          result network when draw_flag is set true.
          This file is in format for input to AUTOCAD using
          AIAI AUTOCAD/AI Planner interface package.
          New procedure calculate_level added to compute
          out the maximum depth of any node in the
          network.  Brian Drabble.
          Also added print using user provided routine domain_effect_pr
          to file tfin.lsp for simulation (context at node) when context_flag
          is true.
          20-Jun-85: initial version, Austin Tate
          (c) Copyright 1985,1990 AIAI, University of Edinburgh';

define pr_one_gost(x); vars v;
  tabs(1);
  genpr(itemid(x));
  value(x) -> v;
  if length(v)=1 then pr(' from only ')
  else pr(' from any of '); endif;
  genpr(value(x)); 1.nl;
enddefine;

define what_for_n(n);
  vars cuctxt;
  gost -> cuctxt;
  1.nl; pr('Statements that must hold for activity ');
  pr(n); pr(' to be executed.'); 1.nl;
  appitems({=== === === %n%},===,pr_one_gost);
enddefine;
             
define why_n(n);
  vars cuctxt;
  gost -> cuctxt;
  1.nl; pr('Statements that activity ');
  pr(n); pr(' achieves for others.'); 1.nl;
  appitems({=== === === ===},<| "contains", n |>,pr_one_gost);
enddefine;

;;; autocad file creation

define calculate_level(entry) -> retval;
  ;;;
  ;;; this procedure calculates the longest path to a single node
  ;;;
      vars level_count testflag entry2 nodelist seenlist addition;
      vars active_list centry2 centry plist;
      0 -> level_count;
      0 -> testflag;
      [^entry] -> nodelist;
      [] -> seenlist;
      1 -> addition;
      until testflag = 1 do
         if addition = 0 then
            1 -> testflag;
         else
            ;;;
            ;;; add sucessors at this level
            ;;;
                level_count + 1 -> level_count;
                0 -> addition;
                [] -> active_list;
                for centry2 in nodelist do
                    node(centry2) -> centry;
                    if prenodes(centry) /= [] then
                       for entry2 in prenodes(centry) do
                           if entry2 /= 1 then
                              [^^active_list ^entry2] -> active_list;
                              1 -> addition;
                           endif;
                       endfor;
                    endif;
                endfor;
                for entry2 in nodelist do
                    if not(member(entry2,seenlist)) then
                       entry2 :: seenlist -> seenlist;
                    endif;
                endfor;
                [] -> nodelist;
                if active_list /= [] then
                   for entry2 in active_list do
                       if not(member(entry2, nodelist)) then
                          entry2 :: nodelist -> nodelist
                       endif;
                   endfor;
                   [] -> active_list;
                endif;
        endif;
      enduntil;
  ;;;
  ;;; return the value
  ;;;
      if entry /= 1 then
         level_count + 1 -> level_count;
      endif;
      entry -> centry;
      node(entry) -> entry;
      succnodes(entry) -> plist;
      [^centry ^level_count ^plist] -> retval;
  ;;;
  ;;; end of the procedure
  ;;;
enddefine;

vars draw_flag; false -> draw_flag;
vars draw_filename; 'tfin.lsp' -> draw_filename;

define drawnet();
  ;;;
  ;;; this procedure first identifies the level of each node in the network
  ;;;
      vars worklist mpoint maxdepth
           sorted_list ilist index_list mpoint2 maxwidth counter_list
           depthcounter pointslist singlewidth yvalue xvalue maxlength
           lineout nodeval centry slist noderec ntype offset 
           xval yval xval2 yval2 nodelist seenlist addition active_list 
           centry2 plist;
      vars oldcucharout sthing;
      vars clist,testflag,depthlist,level_count,entry,entry2;
      vars nheight,nwidth,dwidth;

      false -> pop_pr_ratios;
      100 -> nwidth;
      30 -> nheight;
      20 -> dwidth;
  ;;;
  ;;; add the plan head to the list and start off the iteration
  ;;; 
      [] -> worklist;
      for entry from 1 to numnodes do
         calculate_level(entry) -> retval;
         retval :: worklist -> worklist;
      endfor;
  ;;;
  ;;; we now have the results of the search, calculate the maximum
  ;;; width at any depth
  ;;; 
      length(worklist) -> mpoint;
      worklist(mpoint-1)(2) -> maxdepth;
      syssort(worklist, procedure x y; if x(2) < y(2) then true else
      false endif endprocedure) -> sorted_list; 

      [] -> ilist;
      for x from 1 to maxdepth do
         0 :: ilist -> ilist;
      endfor;

      for entry in sorted_list do
          ilist(entry(2)) + 1 -> ilist(entry(2));
      endfor;
      syssort(ilist, procedure x y; if x < y then true else
      false endif endprocedure) -> index_list; 
  ;;;
  ;;; calculate the maximum width of the drawing area
  ;;;
      length(index_list) -> mpoint2;
      index_list(mpoint2) -> maxwidth;
      maxwidth * 200 -> maxwidth;
      length(index_list) * 150 -> maxlength;
  ;;;
  ;;; iterate round at each level and print the boxes
  ;;;
      sysdelete(draw_filename) -> retval;
      syscreate(draw_filename,2,false) -> retval;
      cucharout -> oldcucharout;
      discout(draw_filename) -> cucharout; 
      pr('(defun C:TFIN ()');
      nl(1);
      '(command "LIMITS" "0,0" "' >< maxlength >< ',' >< maxwidth >< '") (command "ZOOM" "ALL") ' -> lineout;
      lineout.pr;
      nl(1);
      [] -> counter_list;
      for entry from 1 to length(index_list) do
          [] :: counter_list -> counter_list;
      endfor;   
      for entry in sorted_list do
          entry(1) :: counter_list(entry(2)) -> counter_list(entry(2))
      endfor;
      
      0 -> depthcounter;
      [] -> pointslist;
      for entry in counter_list do
          depthcounter + 1 -> depthcounter;
          maxwidth / ilist(depthcounter) -> singlewidth;
          for entry2 from 1 to length(entry) do
              ((entry2 -1) * singlewidth) + (singlewidth /2) -> yvalue;
              (intof((yvalue /10) + 0.5)) * 10 -> yvalue;
              (depthcounter -1) * 150  -> xvalue;
              '(command "INSERT"'.pr;
              entry(entry2) -> nodeval;
              node(nodeval)-> centry;
              if nodetype(centry) = "action" or
                 nodetype(centry) = "phantom" or
                 nodetype(centry) = "goal" then
                 ' "NODE" "' >< xvalue >< ',' >< yvalue >< '" 1 1 0 "'
                             ><nodeval><': '><nodetype(centry)><'" "'
                                                               -> lineout;
                 lineout.pr;
                 genpr(pattern(centry));
                 '")'.pr;
              elseif nodetype(centry) matches "dummy" or
                     nodetype(centry) = "planhead"  then
                 ' "DUMMY" "' >< xvalue >< ',' >< yvalue >< '" 1 1 0 )'
                                                               -> lineout;
                 lineout.pr;
              endif;
              nl(1);
              ;;;
              ;;; store values for future reference
              ;;;
                  [^nodeval ^xvalue ^yvalue] :: pointslist -> pointslist;
          endfor;
          
      endfor;
  ;;;
  ;;; now print all the connected lines
  ;;;
      for entry in sorted_list do
          entry(3) -> slist;
          entry(1) -> nodeval;
          node(nodeval) -> noderec;
          nodetype(noderec) -> ntype;
          if ntype = "action"  or ntype = "phantom" or ntype = "goal" then
             100 -> offset;
          else
             20 -> offset;
          endif;
          pointslist matches [ == [^nodeval ?xval ?yval] == ] -> sthing;
          xval + offset -> xval;
          for entry2 in slist do
              pointslist matches [== [^entry2 ?xval2 ?yval2] == ] -> sthing;
              '(command "LINE" "' >< xval >< ',' >< yval >< '" "' >< xval2 >< ',' >< yval2 >< '") (command "")' -> lineout;
              lineout.pr;
              nl(1);
          endfor;
      endfor;
  ;;;
  ;;; send end of data items and reset the output channels
  ;;;	
      '(princ)'.pr; 1.nl; ')'.pr; 1.nl;
      
      cucharout(termin);
      oldcucharout -> cucharout;   
  ;;;
  ;;; end of procedure
  ;;;
enddefine;

vars context_flag context_filename domain_effect_pr;
false -> context_flag; 'tfin.lsp' -> context_filename;

comment 'domain_effect_pr can be replaced by user';

define domain_effect_pr p v;
  genpr(p); 1.sp; genpr(v); 1.nl;
enddefine;

define state_at_node i; vars retval oldcucharout;
  prnode(i); 1.nl;
  prnodectxt(i);
  why_n(i);
  what_for_n(i);

  if context_flag then
    sysdelete(context_filename) -> retval;
    syscreate(context_filename,2,false) -> retval;
    cucharout -> oldcucharout;
    discout(context_filename) -> cucharout;

    pr('(defun C:TFIN ()');
    1.nl;
    if i.isinteger then node(i) -> i; endif;
    applist(qaall(===,true,i), procedure x; if x.ispair then return endif;
            domain_effect_pr(x,true); endprocedure);
    applist(qaall(===,false,i), procedure x; if x.ispair then return endif;
            domain_effect_pr(x,false); endprocedure);
    '(command "redrawall") (princ)'.pr; 1.nl; ')'.pr; 1.nl;

    cucharout(termin);
    oldcucharout -> cucharout;
  endif;
            
enddefine;
             
define macro tfinfo; vars ch i;
  0 -> ch;
  while ch/=32 do
    clearscreen();
    'Nonlin TF WorkStation Interface - Do you want:-'.pr;
    1.nl; 1.tabs; '0  Show Help Text'.pr;
    1.nl; 1.tabs; '1  Put New TF File'.pr;
    1.nl; 1.tabs; '2  Put Goal Schema'.pr;
    1.nl; 1.tabs; '3  Get Result Network'.pr;
    1.nl; 1.tabs; '4  Get Actions Only Result Network'.pr;
    1.nl; 1.tabs; '5  Get Critical Path Data'.pr;
    1.nl; 1.tabs; '6  Goal Structure - Conditions'.pr;
    1.nl; 1.tabs; '7  Table of Multiple Effects - Effects'.pr;
    1.nl; 1.tabs; '8  Initial Context entries used in plan - Usewhens'.pr;
    1.nl; 1.tabs; '9  Context at a particular node - Simulation'.pr;
    1.nl;
    prompt('Type 0 to 9, <space> for none:',
           [0 1 2 3 4 5 6 7 8 9 %char(32)%]) -> ch;
    if ch/=32 then clearscreen(); endif;
    if     ch=ord('0') then showfile(nonlinprefix><'nonlintxt'><nonlinpostfix);
    elseif ch=ord('1') then 'Give a TF File name: '.pr; apply(nonmac tf)
    elseif ch=ord('2') then 'Give a "plan" statement...'.pr; setpop()
    elseif ch=ord('3') then prnet();
    elseif ch=ord('4') then prreducenet(allnodes,numnodes)
    elseif ch=ord('5') then prcpdata()
    elseif ch=ord('6') then prgost()
    elseif ch=ord('7') then prtome()
    elseif ch=ord('8') then prnodectxt(1)
    elseif ch=ord('9') then
      'Print context at which node (1 to '.pr; numnodes.pr;
      ', end with <return>)'.pr;
      while (.itemread -> i; not(i.isnumber and i>0 and i<=numnodes)) do
      endwhile;
      state_at_node(i);
    endif;
    if ch/=32 then 1.nl;
      prompt('Type <space> to continue:',[%char(32)%]).erase;
    endif;
  endwhile;
enddefine;

nonmac tfinfo -> nonmac prinfo;
