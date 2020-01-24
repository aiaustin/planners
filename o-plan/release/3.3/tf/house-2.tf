;;; House Building Domain - with 2 ways to expand a schema, one will fail
;;;
;;; BAT   5-Dec-76: Nonlin TF.
;;; KWC   9-Sep-85: Converted to O-Plan1 TF.
;;; BD   12-May-92: Converted to O-Plan TF.
;;; BAT  24-Jun-93: Altered comments.
;;;

task build_house;               ;;; top level task schema to initiate planning
  nodes 1 start,  
        2 finish,
        3 action {build house}; ;;; this action is refined by the schema below
  orderings 1 ---> 3, 3 ---> 2;      
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
  ;;; note the unsupervised condition - its satisfaction is outwith
  ;;; the control of this schema but must still be satisfied
end_schema;
  
schema service_1;
  expands {install services};   ;;; one way of expanding {install services}
  only_use_for_effects {installed services contractor A};
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
    ;;; As in the real world this sub-contractor relies heavily on others
    ;;; to prepare things beforehand - see the unsupervised conditions.
end_schema;
           
schema service_2;
  expands {install services};   ;;; another possible expansion
  only_use_for_effects {installed services contractor B};
  nodes     1 action {install drains           },
            2 action {install rough plumbing   },
            3 action {install finished plumbing},
            4 action {install rough wiring     },
            5 action {finish electrical work   },
            6 action {install kitchen equipment},
            7 action {install air conditioning };
  ;;; This sub-contractor fails to {lay storm drains}.
  ;;; This will lead to plan failure when this schema is used
  orderings 1 ---> 2,  2 ---> 3,  4 ---> 5,  2 ---> 6,  4 ---> 6;
  conditions   supervised {drains installed        } at 2 from [1],
               supervised {rough plumbing installed} at 3 from [2],
               supervised {rough wiring installed  } at 5 from [4],
               supervised {rough plumbing installed} at 6 from [2],
               supervised {rough wiring installed  } at 6 from [4],
             unsupervised {foundations laid        } at 1,
             unsupervised {frame and roof erected  } at 4,
             unsupervised {frame and roof erected  } at 7,
             unsupervised {basement floor laid     } at 7,
             unsupervised {flooring finished       } at 3,
             unsupervised {flooring finished       } at 6,
             unsupervised {painted                 } at 5;
  effects {wallpaper on} = false at 5;
  ;;; Effects can be asserted - this one strips wallpaper.
  ;;; Effects of this form can cause interactions to occur and plan steps
  ;;; to be linearised if a condition {wallpaper on} = true appears in, say,
  ;;; the decorate schema.
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
end_schema;

;;; Now for completeness a list of primitive actions. Primitives are
;;; defined as having no nodes list and must have an expands pattern.

schema excavate;
  expands {excavate and pour footers};
  only_use_for_effects {footers poured} = true;
end_schema;

schema pour_concrete;
  expands {pour concrete foundations};
  only_use_for_effects {foundations laid} = true;
end_schema;

schema erect_frame;
  expands {erect frame and roof};
  only_use_for_effects {frame and roof erected} = true;
end_schema;

schema brickwork;
  expands {lay brickwork};
  only_use_for_effects {brickwork done} = true;
end_schema;

schema finish_roofing;
  expands {finish roofing and flashing};
  only_use_for_effects {roofing finished} = true;
end_schema;

schema fasten_gutters;
  expands {fasten gutters and downspouts};
  only_use_for_effects {gutters etc fastened} = true;
end_schema;

schema finish_grading;
  expands {finish grading};
  only_use_for_effects {grading done} = true;
end_schema;

schema pour_walks;
  expands {pour walks and landscape};
  only_use_for_effects {landscaping done} = true;
end_schema;

schema install_drains;
  expands {install drains};
  only_use_for_effects {drains installed} = true;
end_schema;

schema lay_storm;
  expands {lay storm drains};
  only_use_for_effects {storm drains laid} = true;
end_schema;

schema rough_plumbing;
  expands {install rough plumbing};
  only_use_for_effects {rough plumbing installed} = true;
end_schema;

schema install_finished;
  expands {install finished plumbing};
  only_use_for_effects {plumbing finished} = true;
end_schema;

schema rough_wiring;
  expands {install rough wiring};
  only_use_for_effects {rough wiring installed} = true;
end_schema;

schema finish_electrical;
  expands {finish electrical work};
  only_use_for_effects {electrical work finished} = true;
end_schema;

schema install_kitchen;
  expands {install kitchen equipment};
  only_use_for_effects {kitchen equipment installed} = true;
end_schema;

schema install_air;
  expands {install air conditioning};
  only_use_for_effects {air conditioning installed} = true;
end_schema;

schema fasten_plaster;
  expands {fasten plaster and plaster board};
  only_use_for_effects {plastering finished } = true;
end_schema;

schema pour_basement;
  expands {pour basement floor};
  only_use_for_effects {basement floor laid } = true;
end_schema;

schema lay_flooring;
  expands {lay finished flooring};
  only_use_for_effects {flooring finished} = true;
end_schema;

schema finish_garden;
  expands {finish garden};
  only_use_for_effects {garden finished};
end_schema;

schema finish_carpentry;
  expands {finish carpentry};
  only_use_for_effects {carpentry finished} = true;
end_schema;

schema sand;
  expands {sand and varnish floors};
  only_use_for_effects {floors finished} = true;
end_schema;

schema paint;
  expands {paint};
  only_use_for_effects {painted} = true;
end_schema;
