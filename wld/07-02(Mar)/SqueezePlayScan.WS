{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
//
procedure RunScan( newWatchList: String );
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
      ClearIndicators();
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    if( BarCount < 80 ) then
      continue;

    var bbu: integer = BBandUpperSeries( #Close, 22, 2.7 );
    var bar, bbuWidth, countDownBars: integer;
    bbuWidth := SubtractSeries( BBandUpperSeries( #Close, 22, 2.7 ), SMASeries( #Close, 22 ) );
  
    countDownBars := 0;
    for bar := BarCount-44 to BarCount-1 do
    begin
      if( @bbuWidth[bar] <= @bbuWidth[bar-1] ) then
        inc( countDownBars );
    end;
    
    // Last bar close should be less than EMA11
    if( countDownBars < 33 ) then
      continue;

    WatchListAddSymbol( newWatchList, '', GetSymbol );
  end;
  RestorePrimarySeries;
end;


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

if Not IsDaily then
begin
  ShowMessage ('Runs only on Daily data');
  abort;
end;

RunScan( 'B-SqueezePlay' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

