;;; House Building Domain - with time windows
;;;
;;; BAT   5-Dec-76: Nonlin TF.
;;; KWC   9-Sep-85: Converted to O-Plan1 TF.
;;; BD   12-May-92: Converted to O-Plan2 TF.
;;; BAT  20-Nov-92: Time Windows set, multiple kitchen options,
;;;                 ground_condition waiting added
;;; JD   30-Nov-92: Adjusted time windows.
;;;

task build_house;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
  effects {ground_condition} = ready at 1;
end_task;

task build_house_to_time_0;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
  effects {ground_condition} = unsuitable at begin_of 1;
  time_windows duration 3 = 0..35 days;
end_task;

task build_house_to_time_1;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
  effects {ground_condition} = ready at begin_of 1;
  time_windows duration 3 = 0..30 days;
end_task;

task build_house_to_time_2;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
  effects {ground_condition} = ready at begin_of 1;
  time_windows  0~09:00 at begin_of 1,   ;;; start day 0 at 09:00
               35~09:00 at end_of 2;     ;;; finish by day 35 at 09:00
end_task;

schema build;
  expands {build house};        ;;; this expands the top level action
  nodes     1 action {excavate and pour footers    },  ;;; some are primitive
            2 action {pour concrete foundations    },
            3 action {erect frame and roof         },
            4 action {lay brickwork                },
            5 action {finish roofing and flashing  },
            6 action {fasten gutters and downspouts},
            7 action {finish grading               },
            8 action {pour walks and landscape     },
            9 action {install services             },  ;;; some are not.
           10 action {decorate                     };
  orderings 1 ---> 2,  2 ---> 3,  3 ---> 4,  4 ---> 5,
            5 ---> 6,  6 ---> 7,  7 ---> 8;
  ;;; actions 9 & 10 are not ordered wrt other actions - they are in parallel
  conditions   supervised {footers poured        } at 2 from [1],
               supervised {foundations laid      } at 3 from [2],
               supervised {frame and roof erected} at 4 from [3],
               supervised {brickwork done        } at 5 from [4],
               supervised {roofing finished      } at 6 from [5],
               supervised {gutters etc fastened  } at 7 from [6],
             unsupervised {storm drains laid     } at 7,
               supervised {grading done          } at 8 from [7];
end_schema;
  
schema service_1;
  expands {install services};
  only_use_for_effects {installed services 1};
  nodes     1 action {install drains           },
            2 action {lay storm drains         },
            3 action {install rough plumbing   },
            4 action {install finished plumbing},
            5 action {install rough wiring     },
            6 action {finish electrical work   },
            7 action {install kitchen equipment},
            8 action {install air conditioning };
  orderings 1 ---> 3,  3 ---> 4,  5 ---> 6,  3 ---> 7,  5 ---> 7;
  conditions   supervised {drains installed        } at 3 from [1],
               supervised {rough plumbing installed} at 4 from [3],
               supervised {rough wiring installed  } at 6 from [5],
               supervised {rough plumbing installed} at 7 from [3],
               supervised {rough wiring installed  } at 7 from [5],
             unsupervised {foundations laid        } at 1,
             unsupervised {foundations laid        } at 2,
             unsupervised {frame and roof erected  } at 5,
             unsupervised {frame and roof erected  } at 8,
             unsupervised {basement floor laid     } at 8,
             unsupervised {flooring finished       } at 4,
             unsupervised {flooring finished       } at 7,
             unsupervised {painted                 } at 6;
  time_windows duration self = 0 days .. 24 days;
end_schema;
           
schema decor;
  expands {decorate};
  nodes     1 action {fasten plaster and plaster board},
            2 action {pour basement floor             },
            3 action {lay finished flooring           },
            4 action {finish carpentry                },
            5 action {sand and varnish floors         },
            6 action {paint                           };
  orderings  2 ---> 3,  3 ---> 4,  4 ---> 5,  1 ---> 3,  6 ---> 5;
  conditions unsupervised {rough plumbing installed   } at 1,
             unsupervised {rough wiring installed     } at 1,
             unsupervised {air conditioning installed } at 1,
             unsupervised {drains installed           } at 2,
             unsupervised {plumbing finished          } at 6,
             unsupervised {kitchen equipment installed} at 6,
               supervised {plastering finished        } at 3 from [1],
               supervised {basement floor laid        } at 3 from [2],
               supervised {flooring finished          } at 4 from [3],
               supervised {carpentry finished         } at 5 from [4],
               supervised {painted                    } at 5 from [6];
  time_windows duration self = 0 days .. 23 days;
end_schema;

;;; Now for completeness a list of primitive actions. Primitives are
;;; defined as having no nodes list and must have an expands pattern.

schema excavate_when_unsuitable;
  expands {excavate and pour footers};
  only_use_for_effects {footers poured} = true;
  conditions only_use_if {ground_condition} = unsuitable;
  effects {ground_condition} = ready;
  time_windows duration self = 14 days;
end_schema;

schema excavate_when_ready;
  expands {excavate and pour footers};
  only_use_for_effects {footers poured} = true;
  conditions only_use_if {ground_condition} = ready;
  time_windows duration self = 4 days;
end_schema;

schema pour_concrete;
  expands {pour concrete foundations};
  only_use_for_effects {foundations laid} = true;
  time_windows duration self = 2 days;
end_schema;

schema erect_frame;
  expands {erect frame and roof};
  only_use_for_effects {frame and roof erected} = true;
  time_windows duration self = 4 days;
end_schema;

schema brickwork;
  expands {lay brickwork};
  only_use_for_effects {brickwork done} = true;
  time_windows duration self = 7 days;
end_schema;

schema finish_roofing;
  expands {finish roofing and flashing};
  only_use_for_effects {roofing finished} = true;
  time_windows duration self = 3 days;
end_schema;

schema fasten_gutters;
  expands {fasten gutters and downspouts};
  only_use_for_effects {gutters etc fastened} = true;
  time_windows duration self = 1 days;
end_schema;

schema finish_grading;
  expands {finish grading};
  only_use_for_effects {grading done} = true;
  time_windows duration self = 2 days;
end_schema;

schema pour_walks;
  expands {pour walks and landscape};
  only_use_for_effects {landscaping done} = true;
  time_windows duration self = 5 days;
end_schema;

schema install_drains;
  expands {install drains};
  only_use_for_effects {drains installed} = true;
  time_windows duration self = 1 days;
end_schema;

schema lay_storm;
  expands {lay storm drains};
  only_use_for_effects {storm drains laid} = true;
  time_windows duration self = 1 days;
end_schema;

schema rough_plumbing;
  expands {install rough plumbing};
  only_use_for_effects {rough plumbing installed} = true;
  time_windows duration self = 1 days;
end_schema;

schema install_finished_plumbing;
  expands {install finished plumbing};
  only_use_for_effects {plumbing finished} = true;
  time_windows duration self = 2 days;
end_schema;

schema rough_wiring;
  expands {install rough wiring};
  only_use_for_effects {rough wiring installed} = true;
  time_windows duration self = 2 days;
end_schema;

schema finish_electrical;
  expands {finish electrical work};
  only_use_for_effects {electrical work finished} = true;
  time_windows duration self = 1 days;
end_schema;

schema install_kitchen_luxury;
  expands {install kitchen equipment};
  only_use_for_effects {kitchen equipment installed} = true,
                       {installed_level kitchen} = luxury;
  time_windows duration self = 3 days;
end_schema;

schema install_kitchen_standard;
  expands {install kitchen equipment};
  only_use_for_effects {kitchen equipment installed} = true,
                       {installed_level kitchen} = standard;
  time_windows duration self = 2 days;
end_schema;

schema install_air;
  expands {install air conditioning};
  only_use_for_effects {air conditioning installed} = true;
  time_windows duration self = 3 days;
end_schema;

schema fasten_plaster;
  expands {fasten plaster and plaster board};
  only_use_for_effects {plastering finished } = true;
  time_windows duration self = 7 days;
end_schema;

schema pour_basement;
  expands {pour basement floor};
  only_use_for_effects {basement floor laid } = true;
  time_windows duration self = 2 days;
end_schema;

schema lay_flooring;
  expands {lay finished flooring};
  only_use_for_effects {flooring finished} = true;
  time_windows duration self = 3 days;
end_schema;

schema finish_carpentry;
  expands {finish carpentry};
  only_use_for_effects {carpentry finished} = true;
  time_windows duration self = 3 days;
end_schema;

schema sand;
  expands {sand and varnish floors};
  only_use_for_effects {floors finished} = true;
  time_windows duration self = 2 days;
end_schema;

schema paint;
  expands {paint};
  only_use_for_effects {painted} = true;
  time_windows duration self = 3 days;
end_schema;

