{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//////////////////////////////////////////////////////////////////////////////
procedure ValueBuyHammer (newWatchList: String);
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

      var isGreen, isHammer: boolean;
      var bar: integer = BarCount-1;
      if( PriceClose( bar ) > PriceOpen( bar ) ) then
        isGreen := true
      else
        isGreen := false;
      var downTail, body, upTail: float;
      if( isGreen ) then
      begin
        upTail := PriceHigh( bar ) - PriceClose( bar );
        body := PriceClose( bar ) - PriceOpen( bar );
        downTail := PriceOpen( bar ) - PriceLow( bar );
      end
      else
      begin
        upTail := PriceHigh( bar ) - PriceOpen( bar );
        body := PriceOpen( bar ) - PriceClose( bar );
        downTail := PriceClose( bar ) - PriceLow( bar );
      end;
      if( (downTail > 2*body) and (downTail > 2*upTail) ) then
        isHammer := true
      else
        isHammer := false;
      if  ( isHammer )
          //and (HighestBar( bar, #High, 30 ) > bar-10 ) // highest bar very close by
          //and (PriceClose( bar ) < EMA( bar, #Close, 11 )) // below fast ema
          then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
      end;

    except
      continue;
    end;
  end;
end;
//////////////////////////////////////////////////////////////////////////////
function BullishHammer( Bar: integer ): boolean;
begin
  var O, H, L, C, OHL, CHL: float;
  // Defining shortcuts
  O := PriceOpen(Bar) - PriceLow(Bar);
  H := PriceHigh(Bar) - PriceLow(Bar);
  L := PriceLow(Bar);
  C := PriceClose(Bar) - PriceLow(Bar);

  if H=0 then
  begin
    OHL := 0;
    CHL := 0;
  end
  else
  begin
    OHL := O / H;  // Open relative to the bar's range
    CHL := C / H;  // Close relative to the bar's range
  end;

  // Detecting patterns
  Result := (Min(OHL, CHL) > 0.70)  //Open and Close near the High
        and (Max(OHL, CHL) > 0.90)  //Little or no upper shadow
        //and (Abs(OHL - CHL) > 0.1)    //Make sure not a Doji pattern
        and (H > ATR(Bar, 10) * 0.5)      //Long line
        and (SMA(Bar, #Close, 5) < SMA(Bar-1, #Close, 5));  //Identifying downtrend

  if Result then
  begin
    //SetBarColor(Bar, #Green);
    AnnotateBar( 'Hammer', Bar, False, #Green, 8 );
  end;
end;
//////////////////////////////////////////////////////////////////////////////
procedure ValueBuyHammerWizard (newWatchList: String);
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

      if( BullishHammer( BarCount - 1 ) )
          //and (HighestBar( bar, #High, 30 ) > bar-10 ) // highest bar very close by
          //and (PriceClose( bar ) < EMA( bar, #Close, 11 )) // below fast ema
          then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
      end;

    except
      continue;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1 := GetTickCount;

ValueBuyHammer( 'MyE3-VBHammer' );
ValueBuyHammerWizard( 'MyE3-Hammer' );

n2 := GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

