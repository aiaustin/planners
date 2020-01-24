;;; House Building Domain - larger house building example
;;;
;;; BAT   5-Dec-76: Nonlin TF.
;;; KWC   9-Sep-85: Converted to O-Plan1 TF.
;;; BD   12-May-92: Converted to O-Plan TF.
;;; BAT  30-Nov-92: remove multiple landscape schema names
;;; BAT  30-Jun-93: task schema only_use_for_effect removed

task build_large_house;
  nodes 1 start, 
        2 finish,
        3 action {build house};
  orderings 1 ---> 3, 3 ---> 2;      
end_task;

schema build;
  expands {build house};
  nodes     1 action {obtain building permit},
            2 action {lay foundations},
            3 action {build walls and roof},
            4 action {joinery},
            5 action {decorate and fit},
            6 action {install services},
            7 action {landscape},
            8 action {close out house};
  orderings 1 ---> 2,   2 ---> 3,   2 ---> 4,   2 ---> 5,
            2 ---> 6,   2 ---> 7,   3 ---> 8;
  conditions unsupervised {wooden frame and roof erected} at 5;
end_schema;

schema lay_foundations;
  expands {lay foundations};
  nodes     1 action {clear lot and grade for slab},
            2 action {place concrete forms reinforcement rods and sewer lines},
            3 action {pour slab};
  orderings 1 ---> 2,   2 ---> 3;
  effects {foundations laid};
end_schema;

schema build_walls_and_roof;
  expands {build walls and roof};
  nodes     1 action {erect wooden frame including roof},
            2 action {fasten exterior sheathing},
            3 action {insulate outside walls},
            4 action {sheetrock and plaster inside walls},
            5 action {place insulation in attic},
            6 action {attach gutters and downspouts},
            7 action {shingle roof},
            8 action {lay brickwork exterior walls plus inside fireplace};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4, 4 ---> 5, 5 ---> 6, 1 ---> 7,
	    7 ---> 3,   2 ---> 8,   8 ---> 5;
  conditions unsupervised {foundations laid} at 1,
             unsupervised {rough plumbing installed} at 3,
             unsupervised {rough wiring installed} at 3,
             unsupervised {exterior trim complete} at 8;
end_schema;

schema joinery;
  expands {joinery};
  nodes     1 action {do rough carpentry including window and door frames},
            2 action {do finish carpentry cabinets trim mouldings panelling},
            3 action {sand stain and varnish wood panelling and cabinets},
            4 action {lay formica counter surfaces in kitchen};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
  conditions unsupervised {exterior sheathing fastened} at 1,
             unsupervised {plastering done} at 2;
end_schema;

schema landscape;
  expands {landscape};
  nodes     1 action {grade lay forms for walks and driveways},
            2 action {pour walks and driveway},
            3 action {finish grading},
            4 action {landscape_yard};
  orderings 1 ---> 2, 2 ---> 3, 3 ---> 4;
  conditions unsupervised {brickwork laid} at 1,
             unsupervised {interior and exterior cleaned} at 3;
end_schema;

schema install_services;
  expands {install services};
  nodes     1 action {electrical services},
            2 action {plumbing services},
            3 action {install kitchen appliances},
            4 action {heating and air conditioning};
  orderings 2 ---> 3;
  conditions unsupervised {interior painted} at 3;
end_schema;

schema electrical_services;
  expands {electrical services};
  nodes     1 action {install rough wiring},
            2 action {install electrical outlets switches lighting fixtures},
            3 action {final hookup of electrical system};
  orderings 1 ---> 2, 2 ---> 3;
  conditions unsupervised {wooden frame and roof erected} at 1,
             unsupervised {selected surfaces wallpapered} at 2,
             unsupervised {kitchen appliances installed} at 2,
             unsupervised {hot water heater installed} at 2,
             unsupervised {furnace and air conditioner installed} at 2;
end_schema;

schema plumbing_services;
  expands {plumbing services};
  nodes     1 action {install rough plumbing},
            2 action {install tubs and shower basins},
            3 action {install remaining plumbing fixtures},
            4 action {install hot water heater};
  orderings 1 ---> 2, 2 ---> 3,   1 ---> 4;
  conditions unsupervised {wooden frame and roof erected} at 1,
             unsupervised {plastering done} at 2,
             unsupervised {rough carpentry done} at 2,
             unsupervised {bathroom tiles laid} at 3,
             unsupervised {formica surfaces done} at 3;
end_schema;

schema heating_and_ac;
  expands {heating and air conditioning};
  nodes     1 action {install heating and cooling ducts},
            2 action {install furnace and air conditioner};
  orderings 1 ---> 2;
  conditions unsupervised {wooden frame and roof erected} at 1,
             unsupervised {rough wiring installed} at 2;
  effects {heating and air conditioning installed};
end_schema;

schema decorate;
  expands {decorate and fit};
  nodes     1 action {lay bathroom tiles},
            2 action {sand and paint interior walls and trim},
            3 action {lay flooring wood and vinyl},
            4 action {wallpaper selected surfaces},
            5 action {complete exterior trim},
            6 action {paint exterior trim},
            7 action {clean up interior and exterior including yard},
            8 action {lay carpeting},
            9 action {attach cabinet fixtures};
  orderings 5 ---> 6, 6 ---> 7, 7 ---> 8, 2 ---> 3, 3 ---> 7, 2 ---> 4,
	    2 ---> 9;
  conditions unsupervised {tubs and shower basins installed} at 1,
             unsupervised {plumbing finished} at 2,
             unsupervised {exterior sheathing fastened} at 5,
             unsupervised {gutters and downspouts attached} at 6,
             unsupervised {heating and air conditioning installed} at 7;
end_schema;

schema obtain_permit;
  expands {obtain building permit};
  only_use_for_effects {got permit} = true;
end_schema;

schema clear_and_grade;
  expands {clear lot and grade for slab};
  only_use_for_effects {lot cleared} = true;
end_schema;

schema place_forms;
  expands {place concrete forms reinforcement rods and sewer lines};
end_schema;

schema pour_slab;
  expands {pour slab};
end_schema;

schema erect_wooden_frame;
  expands {erect wooden frame including roof};
  only_use_for_effects {wooden frame and roof erected} = true;
end_schema;

schema fasten_exterior_sheathing;
  expands {fasten exterior sheathing};
  only_use_for_effects {exterior sheathing fastened} = true;
end_schema;

schema install_rough_plumbing;
  expands {install rough plumbing};
  only_use_for_effects {rough plumbing installed} = true;
end_schema;

schema install_rough_wiring;
  expands {install rough wiring};
  only_use_for_effects {rough wiring installed} = true;
end_schema;

schema insulate_outside;
  expands {insulate outside walls};
end_schema;

schema plaster_inside;
  expands {sheetrock and plaster inside walls};
  only_use_for_effects {plastering done} = true;
end_schema;

schema rough_carpentry;
  expands {do rough carpentry including window and door frames};
  only_use_for_effects {rough carpentry done} = true;
end_schema;

schema finish_carpentry;
  expands {do finish carpentry cabinets trim mouldings panelling};
end_schema;

schema sand_and_varnish;
  expands {sand stain and varnish wood panelling and cabinets};
end_schema;

schema do_kitchen_surfaces;
  expands {lay formica counter surfaces in kitchen};
  only_use_for_effects {formica surfaces done} = true;
end_schema;

schema install_tubs;
  expands {install tubs and shower basins};
  only_use_for_effects {tubs and shower basins installed} = true;
end_schema;

schema do_tiles;
  expands {lay bathroom tiles};
  only_use_for_effects {bathroom tiles laid} = true;
end_schema;

schema install_remaining_plumbing;
  expands {install remaining plumbing fixtures};
  only_use_for_effects {plumbing finished} = true;
end_schema;

schema sand_and_paint;
  expands {sand and paint interior walls and trim};
  only_use_for_effects {interior painted} = true;
end_schema;

schema lay_flooring;
  expands {lay flooring wood and vinyl};
end_schema;

schema do_wallpaper;
  expands {wallpaper selected surfaces};
  only_use_for_effects {selected surfaces wallpapered} = true;
end_schema;

schema install_kitchen;
  expands {install kitchen appliances};
  only_use_for_effects {kitchen appliances installed} = true;
end_schema;

schema install_water_heater;
  expands {install hot water heater};
  only_use_for_effects {hot water heater installed} = true;
end_schema;

schema install_heating;
  expands {install heating and cooling ducts};
end_schema;

schema install_furnace;
  expands {install furnace and air conditioner};
  only_use_for_effects {furnace and air conditioner installed} = true;
end_schema;

schema complete_trim;
  expands {complete exterior trim};
  only_use_for_effects {exterior trim complete} = true;
end_schema;

schema lay_brickwork;
  expands {lay brickwork exterior walls plus inside fireplace};
  only_use_for_effects {brickwork laid} = true;
end_schema;

schema single_roof;
  expands {shingle roof};
end_schema;

schema attach_gutters;
  expands {attach gutters and downspouts};
  only_use_for_effects {gutters and downspouts attached} = true;
end_schema;

schema paint_exterior;
  expands {paint exterior trim};
end_schema;

schema place_insulation;
  expands {place insulation in attic};
end_schema;

schema lay_walks;
  expands {grade lay forms for walks and driveways};
end_schema;

schema pour_walks;
  expands {pour walks and driveway};
end_schema;

schema finish_grading;
  expands {finish grading};
end_schema;

schema landscape_yard;
  expands {landscape_yard};
end_schema;

schema install_switches;
  expands {install electrical outlets switches lighting fixtures};
end_schema;

schema final_hookup;
  expands {final hookup of electrical system};
end_schema;

schema clean_up;
  expands {clean up interior and exterior including yard};
  only_use_for_effects {interior and exterior cleaned} = true;
end_schema;

schema carpet;
  expands {lay carpeting};
end_schema;

schema attach_cabinet_fixtures;
  expands {attach cabinet fixtures};
end_schema;

schema close_out;
  expands {close out house};
end_schema;

