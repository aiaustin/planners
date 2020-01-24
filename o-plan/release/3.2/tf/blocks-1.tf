;;; Single schema block stacking domain for O-Plan
;;;
;;; BAT   5-Jan-90: Initially created.
;;; BD   12-May-92: Validated as adhering to new TF syntax.
;;; BAT  27-Jul-92: Task schemas made regular.
;;; BAT  29-Mar-94: Comments added.
;;;

;;;
;;; give conditions and effects at same end of a node so they are instantaneous
;;;

defaults condition_node_end = begin_of,
         condition_contributor_node_end = begin_of,
         effect_node_end = begin_of;

;;;
;;; Always defines statements which can never be refuted by action effects
;;;

always {cleartop table};

;;;
;;; Objects in the world.
;;;

types objects = (a b c table), 
      movable_objects = (a b c);

;;;
;;; The single schema can be used in many ways
;;; This differs from the tailored schemas which can only be used
;;; in defined ways in the blocks_2.tf domain
;;;

schema puton;
  vars ?x = ?{type movable_objects}, 
       ?y = ?{type objects}, 
       ?z = ?{type objects};
  vars_relations ?x /= ?y, ?y /= ?z, ?x /= ?z;
  expands {puton ?x ?y};                        ;;; the actual action name
  only_use_for_effects
              {on ?x ?y}    = true,                                   
              {cleartop ?y} = false,            ;;; satisfy conditions in plan
              {on ?x ?z}    = false,
              {cleartop ?z} = true;
  conditions  only_use_for_query {on ?x ?z},    ;;; used to bind one or
                                                ;;; more free variables
              achieve {cleartop ?x},            ;;; conditions have value true
              achieve {cleartop ?y};            
end_schema;

;;;
;;; The above schema is intended to be a reasonable definition for many tasks.
;;; Note that the only_use_for_query condition type places a restriction on
;;; the ways in which the schema can be used.  This certainly limits the
;;; plans that can be generated.  To allow for any possible plan to be
;;; generated, including ones with redundant actions, it is necessary to
;;; employ the most general condition type, achieve.  Such a replacement will
;;; allow for very large search spaces in which plans for many problems may
;;; not be found in any reasonable time.
;;;

;;; Problem 1 - the Sussman Anomaly
;;;                                            +---+
;;;                                            | A |
;;;      +---+                                 +---+
;;;      | C |              --------->         | B |     
;;;      +---+  +---+                          +---+
;;;      | A |  | B |                          | C |
;;; -----+---+--+---+-----                -----+---+-----
;;;         TABLE

task stack_abc;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {on a b} at 2,
             achieve {on b c} at 2;
  effects {on c a} at 1,
          {on a table} at 1,
          {on b table} at 1,
          {cleartop c} at 1,
          {cleartop b} at 1;
end_task;

;;; Problem 2
;;;                                            +---+
;;;                                            | A |
;;;      +---+                                 +---+
;;;      | A |              --------->         | B |     
;;;      +---+  +---+                          +---+
;;;      | B |  | C |                          | C |
;;; -----+---+--+---+-----                -----+---+-----
;;;         TABLE
;;;
;;; This task performs poorly with a search alternatives selector
;;; which is beadth orientated.  Try a depth orientated selector
;;; by using the DM Developer's Menu Break-in option and typing in
;;; the following evaluation function (see O-Plan Demonstration Guide):
;;;        (defun atm-alt-rating-fn (alt) 100 )

task stack_abc_2;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {on a b} = true at 2,
             achieve {on b c} = true at 2;
  effects {on a b} at 1,
          {on c table} at 1,
          {on b table} at 1,
          {cleartop c} at 1,
          {cleartop a} at 1;
end_task;

;;; Problem 3
;;;                                            +---+
;;;                                            | C |
;;;      +---+                                 +---+
;;;      | C |              --------->         | B |     
;;;      +---+  +---+                          +---+
;;;      | A |  | B |                          | A |
;;; -----+---+--+---+-----                -----+---+-----
;;;         TABLE

task stack_cba;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {on c b} = true at 2,
             achieve {on b a} = true at 2;
  effects {on c a} at 1,
          {on a table} at 1,
          {on b table} at 1,
          {cleartop c} at 1,
          {cleartop b} at 1;
end_task;

;;; Problem 4
;;;                                            +---+
;;;                                            | B |
;;;      +---+                                 +---+
;;;      | C |              --------->         | A |     
;;;      +---+  +---+                          +---+
;;;      | A |  | B |                          | C |
;;; -----+---+--+---+-----                -----+---+-----
;;;         TABLE

task stack_bac;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {on b a} = true at 2,
             achieve {on a c} = true at 2;
  effects {on c a} at 1,
          {on a table} at 1,
          {on b table} at 1,
          {cleartop c} at 1,
          {cleartop b} at 1;
end_task;

