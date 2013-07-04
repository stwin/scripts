{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

//______________________________________________________________________________
function BullishHammer( Bar: integer ): boolean;
begin
  var OHL, CHL: float;

  // Open relative to the bar's range
  OHL :=  (PriceOpen(Bar) - PriceLow(Bar)) / ( PriceHigh(Bar) - PriceLow(Bar));

  // Close relative to the bar's range
  CHL :=  (PriceClose(Bar) - PriceLow(Bar)) / ( PriceHigh(Bar) - PriceLow(Bar));

  // Detecting patterns
  Result := (Min(OHL, CHL) > 0.70)  //Open and Close near the High
        and (Max(OHL, CHL) > 0.90);  //Little or no upper shadow
end;
//______________________________________________________________________________
//
procedure GenCandleReversalWatchList( newWatchList: String );
begin
  var watchListNum: integer;

  // Clear the new watch list if it exists
  WatchListClear( newWatchList );

  for watchListNum := 0 to WatchListCount - 1 do
  begin

    PrintStatus ('Processing: ' + IntToStr(watchListNum+1)
          + '/' + IntToStr(WatchListCount)
          + ' ' +  WatchListSymbol (watchListNum));
    ClearIndicators();
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // Second last should be red
    //if( PriceClose(BarCount-2) > PriceOpen(BarCount-2) ) then
    //  continue;
      
    // Last bar should be green or a hammer
    if( ( PriceClose(BarCount-1) < PriceOpen(BarCount-1) ) and
        ( Not BullishHammer( BarCount-1 ) ) ) then
      continue;
      
    // Last bar close should be less than EMA11
    if( PriceLow(BarCount-1) > EMA(BarCount-1, #Close, 11) ) then
      continue;
      
    WatchListAddSymbol( newWatchList, '', GetSymbol);
  end;
  RestorePrimarySeries;
end;

//______________________________________________________________________________
//
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

if Not IsDaily then
begin
  ShowMessage ('Runs only on Daily data');
  abort;
end;

GenCandleReversalWatchList( 'B-CandleBullish' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

