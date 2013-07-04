{$NO_AUTO_EXECUTE}

const count = 100000;
var x, y, t1, Bar: integer;
var s: string;

var a: array of string = ['one','two','three'];
var b: string = 'one,two,three';
var c: comvariantarray; c:= ['one','two','three'];

t1 := GetTickCount;
for Bar := 1 to count do;
Print('loop base : '+AsString(GetTickCount-t1));
PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do continue;
Print('avoid continue : '+AsString(GetTickCount-t1));
Print('');PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do x := x + 1;
Print('use x=x+1 : '+AsString(GetTickCount-t1));
PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do inc(y);
Print('avoid inc(x) : '+AsString(GetTickCount-t1));
Print('');PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do for x := 0 to a.length-1 do s := a[x];
Print('use array : '+AsString(GetTickCount-t1));
PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do for x := 0 to c.length-1 do s := c[x];
Print('comvariantarray ok: '+AsString(GetTickCount-t1));
PrintFlush;

t1 := GetTickCount;
for Bar := 1 to count do for x := 0 to 2 do s := gettoken(b,x,',');
Print('avoid gettoken : '+AsString(GetTickCount-t1));

