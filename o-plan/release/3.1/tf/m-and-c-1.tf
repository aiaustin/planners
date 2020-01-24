;;; Missionaries and cannibals
;;;
;;; JD    10-Feb-94: Initial version
;;; JD:   13-Jul-94: use {x plus y is z} and {tried ?? ...} forms
;;; Updated: Thu Feb 23 10:07:47 1995
;;;
;;; A state has the form {boat_bank m_left c_left m_right c_right}.
;;;
;;; Presumably we could omit the counts for one side, since they're
;;; implicit in the counts for the other.

types number = (n_0 n_1 n_2 n_3);

always 

       ;;; Arithmetic

       {n_1 plus n_0 is n_1},
       {n_1 plus n_1 is n_2},
       {n_1 plus n_2 is n_3},

       {n_2 plus n_0 is n_2},
       {n_2 plus n_1 is n_3},

       ;;; Safety of (m,c): similar to >=, except for m = 0.
       ;;; However, some of these are actually unsafe, since
       ;;; they imply an unsafe situation on the opposite bank.
       ;;; This is ok though, because we check both banks.

       {safe n_3 n_0}, {safe n_3 n_1}, {safe n_3 n_2}, {safe n_3 n_3},
       {safe n_2 n_0}, {safe n_2 n_1}, {safe n_2 n_2},
       {safe n_1 n_0}, {safe n_1 n_1},
       {safe n_0 n_0}, {safe n_0 n_1}, {safe n_0 n_2}, {safe n_0 n_3};


;;; Tasks

task mc_problem;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {state} = {right n_0 n_0 n_3 n_3} at 2;
  effects {state} = {left n_3 n_3 n_0 n_0} at 1,
          {tried ?? ?? ?? ?? ??} = false at 1;
end_task;

 
;;; Schemas that move people to left to right

schema move_2_missionaries_right;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_mr = ?{type number};
  expands {move 2 m r};
  only_use_for_effects {state} = {right ?new_ml ?cl ?new_mr ?cr};
  ;;; want {left ?new_ml+2 ?cl ?new_mr-2 ?cr}
  ;;; hence ?ml = ?new_ml + 2,
  ;;;       ?mr = ?new_mr - 2
  conditions only_use_if {n_2 plus ?new_ml is ?ml},
             only_use_if {n_2 plus ?mr is ?new_mr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried left ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {left ?ml ?cl ?mr ?cr};
  effects {tried left ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_2_cannibals_right;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_cl = ?{type number},
       ?new_cr = ?{type number};
  expands {move 2 c r};
  only_use_for_effects {state} = {right ?ml ?new_cl ?mr ?new_cr};
  conditions only_use_if {n_2 plus ?new_cl is ?cl},
             only_use_if {n_2 plus ?cr is ?new_cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried left ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {left ?ml ?cl ?mr ?cr};
  effects {tried left ?ml ?cl ?mr ?cr} = true;
end_schema;


schema move_1_missionary_right;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_mr = ?{type number};
  expands {move 1 m r};
  only_use_for_effects {state} = {right ?new_ml ?cl ?new_mr ?cr};
  ;;; want {left ?new_ml+1 ?cl ?new_mr-1 ?cr}
  ;;; hence ?ml = ?new_ml + 1,
  ;;;       ?mr = ?new_mr - 1
  conditions only_use_if {n_1 plus ?new_ml is ?ml},
             only_use_if {n_1 plus ?mr is ?new_mr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried left ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {left ?ml ?cl ?mr ?cr};
  effects {tried left ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_1_cannibal_right;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_cl = ?{type number},
       ?new_cr = ?{type number};
  expands {move 1 c r};
  only_use_for_effects {state} = {right ?ml ?new_cl ?mr ?new_cr};
  conditions only_use_if {n_1 plus ?new_cl is ?cl},
             only_use_if {n_1 plus ?cr is ?new_cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried left ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {left ?ml ?cl ?mr ?cr};
  effects {tried left ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_1_of_each_right;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_cl = ?{type number},
       ?new_mr = ?{type number},
       ?new_cr = ?{type number};
  expands {move 1 m 1 c r};
  only_use_for_effects {state} = {right ?new_ml ?new_cl ?new_mr ?new_cr};
  conditions only_use_if {n_1 plus ?new_ml is ?ml},
             only_use_if {n_1 plus ?new_cl is ?cl},
             only_use_if {n_1 plus ?mr is ?new_mr},
             only_use_if {n_1 plus ?cr is ?new_cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried left ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {left ?ml ?cl ?mr ?cr};
  effects {tried left ?ml ?cl ?mr ?cr} = true;
end_schema;


;;; Schemas that move people right to left

schema move_1_missionary_left;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_mr = ?{type number};
  expands {move 1 m l};
  only_use_for_effects {state} = {left ?new_ml ?cl ?new_mr ?cr};
  ;;; want {right ?new_ml-1 ?cl ?new_mr+1 ?cr}
  ;;; hence ?ml = ?new_ml - 1,
  ;;;       ?mr = ?new_mr + 1
  conditions only_use_if {n_1 plus ?ml is ?new_ml},
             only_use_if {n_1 plus ?new_mr is ?mr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried right ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {right ?ml ?cl ?mr ?cr};
  effects {tried right ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_1_cannibal_left;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_cl = ?{type number},
       ?new_cr = ?{type number};
  expands {move 1 c l};
  only_use_for_effects {state} = {left ?ml ?new_cl ?mr ?new_cr};
  conditions only_use_if {n_1 plus ?cl is ?new_cl},
             only_use_if {n_1 plus ?new_cr is ?cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried right ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {right ?ml ?cl ?mr ?cr};
  effects {tried right ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_1_of_each_left;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_cl = ?{type number},
       ?new_mr = ?{type number},
       ?new_cr = ?{type number};
  expands {move 1 m 1 c l};
  only_use_for_effects {state} = {left ?new_ml ?new_cl ?new_mr ?new_cr};
  conditions only_use_if {n_1 plus ?ml is ?new_ml},
             only_use_if {n_1 plus ?cl is ?new_cl},
             only_use_if {n_1 plus ?new_mr is ?mr},
             only_use_if {n_1 plus ?new_cr is ?cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried right ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {right ?ml ?cl ?mr ?cr};
  effects {tried right ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_2_missionaries_left;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_ml = ?{type number},
       ?new_mr = ?{type number};
  expands {move 2 m l};
  only_use_for_effects {state} = {left ?new_ml ?cl ?new_mr ?cr};
  conditions only_use_if {n_2 plus ?ml is ?new_ml},
             only_use_if {n_2 plus ?new_mr is ?mr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried right ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {right ?ml ?cl ?mr ?cr};
  effects {tried right ?ml ?cl ?mr ?cr} = true;
end_schema;

schema move_2_cannibals_left;
  vars ?ml = ?{type number},
       ?cl = ?{type number},
       ?mr = ?{type number},
       ?cr = ?{type number},
       ?new_cl = ?{type number},
       ?new_cr = ?{type number};
  expands {move 2 c l};
  only_use_for_effects {state} = {left ?ml ?new_cl ?mr ?new_cr};
  conditions only_use_if {n_2 plus ?cl is ?new_cl},
             only_use_if {n_2 plus ?new_cr is ?cr},
             only_use_if {safe ?ml ?cl},
             only_use_if {safe ?mr ?cr},
             only_use_if {tried right ?ml ?cl ?mr ?cr} = false,
             achieve {state} = {right ?ml ?cl ?mr ?cr};
  effects {tried right ?ml ?cl ?mr ?cr} = true;
end_schema;
