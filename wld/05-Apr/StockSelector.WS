{$NO_AUTO_EXECUTE}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindAllTimeHigh;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
    SetPrimarySeries (WatchListSymbol (n) );
    if BarCount > 200 then
    begin
      var i: integer;
      var isAllTimeHigh: boolean;
      var Last10Avg : float;

      Last10Avg := 0;
      for i := 1 to 10 do
      begin
        Last10Avg := Last10Avg + PriceHigh (BarCount-i);
      end;
      Last10Avg := Last10Avg / 10;
      //Print (floatToStr (Last10Avg) + '  ' + floattostr (pricehigh(barcount-1)));
      
      isAllTimeHigh := true;
      for i := 0 to BarCount - 11 do
      begin
          if (Last10Avg < PriceHigh (i)) then
            isAllTimeHigh := false;
      end;
      if (isAllTimeHigh) then
      begin
        Print (GetSymbol); PrintFlush;
      end;
    end;
    //Print ('Symbol : ' + GetSymbol);  PrintFlush ;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindAllTimeHighWeekly;    // Run on Weekly Data
begin
  var watchListNum: integer;
  if Not IsWeekly then
  begin
    ShowMessage ('Runs only on Weekly data');
    abort;
  end;
  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
   var allTimeHigh : boolean;
   allTimeHigh := true;
   PrintStatus ('Processing: ' + IntToStr(watchListNum) + ' ' +  WatchListSymbol (watchListNum));
   try
   SetPrimarySeries (WatchListSymbol (watchListNum) );
   except
      continue;
   end;
   // Skip if Price < 4
   if (PriceCLose(BarCount-1) < 4) then
      continue;
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
       Print (GetSymbol);
       PrintFlush;
     end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindWeeklyAllTimeHighVolumeDoulbeIn4Week (weekBack: integer);    // Run on Weekly Data
begin
  var watchListNum: integer;
  if Not IsWeekly then
  begin
    ShowMessage ('Runs only on Weekly data');
    abort;
  end;
  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
   var allTimeHigh : boolean;
   allTimeHigh := true;
   PrintStatus ('Processing: ' + IntToStr(watchListNum) + ' ' +  WatchListSymbol (watchListNum));
   try
   SetPrimarySeries (WatchListSymbol (watchListNum) );
   except
      continue;
   end;
   // Skip if Price < 4
   if (PriceCLose(BarCount-1-weekBack) < 4) then
      continue;
   var currentBar: integer;
   for currentBar := 0 to BarCount-2-weekBack do
   begin
     if (PriceHigh(currentBar) >= PriceHigh(BarCount - 1-weekBack)) then
     begin
       allTimeHigh := false;
       break;
     end;
   end;
     if (allTimeHigh) then
     begin
       if (Volume(BarCount-1-weekBack) > 2*Volume(BarCount-6-weekBack)) And
          (Volume(BarCount-1-weekBack) > 2*Volume(BarCount-2-weekBack)) And
          (Volume(BarCount-1-weekBack) > 2*Volume(BarCount-3-weekBack)) And
          (Volume(BarCount-1-weekBack) > 2*Volume(BarCount-4-weekBack)) And
          (Volume(BarCount-1-weekBack) > 2*Volume(BarCount-5-weekBack)) then
       begin
         Print (GetSymbol);
         PrintFlush;
       end;
     end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindPriceDoubledInTwoMonth;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
    SetPrimarySeries (WatchListSymbol (n) );
    var symbolAdded : boolean;
    symbolAdded := false;
    if BarCount > 50 then
    begin
      var i : integer;
      var j : integer;
      for j := 1 to 5 do
      begin
        for i:= j+1 to 45 do
        begin
          if (PriceClose(BarCount-j) > (2*PriceClose(BarCount-i))) then
          begin
            Print (GetSymbol + #9#9 + FloatToStr(PriceClose(BarCount-j)) + ' > 2*' + FloatToStr(PriceClose(BarCount-i))); PrintFlush;
            symbolAdded := true;
          end;
        if symbolAdded then
          break;
        end;
      if symbolAdded then
        break;
      end;
    end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindVolumeDoubledInTwoMonth;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
    SetPrimarySeries (WatchListSymbol (n) );
    var symbolAdded : boolean;
    symbolAdded := false;
    if BarCount > 50 then
    begin
      var i : integer;
      var vol1: float;
      for i:= 21 to 45 do
      begin
        vol1 := vol1 + Volume(BarCount-i);
      end;
      vol1 := vol1 / 25;

      var j: integer;
      var vol: float;
      vol := 0;
      for j := 1 to 5 do
      begin
        vol := vol + Volume(BarCount-j);
      end;
      vol := vol / 5;
      if (vol > (2*vol1)) then
      begin
            Print (GetSymbol + #9 + #9 + FloatToStr(vol) + ' > 2*' + FloatToStr(vol1)); PrintFlush;
            symbolAdded := true;
      end;
    end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindPriceGreatThan4;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   SetPrimarySeries (WatchListSymbol (n) );
   if (PriceClose(BarCount-1) > 4) then
   begin
     Print (GetSymbol + '       ' + #9 + FloatToStr(PriceClose(BarCount-1))
                + ' ' + FloatToStr(Volume(BarCount-1))); PrintFlush;
   end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindPriceGreatThan4AndLastBarUp;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   SetPrimarySeries (WatchListSymbol (n) );
   if (PriceClose(BarCount-1) > 4) And (PriceClose(BarCount-1) > PriceOpen(BarCount-1))
        //And (Volume(BarCount-1) > (2*Volume(BarCount-3)))
        //And (Volume(BarCount-1) > Volume(BarCount-2))
        //And (Volume(BarCount-2) > Volume(BarCount-3))
        then
   begin
     Print (GetSymbol + '       ' + #9 + FloatToStr(PriceClose(BarCount-1))
                + ' ' + FloatToStr(Volume(BarCount-1))); PrintFlush;
   end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindPriceNearHundreds;
begin
  var n: integer;
  for n := 0 to WatchListCount - 1 do
  //for n := 0 to 10 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   SetPrimarySeries (WatchListSymbol (n) );
   if (PriceClose(BarCount-1) > 90) then
   begin
     Print (GetSymbol + '       ' + #9 + FloatToStr(PriceClose(BarCount-1))
                + ' ' + FloatToStr(Volume(BarCount-1))); PrintFlush;
   end;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  FindHighDoubleOfLowMonthly;     // Monthly
begin
  var watchListNum: integer;
  if Not IsMonthly then
  begin
    ShowMessage ('Runs only on Monthly data');
    abort;
  end;
  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
   var symbolAdded : boolean;
   symbolAdded := false;
   PrintStatus ('Processing: ' + IntToStr(watchListNum) + ' ' +  WatchListSymbol (watchListNum));
   try
   SetPrimarySeries (WatchListSymbol (watchListNum) );
   except
      continue;
   end;
   // Skip if Price < 4
   if (PriceCLose(BarCount-1) < 4) then
      continue;
   var currentBar: integer;
   for currentBar := 0 to BarCount -1 do
   begin
     if (PriceHigh(currentBar) > (2*PriceLow(currentBar))) then
     begin
       Print (GetSymbol
                + ',' + FloatToStr(GetMonth(currentBar)) + '/'
                      + FloatToStr(GetDay(currentBar)) + '/'
                      + FloatToStr(GetYear(currentBar))
                + ',' + FloatToStr(PriceOpen(currentBar))
                + ',' + FloatToStr(PriceHigh(currentBar))
                + ',' + FloatToStr(PriceLow(currentBar))
                + ',' + FloatToStr(PriceClose(currentBar))
                + ',' + FloatToStr(Volume(currentBar))
                + ',' + FloatToStr(PriceClose(BarCount-1)));
       PrintFlush;
       symbolAdded := true;
     end;
     if (symbolAdded) then
        break;
   end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  SelectStocksForShorting (newWatchList : String);
begin
  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  var n: integer;
  for n := 0 to WatchListCount - 1 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   try
   SetPrimarySeries (WatchListSymbol (n) );
   except
      continue;
   end;
   var priceChange1, priceChange2, priceChange3: float;
   priceChange1 := (PriceClose(BarCount-1)-PriceOpen(BarCount-1))*100/PriceOpen(BarCount-1);
   priceChange2 := (PriceClose(BarCount-2)-PriceOpen(BarCount-2))*100/PriceOpen(BarCount-2);
   priceChange3 := (PriceClose(BarCount-3)-PriceOpen(BarCount-3))*100/PriceOpen(BarCount-3);
   if (PriceClose(BarCount-1) > 10) // closing requirement
        And (Volume(BarCount-1) > 10000) // Volume requirement
        And (priceChange1 < -1.0) // Last Bar
        And (priceChange2 < -1.0) // Second Last Bar
        And (priceChange3 < -1.0) // Third Last Bar
        //And (PriceOpen(BarCount-1) = PriceHigh(BarCount-1)) // No Tail in last bar
        //And (PriceOpen(BarCount-2) = PriceHigh(BarCount-2)) // No Tail in 2nd last bar
        //And (PriceOpen(BarCount-3) = PriceHigh(BarCount-3)) // No Tail in 3rd last bar
        then
   begin
     WatchListAddSymbol (newWatchList, '', GetSymbol);
     {Print (GetSymbol + '       ' + #9 + FloatToStr(PriceClose(BarCount-1))
                + #9 + FloatToStr(Volume(BarCount-1))
                + #9 + FloatToStr(priceChange1)
                + #9 + FloatToStr(priceChange2)
                + #9 + FloatToStr(priceChange3)
                ); PrintFlush;
     }
   end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  SelectStocksForBuying (newWatchList : String);
begin
  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  var n: integer;
  for n := 0 to WatchListCount - 1 do
  begin
   PrintStatus ('Processing: ' + IntToStr(n) + ' ' +  WatchListSymbol (n));
   try
   SetPrimarySeries (WatchListSymbol (n) );
   except
      continue;
   end;
   var priceChange1, priceChange2, priceChange3: float;
   priceChange1 := (PriceClose(BarCount-1)-PriceOpen(BarCount-1))*100/PriceOpen(BarCount-1);
   priceChange2 := (PriceClose(BarCount-2)-PriceOpen(BarCount-2))*100/PriceOpen(BarCount-2);
   priceChange3 := (PriceClose(BarCount-3)-PriceOpen(BarCount-3))*100/PriceOpen(BarCount-3);
   if (PriceClose(BarCount-1) > 6) // closing requirement
        And (Volume(BarCount-1) > 10000) // Volume requirement
        And (priceChange1 > 1.0) // Last Bar
        And (priceChange2 > 1.0) // Second Last Bar
        And (priceChange3 > 1.0) // Third Last Bar
        //And (PriceOpen(BarCount-1) = PriceLow(BarCount-1)) // No Tail in last bar
        //And (PriceOpen(BarCount-2) = PriceLow(BarCount-2)) // No Tail in 2nd last bar
        //And (PriceOpen(BarCount-3) = PriceLow(BarCount-3)) // No Tail in 3rd last bar
        then
   begin
     WatchListAddSymbol (newWatchList, '', GetSymbol);
     {Print (GetSymbol + '       ' + #9 + FloatToStr(PriceClose(BarCount-1))
                + #9 + FloatToStr(Volume(BarCount-1))
                + #9 + FloatToStr(priceChange1)
                + #9 + FloatToStr(priceChange2)
                + #9 + FloatToStr(priceChange3)
                ); PrintFlush;
      }
   end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
var BaseWatchList: string;
var n1, n2: integer;

//BaseWatchList := 'AA1-Data3y';
//BaseWatchList := 'AA3-Data3m';
//BaseWatchList := 'All Time High';
//BaseWatchList := 'vol double in 2 months';
BaseWatchList := WatchListName;

n1:= GetTickCount;

WatchListSelect (BaseWatchList);
Print ('Current Watchlist is : ' + WatchListName );  PrintFlush;
Print ('Number of symbols : ' + IntToStr(WatchListCount) );  PrintFlush;

//FindAllTimeHigh;
//FindAllTimeHighWeekly;
//FindWeeklyAllTimeHighVolumeDoulbeIn4Week (0);
//FindPriceDoubledInTwoMonth;
//FindVolumeDoubledInTwoMonth ;
//FindPriceGreatThan4;
//FindPriceGreatThan4AndLastBarUp;
//FindPriceNearHundreds;
//FindHighDoubleOfLowMonthly;

SelectStocksForShorting ('CustomForShorting');
SelectStocksForBuying ('CustomForBuying');

n2:= GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

