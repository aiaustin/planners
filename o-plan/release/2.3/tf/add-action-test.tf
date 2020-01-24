task Operation_Columbus;
  nodes sequential 
          1 start,
          3 action {fly_transport Honolulu Delta},
          parallel
            4 action {evacuate Abyss 50},
            5 action {evacuate Barnacle 100},
            6 dummy  ;;; 6 action {evacuate Calypso 20}
          end_parallel,
          7 dummy,
          parallel
            8 action {fly_passengers Delta Honolulu},
            9 action {fly_transport Delta Honolulu}
          end_parallel,
          2 finish
        end_sequential;
  effects {all_out} = true at begin_of 7;
end_task;


;;; Task Evacuate_to_Delta evacuates prople from Abyss, Barnacle and
;;; Calypso to Delta.  It used GTs already present in Delta so that
;;; no air transport is needed.

task Evacuate_to_Delta;
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
  nodes 1 action {drive ?take in ?gt from ?from};
  conditions only_use_if {evacuate_to ?to},
             unsupervised {transport_available} = true at begin_of self,
             unsupervised {all_out} = false at end_of self,
             unsupervised {in_use_for ?gt} = available at begin_of self,
               supervised {in_use_for ?gt} = ?from
                          at end_of self from begin_of self;
  effects {in_use_for ?gt} = ?from at begin_of self,
          {in_use_for ?gt} = available at end_of self;
end_schema;


;;; A primitive

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

