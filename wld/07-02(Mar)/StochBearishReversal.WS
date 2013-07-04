{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

//______________________________________________________________________________
//
procedure GenStochBearishReversalWatchList( newWatchList: String );
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

    if( BarCount < 50 ) then
      continue;

    if( StochD( BarCount-1, 7, 3 ) < 70 ) then
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

GenStochBearishReversalWatchList( 'B-StochBearish' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

