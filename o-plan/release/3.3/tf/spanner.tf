;;; File: spanner.tf
;;; Purpose: demonstration of need to have an achieve condition span
;;;          outside of schema which introduces it for some solutions.
;;; Created:  Austin Tate 18-Mar-93
;;; Modified: Austin Tate 19-Mar-93
;;;           Austin Tate 10-Aug-93: a comment deleted
;;;           Austin Tate  9-Feb-95: achieve_after_point altered
;;;                                  from begin_of start to end_of start

;;; world model:
;;;       {setup_1} = done (or undef)
;;;       {setup_2} = done (or undef)
;;;       {assembly} = done (or undef)
;;;       {status clean_room} = clean or dirty
;;; Once the clean_room is dirty, there is no action to allow it to be cleaned

;;;
;;; give conditions and effects at same end of a node so they are instantaneous
;;;

defaults condition_node_end = begin_of,
         condition_contributor_node_end = begin_of,
         effect_node_end = begin_of;

;;;      achieve_after_point = end_of start


;;; note if schema setup_1_a is not available, and there is no means to
;;; clean up the clean_room (schema do_cleanup is not available), then unless
;;; the default above for achieve_after_point is "end_of start", no solution
;;; will be found for task spanner_2.  Try this by altering the
;;; achieve_after_point to be begin_of self.  Putting in the do_cleanup schema
;;; will enable a solution to be found even in this case, but then the optimal
;;; solution (where no clean up is needed) is not available

task spanner_1;
  nodes 1 start,
        2 finish,
        3 action {do_setup_1},
        4 action {do_assembly};
  orderings 1 ---> 3, 3 ---> 4, 4 ---> 2;
  conditions supervised {setup_1} = done at 4 from 3;
  effects {status clean_room} = clean at 1,
          {setup_2} = done at 1;
end_task;

;;; there is one solution for task spanner_1 with the TF options provided.
;;; if schema setup_1_a is added, then there are two solutions.

task spanner_2;
  nodes 1 start,
        2 finish,
        3 action {do_setup_1},
        4 action {do_assembly};
  orderings 1 ---> 3, 3 ---> 4, 4 ---> 2;
  conditions supervised {setup_1} = done at 4 from 3;
  effects {status clean_room} = clean at 1;
          ;;; {setup_2} is not yet done
end_task;

;;; with the TF options provided, there is one solution for task spanner_2.
;;;     There would be no solutions if the achieve had to remain within the
;;;     temporal scope of its parent (as for NOAH, Nonlin and SIPE Goals).
;;;     This can be shown by making defaults after_node_end = begin_of self.
;;; with the TF options provided, if schema setup_1_a is added,
;;;     then there are two solutions.
;;;     There would then be one solution if the achieve had to remain within
;;;     the temporal scope of its parent (as for NOAH, Nonlin and SIPE Goals).
;;;     This can be shown by making defaults after_node_end = begin_of self.

schema do_assembly;
  expands {do_assembly};
  conditions achieve {setup_1} = done,
             achieve {setup_2} = done;
  effects {assembly} = done;
end_schema;

;;; schema do_setup_1_a;
;;;   expands {do_setup_1};
;;;   only_use_for_effects {setup_1} = done;
;;; end_schema;

schema do_setup_1_b;
  ;;; dirty setup method
  expands {do_setup_1};
  only_use_for_effects {setup_1} = done;
  effects {status clean_room} = dirty;
end_schema;

schema do_setup_2;
  expands {do_setup_2};
  only_use_for_effects {setup_2} = done;
  conditions achieve {status clean_room} = clean;
end_schema;

;;; schema do_cleanup;
;;;   expands {do_cleanup};
;;;   only_use_for_effects {status clean_room} = clean;
;;; end_schema;

