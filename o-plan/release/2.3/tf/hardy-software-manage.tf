;;;;;;; HARDY generated Task Formalism code 


types
    module = (MIM NPL PL CA MR time billing disbursements),
    programming_team = (team_A team_B team_C),
    installation_engineer = (engineer_A engineer_B);

task Accounting_and_management_information_system; 
 nodes
    1 start,
    2 finish,
    3 action {build common data dictionary system},
    4 action {master information maintenance system},
    5 action {nominal and private ledger system},
    6 action {time system},
    7 action {client accounting system},
    8 action {management reports system},
    9 action {user system}; 
 orderings
    1 ---> 3,
    1 ---> 4,
    1 ---> 5,
    1 ---> 6,
    1 ---> 7,
    1 ---> 8,
    1 ---> 9,
    3 ---> 2,
    4 ---> 2,
    5 ---> 2,
    6 ---> 2,
    7 ---> 2,
    8 ---> 2,
    9 ---> 2; 
 effects
    {information system completed} at 2,
    {status programming_team team_A} = unallocated at begin_of 1,
    {status programming_team team_B} = unallocated at begin_of 1,
    {status programming_team team_C} = unallocated at begin_of 1,
    {status installation_engineer engineer_A} = unallocated at begin_of 1,
    {status installation_engineer engineer_B} = unallocated at begin_of 1; 
 time_windows
    0~09:00 at 1,
    35~09:00 at 2;
end_task;

schema master_information_maintenance_system; 
 vars
    ?team = ?{type programming_team};
 expands {master information maintenance system}; 
 nodes
    1 action {specify_program MIM},
    2 action {carry_out_programming_and_unit_tests_part_1 MIM},
    3 action {carry_out_programming_and_unit_tests_part_2 MIM},
    4 action {integration_tests MIM},
    5 action {carry_out_subsystem_acceptance_and_tests MIM}; 
 orderings
    1 ---> 2,
    2 ---> 4,
    2 ---> 3,
    3 ---> 5; 
 conditions
    supervised {program_specification MIM} = completed at 2 from [1],
    unsupervised {common data dictionary system} = completed at 2,
    supervised {carry_out_programming_and_unit_tests_part_1 MIM} = completed at 4 from [2],
    supervised {carry_out_programming_and_unit_tests_part_2 MIM} = completed at 5 from [3],
    unsupervised {status programming_team ?team} = unallocated at 1; 
 effects
    {master information maintenance system} = completed at 5,
    {status programming_team ?team} = allocated at begin_of 1,
    {status programming_team ?team} = unallocated at begin_of 5; 
 time_windows
    duration self = between 0 days and 5 days;
end_schema;

schema program_specification; 
 vars
    ?x = ?{type module};
 expands {specify_program ?x}; 
 only_use_for_effects
    {program_specification ?x} = completed;
end_schema;

schema program_tests_1; 
 vars
    ?x = ?{type module};
 expands {carry_out_programming_and_unit_tests_part_1 ?x}; 
 only_use_for_effects
    {programming_and_unit_tests_part_1 ?x} = completed;
end_schema;

schema program_tests_2; 
 vars
    ?x = ?{type module};
 expands {carry_out_programming_and_unit_tests_part_2 ?x}; 
 only_use_for_effects
    {programming_and_unit_tests_part_2 ?x} = completed;
end_schema;

schema integrated_tests; 
 vars
    ?x = ?{type module};
 expands {integration_tests ?x}; 
 only_use_for_effects
    {integrated_tests ?x} = completed;
end_schema;

schema subsystem_acceptance; 
 vars
    ?x = ?{type module};
 expands {carry_out_subsystem_acceptance_and_tests ?x}; 
 only_use_for_effects
    {subsystem_acceptance_tests ?x} = completed;
end_schema;

schema nominal_and_private_ledger_system; 
 vars
    ?team = ?{type programming_team};
 expands {nominal and private ledger system}; 
 nodes
    1 action {specify_program NPL},
    2 action {carry_out_programming_and_unit_tests_part_1 NPL},
    3 action {carry_out_programming_and_unit_tests_part_2 NPL},
    4 action {integration_tests NPL},
    5 action {carry_out_subsystem_acceptance_and_tests NPL}; 
 orderings
    1 ---> 2,
    2 ---> 3,
    2 ---> 4,
    3 ---> 5; 
 conditions
    supervised {program_specification NPL} = completed at 2 from [1],
    supervised {carry_out_programming_and_unit_tests_part_1 NPL} = completed at 4 from [2],
    supervised {carry_out_programming_and_unit_tests_part_2 NPL} = completed at 5 from [3],
    unsupervised {status programming_team ?team} = unallocated at 1; 
 effects
    {nominal and private ledger system} = completed at 5,
    {status programming_team ?team} = allocated at begin_of 1,
    {status programming_team ?team} = unallocated at begin_of 5; 
 time_windows
    duration self = between 0 days and 10 days;
end_schema;

schema time_system; 
 vars
    ?team = ?{type programming_team};
 expands {time system}; 
 nodes
    1 action {specify_program time},
    2 action {carry_out_programming_and_unit_tests_part_1 time},
    3 action {carry_out_programming_and_unit_tests_part_2 time},
    4 action {integration_tests time},
    5 action {carry_out_subsystem_acceptance_and_tests time}; 
 orderings
    1 ---> 2,
    2 ---> 3,
    2 ---> 4,
    3 ---> 5; 
 conditions
    supervised {program_specification time} = completed at 2 from [1],
    supervised {carry_out_programming_and_unit_tests_part_1 time} = completed at 4 from [2],
    supervised {carry_out_programming_and_unit_tests_part_2 time} = completed at 5 from [3],
    unsupervised {status programming_team ?team} = unallocated at 1; 
 effects
    {time system} = completed at 5,
    {status programming_team ?team} = allocated at begin_of 1,
    {status programming_team ?team} = unallocated at begin_of 5; 
 time_windows
    duration self = between 0 days and 5 days;
end_schema;

schema client_accounting; 
 vars
    ?team = ?{type programming_team};
 expands {client accounting system}; 
 nodes
    1 action {specify_program CA},
    2 action {carry_out_programming_and_unit_tests_part_1 CA},
    3 action {carry_out_programming_and_unit_tests_part_2 CA},
    4 action {integration_tests CA},
    5 action {carry_out_subsystem_acceptance_and_tests CA}; 
 orderings
    1 ---> 2,
    2 ---> 3,
    2 ---> 4,
    3 ---> 5; 
 conditions
    supervised {program_specification CA} = completed at 2 from [1],
    supervised {carry_out_programming_and_unit_tests_part_1 CA} = completed at 4 from [2],
    supervised {carry_out_programming_and_unit_tests_part_2 CA} = completed at 5 from [3],
    unsupervised {common data dictionary system} = completed at 2,
    unsupervised {status programming_team ?team} = unallocated at 1; 
 effects
    {client accounting system} = completed at 5,
    {status programming_team ?team} = allocated at begin_of 1,
    {status programming_team ?team} = unallocated at begin_of 5; 
 time_windows
    duration self = between 0 days and 5 days;
end_schema;

schema management_reports_system; 
 vars
    ?team = ?{type programming_team};
 expands {management reports system}; 
 nodes
    1 action {specify_program MR},
    2 action {carry_out_programming_and_unit_tests_part_1 MR},
    3 action {carry_out_programming_and_unit_tests_part_2 MR},
    4 action {integration_tests MR},
    5 action {carry_out_subsystem_acceptance_and_tests MR}; 
 orderings
    1 ---> 2,
    2 ---> 3,
    2 ---> 4,
    3 ---> 5; 
 conditions
    supervised {program_specification MR} = completed at 2 from [1],
    supervised {carry_out_programming_and_unit_tests_part_1 MR} = completed at 4 from [2],
    supervised {carry_out_programming_and_unit_tests_part_2 MR} = completed at 5 from [3],
    unsupervised {common data dictionary system} = completed at 2,
    unsupervised {status programming_team ?team} = unallocated at 1; 
 effects
    {management reports system} = completed,
    {status programming_team ?team} = allocated at begin_of 1,
    {status programming_team ?team} = unallocated at begin_of 5; 
 time_windows
    duration self = between 0 days and 5 days;
end_schema;

schema user_system;
 expands {user system}; 
 nodes
    1 action {perform user and clerical procedures},
    2 action {assemble training material},
    3 action {develop screen menu instructions for terminal operators},
    4 action {document computer operations instructions and JCL};
end_schema;
schema gen6;      ;;; HARDY generated
 expands {build common data dictionary system};
  only_use_for_effects
    {common data dictionary system} = completed;
end_schema;

schema gen7;      ;;; HARDY generated
 expands {perform user and clerical procedures};
  only_use_for_effects
    {user and clerical procedures} = completed;
end_schema;

schema gen8;      ;;; HARDY generated
 expands {assemble training material};
  only_use_for_effects
    {training material} = completed;
end_schema;

schema gen9;      ;;; HARDY generated
 expands {develop screen menu instructions for terminal operators};
  only_use_for_effects
    {screen menu instructions for terminal operators} = completed;
end_schema;

schema gen10;      ;;; HARDY generated
 expands {document computer operations instructions and JCL};
  only_use_for_effects
    {documentation for computer operations instructions and JCL} = completed;
end_schema;

