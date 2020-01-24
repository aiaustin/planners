;;; File: island-rescue-1a.tf
;;; Contains: TF for Pacifica-style evacuations
;;; Created: Jeff Dalton, 24 Sep 94
;;; Updated: Mon Jul  3 19:59:07 1995

;;; This is a variation on island-rescue-1.tf.  It separates the GT
;;; allocation from the decisions about how many to transport.  Of
;;; course, this won't work if different GTs have different capacity.
;;; But then, neither would our previous approach, because it needs
;;; to obtain the capacity w/o dealing with PSVs.

;;; It's not clear that this is an improvement, because the plans are
;;; much more cluttered (which was already a problem, because of the
;;; ends of "evacuate" nodes around all the "drive"s).

;;; N.B. Requires an O-Plan version *later than* 2.2.

;;; Island-rescue is a Pacifica domain, but goes about things differently.
;;; Some things are simplified.  E.g. we don't check what country a city
;;; is in before driving it, and road transportation isn't broken down
;;; into drive, load, and unload steps.  OTOH, we try to do more with
;;; "resources".

;;; A City contains a particular number of people to be evacuated.
;;; GTs have a capacity, so more than one trip to a city may be needed.

;;; This version explores an alternative to the M&C-derived approach
;;; used in island-rescue-0.

types ground_transport = (GT1 GT2),
      air_transport    = (C5 B707),
      country          = (Pacifica Hawaii_USA),
      location         = (Abyss Barnacle Calypso Delta Honolulu),
      city             = (Abyss Barnacle Calypso Delta),
      air_base         = (Delta Honolulu);

always {country Abyss} = Pacifica,
       {country Barnacle} = Pacifica,
       {country Calypso} = Pacifica,
       {country Delta} = Pacifica,
       {country Honolulu} = Hawaii_USA,

       {evacuate_to Delta};   ;;; the evacuation point in Pacifica


;;; Task Evacuate_to_Delta evacuates prople from Abyss, Barnacle and
;;; Calypso to Delta.  It used GTs already present in Delta so that
;;; no air transport is needed.

task Evacuate_to_Delta;
  nodes sequential 
          1 start,
          parallel
            3 action {evacuate Abyss 50},
            4 action {evacuate Barnacle 100}
;;;            5 action {evacuate Calypso 20}
          end_parallel,
          2 finish
        end_sequential;
  effects {at GT1} = Delta at 1,
          {at GT2} = Delta at 1,
          {in_use_for GT1} = available at 1,
          {in_use_for GT2} = available at 1,
          {gt_capacity 30} at 1;
end_task;

;;; Task Evacuate_to_Hawaii shows what happens when air transport is
;;; added. 

task Evacuate_to_Hawaii;
  nodes sequential 
          1 start,
          3 action {fly_transport_in_theater Honolulu Delta},
          parallel
            4 action {evacuate Abyss 50},
            5 action {evacuate Barnacle 100}
;;;            6 action {evacuate Calypso 20}
          end_parallel,
          parallel
            6 action {fly_passengers Delta Honolulu},
            7 action {fly_transport_out_of_theater Delta Honolulu}
          end_parallel,
          2 finish
        end_sequential;
  effects {gt_capacity 50} at 1;
end_task;

;;; Task Large_one_city_evacuation uses lower-capacity GTs so that more
;;; trips are required -- the "large" is relative to GT capacity.  GT
;;; allocation is simplified by evacuating only one city.

task Large_one_city_evacuation;
  nodes sequential 
          1 start,
          3 action {evacuate Barnacle 100},
          2 finish
        end_sequential;
  effects {at GT1} = Delta at 1,
          {at GT2} = Delta at 1,
          {in_use_for GT1} = available at 1,
          {in_use_for GT2} = available at 1,
          {gt_capacity 25} at 1;
  time_windows 0..12 hours at end_of 2;
end_task;

;;; The "Fast" version can be done only if some road transport steps
;;; occur in parallel.  There are enough GTs to do two at once.

task Fast_large_one_city_evacuation;
  nodes sequential 
          1 start,
          3 action {evacuate Barnacle 100},
          2 finish
        end_sequential;
  effects {at GT1} = Delta at 1,
          {at GT2} = Delta at 1,
          {in_use_for GT1} = available at 1,
          {in_use_for GT2} = available at 1,
          {gt_capacity 25} at 1;
  time_windows 0..6 hours at end_of 2;
end_task;


;;; Road transport

;;; This is simplified, e.g. by not modelling where each GT is.
;;; In_use_for suffices to keep GTs from being used "impossibly",
;;; because they're never "available" unless in the right place.

;;; The recursive expansion results in long node numbers...

schema null_evacuation;
  vars ?city   = ?{type city};
  expands {evacuate ?city 0};
  time_windows duration self = 0;
end_schema;

schema road_evacuation;
  vars ?from     = ?{type city},
       ?n        = ?{and ?{satisfies numberp} ?{satisfies > 0}},
       ?capacity = ?{satisfies numberp},
       ?take     = ?{satisfies numberp},
       ?leave    = ?{satisfies numberp};
  expands {evacuate ?from ?n};
  nodes 1 action {by_road ?take from ?from},
        2 action {evacuate ?from ?leave};
  conditions only_use_if {gt_capacity ?capacity},
             compute {min ?n ?capacity} = ?take,
             compute {- ?n ?take} = ?leave;
end_schema;

schema drive;
  vars ?from     = ?{type city},
       ?take     = ?{satisfies numberp},
       ?gt       = ?{type ground_transport};
  expands {by_road ?take from ?from};
  nodes 1 action {drive ?take in ?gt from ?from};
  conditions unsupervised {in_use_for ?gt} = available,
               supervised {in_use_for ?gt} = ?from
                          at end_of self from begin_of self;
  effects {in_use_for ?gt} = ?from at begin_of self,
          {in_use_for ?gt} = available at end_of self;
  time_windows duration self = 3 hours .. 4 hours;
end_schema;

;;; A primitive
schema primitive_drive;
  vars ?from     = ?{type city},
       ?take     = ?{satisfies numberp},
       ?gt       = ?{type ground_transport};
  expands {drive ?take in ?gt from ?from};
end_schema;

;;; Simple air transport

;;; It may seen that these schemas are *too* simple, but the added
;;; complexity of the Pacifica.tf versions doesn't accomplish anything
;;; interesting.

schema simple_fly_transport1;
  vars ?from = ?{type air_base},
       ?to   = ?{type air_base};
  expands {fly_transport_in_theater ?from ?to};
  effects {at GT1} = ?to,
          {at GT2} = ?to,
          {in_use_for GT1} = available,
          {in_use_for GT2} = available;
end_schema;

schema simple_fly_transport2;
  vars ?from = ?{type air_base},
       ?to   = ?{type air_base};
  expands {fly_transport_out_of_theater ?from ?to};
  effects {at GT1} = ?to,
          {at GT2} = ?to,
          {in_use_for GT1} = unavailable,
          {in_use_for GT2} = unavailable;
end_schema;

schema simple_fly_passengers;
  vars ?to   = ?{type air_base},
       ?from = ?{type air_base};
  expands {fly_passengers ?from ?to};
end_schema;


;;; End
