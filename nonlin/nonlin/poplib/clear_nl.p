vars oplan_terminal_type; undef -> oplan_terminal_type;

define clearscreen;
  comment can be done with
          vedscreenclear() vedscreenflush() if VED present;
  comment can be done in a terminal independent way on UNIX with
          sysobey('clear');
  comment can be done in a Windows Command Window with sysobey('cls');
  comment can be done slowly on any system by scrolling the screen up n lines
          nl(n);
  comment can be done with rawcharout of appropriate characters for the
          particular VDU in use followed by a flush and delay if needed
          rawcharout(<code>) ...  sysflush(popdevraw) syssleep(<ms delay>);
  comment particular form that follows may be altered before NONLIN creation;

  comment see poplib/orig_clear.p for a range of other options that might work;

  nl(24);

enddefine;
