;;; File: pacifica-4.tf
;;;
;;; Purpose: PRECiS NEO (Non-combatant Evacuation Operations) Scenario.
;;;          Domain description for transportation logistics problems.
;;;
;;; Concept: Glen A. Reece (DAI, Edinburgh) and Austin Tate (AIAI)
;;;
;;; Purpose: PRECiS NEO (Non-combatant Evacuation Operations) Scenario.
;;;          Domain description for transportation logistics problems.
;;;          TF for Pacifica repair demonstration for Year 3
;;;
;;; Created:  Brian Drabble: 7th March 1995
;;;
;;; Pacifica is an island state in the Pacific.  Due to its inaccessibility
;;; over the centuries, it remains shrouded in mystery.  Parts of its terrain
;;; remain unexplored...
;;;
;;; Status Notes: Refer to the file BD-README for details
;;;
;;; world model:
;;;   {country ?{type location}} = ?{type country}
;;;   {in_use_for_gt ?{type ground_transport}}
;;;                              = in_transit, available, ?{type city}
;;;   {in_use_for_at ?{type air_transport}}
;;;                              = in_transit, available, ?{type city}
;;;   {location_gt ?{type ground_transport}
;;;                              = ?{type location}
;;;   {location_at ?{type air_transport}
;;;                              = ?{type location}
;;;   {people_at_POE_from ?{type city}} = 0, 50
;;;                              POE is Point Of Embarkation
;;;   {nationals out} = true
;;;
;;; The schemas contained within this files are used as repair actions for
;;; the precis domain. Within the domain a number of changes can take place
;;; either in terms of the task, i.e. new evacuuees need to be picked up or
;;; in terms of the environment in which failures of transports can occur.
;;; The failure of transports occur due to either blown engines or blown
;;; tyres.
;;;
;;; The repair actions available are as follows:
;;;
;;; repair-tyre : The driver of the ground transport can fix the tyre
;;;               by the side of the road. The effect of the repair
;;;               action is to delay the ground transport by a fixed
;;;               amount of time.
;;;
;;; repair-engine : The engine can only be fixed by a repair crew which is
;;;                 dispatched from Delta with a tow truck. The transport is
;;;                 then towed to Delta for repairs. The evacuees remain with
;;;                 truck while it is being towed.
;;;
;;; move-by-air : The failure of the transport occurs in a time critical
;;;               situation and there is insufficient time to tow the broken
;;;               transport to Delta. The evacuees are moved from the broken
;;;               ground transport by helicopter to Delta and the transport
;;;               is abandoned.
;;;
;;; move-by-road: This is similar to the move-by-air schema except that the
;;;               ecacuees are moved by another ground transport instead of
;;;               by helicopter.
;;;
;;; The model also allows for the addition of new actions once the plan has
;;; been generated and while execution is in progress. 
;;; The task task_partial_evacuation leaves the people at Calypso "behind" 
;;; during the first generation of the plan. These can then be added in when
;;; "intelligence reports" provide information on the where abouts of the
;;; new group iof evacuees.
;;;

types 
 ;;;
 ;;; Transport Assets
 ;;;
     ground_transport         = (GT1 GT2),
     repair_truck             = (RT1),
     ground_vehicles          = (GT1 GT2 RT1),
     helicopter               = (AT1),
     air_transporter_cargo    = (C5 C130 C141),
     air_transporter_evacuees = (B707),
 ;;;
 ;;; Geograpghic Information
 ;;;
     country          = (Pacifica Hawaii_USA),
     location         = (Abyss Barnacle Calypso Delta Honolulu Breakdown),
     city             = (Abyss Barnacle Calypso Delta),
     air_base         = (Delta Honolulu),
     transport_use    = (in_transit available Abyss Barnacle Calypso Delta);

 ;;;
 ;;; resource information
 ;;;
 ;;;   resource_units gallons = count;

resource_types
     consumable_strictly {resource aviation_fuel_delta_tank1} = gallons,
     consumable_strictly {resource diesel_fuel_delta_tank2} = gallons;

always {country Abyss} = Pacifica,
       {country Barnacle} = Pacifica,
       {country Calypso} = Pacifica,
       {country Delta} = Pacifica,
       {country Honolulu} = Hawaii_USA;

initially
       {evacuate_to Delta},   ;;; the evacuation point in Pacifica
       {all_out} = false;

;;;
;;;------------------------------------------------------------------------
;;;                        Task Definitions

task Operation_Magellan;
  nodes 1 start,
        2 finish,
        3 action {evacuate_stranded_people by_road},
        4 action {evacuate_stranded_people by_air},
        5 action {repair blown_tyre},
        6 action {repair blown_engine in_situ};
  orderings 1 ---> 3, 1 ---> 4, 1 ---> 5, 1 ---> 6,
            3 ---> 2, 4 ---> 2, 5 ---> 2, 6 ---> 2;
end_task;

task Operation_Columbus;
  nodes sequential 
          1 start,
          3 action {fly_transport Honolulu Delta},
          parallel
            4 action {evacuate Abyss 50},
            5 action {evacuate Barnacle 100},
          end_parallel,
          6 dummy,
          parallel
            7 action {fly_passengers Delta Honolulu},
            8 action {fly_transport Delta Honolulu}
          end_parallel,
          2 finish
        end_sequential;
  effects {all_out} = true at begin_of 6;
end_task;


;;; Task Evacuate_to_Delta evacuates prople from Abyss, Barnacle and
;;; Calypso to Delta.  It used GTs already present in Delta so that
;;; no air transport is needed.

task Operation_Raliegh;
  nodes sequential 
          1 start,
          parallel
            3 action {evacuate Abyss 50},
            4 action {evacuate Barnacle 100},
            5 dummy  ;;; 5 action {evacuate Calypso 20}
          end_parallel,
          2 finish
        end_sequential;
  effects {transport_available} = true at end_of 1,
          {all_out} = true at begin_of 2,
          {in_use_for GT1} = available,
          {in_use_for GT2} = available;
end_task;


;;; Road_transport

;;; Note that it makes a round trip.  Hence the {at ?gt} = ?to at
;;; begin_of self.

schema road_transport;
  vars ?from     = ?{type city},
       ?to       = ?{type air_base},
       ?gt       = ?{type ground_transport},
       ?take     = ?{satisfies numberp};
  expands {evacuate ?from ?take};
  nodes 1 action {prepare_transport ?gt},
	2 action {drive ?take in ?gt from ?from};
  orderings 1 ---> 2;
  conditions only_use_if {evacuate_to ?to},
             unsupervised {transport_available} = true at begin_of self,
             unsupervised {all_out} = false at end_of self,
             unsupervised {in_use_for ?gt} = available at begin_of self,
               supervised {in_use_for ?gt} = ?from
                          at end_of self from begin_of self,
             supervised {tyre_status ?gt} = working at end_of 2 from 1,
             supervised {engine_status ?gt} = working at end_of 2 from 1;

  effects {in_use_for ?gt} = ?from at begin_of self,
          {in_use_for ?gt} = available at end_of self;
end_schema;


;;; Primitives for ground transport

schema prepare_the_GT_vehicle;
  vars ?GT = ?{type ground_transport};
  expands {prepare_transport ?GT};
  effects {tyre_status ?GT} = working,
          {engine_status ?GT} = working;
end_schema;

schema drive;
  vars ?from     = ?{type city},
       ?take     = ?{satisfies numberp},
       ?gt       = ?{type ground_transport};
  expands {drive ?take in ?gt from ?from};
  time_windows duration self = 3 hours .. 4 hours;
end_schema;


;;; Simple air transport

;;; It may seen that these schemas are *too* simple, but the added
;;; complexity of the Pacifica.tf versions doesn't accomplish anything
;;; interesting.

schema simple_fly_transport;
  vars ?from = ?{type air_base},
       ?to   = ?{type air_base};
  expands {fly_transport ?from ?to};
  effects {transport_available} = true,
          {in_use_for GT1} = available,
          {in_use_for GT2} = available;
end_schema;

schema simple_fly_passengers;
  vars ?to   = ?{type air_base},
       ?from = ?{type air_base};
  expands {fly_passengers ?from ?to};
end_schema;


;;;------------------------------------------------------------------------
;;;   Repair actions to fix blown tyres and engines or evacuate people
;;;

schema Repair_the_tyre;
   vars ?gt = ?{type ground_transport};
   expands {repair blown_tyre};

   only_use_for_effects {tyre_status ?GT} = working;

   nodes 1 action {remove blown_tyre},
         2 action {replace tyre};

   orderings 1 ---> 2;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema Repair_the_engine;
   vars ?rt = ?{type repair_truck},
        ?gt = ?{type ground_transport};

   expands {repair blown_engine in_situ};

   only_use_for_effects {engine_status ?gt} = working;

   nodes 1 action {assemble ?rt crew},
         2 action {drive_rt ?rt Breakdown},
         3 action {pickup broken_gt},
         4 action {drive_rt ?rt Delta};

   orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema Move_the_evacuees_by_air;
   vars ?at = ?{type helicopter},
        ?vehicle;

   expands {evacuate_stranded_people by_air};

   only_use_for_effects {engine_status ?vehicle} = working;

   nodes 1 action {scramble ?at crew},
         2 action {fly ?at Breakdown},
         3 action {load_at ?at Breakdown},
         4 action {fly ?at Delta},
         5 action {unload_at ?at Delta};

   orderings 1 ---> 2, 2 ---> 3, 3 ---> 4, 4 ---> 5;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema Move_evacuees_by_road;
   vars ?gt = ?{type ground_transport},
        ?vehicle;
 
   expands {evacuate_stranded_people by_road};
 
   only_use_for_effects {engine_status ?vehicle} = working;

   nodes 1 action {assemble ?gt crew},
         2 action {drive ?gt Breakdown},
         3 action {load_gt ?gt Breakdown},
         4 action {drive ?gt Delta};

   orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
end_schema;

;;;------------------------------------------------------------------------
;;;  Primitives for the repair actions
;;;

schema scramble_the_AT_crew;
  vars ?at = ?{type helicopter};
  expands {scramble ?at crew};
  only_use_for_effects {status AT crew} =  scrambled;
end_schema;

;;;------------------------------------------------------------------------
;;;
;;;
 
schema fly_the_helicopter;
  vars ?at = ?{type helicopter},
       ?location;
  expands {fly ?at ?location};
  only_use_for_effects {flight_status ?at} = inflight;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema load_the_helicopter;
  vars ?at = ?{type helicopter},
       ?location;
  expands {load_at ?at ?location};
  only_use_for_effects {load_status ?at} = loaded;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema unload_the_helicopter;
  vars ?at = ?{type helicopter},
       ?location;
  expands {unload_at ?at ?location};
  only_use_for_effects {load_status ?at} = unloaded;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema assemble_the_GT_crew;
  vars ?vehicle = ?{type ground_vehicles};
  expands {assemble ?vehicle crew};
  only_use_for_effects {status ?vehicle crew} =  assembled;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema pick_up_the_broken_GT;
   expands {pickup broken_gt};
   only_use_for_effects {broken_down GT} = picked_up;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema drive_the_repair_truck;
   vars ?rt, ?location;
   expands {drive_rt ?rt ?location};
   only_use_for_effects {drive_status ?rt} = on_road;
end_schema;
;;;
;;;------------------------------------------------------------------------
;;;

schema remove_the_blown_tyre;
   expands {remove blown_tyre};
   only_use_for_effects {blown tyre} = removed;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema replace_the_tyre;
   expands {replace tyre};
   only_use_for_effects {new tyre} = replaced;
end_schema;

;;;------------------------------------------------------------------------
;;; End of Domain Encoding
;;;




