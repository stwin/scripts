{$NO_AUTO_EXECUTE}

// This modifies the basic key buy setup. In key buy setup, it detects for
// three down bars. Here, in addition to three down bars, it needs one
// up bar.

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function isDown (Bar: integer): boolean;
begin
  result := false;
  if (PriceClose (Bar) < PriceClose (Bar-1))
    and (PriceClose (Bar) < PriceOpen (Bar))
    //and ((PriceHigh (Bar) - PriceOpen (Bar))
    //    < (0.5 * (PriceOpen (Bar) - PriceClose (Bar))))
    //and ((PriceClose (Bar) - PriceLow (Bar))
    //    < (0.5 * (PriceOpen (Bar) - PriceClose (Bar))))
    then
    result := true;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function isUp (Bar: integer): boolean;
begin
  result := false;
  if (PriceClose (Bar) > PriceClose (Bar-1))
    and (PriceClose (Bar) > PriceOpen (Bar))
    //and ((PriceHigh (Bar) - PriceClose (Bar))
    //    < (0.5 * (PriceClose (Bar) - PriceOpen (Bar))))
    //and ((PriceOpen (Bar) - PriceLow (Bar))
    //    < (0.5 * (PriceClose (Bar) - PriceOpen (Bar))))
    then
    result := true;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function isNewHighRecently (Bar: integer): boolean;
begin
  var newHigh : float;
  var count : integer;

  result := true;

  // Find the highest one in the last couple of bars
  newHigh := PriceHigh (Bar);
  for count := 1 to 7 do
  begin
    if (newHigh < PriceHigh (Bar-count)) then
      newHigh := PriceHigh (Bar-count);
  end;
  // Now newHigh contains the highest high of the last 8 bars

  // Is newHigh really a new high in the last 30 bars
  for count := 8 to 37 do
  begin
    if (newHigh < PriceHigh (Bar-count)) then
    begin
      result := false;
      break;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
function isNewLowRecently (Bar: integer): boolean;
begin
  var newLow : float;
  var count : integer;

  result := true;

  // Find the lowest one in the last couple of bars
  newLow := PriceLow (Bar);
  for count := 1 to 7 do
  begin
    if (newLow > PriceLow (Bar-count)) then
      newLow := PriceLow (Bar-count);
  end;
  // Now newLow contains the lowest low of the last 8 bars

  // Is newLow really a new low in the last 30 bars
  for count := 8 to 37 do
  begin
    if (newLow > PriceLow (Bar-count)) then
    begin
      result := false;
      break;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure processCurrentSymbolForBuyOpportunity (newWatchList: String);
begin
  var Bar, startBar: integer;

  startBar := BarCount - 20;
  if (startBar < 20) then
    startBar := 20;

  for Bar := startBar to BarCount-1 do
  //Bar:= BarCount-1 ;
  begin
    if (PriceClose (Bar) > PriceOpen (Bar))
      and isDown (Bar-1)
      and isDown (Bar-2)
      and isDown (Bar-3)
      then
    begin
      //Print (GetSymbol + ' : down 3 bars');  PrintFlush;
      if (PriceHigh (Bar-1) < PriceHigh (Bar-2))
        and (PriceHigh (Bar-2) < PriceHigh (Bar-3))
        then
      begin
        //Print (GetSymbol + ' : strictly down three bars');  PrintFlush;
        if isNewHighRecently (Bar-1)
        then
        begin
          //Print (GetSymbol + ' : all criterias met');  PrintFlush;
          WatchListAddSymbol (IntToStr(GetMonth(Bar))
                  + IntToStr(GetDay(Bar)) + '-' + newWatchList, '', GetSymbol);
        end;
      end;

    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure processCurrentSymbolForShortOpportunity (newWatchList: String);
begin
  var Bar, startBar: integer;

  startBar := BarCount - 20;
  if (startBar < 20) then
    startBar := 20;

  for Bar := startBar to BarCount-1 do
  begin
    // Clear the new watch lists if it exists
    // WatchListClear (newWatchList);

    if (PriceClose (Bar) < PriceOpen (Bar))
      and isUp (Bar-1)
      and isUp (Bar-2)
      and isUp (Bar-3)
      then
    begin
      //Print (GetSymbol + ' : up 3 bars');  PrintFlush;
      if (PriceLow (Bar-1) > PriceLow (Bar-2))
        and (PriceLow (Bar-2) > PriceLow (Bar-3))
        then
      begin
        //Print (GetSymbol + ' : strictly up three bars');  PrintFlush;
        if isNewLowRecently (Bar-1)
        then
        begin
          //Print (GetSymbol + ' : all criterias met');  PrintFlush;
          WatchListAddSymbol (IntToStr(GetMonth(Bar))
                  + IntToStr(GetDay(Bar)) + '-' + newWatchList, '', GetSymbol);
        end;
      end;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure ScanWatchList (newBuyWatchList, newShortWatchList: String);
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

    processCurrentSymbolForBuyOpportunity (newBuyWatchList);
    processCurrentSymbolForShortOpportunity (newShortWatchList)
  end;

end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure FindBearishRB (newShortWatchList: String);
begin
  var watchListNum: integer;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch lists if it exists
  WatchListClear (newShortWatchList);

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

    var upTail, downTail, range: float;
    range :=  PriceClose(BarCount-1) - PriceOpen(Barcount-1);
    upTail := PriceHigh(BarCount-1)-PriceClose(BarCount-1);
    downTail := PriceOpen(BarCount-1)-PriceLow(BarCount-1);

    if (range > 0)
        and (downTail < (0.5 * upTail) )
        and (upTail >= range)
        then
    begin
       Print (GetSymbol + ' : all criterias met');  PrintFlush;
       WatchListAddSymbol (newShortWatchList, '', GetSymbol);
    end;
  end;

end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

var n1, n2: integer;

n1:= GetTickCount;

Print ('Current Watchlist is : ' + WatchListName );  PrintFlush;
Print ('Number of symbols : ' + IntToStr(WatchListCount) );  PrintFlush;

ScanWatchList ('MyKeySetupBuy', 'MyKeySetupShort');
//FindBearishRB ('KeySetupShortRB');

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');


