;;; Space Platform TF - demonstration of AutoCAD PlanWorld Viewers
;;;
;;; BAT  1-Mar-90: Date of Creation
;;; BD  12-May-92: Modified for new O-Plan TF Syntax
;;; BD  12-May-92: Operators added for building three types of platform
;;; BAT  2-Apr-93: location and port_code made functional format
;;; BAT  8-Sep-93: condition type use corrected
;;; BAT 31-Mar-94: only_use_if use is incorrect at three "needs altering"
;;;                points (unsupervised should be used), and in one other
;;;                case "could be improved" the use is legitimate, but
;;;                perhaps could instead be an unsupervised also.
;;;                These 4 are left in to ensure the current implementation
;;;                will find solutions.  More flexible and systematic
;;;                unsupervised condition handling is needed eventually.
;;; BAT  5-Jul-94: spelling mistake in comments corrected

always {port_code A}=  90,   ;;; codes for 3 axis rotation of objects
       {port_code B}=   0,
       {port_code C}= -90,
       {port_code D}= 180,
       {port_code E}=   1,
       {port_code F}=  -1;

task space_platform;
  nodes 1 start,
        2 finish,
        3 action {build platform};
  orderings 1 ---> 3, 3 ---> 2;
  effects {anchored A} at 1,
          {location A}={100 150 0} at 1,
          {location B}={180 150 0} at 1,
          {location C}={300 150 0} at 1;
end_task;

task small_space_platform;
  nodes 1 start,
        2 finish,
        3 action {build small_platform};
  orderings 1 ---> 3, 3 ---> 2;
  effects {anchored A} at 1,
          {location A}={100 150 0} at 1,
          {location B}={180 150 0} at 1,
          {location C}={300 150 0} at 1;
end_task;

task large_space_platform;
  nodes 1 start,
        2 finish,
        3 action {build large_platform};
  orderings 1 ---> 3, 3 ---> 2;
  effects {anchored A} at 1,
          {location A}={100 150 0} at 1,
          {location B}={180 150 0} at 1,
          {location C}={300 150 0} at 1,
          {location D}={360 150 0} at 1,
          {location E}={440 150 0} at 1,
          {location F}={520 150 0} at 1,
          {location G}={300  30 0} at 1,
          {location H}={360  30 0} at 1;
end_task;

schema build_platform;
  expands {build platform};
  nodes     1 dummy,
            2 action {place_joint A},
            3 action {place_joint B},
            4 action {place_joint C},
            5 action {place_truss 3 A B B D},
            6 action {place_truss 5 B B C D},
            7 action {place_module 100 B C none none},
            8 action {place_module  40 B A none none},
            9 dummy,
           10 action {place_radiator 40 20 A A},
           11 action {place_radiator 40 20 A C},
           12 action {place_solar_panel 60 40 20 A E},
           13 action {place_solar_panel 60 40 20 A F},
           14 action {place_solar_panel 60 40 20 C E},
           15 action {place_solar_panel 60 40 20 C F},
           16 action {place_antenna 30 20 C C};
  orderings 1 ---> 2,  1 ---> 3,  1 ---> 4,  1 ---> 5,  1 ---> 6,  1 ---> 7,
            1 ---> 8,  2 ---> 9,  3 ---> 9,  4 ---> 9,  5 ---> 9,  6 ---> 9,
            7 ---> 9,  8 ---> 9,  9 ---> 10, 9 ---> 11, 9 ---> 12, 9 ---> 13,
            9 ---> 14, 9 ---> 15, 9 ---> 16;
end_schema;

schema build_small_platform;
  expands {build small_platform};
  nodes     1 dummy,
            2 action {place_joint A},
            3 action {place_module 100 A D none none},
            4 dummy,
            5 action {place_radiator 30 10 A A},
            6 action {place_solar_panel 100 20 20 A E},
            7 action {place_solar_panel 100 20 20 A F},
            8 action {place_antenna 30 20 A C};
  orderings 1 ---> 2, 1 ---> 3, 2 ---> 4, 3 ---> 5,
            4 ---> 5, 4 ---> 6, 4 ---> 7, 4 ---> 8;
end_schema;

schema build_large_platform;
  expands {build large_platform};
  nodes     1 dummy,
            2 action {place_joint A},
            3 action {place_joint B},
            4 action {place_joint C},
            5 action {place_joint D},
            6 action {place_joint E},
            7 action {place_joint F},
            8 action {place_joint G},
            9 action {place_joint H},
           10 action {place_tube 40 C B D D},
           11 action {place_tube 10 G C none none},
           12 action {place_tube 10 H C none none},
           13 action {place_truss 3 A B B D},
           14 action {place_truss 5 B B C D},
           15 action {place_truss 3 D B E D},
           16 action {place_truss 3 E B F D},
           17 action {place_module 100 C C G A},
           18 action {place_module 100 D C H A},
           19 action {place_module  40 G B H D},
           20 action {place_module  60 C A none none},
           21 action {place_module  40 D A none none},
           22 dummy,
           23 action {place_radiator 60 20 A A},
           24 action {place_radiator 60 20 A C},
           25 action {place_solar_panel 60 40 20 B E},
           26 action {place_solar_panel 60 40 20 B F},
           27 action {place_solar_panel 60 40 20 E E},
           28 action {place_solar_panel 60 40 20 E F},
           29 action {place_solar_panel 60 40 20 F E},
           30 action {place_solar_panel 60 40 20 F F},
           31 action {place_antenna 20 20 B C},
           32 action {place_antenna 80 20 F C};
  orderings  1 ---> 2,   1 ---> 3,   1 ---> 4,   1 ---> 5,   1 ---> 6, 
             1 ---> 7,   1 ---> 8,   1 ---> 9,   1 ---> 10,  1 ---> 11,
             1 ---> 12,  1 ---> 13,  1 ---> 14,  1 ---> 15,  1 ---> 16,
             1 ---> 17,  1 ---> 18,  1 ---> 19,  1 ---> 20,  1 ---> 21,
             2 ---> 22,  3 ---> 22,  4 ---> 22,  5 ---> 22,  6 ---> 22, 
             7 ---> 22,  8 ---> 22,  9 ---> 22, 10 ---> 22, 11 ---> 22,
            12 ---> 22, 13 ---> 22, 14 ---> 22, 15 ---> 22, 16 ---> 22,
            17 ---> 22, 18 ---> 22, 19 ---> 22, 20 ---> 22, 21 ---> 22,
            22 ---> 23, 22 ---> 24, 22 ---> 25, 22 ---> 26, 22 ---> 27,
            22 ---> 28, 22 ---> 29, 22 ---> 30, 22 ---> 31, 22 ---> 32;
end_schema;

schema one_joint_1;
  vars ?j=?{not none}, ?x=undef, ?y=undef, ?z=undef;
  expands {place_joint ?j};
  only_use_for_effects {joint_at ?j ?x ?y ?z};  ;;; was at 1
  nodes 1 action {joint ?j ?x ?y ?z};
  conditions only_use_if {anchored ?j}=true,        ;;; could be improved
             only_use_if {location ?j}={?x ?y ?z};
end_schema;

schema one_joint_2;
  vars ?j=?{not none}, ?x=undef, ?y=undef, ?z=undef;
  expands {place_joint ?j};
  only_use_for_effects {joint_at ?j ?x ?y ?z};
  nodes 1 action {joint ?j ?x ?y ?z};
  conditions only_use_if {location ?j}={?x ?y ?z},
             unsupervised {anchored ?j}=true;
end_schema;

schema one_truss_1;
  vars ?len=undef, ?j1=?{not none}, ?p1=undef, ?j2=undef,   ?p2=undef,
       ?x=undef,   ?y=undef,        ?z=undef,  ?code=undef;
  expands {place_truss ?len ?j1 ?p1 ?j2 ?p2};
  nodes 1 action {truss ?len ?x ?y ?z ?code};
  conditions only_use_if {location ?j1}={?x ?y ?z},
             only_use_if {port_code ?p1}=?code,
             achieve {joint_at ?j1 ?x ?y ?z};
  effects {truss_at ?len ?x ?y ?z ?code},
          {anchored ?j2}=true;
end_schema;

schema one_truss_2;
  vars ?len=undef, ?j1=undef, ?p1=undef, ?j2=?{not none}, ?p2=undef,
       ?x=undef,   ?y=undef,  ?z=undef,  ?code=undef; 
  expands {place_truss ?len ?j1 ?p1 ?j2 ?p2};
  nodes 1 action {truss ?len ?x ?y ?z ?code};
  conditions only_use_if {location ?j2}={?x ?y ?z},
             only_use_if {port_code ?p2}=?code,
             achieve {joint_at ?j2 ?x ?y ?z};
  effects {truss_at ?len ?x ?y ?z ?code},
          {anchored ?j1}=true;
end_schema;

;;;
;;; only_use_if to check that a real joint is involved - allows for "none"
;;;

schema one_tube_1;
  vars ?len=undef, ?j1=?{not none}, ?p1=undef, ?j2=undef, ?p2=undef,
       ?x=undef,   ?y=undef,        ?z=undef,  ?code=undef;
  expands {place_tube ?len ?j1 ?p1 ?j2 ?p2};
  nodes 1 action {tube ?len ?x ?y ?z ?code};
  conditions only_use_if {location ?j1}={?x ?y ?z},
             only_use_if {port_code ?p1}=?code,
             achieve {joint_at ?j1 ?x ?y ?z};
  effects {tube_at ?len ?x ?y ?z ?code},
          {anchored ?j2}=true;
end_schema;

schema one_tube_2;
  vars ?len=undef, ?j1=undef, ?p1=undef, ?j2=?{not none}, ?p2=undef,
       ?x=undef,   ?y=undef,  ?z=undef,  ?code=undef;
  expands {place_tube ?len ?j1 ?p1 ?j2 ?p2};
  nodes 1 action {tube ?len ?x ?y ?z ?code};
  conditions only_use_if {location ?j2}={?x ?y ?z},
             only_use_if {port_code ?p2}=?code,
             achieve {joint_at ?j2 ?x ?y ?z};
  effects {tube_at ?len ?x ?y ?z ?code},
          {anchored ?j1}=true;
end_schema;

schema one_module_1;
  vars ?len=undef, ?j1=?{not none}, ?p1=undef, ?j2=undef, ?p2=undef,
       ?x=undef,   ?y=undef,        ?z=undef,  ?code=undef;
  expands {place_module ?len ?j1 ?p1 ?j2 ?p2};
  nodes 1 action {module ?len ?x ?y ?z ?code};
  conditions only_use_if {location ?j1}={?x ?y ?z},
             only_use_if {port_code ?p1}=?code,
             achieve {joint_at ?j1 ?x ?y ?z};
  effects {module_at ?len ?x ?y ?z ?code},
          {anchored ?j2}=true;
end_schema;

schema one_module_2;
  vars ?len=undef, ?j1=undef, ?p1=undef, ?j2=?{not none}, ?p2=undef,
       ?x=undef,   ?y=undef,  ?z=undef,  ?code=undef;
   expands {place_module ?len ?j1 ?p1 ?j2 ?p2};
   nodes 1 action {module ?len ?x ?y ?z ?code};
   conditions only_use_if {location ?j2}={?x ?y ?z},
              only_use_if {port_code ?p2}=?code,
              achieve {joint_at ?j2 ?x ?y ?z}; 
   effects {module_at ?len ?x ?y ?z ?code},
           {anchored ?j1}=true;
end_schema;

schema radiator;
  vars ?len=undef, ?width=undef, ?j1=?{not none}, ?p1=undef,
       ?x=undef,   ?y=undef,     ?z=undef,        ?code=undef;
  expands {place_radiator ?len ?width ?j1 ?p1};
  nodes 1 action {radiator ?len ?width ?x ?y ?z ?code};
  conditions only_use_if {joint_at ?j1 ?x ?y ?z},    ;;; needs altering
             only_use_if {port_code ?p1}=?code;
  effects {radiator_at ?len ?width ?x ?y ?z ?code};
end_schema;

schema solar_panel;
  vars ?len=undef, ?width=undef, ?rot=undef, ?j1=?{not none}, 
       ?p1=undef,  ?x=undef,     ?y=undef,   ?z=undef, 
       ?code=undef;
  expands {place_solar_panel ?len ?width ?rot ?j1 ?p1};
  nodes 1 action {solar_panel ?len ?width ?rot ?x ?y ?z ?code};
  conditions only_use_if {joint_at ?j1 ?x ?y ?z},    ;;; needs altering
             only_use_if {port_code ?p1}=?code;
  effects {solar_panel_at ?len ?width ?rot ?x ?y ?z ?code};
end_schema;

schema antenna;
  vars ?width=undef, ?rot=undef, ?j1=?{not none}, ?p1=undef, 
       ?x=undef,     ?y=undef,   ?z=undef,        ?code=undef;
  expands {place_antenna ?width ?rot ?j1 ?p1};
  nodes 1 action {antenna ?width ?rot ?x ?y ?z ?code};
  conditions only_use_if {joint_at ?j1 ?x ?y ?z},    ;;; needs altering
             only_use_if {port_code ?p1}=?code;
  effects {antenna_at ?width ?rot ?x ?y ?z ?code};
end_schema;

;;;
;;; Primitive Schemas of the domain which cannot be expanded further
;;;

schema insert_joint;
  expands {joint ?? ?? ?? ??};
end_schema;

schema insert_truss;
  expands {truss ?? ?? ?? ?? ??};
end_schema;

schema insert_module;
  expands {module ?? ?? ?? ?? ??};
end_schema;

schema insert_tube;
  expands {tube ?? ?? ?? ?? ??};
end_schema;

schema insert_radiator;
  expands {radiator ?? ?? ?? ?? ?? ??};
end_schema;

schema insert_solar_panel;
  expands {solar_panel ?? ?? ?? ?? ?? ?? ??};
end_schema;

schema insert_antenna;
  expands {antenna ?? ?? ?? ?? ?? ??};
end_schema;
