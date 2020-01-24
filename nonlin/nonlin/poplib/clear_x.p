define clearscreen;
  rawcharout(27);      rawcharout(`[`);      rawcharout(`;`);
  rawcharout(`H`);     rawcharout(27);       rawcharout(`[`);
  rawcharout(`2`);     rawcharout(`J`);
  sysflush(popdevraw);
enddefine;
