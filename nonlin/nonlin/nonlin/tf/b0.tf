comment 'simple block stacking domain for NONLIN 2';
comment ' BLOCKS0 - 12-Oct-83';

true -> autocond;

actschema puton
  pattern {put @*x on top of @*y}
  conditions usewhen {cleartop @*x} at self
             usewhen {cleartop @*y} at self
             usewhen {on @*x @*z} at self
  effects + {on @*x @*y}
          - {cleartop @*y}
          - {on @*x @*z}
          + {cleartop @*z}
  vars x undef     y undef     z undef;
end;

opschema makeon
  pattern {on @*x @*y}
  expansion 1 goal {cleartop @*x}
            2 goal {cleartop @*y}
            3 action {put @*x on top of @*y}
  orderings 1 ---> 3   2 ---> 3
  vars x undef    y undef;
end;

opschema makeclear
  pattern {cleartop @*x}
  expansion 1 goal {cleartop @*y}
            2 action {put @*y on top of @*z}
  orderings 1 ---> 2
  conditions usewhen {on @*y @*x} at 2
             usewhen {cleartop @*z} at 2
  vars x <:non table:>   y undef
       z <:et <:non @*x:> <:non @*y:> :>;
end;

always {cleartop table};

initially {on c a}
          {on a table}
          {on b table}
          {cleartop c}
          {cleartop b} ;

prcontext();
