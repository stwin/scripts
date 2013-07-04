{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

//////////////////////////////////////////////////////////////////////////////
procedure  PrintNumDaysToMultiply (factor: float; cutoff: integer);
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

    // at least 6 months
    if (BarCount < (22*6)) then
      continue;

    var numDays, bar: integer;
    var recentHigh: float = Highest (BarCount-1, #High, 10);
    var recentHighBar: integer = HighestBar (BarCount-1, #High, 10);
    //for bar := BarCount-recentHighBar downto BarCount-cutoff do
    for bar := recentHighBar downto BarCount-cutoff do
    begin
      if (recentHigh > (PriceLow(bar)*factor)) then
      begin
        numDays := BarCount - bar;
        Print (GetSymbol + #9 + '  ' + IntToStr(numDays));  PrintFlush;
        break;
      end;
    end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
procedure  SelectStockWhichMultiplyInGivenDays (newWatchList: String;
            factor: float; numDays: integer);
begin

  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
    SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // skip if volume < 10000
    if (Volume(BarCount-1) < 10000) then
      continue;

    //Print ('BarCount = ' + IntToStr(BarCount));  PrintFlush;
    // at least 6 months
    if (BarCount < (22*6)) then
      continue;

    var highestPrice: float = Highest (BarCount-1, #High, numDays);
    var highestPriceBar: integer = HighestBar (BarCount-1, #High, numDays);
    var lowestPrice: float = Lowest (highestPriceBar-1, #Low, numDays);
    var lowestPriceBar: integer = LowestBar (highestPriceBar-1, #Low, numDays);
    //Print ('('+IntToStr(highestPriceBar)+','+FloatToStr(highestPrice)
    //    +')-('+IntToStr(lowestPriceBar)+','+FloatToStr(lowestPrice)+')');PrintFlush;
    if (highestPrice > (factor*lowestPrice)) then
      WatchListAddSymbol (newWatchList, '', GetSymbol);
  end;
end;
//////////////////////////////////////////////////////////////////////////////
procedure  SelectStockWithUnexpectedPriceChange (newWatchList: String;
            percentChange: float; startBar, endBar: integer);
begin

  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
    SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // skip if volume < 10000
    if (Volume(BarCount-1) < 10000) then
      continue;

    //Print ('BarCount = ' + IntToStr(BarCount));  PrintFlush;
    // at least 6 months
    if (BarCount < (22*6)) then
      continue;

    var bar: integer;
    for bar := startBar to endBar do
    begin
      var change: float = 100*(PriceClose(bar) - PriceClose(bar-1))/PriceClose(bar-1);
      if (change > percentChange) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        Print (GetSymbol + '   ' + FloatToStr(change) + '   ' + DateToStr(GetDate(bar)));
      end;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1 := GetTickCount;

//PrintNumDaysToMultiply (2, 22*3); // stocks which doubled in less than 3 months
//SelectStockWhichMultiplyInGivenDays ('StudyMultiplyInGivenDays', 1.5, 22*1);
SelectStockWithUnexpectedPriceChange ('StudyMultiplyInGivenDays', 25,
                                            BarCount-22, BarCount-1);

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');



