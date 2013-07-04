{$NO_AUTO_EXECUTE}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  GenerateAllTimeHighWeeklyWatchList (newWatchList : String);
begin
  var watchListNum: integer;

  // Set scale to weekly
  SetScaleWeekly;
  if Not IsWeekly then
  begin
    ShowMessage ('Runs only on Weekly data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

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

    // Skip if Price < 4  or weekly volume < 50000 (daily < 10000)
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 50000) then
      continue;

    var allTimeHigh : boolean;
    allTimeHigh := true;
    var currentBar: integer;
    for currentBar := 0 to BarCount-2 do
    begin
      if (PriceHigh(currentBar) >= PriceHigh(BarCount - 1)) then
      begin
        allTimeHigh := false;
        break;
      end;
    end;
    if (allTimeHigh) then
    begin
      WatchListAddSymbol (newWatchList, '', GetSymbol);
    end;
  end;
  RestorePrimarySeries;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  Generate52WeekHighWeeklyWatchList (newWatchList : String);
begin
  var watchListNum: integer;

  // Set scale to weekly
  SetScaleWeekly;
  if Not IsWeekly then
  begin
    ShowMessage ('Runs only on Weekly data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

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

    // Skip if Price < 4  or weekly volume < 50000 (daily < 10000)
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 50000) then
      continue;

    var allTimeHigh : boolean;
    allTimeHigh := true;
    var currentBar, startBar: integer;

    if (BarCount < 52) then
      startBar := 0
    else
      startBar := BarCount - 52;

    for currentBar := startBar to BarCount-2 do
    begin
      if (PriceHigh(currentBar) >= PriceHigh(BarCount - 1)) then
      begin
        allTimeHigh := false;
        break;
      end;
    end;
    if (allTimeHigh) then
    begin
      WatchListAddSymbol (newWatchList, '', GetSymbol);
    end;
  end;
  RestorePrimarySeries;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  Generate52WeekLowWeeklyWatchList (newWatchList : String);
begin
  var watchListNum: integer;

  // Set scale to weekly
  SetScaleWeekly;
  if Not IsWeekly then
  begin
    ShowMessage ('Runs only on Weekly data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

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

    // Skip if Price < 4  or weekly volume < 50000 ( daily < 10000)
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 50000) then
      continue;

    // Find 52 week low
    var allTimeLow : boolean;
    allTimeLow := true;
    var currentBar, startBar: integer;

    if (BarCount < 52) then
      startBar := 0
    else
      startBar := BarCount - 52;
      
    for currentBar := startBar to BarCount-2 do
    begin
      if (PriceLow(currentBar) <= PriceLow(BarCount - 1)) then
      begin
        allTimeLow := false;
        break;
      end;
    end;
    if (allTimeLow) then
    begin
      WatchListAddSymbol (newWatchList, '', GetSymbol);
    end;
  end;
  RestorePrimarySeries;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  GeneratePriceRangeWatchList (newWatchList: String;
                              lowerPrice, upperPrice: integer);
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

    if (PriceClose(BarCount - 1) >= lowerPrice)
            And (PriceClose(BarCount - 1) < upperPrice) then
    begin
      WatchListAddSymbol (newWatchList, '', GetSymbol);
    end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  GenerateMostActive100WatchList (newWatchList: String );
begin
  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  var list: TList;
  list := TList.create ();

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

    list.AddData (Volume (BarCount-1), GetSymbol);

  end;

  list.SortNumeric;
  //Print (IntToStr (list.Count));
  var count : integer;
  for count := list.Count - 1 downto list.Count - 100   do
  begin
    if (count < 0) then
        break;
    WatchListAddSymbol (newWatchList, '', list.Data (count));
    Print (list.Data (count) + '   ' + FloatToStr(list.Item (count)));   PrintFlush;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  GenerateMostActiveAvgDaily100WatchList (newWatchList: String );
begin
  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  var list: TList;
  list := TList.create ();

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

    // find last month avg daily volume
    if ((BarCount - 22) < 0) then
      continue;
    var avgVol : float;
    var count: integer;
    avgVol := 0;
    for count := BarCount-22 to BarCount-1 do
    begin
      avgVol := avgVol + Volume(count);
    end;
    avgVol := avgVol/22;
    
    list.AddData (avgVol, GetSymbol);
  end;

  list.SortNumeric;
  //Print (IntToStr (list.Count));
  var count : integer;
  for count := list.Count - 1 downto list.Count - 100   do
  begin
    if (count < 0) then
        break;
    WatchListAddSymbol (newWatchList, '', list.Data (count));
    Print (list.Data (count) + '   ' + FloatToStr(list.Item (count)));   PrintFlush;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
var BaseWatchList: string;
var n1, n2: integer;

//BaseWatchList := 'AA1-Data3y';
//BaseWatchList := WatchListName;

n1:= GetTickCount;

//WatchListSelect (BaseWatchList);
//Print ('Current Watchlist is : ' + WatchListName );  PrintFlush;
//Print ('Number of symbols : ' + IntToStr(WatchListCount) );  PrintFlush;

var generateForWeekly: boolean;

//generateForWeekly := true;
generateForWeekly := false;

if (generateForWeekly) Then
begin
  GeneratePriceRangeWatchList ('WRPrice 4-10000', 4, 10000);
  GenerateAllTimeHighWeeklyWatchList ('WRAllTimeHighWeekly');
  Generate52WeekHighWeeklyWatchList ('WR52WeekHighWeekly');
  Generate52WeekLowWeeklyWatchList ('WR52WeekLowWeekly');
  GeneratePriceRangeWatchList ('WRPrice 4-10', 4, 10);
  GeneratePriceRangeWatchList ('WRPrice 10-20', 10, 20);
  GeneratePriceRangeWatchList ('WRPrice 20-90', 20, 90);
  GeneratePriceRangeWatchList ('WRPrice 90-10000', 90, 10000);
  GeneratePriceRangeWatchList ('WRPrice 0-4', 0, 4);
  GenerateMostActive100WatchList ('WRMostActive100');
  GenerateMostActiveAvgDaily100WatchList ('WRMostActiveAvgDaily100');
end;
  GeneratePriceRangeWatchList ('WRPrice 4-10000', 4, 10000);

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');



