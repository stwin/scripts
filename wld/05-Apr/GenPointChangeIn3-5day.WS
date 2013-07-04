{$NO_AUTO_EXECUTE}

// Generate many watchlists for 10%, 15%, 20%, 5, 8, 12 for 1d, 3d, 5d, 10d
// Run this script with care

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TwoDigitIntToStr (num: integer): String;
begin
  var str: String;
  str := IntToStr (num);
  if (Length(str) = 1) then
    str := '0' + str;
  result := str;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure processCurrentSymbolDayRangePriceChange (wlName: string; startBar,
                         endBar: integer; changeMin, changeMax: float; isPercent: boolean);
begin
  var change: float;

  change := (PriceClose(endBar) - PriceOpen(startBar));

  if (isPercent) then
      change := change / PriceOpen(startBar) * 100;

  if (change >= 0) then
  begin
    if (changeMin <= change ) and (change < changeMax) then
    begin
        if (isPercent) then
            wlName := wlName + '%';
        wlName := wlName + '-Buy=' + FormatFloat('#',changeMin)
                                    + ' to ' + FormatFloat('#',changeMax);
        WatchListAddSymbol (wlName, '', GetSymbol);
        //WatchListDelete (wlName);
    end;
  end
  else
  begin
    if (-changeMin >= change ) and (change > -changeMax) then
    begin
        if (isPercent) then
            wlName := wlName + '%';
        wlName := wlName + '-Short=' + FormatFloat('#',-changeMin)
                                    + ' to ' + FormatFloat('#',-changeMax);
        WatchListAddSymbol (wlName, '', GetSymbol);
        //WatchListDelete (wlName);
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure processCurrentSymbol;
begin
  var bar, startBar: integer;
  var change: float;
  var wlName: string;

  startBar := BarCount - 60;
  if (startBar < 20) then
    startBar := 20;

  //Bar := BarCount-1;
  for bar := startBar to BarCount-1 do
  begin

    wlName := TwoDigitIntToStr(GetMonth(Bar)) + TwoDigitIntToStr(GetDay(Bar));

    var startBar, endBar, numDay: integer;
    var wlName2: string;

    // 1 day
    numDay := 1;
    startBar := bar-numDay+1;
    endBar := bar;
    wlName2 := wlName + '-' + TwoDigitIntToStr(numDay) + 'd';
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 10, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 10, 20, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 999, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 8, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 8, 12, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 12, 999, false);

    // 3 day
    numDay := 3;
    startBar := bar-numDay+1;
    endBar := bar;
    wlName2 := wlName + '-' + TwoDigitIntToStr(numDay) + 'd';
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 10, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 10, 20, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 999, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 8, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 8, 12, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 12, 999, false);

    // 5 day
    numDay := 5;
    startBar := bar-numDay+1;
    endBar := bar;
    wlName2 := wlName + '-' + TwoDigitIntToStr(numDay) + 'd';
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 10, 20, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 50, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 50, 999, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 10, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 10, 20, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 999, false);

    // 10 day
    numDay := 10;
    startBar := bar-numDay+1;
    endBar := bar;
    wlName2 := wlName + '-' + TwoDigitIntToStr(numDay) + 'd';
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 40, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 40, 100, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 100, 999, true);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 5, 10, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 10, 20, false);
    processCurrentSymbolDayRangePriceChange (wlName2, startBar, endBar, 20, 999, false);

  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure ScanWatchList ();
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

    // Skip if Price < 4  or weekly volume < 50000 ( daily < 10000)
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 10000) then
      continue;

    processCurrentSymbol;
  end;

end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

var n1, n2: integer;

n1:= GetTickCount;

Print ('Current Watchlist is : ' + WatchListName );  PrintFlush;
Print ('Number of symbols : ' + IntToStr(WatchListCount) );  PrintFlush;

ScanWatchList ();

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');



