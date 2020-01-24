;;; File: pacifica-2.tf
;;;
;;; Purpose: PRECiS NEO (Non-combatant Evacuation Operations) Scenario.
;;;          Domain description for transportation logistics problems.
;;;
;;; Concept: Glen A. Reece (DAI, Edinburgh) and Austin Tate (AIAI) 12-Dec-92
;;;
;;; Created:  Brian Drabble:  6th April 1994
;;;
;;; Pacifica is an island state in the Pacific.  Due to its inaccessibility
;;; over the centuries, it remains shrouded in mystery.  Parts of its terrain
;;; remain unexplored...
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

types 
 ;;;
 ;;; Transport Assets
 ;;;
     ground_transport         = (GT1 GT2),
     helicopter               = (AT1),
     air_transporter_cargo    = (C5 C130 C141),
     air_transporter_evacuees = (B707),
 ;;;
 ;;; Geograpghic Information
 ;;;
     country          = (Pacifica Hawaii_USA),
     location         = (Abyss Barnacle Calypso Delta Honolulu),
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

;;;
;;;------------------------------------------------------------------------
;;;                        Task Definitions

task Operation_Columbus;
  nodes 1  start,
        2  finish,
        3  action {transport_helicopters Honolulu Delta},
	4  action {transport_ground_transports Honolulu Delta},
	5  dummy,
        6  action {transport Abyss Delta},
        7  action {transport Barnacle Delta},
        8  action {transport Calypso Delta},
	9  dummy,
        10 action {fly_passengers Delta Honolulu},
        11 action {transport_ground_transports Delta Honolulu},
	12 action {transport_helicopters Delta Honolulu};

  orderings 1 ---> 3, 1 ---> 4, 3 ---> 5, 4 ---> 5, 5 ---> 6,
            5 ---> 7, 5 ---> 8, 6 ---> 9, 7 ---> 9, 8 ---> 9,
            9 --->10, 9 --->11, 9 --->12, 10---> 2, 11---> 2,
	    12---> 2;

  effects {location_gt GT1} = Honolulu at 1,
          {location_gt GT2} = Honolulu at 1,
          {location_at AT1} = Honolulu at 1,
          {location_at AT2} = Honolulu at 1,
          {at C5} = Honolulu at 1,
          {at C141} = Honolulu at 1,
          {at C130} = Honolulu at 1,          
          {at B707} = Delta at 1,

          {people_at_POE_from Abyss} = 0 at 1,
          {people_at_POE_from Barnacle} = 0 at 1,
          {people_at_POE_from Calypso} = 0 at 1,
          {in_use_for_gt GT1} = in_transit at 1,
          {in_use_for_gt GT2} = in_transit at 1,
          {in_use_for_at AT1} = in_transit at 1,
	  {in_use_for_at AT2} = in_transit at 1;

  resources 
     consumes {resource aviation_fuel_delta_tank1} = 0 .. 160 gallons overall,
     consumes {resource diesel_fuel_delta_tank2} = 0 .. 80 gallons overall;
end_task;

;;;
;;;------------------------------------------------------------------------
;;;                       Support Operators

schema transport_ground_transports;
;;;
;;; This schema is used to provide ground transportation from
;;; one air base location to another air base location.  This must take
;;; place by using a cargo plane to fly the nominated transportation
;;; vehicles from the source base to the destination base.
;;;
;;; fly all transport explictly from one base to another. No "forall" yet.
;;;
  vars  ?FROM = ?{type air_base},
        ?TO   = ?{type air_base},
        ?USE1 = ?{and ?{type transport_use} ?{not ?{type city}}},
        ?USE2 = ?{and ?{type transport_use} ?{not ?{type city}}};

  expands {transport_ground_transports ?FROM ?TO};

  only_use_for_effects {location_gt GT1} = ?TO,
                       {location_gt GT2} = ?TO;

  conditions achieve {at C141} = ?FROM,    ;;; make air lift available
             unsupervised {location_gt GT1} = ?FROM,
             unsupervised {location_gt GT2} = ?FROM,
             unsupervised {in_use_for_gt GT1} = ?USE1,
             unsupervised {in_use_for_gt GT2} = ?USE2;

  effects {at C141} = ?TO,
          {in_use_for_gt GT1} = in_transit at begin_of self,
          {in_use_for_gt GT2} = in_transit at begin_of self,
          {in_use_for_gt GT1} = available at end_of self,
          {in_use_for_gt GT2} = available at end_of self;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema transport_helicopters;
;;;
;;; This schema is used to provide air transportation from
;;; one air base location to another air base location.  This must take
;;; place by using a cargo plane to fly the nominated transportation
;;; helicopters from the source base to the destination base.
;;;
;;; fly all transport explictly from one base to another. No "forall" yet.
;;;
;;;
  vars  ?FROM = ?{type air_base},
        ?TO   = ?{type air_base},
        ?USE1 = ?{and ?{type transport_use} ?{not ?{type city}}},
        ?USE2 = ?{and ?{type transport_use} ?{not ?{type city}}};

  expands {transport_helicopters ?FROM ?TO};

  only_use_for_effects {location_at AT1} = ?TO,
                       {location_at AT2} = ?TO;

  conditions achieve {at C5} = ?FROM,    ;;; make air lift available
             unsupervised {location_at AT1} = ?FROM,
             unsupervised {location_at AT2} = ?FROM, 
             unsupervised {in_use_for_at AT1} = ?USE1,
             unsupervised {in_use_for_at AT2} = ?USE2;

  effects {at C5} = ?TO,
          {in_use_for_at AT1} = in_transit at begin_of self,
          {in_use_for_at AT2} = in_transit at begin_of self,
          {in_use_for_at AT1} = available at end_of self,
          {in_use_for_at AT2} = available at end_of self;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema ground_transport_evacuees;
;;;
;;; This schema functionally transports people from one location
;;; to another via ground transportation.  The transporation vehicle
;;; must be taken from an air_base and return to an air_base
;;;
  vars  ?COUNTRY = ?{type country},
        ?LOC1 = ?{type air_base},
        ?LOC2 = ?{type city},
        ?LOC3 = ?{type air_base},
        ?GT   = ?{type ground_transport};

  expands {transport ?LOC2 ?LOC3};

  nodes 1 action {drive ?GT ?LOC2},
        2 action {load_gt ?GT ?LOC2},
        3 action {drive ?GT ?LOC3},
        4 action {unload_gt ?GT ?LOC3};

  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;

  conditions only_use_if {country ?LOC2} = ?COUNTRY,
             only_use_if {country ?LOC3} = ?COUNTRY,
             ;;; above only allows one air_base per country at present (92.12).
             ;;; could make unsupervised if need more than 1 - search increased
             ;;; next could be achieve to pick up available transports?
             unsupervised {location_gt ?GT} = ?LOC1 at 1,
             unsupervised {country ?LOC1} = ?COUNTRY at 1,
             unsupervised {in_use_for_gt ?GT} = available at 1,
             supervised {in_use_for_gt ?GT} = ?LOC2 at 4 from begin_of 1;

  effects {in_use_for_gt ?GT} = ?LOC2 at begin_of 1,  ;;; reserve transport
          {people_at_POE_from ?LOC2} = 50 at 4;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema air_transport_evacuees;
;;;
;;; This schema functionally transports people from one location
;;; to another via a helicopter.  The helicopter leaves from an 
;;; air_base and return to an air_base afterwards
;;;
  vars  ?COUNTRY = ?{type country},
        ?LOC1 = ?{type air_base},
        ?LOC2 = ?{type city},
        ?LOC3 = ?{type air_base},
        ?Heli = ?{type helicopter};

  expands {transport ?LOC2 ?LOC3};

  nodes 1 action {fly ?Heli ?LOC2},
        2 action {load_at ?Heli ?LOC2},
        3 action {fly ?Heli ?LOC3},
        4 action {unload_at ?Heli ?LOC3};

  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;

  conditions only_use_if {country ?LOC2} = ?COUNTRY,
             only_use_if {country ?LOC3} = ?COUNTRY,
             unsupervised {location_at ?Heli} = ?LOC1 at 1,
             unsupervised {country ?LOC1} = ?COUNTRY at 1,
             unsupervised {in_use_for_at ?Heli} = available at 1,
             supervised {in_use_for_at ?Heli} = ?LOC2 at 4 from begin_of 1;

  effects {in_use_for_at ?Heli} = ?LOC2 at begin_of 1,  ;;; reserve transport
          {people_at_POE_from ?LOC2} = 50 at 4;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema fly_passengers;
;;;
;;; This schema transports the evacuees from the airport at Delta to 
;;; Honolulu. The evacuees must be moved by passenger aircraft.
;;; ideally universally quantify {people_at_POE_from ??} = 0;
;;;
  vars ?TO   = ?{type air_base},
       ?FROM = ?{type air_base};

  expands {fly_passengers ?FROM ?TO};

  ;;; B707 assumed to be at FROM location at present
  ;;; conditions on availability of B707 needed later
  effects {at B707} = ?TO,
          {people_at_POE_from Abyss} = 0,
          {people_at_POE_from Barnacle} = 0,
          {people_at_POE_from Calypso} = 0,
          {nationals out} = true;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema drive_ground_transport;
  vars ?GT   = ?{type ground_transport},
       ?LOC  = ?{type location};

  expands {drive ?GT ?LOC};

  effects {location_gt ?GT} = ?LOC;

  resources consumes {resource diesel_fuel_delta_tank2} = 10 gallons;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema load_ground_transport;
  vars  ?GT   = ?{type ground_transport},
        ?LOC  = ?{type location};

  expands {load_gt ?GT ?LOC};

  conditions unsupervised {location_gt ?GT} = ?LOC,
             unsupervised {in_use_for_gt ?GT} = ?LOC;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema unload_ground_transport;
  vars ?GT  = ?{type ground_transport},
       ?LOC = ?{type location};

  expands {unload_gt ?GT ?LOC};

  conditions unsupervised {location_gt ?GT} = ?LOC;

  effects {in_use_for_gt ?GT} = available;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema fly_helicopter_transport;
  vars ?Heli = ?{type helicopter},
       ?LOC  = ?{type location};

  expands {fly ?Heli ?LOC};

  effects {location_at ?Heli} = ?LOC;

  resources consumes {resource aviation_fuel_delta_tank1} = 30 gallons;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema load_helicopter_transport;
  vars  ?Heli = ?{type helicopter},
        ?LOC  = ?{type location};

  expands {load_at ?Heli ?LOC};

  conditions unsupervised {location_at ?Heli} = ?LOC,
             unsupervised {in_use_for_at ?Heli} = ?LOC;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;

schema unload_helicopter_transport;
  vars ?Heli= ?{type helicopter},
       ?LOC = ?{type location};

  expands {unload_at ?Heli ?LOC};

  conditions unsupervised {location_at ?Heli} = ?LOC;

  effects {in_use_for_at ?Heli} = available;
end_schema;

;;;
;;;------------------------------------------------------------------------
;;;
