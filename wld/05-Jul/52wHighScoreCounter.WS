{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
const tradingDays = 252;

///////////////////////////////////////////////////////////////////////////////
function FindScore (startBar, endBar: integer): integer;
begin
  var bar, score: integer;
  score := 0;
  for bar := startBar to endBar do
  begin
    if PriceHigh(bar) > Highest(Bar-1, #High, tradingDays ) then
      score := score+1;
  end;
  Result := score;
end;

//////////////////////////////////////////////////////////////////////////////
procedure  ScanWatchList ();
begin

  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
    SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // skip if volume < 10000
    if (Volume(BarCount-1) < 10000) then
      continue;

    // at least 2 year of data
    if (BarCount < (2*tradingDays)) then
      continue;

    var score: integer;
    score := FindScore (BarCount-22, BarCount-1);
    Print (GetSymbol + #9 + '  ' + IntToStr(score));
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1 := GetTickCount;

ScanWatchList ();

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');



