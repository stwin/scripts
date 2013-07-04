{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

//______________________________________________________________________________
function ShootingStar( Bar: integer ): boolean;
begin
  var OHL, CHL: float;

  // Open relative to the bar's range
  OHL :=  (PriceOpen(Bar) - PriceLow(Bar)) / ( PriceHigh(Bar) - PriceLow(Bar));

  // Close relative to the bar's range
  CHL :=  (PriceClose(Bar) - PriceLow(Bar)) / ( PriceHigh(Bar) - PriceLow(Bar));

  // Detecting patterns
  Result := (Min(OHL, CHL) < 0.10)  //Little or no lower shadow
        and (Max(OHL, CHL) < 0.30); //Open and Close near the Low
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
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // Second last should be green
    //if( PriceClose(BarCount-2) < PriceOpen(BarCount-2) ) then
    //  continue;
      
    // Last bar should be red or a shooting star
    if( ( PriceClose(BarCount-1) > PriceOpen(BarCount-1) ) and
        ( Not ShootingStar( BarCount-1 ) ) ) then
      continue;
      
    // Last bar high should be more than EMA11
    if( PriceHigh(BarCount-1) < EMA(BarCount-1, #Close, 11) ) then
      continue;
      
    WatchListAddSymbol( newWatchList, '', GetSymbol);
  end;
  RestorePrimarySeries;
  ClearIndicators();
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

GenCandleReversalWatchList( 'B-CandleBearish' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

