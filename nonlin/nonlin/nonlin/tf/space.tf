comment 'Space Platform TF';
comment 'Austin Tate - 20-Feb-90';

false -> autocond; comment 'manual supervised conditions entry';

primitive {joint === === === === }
          {truss === === === === === }
          {module === === === === === }
          {tube === === === === === }
          {radiator === === === === === === }
          {solar_panel === === === === === === ===}
          {antenna === === === === === === }
          ;

actschema platform_1
  pattern {build platform}
  expansion 1 dummy
            2 action {place_joint A}
            3 action {place_joint B}
            4 action {place_joint C}
            5 action {place_truss 3 A B B D}
            6 action {place_truss 5 B B C D}
            7 action {place_module 100 B C none none}
            8 action {place_module  40 B A none none}
            9 dummy
           10 action {place_radiator 40 20 A A}
           11 action {place_radiator 40 20 A C}
           12 action {place_solar_panel 60 40 20 A E}
           13 action {place_solar_panel 60 40 20 A F}
           14 action {place_solar_panel 60 40 20 C E}
           15 action {place_solar_panel 60 40 20 C F}
           16 action {place_antenna 30 20 C C}
  orderings 1 ---> 2 1 ---> 3 1 ---> 4 1 ---> 5 1 ---> 6 1 ---> 7 1 ---> 8
            2 ---> 9 3 ---> 9 4 ---> 9 5 ---> 9 6 ---> 9 7 ---> 9 8 ---> 9
            9 ---> 10 9 ---> 11 9 ---> 12 9 ---> 13 9 ---> 14
            9 ---> 15 9 ---> 16
end;

actschema platform_2
  pattern {build small_platform}
  expansion 1 dummy
            2 action {place_joint A}
            3 action {place_module 100 A D none none}
            4 dummy
            5 action {place_radiator 30 10 A A}
            6 action {place_solar_panel 100 20 20 A E}
            7 action {place_solar_panel 100 20 20 A F}
            8 action {place_antenna 30 20 A C}
  orderings 1 ---> 2 1 ---> 3 2 ---> 4 3 ---> 5
            4 ---> 5 4 ---> 6 4 ---> 7 4 ---> 8
end;

actschema platform_3
  pattern {build large_platform}
  expansion 1 dummy
            2 action {place_joint A}
            3 action {place_joint B}
            4 action {place_joint C}
            5 action {place_joint D}
            6 action {place_joint E}
            7 action {place_joint F}
            8 action {place_joint G}
            9 action {place_joint H}
           10 action {place_tube 40 C B D D}
           11 action {place_tube 10 G C none none}
           12 action {place_tube 10 H C none none}
           13 action {place_truss 3 A B B D}
           14 action {place_truss 5 B B C D}
           15 action {place_truss 3 D B E D}
           16 action {place_truss 3 E B F D}
           17 action {place_module 100 C C G A}
           18 action {place_module 100 D C H A}
           19 action {place_module  40 G B H D}
           20 action {place_module  60 C A none none}
           21 action {place_module  40 D A none none}
           22 dummy
           23 action {place_radiator 60 20 A A}
           24 action {place_radiator 60 20 A C}
           25 action {place_solar_panel 60 40 20 B E}
           26 action {place_solar_panel 60 40 20 B F}
           27 action {place_solar_panel 60 40 20 E E}
           28 action {place_solar_panel 60 40 20 E F}
           29 action {place_solar_panel 60 40 20 F E}
           30 action {place_solar_panel 60 40 20 F F}
           31 action {place_antenna 20 20 B C}
           32 action {place_antenna 80 20 F C}
  orderings 1 ---> 2 1 ---> 3 1 ---> 4 1 ---> 5 1 ---> 6 1 ---> 7 1 ---> 8
            1 ---> 9 1 ---> 10 1 ---> 11 1 ---> 12 1 ---> 13 1 ---> 14
            1 ---> 15 1 ---> 16 1 ---> 17 1 ---> 18 1 ---> 19 1 ---> 20
            1 ---> 21
            2 ---> 22 3 ---> 22 4 ---> 22 5 ---> 22 6 ---> 22 7 ---> 22
            8 ---> 22 9 ---> 22 10 ---> 22 11 ---> 22 12 ---> 22
            13 ---> 22 14 ---> 22 15 ---> 22 16 ---> 22 17 ---> 22
            18 ---> 22 19 ---> 22 20 ---> 22 21 ---> 22
            22 ---> 23 22 ---> 24 22 ---> 25 22 ---> 26 22 ---> 27
            22 ---> 28 22 ---> 29 22 ---> 30 22 ---> 31 22 ---> 32
end;

actschema one_joint_1
  pattern {place_joint @*j}
  expansion 1 action {joint @*j @*x @*y @*z}
  conditions usewhen {anchored @*j} at 1
             usewhen {location @*j {@*x @*y @*z}} at 1
  effects +{joint_at @*j @*x @*y @*z}
  vars j <:non none:> x undef y undef z undef
end;

actschema one_joint_2
  pattern {place_joint @*j}
  expansion 1 action {joint @*j @*x @*y @*z}
  conditions usewhen {location @*j {@*x @*y @*z}} at 1
             unsupervised {anchored @*j} at 1
  effects +{joint_at @*j @*x @*y @*z}
  vars j <:non none:> x undef y undef z undef
end;

opschema one_joint_3
  pattern {joint_at @*j @*x @*y @*z}
  expansion 1 action {joint @*j @*x @*y @*z}
  conditions usewhen {location @*j {@*x @*y @*z}} at 1
             unsupervised {anchored @*j} at 1
  effects +{joint_at @*j @*x @*y @*z}
  vars j <:non none:> x undef y undef z undef
end;

actschema one_truss_1
  pattern {place_truss @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j1 @*x @*y @*z}
            2 action {truss @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j1 {@*x @*y @*z}} at 1
             usewhen {port_at @*p1 @*code} at 1
             supervised {joint_at @*j1 @*x @*y @*z} at 2 from 1
  effects +{truss_at @*len @*x @*y @*z @*code}
          +{anchored @*j2}
  vars len undef j1 <:non none:> p1 undef j2 undef p2 undef
       x undef y undef z undef code undef
end;

actschema one_truss_2
  pattern {place_truss @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j2 @*x @*y @*z}
            2 action {truss @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j2 {@*x @*y @*z}} at 1
             usewhen {port_at @*p2 @*code} at 1
             supervised {joint_at @*j2 @*x @*y @*z} at 2 from 1
  effects +{truss_at @*len @*x @*y @*z @*code}
          +{anchored @*j1}
  vars len undef j1 undef p1 undef j2 <:non none:> p2 undef
       x undef y undef z undef code undef
end;

comment 'usewhen to check that this is a real joint - allows for "none" ';

actschema one_tube_1
  pattern {place_tube @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j1 @*x @*y @*z}
            2 action {tube @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j1 {@*x @*y @*z}} at 1
             usewhen {port_at @*p1 @*code} at 1
             supervised {joint_at @*j1 @*x @*y @*z} at 2 from 1
  effects +{tube_at @*len @*x @*y @*z @*code}
          +{anchored @*j2}
  vars len undef j1 <:non none:> p1 undef j2 undef p2 undef
       x undef y undef z undef code undef
end;

actschema one_tube_2
  pattern {place_tube @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j2 @*x @*y @*z}
            2 action {tube @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j2 {@*x @*y @*z}} at 1
             usewhen {port_at @*p2 @*code} at 1
             supervised {joint_at @*j2 @*x @*y @*z} at 2 from 1
  effects +{tube_at @*len @*x @*y @*z @*code}
          +{anchored @*j1}
  vars len undef j1 undef p1 undef j2 <:non none:> p2 undef
       x undef y undef z undef code undef
end;

actschema one_module_1
  pattern {place_module @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j1 @*x @*y @*z}
            2 action {module @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j1 {@*x @*y @*z}} at 1
             usewhen {port_at @*p1 @*code} at 1
             supervised {joint_at @*j1 @*x @*y @*z} at 2 from 1
  effects +{module_at @*len @*x @*y @*z @*code}
          +{anchored @*j2}
  vars len undef j1 <:non none:> p1 undef j2 undef p2 undef
       x undef y undef z undef code undef
end;

actschema one_module_2
  pattern {place_module @*len @*j1 @*p1 @*j2 @*p2}
  expansion 1 goal {joint_at @*j2 @*x @*y @*z}
            2 action {module @*len @*x @*y @*z @*code}
  orderings 1 ---> 2
  conditions usewhen {location @*j2 {@*x @*y @*z}} at 1
             usewhen {port_at @*p2 @*code} at 1
             supervised {joint_at @*j2 @*x @*y @*z} at 2 from 1
  effects +{module_at @*len @*x @*y @*z @*code}
          +{anchored @*j1}
  vars len undef j1 undef p1 undef j2 <:non none:> p2 undef
       x undef y undef z undef code undef
end;

actschema radiator
  pattern {place_radiator @*len @*width @*j1 @*p1}
  expansion 1 action {radiator @*len @*width @*x @*y @*z @*code}
  conditions usewhen {joint_at @*j1 @*x @*y @*z} at 1
             usewhen {port_at @*p1 @*code} at 1
  effects +{radiator_at @*len @*width @*x @*y @*z @*code}
  vars len undef width undef j1 <:non none:> p1 undef
       x undef y undef z undef code undef
end;

actschema solar_panel
  pattern {place_solar_panel @*len @*width @*rot @*j1 @*p1}
  expansion 1 action {solar_panel @*len @*width @*rot @*x @*y @*z @*code}
  conditions usewhen {joint_at @*j1 @*x @*y @*z} at 1
             usewhen {port_at @*p1 @*code} at 1
  effects +{solar_panel_at @*len @*width @*rot @*x @*y @*z @*code}
  vars len undef width undef rot undef j1 <:non none:> p1 undef
       x undef y undef z undef code undef
end;

actschema antenna
  pattern {place_antenna @*width @*rot @*j1 @*p1}
  expansion 1 action {antenna @*width @*rot @*x @*y @*z @*code}
  conditions usewhen {joint_at @*j1 @*x @*y @*z} at 1
             usewhen {port_at @*p1 @*code} at 1
  effects +{antenna_at @*width @*rot @*x @*y @*z @*code}
  vars width undef rot undef j1 <:non none:> p1 undef
       x undef y undef z undef code undef
end;

comment 'initially for platform, alternatives given here for small_platform';
comment 'and large_platform';

comment 'small_platform:-

initially {anchored A}
          {location A {500 250 200}
          ;

         platform:-

initially {anchored A}
          {location A {100 150 0}}
          {location B {180 150 0}}
          {location C {300 150 0}}
          ;

         large_platform:-

initially {anchored A}
          {location A {100 150 0}}
          {location B {180 150 0}}
          {location C {300 150 0}}
          {location D {360 150 0}}
          {location E {440 150 0}}
          {location F {520 150 0}}
          {location G {300  30 0}}
          {location H {360  30 0}}
          ;
';
          
initially {anchored A}
          {location A {100 150 0}}
          {location B {180 150 0}}
          {location C {300 150 0}}
          {location D {360 150 0}}
          {location E {440 150 0}}
          {location F {520 150 0}}
          {location G {300  30 0}}
          {location H {360  30 0}}
          ;

always {port_at A  90}
       {port_at B   0}
       {port_at C -90}
       {port_at D 180}
       {port_at E   1}
       {port_at F  -1}
       ;

prcontext();

vars ok_preds;
[joint_at truss_at tube_at module_at radiator_at solar_panel_at antenna_at]
  -> ok_preds;

define drop_at p; vars len i;
  comment 'print a word without last three characters ("_at")';
  destword(p) -> len;
  .erase; .erase; .erase; comment 'last three characters on stack removed';
  (len-3).consword.pr;
enddefine;

define domain_effect_pr p v; vars i pred start;
  if p.isitem then itemid(p) -> p; endif;
  itemid(subscrv(1,p)) -> pred;
  if not(member(pred,ok_preds)) then return; endif;
  pr("(");
  drop_at(pred); 
  if pred="joint_at" then 3 -> start else 2 -> start; endif;
  comment 'drop joint name for effect output';
  for i from start to datalength(p) do 1.sp; genpr(subscrv(i,p)) endfor;
  pr(")"); 1.nl;
enddefine;
