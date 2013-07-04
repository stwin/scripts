{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);


///////////////////////////////////////////////////////////////////////////////
procedure GenerateValueBuyWatchList (newWatchList: String);
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
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // Skip if Price < 4  or weekly volume < 50000 (daily < 10000)
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 50000) then
      continue;

    var isInUptrend : boolean;
    isInUptrend := false;

    // FIRST WEEKLY EMA
    SetScaleWeekly;
    if (EMA(BarCount-1, #Close, 26) >= EMA(BarCount-15, #Close, 26)) then
    begin
      isInUptrend := true;
    end;
    RestorePrimarySeries;
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    if (not isInUptrend) then
      continue;


    if (PriceLow(BarCount-1) < EMA(BarCount-1, #Close, 22))
      then
    begin
      var upperShadow, lowerShadow, body: float;
      if (PriceClose(BarCount-1) > PriceOpen(BarCount-1)) then
      begin
        upperShadow := PriceHigh(BarCount-1)-PriceClose(BarCount-1);
        lowerShadow := PriceOpen(BarCount-1)-PriceLow(BarCount-1);
        body := PriceClose(BarCount-1) - PriceOpen(BarCount-1);
      end
      else
      begin
        upperShadow := PriceHigh(BarCount-1)-PriceOpen(BarCount-1);
        lowerShadow := PriceClose(BarCount-1)-PriceLow(BarCount-1);
        body := PriceOpen(BarCount-1) - PriceClose(BarCount-1);
      end;
      if (upperShadow < lowerShadow)
        and (body < lowerShadow)
        then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
      end;
    end;
  end;
  RestorePrimarySeries;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

GenerateValueBuyWatchList ('BAATHValueBuy');


n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

