;;; House Building Domain - Increment to house_1.tf
;;;
;;; Incremental addition of an Alternative Services Schema and its associated
;;; two new primitive schemas
;;;
;;; BAT   5-Dec-76: Nonlin TF.
;;; KWC   9-Sep-85: Converted to O-Plan1 TF.
;;; BD   12-May-92: Converted to O-Plan TF.
;;; BAT  17-Jul-92: Added second task schema for version 1.1.
;;;
;;; NOTE: Requires house_1.tf to be preloaded before this TF file
;;;
;;; The new services schema adds:
;;;
;;;        1. 5 action {install gas piping and valves  },
;;;           6 action {install cooker and hob         },
;;;
;;;        2. supervised {pipes and valves installed} at 7 from [6]
;;;
;;;        3. 6 ---> 7
;;;

;;; at present must have a task schema in last file loaded for version 1.1

task build_house_2;             ;;; top level task schema to initiate planning
  nodes 1 start,
        2 finish,
        3 action {build house}; ;;; this action is refined by the schema below
  orderings 1 ---> 3, 3 ---> 2;
end_task;

schema service_2;
  expands {install services};
  only_use_for_effects {installed services 2};
  nodes     1  action {install drains                 },
            2  action {lay storm drains               },
            3  action {install rough plumbing         },
            4  action {install finished plumbing      },
            5  action {install rough wiring           },
	    6  action {install gas piping and valves  },
            7  action {install cooker and hob         },
            8  action {finish electrical work         },
            9  action {install kitchen equipment      },
            10 action {install air conditioning       };

  orderings 1 ---> 3,  3 ---> 4,  5 ---> 8,  3 ---> 9,  5 ---> 9,
            3 ---> 6,  6 ---> 7;
  conditions   supervised {drains installed          } at 3 from [1],
               supervised {rough plumbing installed  } at 4 from [3],
               supervised {pipes and valves installed} at 7 from [6],
               supervised {rough wiring installed    } at 8 from [5],
               supervised {rough plumbing installed  } at 9 from [3],
               supervised {rough wiring installed    } at 9 from [5],
             unsupervised {foundations laid          } at 1,
             unsupervised {foundations laid          } at 2,
             unsupervised {frame and roof erected    } at 5,
             unsupervised {frame and roof erected    } at 10,
             unsupervised {basement floor laid       } at 10,
             unsupervised {flooring finished         } at 4,
             unsupervised {flooring finished         } at 9,
             unsupervised {painted                   } at 8;
end_schema;
           
schema install_pipes_and_valves;
  expands {install gas piping and valves};
  only_use_for_effects {pipes and valves installed} = true;
end_schema;

schema connect_cooker_and_hob;
  expands {install cooker and hob};
  only_use_for_effects {cooker and hob connected} = true;
end_schema;
