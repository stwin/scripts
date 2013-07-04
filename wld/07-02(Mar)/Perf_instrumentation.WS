{$NO_AUTO_EXECUTE}


const count = 100;
var t1, i: integer;

t1 := GetTickCount;
for i := 1 to count do;
Print('loop base : '+AsString(GetTickCount-t1));
PrintFlush;

var x : integer = 0;

t1 := GetTickCount;
for i := 1 to count do
      x := x + 1;

Print('avoid continue : '+AsString(GetTickCount-t1));
Print('');PrintFlush;



