{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
function FindScore (startBar, endBar: integer): integer;
begin
  var bar, score, greenCount: integer;
  score := 0;
  greenCount := 0;
  for bar := startBar to endBar do
  begin
    var countScore: boolean = false;
    if( PriceClose( bar ) > PriceOpen( bar ) ) then
      greenCount := greenCount + 1
    else
      countScore := true;
    if( bar = (BarCount-1) ) then
      countScore := true;
    if( countScore ) then
    begin
      if( greenCount >= 3 ) then
        score := score + greenCount - 2;
      greenCount := 0;
    end;
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
    if (BarCount < (2*252)) then
      continue;

    var score: integer;
    score := FindScore (BarCount-22*3, BarCount-1);
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



