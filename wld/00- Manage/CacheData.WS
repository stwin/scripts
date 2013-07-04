{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

// This chartscript caches the data for a particular watchlist

///////////////////////////////////////////////////////////////////////////////
// Main Program
var watchListNum: integer;

for watchListNum := 0 to WatchListCount - 1 do
begin
  PrintStatus ('Caching: ' + IntToStr(watchListNum) + ' ' +  WatchListSymbol (watchListNum));

  // Read the chart table for the symbol
  try
  SetPrimarySeries (WatchListSymbol (watchListNum) );
  except
    continue;
  end;
end;
RestorePrimarySeries;
//PrintStatus ('Done');

