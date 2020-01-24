;;;;;;; HARDY generated Task Formalism code 


task operation_columbus; 
 nodes
    1 start,
    2 finish,
    3 action {fly_transport Honolulu Delta},
    4 action {transport Abyss Delta},
    5 action {transport Barnacle Delta},
    6 action {transport Calypso Delta},
    7 dummy,
    8 action {fly_transport Delta Honolulu},
    9 action {fly_passengers Delta Honolulu};

 orderings
    8 ---> 2,
    3 ---> 6,
    3 ---> 5,
    3 ---> 4,
    1 ---> 3,
    4 ---> 7,
    5 ---> 7,
    6 ---> 7,
    7 ---> 8,
    7 ---> 9,
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
