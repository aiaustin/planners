;;; ARPI Tier-1 Search Based Scenario
;;; No negative goals in this scenario
;;;
;;; BAT  31-Mar-94: Initial translation from Matt Ginsberg ARPI example

;;; should really give conditions and effects at same end of a node if
;;; they are instantaneous, not important in this particular formulation
;;;
;;; defaults condition_node_end = begin_of,
;;;          condition_contributor_node_end = begin_of,
;;;          effect_node_end = begin_of;

;;; There is no way to get the population back to the capital once they leave.
;;; You can't ever use sanctions because you can't get France and England to
;;; agree.

task tier_1_search;
  nodes 1 start,
        2 finish;
  orderings 1 ---> 2;
  conditions achieve {pop_safe} at 2,
             achieve {stability} at 2;
  effects {destroyer_available}=true at 1,
          {carrier_available}=true at 1,
          {marines_available}=true at 1,
          {transport_available}=true at 1,
          {pop_in_capital}=true at 1;
end_task;

schema airlift;
  expands {airlift};
  only_use_for_effects {pop_safe}=true;
  conditions achieve {pop_at_airport},
             achieve {air_superiority};
  effects {pop_at_airport}=false;
end_schema;

;;; Airlift has as preconditions that the population be at the
;;; airport and that we have established air superiority.  It
;;; achieves the goal pop_safe and deletes pop_at_airport.

schema sealift;
  expands {sealift};
  only_use_for_effects {pop_safe}=true;
  conditions achieve {pop_at_port},
             achieve {transport_ready};
  effects {pop_at_port}=false;
end_schema;

schema defeat_rebels;
  expands {defeat_rebels};
  only_use_for_effects {stability}=true;
  conditions achieve {ground_superiority},
             achieve {air_superiority};
end_schema;

schema threaten;
  expands {threaten};
  only_use_for_effects {stability}=true;
  conditions achieve {offensive_presence};
end_schema;

schema blockade;
  expands {blockade};
  only_use_for_effects {stability}=true;
  conditions achieve {transport_ready},
             achieve {ground_superiority};
end_schema;

schema sanctions;
  expands {sanctions};
  only_use_for_effects {stability}=true;
  conditions achieve {England_agrees},
             achieve {France_agrees};
end_schema;

schema negotiate_France;
  expands {negotiate_France};
  only_use_for_effects {France_agrees}=true;
  effects {England_agrees}=false;  ;;; this is intended
end_schema;

schema negotiate_England;
  expands {negotiate_England};
  only_use_for_effects {England_agrees}=true;
  effects {France_agrees}=false;   ;;; this is intended
end_schema;

schema drive_to_airport;
  expands {drive_to_airport};
  only_use_for_effects {pop_at_airport}=true;
  conditions achieve {air_superiority},
             achieve {pop_in_capital};
  effects {pop_in_capital}=false;
end_schema;

schema escort_to_ocean;
  expands {escort_to_ocean};
  only_use_for_effects {pop_at_port}=true,
                       {ground_superiority}=true;
  conditions achieve {marines_available},
             achieve {pop_in_capital};
  effects {marines_available}=false,
          {pop_in_capital}=false;
end_schema;

schema engage_rebels;
  expands {engage_rebels};
  only_use_for_effects {ground_superiority}=true,
                       {air_superiority}=true;
  conditions achieve {beachhead};
end_schema;

schema marine_landing;
  expands {marine_landing};
  only_use_for_effects {beachhead}=true;
  conditions achieve {marines_available};
  effects {marines_available}=false;
end_schema;

schema air_ops;
  expands {air_ops};
  only_use_for_effects {air_superiority}=true;
  conditions achieve {carrier_available};
  effects {destroyer_available}=true;
end_schema;

schema move_destroyer;
  expands {move_destroyer};
  only_use_for_effects {offensive_presence}=true;
  conditions achieve {destroyer_available};
  effects {carrier_available}=false;
end_schema;

schema move_transport;
  expands {move_transport};
  only_use_for_effects {transport_ready}=true;
  conditions achieve {transport_available};
end_schema;


