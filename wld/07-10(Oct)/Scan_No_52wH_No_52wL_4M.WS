{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
function readWatchList(): TList;
begin
  var watchListNum: integer;
  var list : TList;

  list := TList.Create;
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    list.Add( WatchListSymbol (watchListNum) );
  end;
  Result := list;
end;


///////////////////////////////////////////////////////////////////////////////

var list : TList;

list := readWatchList();

  var num: integer;

  // Clear the new watch list if it exists
  WatchListClear ('A5-Temp');

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('PriceVolumeBarsRequirement: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );

      if( BarCount < 900 ) then
        continue;

      Singlecalcmode(true);
      if ( highestbar(barcount-1, #High, 600) < Barcount-252 )
        and ( lowestbar(barcount-1, #low, 600 ) < BarCount-252 )
        then
          WatchListAddSymbol ('A5-Temp', '', GetSymbol);
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();

