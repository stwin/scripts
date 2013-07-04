{$NO_AUTO_EXECUTE}

// Generate many watchlists for % change
// Run this script with care

abort; // incomplete

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function TwoDigitIntToStr (num: integer): string;
begin
  var str: string;
  str := IntToStr (num);
  if (Length(str) = 1) then
    str := '0' + str;
  result := str;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure ProcessSelectedBar (selectedBar: integer);
begin
  var bar, startBar: integer;
  var wlName: string;

  wlName := TwoDigitIntToStr(GetMonth(selectedBar))
                        + TwoDigitIntToStr(GetDay(selectedBar)) + ' ';
  //Print ('Finding 52wLow');   PrintFlush;
  // First 52 w Low
  startBar := selectedBar - 52*5;
  if (startBar < 0) then
    startBar := 0;

  var low52w : boolean;
  low52w := true;

  //Print (GetSymbol+' SelectedBar: ' + IntToStr(selectedBar) + '  startBar: ' +
  //          IntToStr (startBar)); PrintFlush;
  for bar := startBar to selectedBar-1 do
  begin
    //Print (' ....' + GetSymbol);   PrintFlush;
    if (PriceLow(bar) <= PriceLow(selectedBar)) then
    begin
      low52w := false;
      break;
    end;
  end;
  if (low52w) then
  begin
    WatchListAddSymbol (wlName + 'Low52w', '', GetSymbol);
    //WatchListDelete (wlName + 'Low52w');
  end;

  //Print ('Finding 52wHigh'); PrintFlush;
  // Now 52 w High
  startBar := selectedBar - 52*5;
  if (startBar < 0) then
    startBar := 0;

  var high52w : boolean;
  high52w := true;

  for bar := startBar to selectedBar-1 do
  begin
    if (PriceHigh(bar) >= PriceHigh(selectedBar)) then
    begin
      high52w := false;
      break;
    end;
  end;
  if (high52w) then
  begin
    WatchListAddSymbol (wlName + 'High52w', '', GetSymbol);
    //WatchListDelete (wlName + 'High52w');

    //Print ('Finding ATH');
    // All time high are always 52w High
    var allTimeHigh: boolean;
    allTimeHigh := true;

    for bar := 0 to selectedBar-1 do
    begin
      if (PriceHigh(bar) >= PriceHigh(selectedBar)) then
      begin
        allTimeHigh := false;
        break;
      end;
    end;
    if (allTimeHigh) then
    begin
      WatchListAddSymbol (wlName + 'AllTimeHigh', '', GetSymbol);
      //WatchListDelete (wlName + 'AllTimeHigh');
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure processCurrentSymbol;
begin
  var bar, startBar: integer;

  startBar := BarCount - 50;
  if (startBar < 20) then
    startBar := 20;

  for bar := startBar to BarCount-1 do
  //bar := BarCount-1;
  begin

    ProcessSelectedBar (bar);

  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure ScanWatchList ();
begin
  var watchListNum: integer;

  if not IsDaily then
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
    if (PriceClose(BarCount-1) < 4) or (Volume(BarCount-1) < 10000) then
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
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or '
                        + IntToStr ((n2-n1)/1000) + ' sec to complete');



