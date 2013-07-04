{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
procedure  ScanWatchList ();
begin

  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  var countGreen, countRed: integer;
  countGreen := 0;
  countRed := 0;
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
    if( PriceClose( BarCount-1 ) > PriceOpen( BarCount-1 ) )then
      countGreen := countGreen + 1
    else
      countRed := countRed + 1;
  end;
  Print ('CountRed = ' + countRed);
  Print ('CountGreen = ' + countGreen);
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1 := GetTickCount;

ScanWatchList ();

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');


