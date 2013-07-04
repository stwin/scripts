{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
//
procedure GenerateBullishReversalWatchList (newWatchList: String);
begin
  var watchListNum: integer;
  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear( newWatchList );

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin

    PrintStatus ('Processing: ' + IntToStr(watchListNum+1)
          + '/' + IntToStr(WatchListCount)
          + ' ' +  WatchListSymbol (watchListNum));
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 10000) then
      continue;

    if( BarCount < 254 ) then
      continue;
      
    if( HighestBar( BarCount-1, #High, 254 ) < BarCount-1-88 ) then
      continue;
    if( HighestBar( BarCount-1, #High, 254 ) > BarCount-1-11 ) then
      continue;

    if( EMA( BarCount-1, #Close, 22 ) > EMA( BarCount-2, #Close, 22 ) )
      and ( EMA( BarCount-22, #Close, 22 ) < EMA( BarCount-23, #Close, 22 ) )
      then
    begin
      WatchListAddSymbol( newWatchList, '', GetSymbol);
    end;
  end;
  RestorePrimarySeries;
end;

//______________________________________________________________________________
//
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

GenerateBullishReversalWatchList ( WatchListName + '-BR');

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

