comment 'ROBOT LEVEL BLOCK STACKING PROBLEM FOR NONLIN 2' ;
comment ' BLOCKSC3 - 12-Oct-83' ;

true -> autocond;

primitive {movehand === } {setfingers === };

comment 'PRIMITIVE ALLOWS PATTERNS TO BE TREATED AS IF THEY HAD A NULL
         EXPANSION AND NO EFFECTS (AT THE LEVEL OF PLANNING USED)' ;
         
opschema ehand
  pattern {emptyhand}
  expansion 1 action {movehand { @*x @*y @*highz} }
            2 action {movehand { @*x @*y @*z    } }
            3 action {setfingers @*fingerwidth}
            4 action {movehand { @*x @*y @*highz} }
  orderings sequence 1 to 4
  conditions usewhen {held @*b1} at 1
            compute [ { @*x @*y @*z} = cleararea @*b1]
            compute [ @*highz = + @*z 20]
            compute [ @*width = blockwidth]
            compute [ @*fingerwidth = + @*width 5]
  effects + {emptyhand}
          - {held @*b1}
  vars b1 undef    b2 undef
       x  undef    y  undef    z undef
       highz undef
       width undef fingerwidth undef;
end;

opschema pickup
  pattern {held @*b1}
  expansion 1 goal {emptyhand}
            2 action {movehand { @*x @*y @*highz} }
            3 action {setfingers @*fingerwidth}
            4 action {movehand { @*x @*y @*z    } }
            5 action {setfingers @*width}
            6 action {movehand { @*x @*y @*highz} }
  orderings sequence 1 to 6
  conditions usewhen {cleartop @*b1} at 1
            usewhen {on @*b1 @*b2} at 1
            compute [{ @*x @*y @*z} = position @*b1]
            compute [@*highz = + @*z 20]
            compute [@*width = blockwidth]
            compute [@*fingerwidth = + @*width 5]
  effects + {held @*b1}
          - {emptyhand}
  vars b1 undef    b2 undef    b3 undef
       x undef     y undef     z undef
       highz undef
       width undef fingerwidth undef;
end;

opschema goabove
  pattern {over @*b1}
  expansion 1 action {movehand { @*x @*y @*highz} }
  conditions usewhen {over @*b2} at 1
            compute [ { @*x @*y @*z} = position @*b1]
            compute [ @*highz = + @*z 20]
  effects + {over @*b1}
          - {over @*b2}
  vars b1 undef    b2 <:non @*b1:>
       x undef     y undef     z undef
       highz undef;
end;

actschema putdown
  pattern {putdown @*b1 on @*b2}
  expansion 1 action {movehand { @*x @*y @*lowz} }
            2 action {setfingers @*fingerwidth}
            3 action {movehand { @*x @*y @*highz} }
  orderings sequence 1 to 3
  conditions usewhen {held @*b1} at 1
            usewhen {over @*b2} at 1
            compute [ { @*x @*y @*z} = position @*b2]
            compute [ @*height = blockheight]
            compute [ @*lowz = + @*height @*z]
            compute [ @*width = blockwidth]
            compute [ @*fingerwidth = + @*width 5]
            compute [ @*highz = + @*lowz 20]
  effects + {emptyhand}
          - {held @*b1}
  vars b1 undef    b2 undef
       x undef     y undef     z undef
       lowz undef  highz undef
       height undef
       width undef fingerwidth undef;
end;

actschema puton
  pattern {put @*b1 on top of @*b2}
  expansion 1 goal {held @*b1}
            2 goal {over @*b2}
            3 action {putdown @*b1 on @*b2}
  orderings sequence 1 to 3
  conditions usewhen {cleartop @*b1} at 1
            usewhen {on @*b1 @*b3} at 1
            usewhen {cleartop @*b2} at 2
  effects + {on @*b1 @*b2}
          - {cleartop @*b2}
          - {on @*b1 @*b3}
          + {cleartop @*b3}
  vars b1 undef    b2 <:non table:>    b3 undef;
end;

actschema putontable
  pattern {put @*b1 on top of table}
  expansion 1 goal {held @*b1}
            2 goal {emptyhand}
  orderings 1 ---> 2
  conditions usewhen {cleartop @*b1} at 1
             usewhen {on @*b1 @*b3} at 1
  effects + {on @*b1 table}
          - {on @*b1 @*b3}
          + {cleartop @*b3}
  vars b1 undef    b3 undef;
end;

opschema makeon
  pattern {on @*b1 @*b2}
  expansion 1 goal {cleartop @*b1}
            2 goal {cleartop @*b2}
            3 action {put @*b1 on top of @*b2}
  orderings 1 ---> 3  2 ---> 3
  effects + {on @*b1 @*b2}
          - {cleartop @*b2}
  vars b1 undef    b2 undef;
end;

opschema makeclear
  pattern {cleartop @*b1}
  expansion 1 goal {cleartop @*b2}
            2 action {put @*b2 on top of @*b3}
  orderings 1 ---> 2
  conditions usewhen {on @*b2 @*b1} at 2
             usewhen {cleartop @*b3} at 2
  effects + {cleartop @*b1}
  vars b1 <:non table:>     b2 undef     b3 <:et  <:non @*b1:> <:non @*b2:> :>;
end;

always {cleartop table};

alwayctxt -> cuctxt;

comment 'EXAMPLE OF USE OF NUMERIC DATABASES' ;
8 -> value("blockwidth");
8 -> value("blockheight");

comment 'EXAMPLE COMPUTATIONAL FACILITIES' ;
function cleararea bl;
  1.nl; pr('Give a clear area for ' ); genpr(bl);
  .itread
end;

function position bl; vars qal p;
  comment 'THIS COULD BE A POPPLESTONE-AMBLER POSITION FINDER FROM RELATIONS.
           RETURN {X Y Z} OF CENTRE OF BL' ;
  "on",@@bl,===,3.constrip -> p;
  qaall(p,true,currnode) -> qal; 
  if qal.null then 'block is not on anything' -> qal else hd(qal) -> qal close;
  1.nl; 'Give position (centre) of '.pr; bl.genpr;
  ' when '.pr; qal.genpr;
  .itread
end;

initially {on a b}
          {cleartop a}
          {cleartop c}
          {cleartop d}
          {on b table}
          {on c table}
          {on d table}
          {over d}
          {emptyhand}
          ;
    
comment 'INITIAL SITUATION IS:

                                        I
                                        I
                                      -----
                                       I I
                                       
                    A
                    B          C        D
            ----------------------------------------
            
    ' ;

prcontext();

