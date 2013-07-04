{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

//______________________________________________________________________________
//
procedure GetBigBases( newWatchList: String );
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

    // At least 5 years of data
    if( BarCount < 12*5 ) then
      continue;

    // Highest price > 50
    if( Highest(BarCount-1, #Close, BarCount-1) < 50 ) then
      continue;

    // Current Price < 10
    if( PriceClose(BarCount-1) > 10 ) then
      continue;

    // 5 year High in last 6 months
    if( HighestBar( BarCount-1, #Close, 12*5 ) < (BarCount-6)  ) then
      continue;

    // 5 year High was not 1 year back
    if( HighestBar( BarCount-12, #Close, 12*5 ) > (BarCount-24)  ) then
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

//if Not IsMonthly then
//begin
//  ShowMessage ('Runs only on Monthly data');
//  abort;
//end;

GetBigBases( 'Temp' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

