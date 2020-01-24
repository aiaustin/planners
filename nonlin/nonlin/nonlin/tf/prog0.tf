comment 'a simple programming example with multiple ways to achieve a result
         Also shows use of @@true  and @@false form in compute conditions
         Austin Tate, 25-Oct-83';

true -> autocond;

actschema incr
  pattern {increment level}
  conditions usewhen {at level @*x} at self
             compute [@*y = + @*x 1]
  effects - {at level @*x}
          + {at level @*y}
  vars x undef y undef
end;

actschema decr
  pattern {decrement level}
  conditions usewhen {at level @*x} at self
             compute [@*y = - @*x 1]
  effects - {at level @*x}
          + {at level @*y}
  vars x undef y undef
end;

primitive {level = level + === } {level = level - === } ;

cost {increment level}      1
     {decrement level}      1 
     {level = level + === } 3
     {level = level - === } 3;

opschema doincr
  pattern {at level @*x}
  expansion 1 dummy
            2 goal {at level @*y}
            3 action {increment level}
  orderings 1 ---> 2  2 ---> 3
  conditions usewhen {at level @*z} at 1
             compute [@@true = > @*x @*z]
             compute [@*y = - @*x 1]
  vars x undef y undef z undef
end;


opschema dodecr
  pattern {at level @*x}
  expansion 1 goal {at level @*y}
            2 action {decrement level}
  orderings 1 ---> 2
  conditions usewhen {at level @*z} at 1
             compute [@@true = < @*x @*z]
             compute [@*y = + @*x 1]
  vars x undef y undef z undef
end;

opschema doadd
  pattern {at level @*x}
  expansion action {level = level + @*diff}
  conditions usewhen {at level @*y} at self
             compute [@@true = > @*x @*y]
             compute [@*diff = - @*x @*y]
  effects - {at level @*y}
          + {at level @*x}
  vars x undef y undef diff undef
end;

opschema dosub
  pattern {at level @*x}
  expansion action {level = level - @*diff}
  conditions usewhen {at level @*y} at self
             compute [@@true = < @*x @*y]
             compute [@*diff = - @*y @*x]
  effects - {at level @*y}
          + {at level @*x}
  vars x undef y undef diff undef
end;

initially {at level 5};

prcontext();
