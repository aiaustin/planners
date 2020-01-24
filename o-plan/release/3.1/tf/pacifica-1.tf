;;; File: pacifica-1.tf
;;;
;;; Purpose: Pacifica NEO (Non-combatant Evacuation Operations) Scenario.
;;;          Domain description for transportation logistics problems.
;;;
;;; Concept: Glen A. Reece (DAI, Edinburgh) and Austin Tate (AIAI) 12-Dec-92
;;; 
;;; Created:  Glen Reece   1-Feb-93
;;; Modified: Austin Tate  9-Feb-93 Changed world model and added new tasks
;;;           Glen Reece   5-Mar-93 Sanitized names
;;;           Austin Tate 24-Jun-93 Comments altered
;;;
;;; Pacifica is an island state in the Pacific.  Due to its inaccessibility
;;; over the centuries, it remains shrouded in mystery.  Parts of its terrain
;;; remain unexplored...

;;; Status Notes:
;;;
;;; Blue_Lagoon works in reasonable time, but adds an extra link that
;;;   should not be there (due to unchecked redundant unsupervised
;;;   links - PSV restriction not used fully).
;;; Castaway works in a longer time.
;;; Paradise works in reasonable time.
;;;   GT3 may be added to type ground_transport in advance
;;;   (which will affect the search for solutions for other operations).

types ground_transport = (GT1 GT2),
      air_transport    = (C5 B707),
      country          = (Pacifica Hawaii_USA),
      location         = (Abyss Barnacle Calypso Delta Honolulu),
      city             = (Abyss Barnacle Calypso Delta),
      air_base         = (Delta Honolulu),
      transport_use    = (in_transit available Abyss Barnacle Calypso Delta);

always {country Abyss} = Pacifica,
       {country Barnacle} = Pacifica,
       {country Calypso} = Pacifica,
       {country Delta} = Pacifica,
       {country Honolulu} = Hawaii_USA;

;;; world model:
;;;   {country ?{type location}} = ?{type country}
;;;   {in_use_for ?{type ground_transport}}
;;;                              = in_transit, available, ?{type city}
;;;   {at ?{or ?{type ground_transport} ?{type air_transport}}}
;;;                              = ?{type location}
;;;   {people_at_POE_from ?{type city}} = 0, 50
;;;                              POE is Point Of Embarkation
;;;   {nationals out} = true
;;;

task Operation_Blue_Lagoon;
  nodes 1 start,
        2 finish,
        3 action {fly_transport Honolulu Delta},
        4 action {transport Abyss Delta}, 
        5 action {transport Barnacle Delta}, 
        6 action {transport Calypso Delta},
        7 action {fly_passengers Delta Honolulu},
        8 action {fly_transport Delta Honolulu};
  orderings 1 ---> 3, 3 ---> 4, 3 ---> 5, 3 ---> 6,
            4 ---> 7, 5 ---> 7, 6 ---> 7, 7 ---> 8, 8 ---> 2;
  effects {at GT1} = Honolulu at 1,
          {at GT2} = Honolulu at 1,
          {at C5} = Honolulu at 1,
          {at B707} = Delta at 1,
          {people_at_POE_from Abyss} = 0 at 1,
          {people_at_POE_from Barnacle} = 0 at 1,
          {people_at_POE_from Calypso} = 0 at 1,
          {in_use_for GT1} = in_transit at 1,
          {in_use_for GT2} = in_transit at 1;
end_task;

task Operation_Castaway;
  ;;; transportation provision and removal from POE not ordered wrt
  ;;; ground transportation arrangements.
  nodes 1 start,
        2 finish,
        3 action {fly_transport Honolulu Delta},
        4 action {transport Abyss Delta}, 
        5 action {transport Barnacle Delta}, 
        6 action {transport Calypso Delta},
        7 action {fly_passengers Delta Honolulu},
        8 action {fly_transport Delta Honolulu};
  orderings 1 ---> 3, 3 ---> 8, 8 ---> 2,
            1 ---> 4, 1 ---> 5, 1 ---> 6,
            4 ---> 7, 5 ---> 7, 6 ---> 7, 7 ---> 2;
  effects {at GT1} = Honolulu at 1,
          {at GT2} = Honolulu at 1,
          {at C5} = Honolulu at 1,
          {at B707} = Delta at 1,
          {people_at_POE_from Abyss} = 0 at 1,
          {people_at_POE_from Barnacle} = 0 at 1,
          {people_at_POE_from Calypso} = 0 at 1,
          {in_use_for GT1} = in_transit at 1,
          {in_use_for GT2} = in_transit at 1;
end_task;

task Operation_Paradise;
  ;;; Requires GT3 in type ground_transports to allow its proper use.
  ;;;      but will work without this - not using transport GT3.
  ;;; Scenario with three transports, one available already at Delta.
  nodes 1 start,
        2 finish,
        3 action {fly_transport Honolulu Delta},
        4 action {transport Abyss Delta}, 
        5 action {transport Barnacle Delta}, 
        6 action {transport Calypso Delta},
        7 action {fly_passengers Delta Honolulu},
        8 action {fly_transport Delta Honolulu};
  orderings 1 ---> 3, 3 ---> 4, 3 ---> 5, 3 ---> 6,
            4 ---> 7, 5 ---> 7, 6 ---> 7, 7 ---> 8, 8 ---> 2;
  effects {at GT1} = Honolulu at 1,
          {at GT2} = Honolulu at 1,
          {at GT3} = Delta at 1,
          {at C5} = Honolulu at 1,
          {at B707} = Delta at 1,
          {people_at_POE_from Abyss} = 0 at 1,
          {people_at_POE_from Barnacle} = 0 at 1,
          {people_at_POE_from Calypso} = 0 at 1,
          {in_use_for GT3} = available at 1,
          {in_use_for GT1} = in_transit at 1,
          {in_use_for GT2} = in_transit at 1;
end_task;

schema fly_transport;
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
  expands {fly_transport ?FROM ?TO};
  only_use_for_effects {at GT1} = ?TO,
                       {at GT2} = ?TO;
  conditions achieve {at C5} = ?FROM,    ;;; make air lift available
             unsupervised {at GT1} = ?FROM, ;;; all transport must be
             unsupervised {at GT2} = ?FROM, ;;; ready to go by explicit plan
             unsupervised {in_use_for GT1} = ?USE1,
             unsupervised {in_use_for GT2} = ?USE2;
  effects {at C5} = ?TO,
          {in_use_for GT1} = in_transit at begin_of self,
          {in_use_for GT2} = in_transit at begin_of self,
          {in_use_for GT1} = available at end_of self,
          {in_use_for GT2} = available at end_of self;
end_schema;

;;;schema fly_empty;
;;;
;;; This schema is used simply to return a plan to a needed location
;;; This is not as effective as trying to use planes that are already
;;; at a suitable location in a well scheduled order.
;;;
;;;  vars ?TO = ?{type air_base};
;;;  expands {fly_empty ?TO};
;;;  only_use_for_effects {at C5} = ?TO;
;;;end_schema;

schema road_transport;
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
        2 action {load ?GT ?LOC2},
        3 action {drive ?GT ?LOC3},
        4 action {unload ?GT ?LOC3};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
  conditions only_use_if {country ?LOC2} = ?COUNTRY,
             only_use_if {country ?LOC3} = ?COUNTRY,
             ;;; above only allows one air_base per country at present (92.12).
             ;;; could make unsupervised if need more than 1 - search increased
             ;;; next could be achieve to pick up available transports?
             unsupervised {at ?GT} = ?LOC1 at 1,  ;;; transport from air_base
             unsupervised {country ?LOC1} = ?COUNTRY at 1,
             unsupervised {in_use_for ?GT} = available at 1,
             supervised {in_use_for ?GT} = ?LOC2 at 4 from begin_of 1;
  effects {in_use_for ?GT} = ?LOC2 at begin_of 1,  ;;; reserve transport
          {people_at_POE_from ?LOC2} = 50 at 4;
end_schema;

schema drive;
  vars ?GT   = ?{type ground_transport},
       ?LOC  = ?{type location};
  expands {drive ?GT ?LOC};
  effects {at ?GT} = ?LOC;
end_schema;

schema load;
  vars 	?GT   = ?{type ground_transport},
       	?LOC  = ?{type location};
  expands {load ?GT ?LOC};
  conditions unsupervised {at ?GT} = ?LOC,
             unsupervised {in_use_for ?GT} = ?LOC;
end_schema;

schema unload;
  vars ?GT  = ?{type ground_transport},
       ?LOC = ?{type location};
  expands {unload ?GT ?LOC};
  conditions unsupervised {at ?GT} = ?LOC;
;;; could pick up unsupervised {in_use_for ?GT} = ?LOC2 and have POE effects
  effects {in_use_for ?GT} = available;
end_schema;

schema fly_passengers;
;;; ideally universally quantify {people_at_POE_from ??} = 0;
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
