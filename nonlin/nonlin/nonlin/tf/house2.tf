comment '12-Oct-83  -  House building 2 for NonLin
         Austin Tate';

actschema build
  pattern {build house}
  expansion 1 action {obtain building permit}
            2 action {lay foundations}
            3 action {build walls and roof}
            4 action {joinery}
            5 action {decorate and fit}
            6 action {install services}
            7 action {landscape}
            8 action {close out house}
  orderings 1 ---> 2   2 ---> 3   2 ---> 4   2 ---> 5
            2 ---> 6   2 ---> 7   3 ---> 8
  conditions unsupervised {wooden frame and roof erected} at 5
end;

actschema anonymous
  pattern {lay foundations}
  expansion 1 action {clear lot and grade for slab}
            2 action {place concrete forms,reinforcement rods and sewer lines}
            3 action {pour slab}
  orderings 1 ---> 2   2 ---> 3
  effects + {foundations laid}
end;

actschema anonymous
  pattern {build walls and roof}
  expansion 1 action {erect wooden frame, including roof}
            2 action {fasten exterior sheathing}
            3 action {insulate outside walls}
            4 action {sheetrock and plaster inside walls}
            5 action {place insulation in attic}
            6 action {attach gutters and downspouts}
            7 action {shingle roof}
            8 action {lay brickwork (exterior walls plus inside fireplace) }
  orderings sequence 1 to 6   1 ---> 7   7 ---> 3   2 ---> 8   8 ---> 5
  conditions unsupervised {foundations laid} at 1
             unsupervised {rough plumbing installed} at 3
             unsupervised {rough wiring installed} at 3
             unsupervised {exterior trim complete} at 8
end;

actschema anonymous
  pattern {joinery}
  expansion 1 action {do rough carpentry: including window and door frames}
            2 action {do finish carpentry: cabinets,trim mouldings, panelling}
            3 action {sand, stain and varnish wood panelling and cabinets}
            4 action {lay formica counter surfaces in kitchen}
  orderings sequence 1 to 4
  conditions unsupervised {exterior sheathing fastened} at 1
             unsupervised {plastering done} at 2
end;

actschema anonymous
  pattern {landscape}
  expansion 1 action {grade, lay forms for walks and driveways}
            2 action {pour walks and driveway}
            3 action {finish grading}
            4 action {landscape yard}
  orderings sequence 1 to 4
  conditions unsupervised {brickwork laid} at 1
             unsupervised {interior and exterior cleaned} at 3
end;

actschema anonymous
  pattern {install services}
  expansion 1 action {electrical services}
            2 action {plumbing services}
            3 action {install kitchen appliances}
            4 action {heating and air conditioning}
  orderings 2 ---> 3
  conditions unsupervised {interior painted} at 3
end;

actschema anonymous
  pattern {electrical services}
  expansion 1 action {install rough wiring}
            2 action {install electrical outlets,switches,lighting fixtures}
            3 action {final hookup of electrical system}
  orderings sequence 1 to 3
  conditions unsupervised {wooden frame and roof erected} at 1
             unsupervised {selected surfaces wallpapered} at 2
             unsupervised {kitchen appliances installed} at 2
             unsupervised {hot water heater installed} at 2
             unsupervised {furnace and air conditioner installed} at 2
end;

actschema anonymous
  pattern {plumbing services}
  expansion 1 action {install rough plumbing}
            2 action {install tubs and shower basins}
            3 action {install remaining plumbing fixtures}
            4 action {install hot water heater}
  orderings sequence 1 to 3   1 ---> 4
  conditions unsupervised {wooden frame and roof erected} at 1
             unsupervised {plastering done} at 2
             unsupervised {rough carpentry done} at 2
             unsupervised {bathroom tiles laid} at 3
             unsupervised {formica surfaces done} at 3
end;

actschema anonymous
  pattern {heating and air conditioning}
  expansion 1 action {install heating and cooling ducts}
            2 action {install furnace and air conditioner}
  orderings 1 ---> 2
  conditions unsupervised {wooden frame and roof erected} at 1
             unsupervised {rough wiring installed} at 2
  effects + {heating and air conditioning installed}
end;

actschema anonymous
  pattern {decorate and fit}
  expansion 1 action {lay bathroom tiles}
            2 action {sand and paint interior walls and trim}
            3 action {lay flooring (wood and vinyl) }
            4 action {wallpaper selected surfaces}
            5 action {complete exterior trim}
            6 action {paint exterior trim}
            7 action {clean up interior and exterior, including yard}
            8 action {lay carpeting}
            9 action {attach cabinet fixtures}
  orderings sequence 5 to 8   2 ---> 3   3 ---> 7   2 ---> 4   2 ---> 9
  conditions unsupervised {tubs and shower basins installed} at 1
             unsupervised {plumbing finished} at 2
             unsupervised {exterior sheathing fastened} at 5
             unsupervised {gutters and downspouts attached} at 6
             unsupervised {heating and air conditioning installed} at 7
end;

primitive
  {obtain building permit}
  {clear lot and grade for slab}
  {place concrete forms, reinforcement rods and sewer lines}
  {pour slab}
  {erect wooden frame, including roof}
       with effect + {wooden frame and roof erected}
  {fasten exterior sheathing}
       with effect + {exterior sheathing fastened}
  {install rough plumbing}
       with effect + {rough plumbing installed}
  {install rough wiring}
       with effect + {rough wiring installed}
  {insulate outside walls}
  {sheetrock and plaster inside walls}
       with effect + {plastering done}
  {do rough carpentry: including window and door frames}
       with effect + {rough carpentry done}
  {do finish carpentry: cabinets, trim mouldings, panelling}
  {sand, stain and varnish wood panelling and cabinets}
  {lay formica counter surfaces in kitchen}
       with effect + {formica surfaces done}
  {install tubs and shower basins}
       with effect + {tubs and shower basins installed}
  {lay bathroom tiles}
       with effect + {bathroom tiles laid}
  {install remaining plumbing fixtures}
       with effect + {plumbing finished}
  {sand and paint interior walls and trim}
       with effect + {interior painted}
  {lay flooring (wood and vinyl) }
  {wallpaper selected surfaces}
       with effect + {selected surfaces wallpapered}
  {install kitchen appliances}
       with effect + {kitchen appliances installed}
  {install hot water heater}
       with effect + {hot water heater installed}
  {install heating and cooling ducts}
  {install furnace and air conditioner}
       with effect + {furnace and air conditioner installed}
  {complete exterior trim}
       with effect + {exterior trim complete}
  {lay brickwork (exterior walls plus inside fireplace) }
       with effect + {brickwork laid}
  {shingle roof}
  {attach gutters and downspouts}
       with effect + {gutters and downspouts attached}
  {paint exterior trim}
  {place insulation in attic}
  {grade, lay forms for walks and driveways}
  {pour walks and driveway}
  {finish grading}
  {landscape yard}
  {install electrical outlets, switches, lighting fixtures}
  {final hookup of electrical system}
  {clean up interior and exterior, including yard}
       with effect + {interior and exterior cleaned}
  {lay carpeting}
  {attach cabinet fixtures}
  {close out house}
;

'[house2 TF] ready'.pr; 1.nl;
