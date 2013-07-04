{$NO_AUTO_EXECUTE}

// Generate many watchlists for % change
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
procedure processCurrentSymbol;
begin
  var Bar, startBar: integer;
  var change: float;
  var wlName: String;
  
  startBar := BarCount - 20;
  if (startBar < 20) then
    startBar := 20;

  for Bar := startBar to BarCount-1 do
  //Bar := BarCount-1;
  begin
    // Clear the new watch lists if it exists
    // WatchListClear (newWatchList);

    wlName := TwoDigitIntToStr(GetMonth(Bar)) + TwoDigitIntToStr(GetDay(Bar)) + '=';

    change := (PriceClose(Bar) - PriceOpen(Bar)) / PriceOpen(Bar) * 100;
    if (-10 >= change) then
      wlName := wlName + 'a=' + '<= -10'
    else if (-5 >= change) and (change > -10) then
      wlName := wlName + 'b=' + '-5 to -10'
    else if (-2.5 >= change) and (change > -5) then
      wlName := wlName + 'c=' + '-2.5 to -5'
    else if (-1 >= change) and (change > -2.5) then
      wlName := wlName + 'd=' + '-1 to -2.5'
    else if (0 > change) and (change > -1) then
      wlName := wlName + 'e=' + '0 to -1'
    else if (0 = change) then
      wlName := wlName + 'f=' + '0'
    else if (0 < change) and (change < 1) then
      wlName := wlName + 'g=' + '0 to 1'
    else if (1 <= change) and (change < 2.5) then
      wlName := wlName + 'h=' + '1 to 2.5'
    else if (2.5 <= change) and (change < 5) then
      wlName := wlName + 'i=' + '2.5 to 5'
    else if (5 <= change) and (change < 10) then
      wlName := wlName + 'j=' + '5 to 10'
    else if (10 <= change) then
      wlName := wlName + 'k=' + '>= 10';

    WatchListAddSymbol (wlName, '', GetSymbol);
    //WatchListDelete (wlName);
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


