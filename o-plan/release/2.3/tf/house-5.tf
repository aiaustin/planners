;;; A simple house-building domain with resources

;;; Jeff Dalton   : 1-Jun-93 original TF defined
;;; Brian Drabble : 12-Jun-94 removed better_build_secure_house task due
;;;                 to problems with incremental TF updates in version 2.2 
;;;
;;; Updated: Thu Feb 23 10:07:22 1995

;;; Wolf-proof houses are more expensive.

;;; Tasks:
;;;
;;;   build_house
;;;     Cost is no object, but there's no requirement that the
;;;     house be secure.
;;;   build_secure_house
;;;     The house must be wolf-proof.
;;;   build_cheap_house
;;;     The house must be inexpensive.
;;;   build_cheap_secure_house
;;;     The house must be inexpensive and wolf-proof.
;;;     (No solutions.)

;;; It is expected that a number of schemas can be combined once
;;; variables and expressions can be more widely used and once compute
;;; conditions are available.

types material = (straw sticks bricks);

always {proof_against wolf bricks} = true;

resource_units pounds = count;

resource_types
  consumable_strictly {resource money} = pounds,
  consumable_strictly {resource straw},
  consumable_strictly {resource sticks},
  consumable_strictly {resource bricks};

task build_house;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
end_task;

task build_secure_house;
  nodes 1 start,  
        2 finish,
        3 action {build house},
        4 action {check security};
  orderings 1 ---> 3, 3 ---> 4, 4 ---> 2;
  resources consumes {resource money} = 0 .. 2000 pounds overall;
end_task;

task build_cheap_house;
  nodes 1 start,  
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;
  resources consumes {resource money} = 0 .. 500 pounds overall;
end_task;

task build_cheap_secure_house;
  nodes 1 start,  
        2 finish,
        3 action {build house},
        4 action {check security};
  orderings 1 ---> 3, 3 ---> 4, 4 ---> 2;
  resources consumes {resource money} = 0 .. 500 pounds overall;
end_task;

schema build_house_of_straw;
  expands {build house};
  nodes 1 action {build_house_of straw};
end_schema;

schema build_house_of_sticks;
  expands {build house};
  nodes 1 action {build_house_of sticks};
end_schema;

schema build_house_of_bricks;
  expands {build house};
  nodes 1 action {build_house_of bricks};
end_schema;

schema house_builder;
  vars ?material = ?{type material};
  expands {build_house_of ?material};
  nodes 1 action {build_walls ?material},
        2 action {install door},
        3 action {install windows};
  orderings 1 ---> 2, 1 ---> 3;
  conditions supervised {walls built} at 2 from [1],
             supervised {walls built} at 3 from [1];
end_schema;

;;; /\/: Security_checker is a separate schema, because we can't
;;; put the materials check directly in the task schema.  Secure_
;;; house_builder is better way of doing this, because it doesn't
;;; lead to so much search.

schema security_checker;
  expands {check security};
  local_vars ?material = ?{type material};
  conditions unsupervised {proof_against wolf ?material},
             unsupervised {material wall} = ?material,
             unsupervised {wolf_proof door},
             unsupervised {wolf_proof windows};
end_schema;

schema secure_house_builder;
  vars ?material = ?{type material};
  expands {build secure house};
  nodes 1 action {build_walls ?material},
        2 action {install door},
        3 action {install windows},
        4 dummy;
  orderings 1 ---> 2, 1 ---> 3, 2 ---> 4, 3 ---> 4;
  conditions unsupervised {proof_against wolf ?material} at 1,
             supervised {material wall} = ?material at 4 from [1],
             supervised {walls built} at 2 from [1],
             supervised {walls built} at 3 from [1],
             supervised {wolf_proof door} at 4 from [2],
             supervised {wolf_proof windows} at 4 from [3];
end_schema;

schema build_walls;
  vars ?material = ?{type material};
  expands {build_walls ?material};
  nodes     1 action {purchase ?material},
            2 action {make_walls_from ?material};
  orderings 1 ---> 2;
  conditions supervised {have ?material} at 2 from [1];
end_schema;

;;; Some primitive actions.

schema purchase_straw;
  expands {purchase straw};
  only_use_for_effects {have straw};
  resources consumes {resource money} = 100 pounds,
            consumes {resource straw} = 1000;
end_schema;

schema purchase_sticks;
  expands {purchase sticks};
  only_use_for_effects {have sticks};
  resources consumes {resource money} = 200 pounds,
            consumes {resource sticks} = 1000;
end_schema;

schema purchase_bricks;
  expands {purchase bricks};
  only_use_for_effects {have bricks};
  resources consumes {resource money} = 1000 pounds,
            consumes {resource bricks} = 1000;
end_schema;

schema make_straw_walls;
  expands {make_walls_from straw};
  only_use_for_effects {walls built} = true,
                       {material wall} = straw;
  resources consumes {resource money} = 100 pounds;
end_schema;

schema make_stick_walls;
  expands {make_walls_from sticks};
  only_use_for_effects {walls built} = true,
                       {material wall} = sticks;
  resources consumes {resource money} = 200 pounds;
end_schema;

schema make_brick_walls;
  expands {make_walls_from bricks};
  only_use_for_effects {walls built} = true,
                       {material wall} = bricks;
  resources consumes {resource money} = 500 pounds;
end_schema;

schema install_wolf_proof_door;
  expands {install door};
  only_use_for_effects {door installed} = true,
                       {wolf_proof door} = true;
  resources consumes {resource money} = 100 pounds;
end_schema;

schema install_door;
  expands {install door};
  only_use_for_effects {door installed} = true;
  resources consumes {resource money} = 50 pounds;
end_schema;

schema install_wolf_proof_windows;
  expands {install windows};
  only_use_for_effects {windows installed} = true,
                       {wolf_proof windows} = true;
  resources consumes {resource money} = 100 pounds;
end_schema;

schema install_windows;
  expands {install windows};
  only_use_for_effects {windows installed} = true;
  resources consumes {resource money} = 50 pounds;
end_schema;
