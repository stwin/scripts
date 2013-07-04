{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch ( false );

var n1, n2: integer;
var newWatchList: String;

n1:= GetTickCount;

if ( IsWeekly ) then
  newWatchList := 'Z-Scan-DW-Up-W'
else
  newWatchList := 'Z-Scan-DW-Up-D';

//______________________________________________________________________________
//
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

    if ( BarCount < 50 ) then
    begin
      Print ( 'Skipping ' + IntToStr(watchListNum) + #9 + GetSymbol );
      continue;
    end;

    var ema22, ema11: integer;
    ema22 := EMASeries ( #Close, 22 );
    ema11 := EMASeries ( #Close, 11 );

    if ( ( @ema22[BarCount-1] > @ema22[BarCount-15] ) and
         ( @ema22[BarCount-15] > @ema22[BarCount-30] ) ) then   // Uptrend
    begin
      if ( PriceClose(BarCount-1) < @ema11[BarCount-1] ) then
        WatchListAddSymbol( newWatchList, '', GetSymbol);
    end;
  end;
  RestorePrimarySeries;
end;


n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

