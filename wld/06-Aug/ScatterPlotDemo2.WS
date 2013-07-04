{$NO_AUTO_EXECUTE}
// get some (random) data
var Points: TList = TList.Create;
var n: integer;
for n := 1 to 10000 do
begin
  var x: float = Random;
  var y: float = Sqr(x + Random / 3 - 0.5);
  Points.AddData(x, y);
end;

// compute data range
var minx: float = Points.Item(0);
var maxx: float = Points.Item(0);
var miny: float = Points.Data(0);
var maxy: float = Points.Data(0);
for n := 1 to Points.Count - 1 do
begin
  minx := min(minx, Points.Item(n));
  maxx := max(maxx, Points.Item(n));
  miny := min(miny, Points.Data(n));
  maxy := max(maxy, Points.Data(n));
end;

// compute scaling factors
const Width = 400;
const Height = 400;
const LeftMargin = 50;
const TopMargin = 50;
var Xscale: float = Width / (maxx - minx);
var Yscale: float = Height / (maxy - miny);
if Xscale < YScale then Yscale := Xscale else Xscale := Yscale;

// plot points
var Pane: integer = 0;
for n := 0 to Points.Count - 1 do
begin
  var x: integer = Round(Xscale * (Points.Item(n) - minx));
  var y: integer = Round(Yscale * (maxy - Points.Data(n)));
  DrawText('O', Pane, LeftMargin + x, TopMargin + y, #Black, 2);
end;


