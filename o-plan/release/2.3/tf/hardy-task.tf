;;;;;;; HARDY generated Task Formalism code 


task operation_columbus; 
 nodes
    1 start,
    2 finish,
    3 dummy,
    4 action {fly_transport Honolulu Delta},
    5 action {transport Abyss Delta},
    6 action {transport Barnacle Delta},
    7 action {transport Calypso Delta},
    8 action {fly_passengers Delta Honolulu},
    9 action {fly_transport Delta Honolulu}; 
 orderings
    1 ---> 4,
    4 ---> 6,
    4 ---> 5,
    4 ---> 7,
    5 ---> 3,
    6 ---> 3,
    7 ---> 3,
    3 ---> 8,
    8 ---> 2,
    3 ---> 9,
    9 ---> 2; 
 effects
    {people_at_POE_from Barnacle} = 0 at 1,
    {in_use_for GT2} = in_transit at 1,
    {in_use_for GT1} = in_transit at 1,
    {people_at_POE_from Calypso} = 0 at 1,
    {people_at_POE_from Abyss} = 0 at 1,
    {at B707} = Delta at 1,
    {at C5} = Honolulu at 1,
    {at GT2} = Honolulu at 1,
    {at GT1} = Honolulu at 1;
end_task;
