;;;
;;; Simple block stacking domain for O-Plan.
;;;
;;; This is coded in a similar fashion to that handled by earlier planners
;;; (such as NOAH and NONLIN).  The schemas are not sufficiently general
;;; to generate all possible plans (due in particular to over constrained
;;; condition types - only_use_if being used when it is not appropriate
;;; for block stacking domains).
;;;
;;; Several schemas are provided and are intended for specified purposes.
;;; This differs from the simpler, less efficient, but correct
;;; blocks_1.tf block stacking domain description.
;;;
;;; BAT   5-Dec-76: Nonlin TF.
;;; KWC   9-Sep-85: Converted to O-Plan1 TF.
;;; RBK  27-Sep-91: Added object_types for defining type restrictions for
;;;                 variables.
;;; BD   12-May-92: Validated as adhering to O-Plan TF.
;;; RBK   2-Jul-92: Condition types corrected.
;;; BAT  28-Jul-92: Task schemas made regular.
;;; BAT  30-Apr-93: Comments added about only_use_if handling restrictions.
;;; BAT   8-Sep-93: only_use_if altered to only be on overall expansion.
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

;;;
;;; Objects in the world.
;;;

types objects = (a b c d e t1 t2 t3), 
      movable_objects = (a b c d e);

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

task stack_abcde;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {on a b} = true at 2,
             achieve {on b c} = true at 2,
	     achieve {on c d} = true at 2,
	     achieve {on d e} = true at 2;
  effects {on e d} at 1,
          {on d t1} at 1,
	  {on a t2} at 1,
	  {on b c} at 1,
	  {on c t3},
	  {cleartop e},
	  {cleartop a},
	  {cleartop b};
end_task;











