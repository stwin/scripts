var upArray: array[1..10] of integer;
var downArray: array[1..10] of integer;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function isUp (Bar: integer): boolean;
begin
  if (PriceClose(Bar) > PriceOpen(Bar)) then
    Result := true
  else
    Result := false;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function isDown (Bar: integer): boolean;
begin
  if (PriceClose(Bar) < PriceOpen(Bar)) then
    Result := true
  else
    Result := false;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

procedure countUpAndDownBars;
begin

var Bar, startBar: integer;
var count: integer;

if (BarCount < 20) then
  exit;

startBar := BarCount - 100;
if (startBar < 10) then startBar := 10;

for Bar := startBar to BarCount-1 do
begin
  if (PriceOpen(Bar) = PriceClose(Bar)) then
    continue;
  //if (Bar = BarCount-1) Or ((isUp(Bar) <> isUp(Bar+1))) then
  begin
    for count := 1 to 10 do
    begin
      if (isUp(Bar) <> isUp(Bar-count)) then
        break;
      if (isDown(Bar) <> isDown(Bar-count)) then
        break;
    end;
    if (count > 10) then continue;
    if (isUp(Bar)) then
      upArray[count] := upArray[count] + 1
    else if (isDown(Bar)) then
      downArray[count] := downArray[count] + 1;
  end;
end; // for

end; // procedure
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

procedure countUpAndDownBarsInWatchList;
begin
  WatchListSelect (WatchListName);
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   try
   SetPrimarySeries (WatchListSymbol (n) );
   except
      continue;
   end;
   countUpAndDownBars;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

var count: integer;
var BellSeries, BellPane: integer;
BellPane := CreatePane (400, true, true);
BellSeries := CreateSeries;

//countUpAndDownBars;
countUpAndDownBarsInWatchList;

if (BarCount < 20) then
  exit;
  
for count := 1 to 10 do
begin
  SetSeriesValue (BarCount-10-count, BellSeries, downArray[count]);
  SetSeriesBarColor (BarCount-10-count, BellSeries, #Red);
  AnnotateChart (IntToStr(count), BellPane, BarCount-10-count,
              downArray[count]+downArray[1]*0.1, #blue, 8);
  AnnotateChart (IntToStr(downArray[count]), BellPane, BarCount-10-count,
              downArray[count]+downArray[1]*0.2, #red, 8);

  SetSeriesValue (BarCount-1-10+count, BellSeries, upArray[count]);
  SetSeriesBarColor (BarCount-1-10+count, BellSeries, #Green);
  AnnotateChart (IntToStr(count), BellPane, BarCount-1-10+count,
              upArray[count]+upArray[1]*0.1, #blue, 8);
  AnnotateChart (IntToStr(upArray[count]), BellPane, BarCount-1-10+count,
              upArray[count]+upArray[1]*0.2, #green, 8);


  Print (IntToStr(downArray[count]) + '#9' + IntToStr(upArray[count]));
end;

PlotSeries (BellSeries, BellPane, #Blue, #ThickHist);
//PlotArea (BellSeries, BellPane, #Red);

