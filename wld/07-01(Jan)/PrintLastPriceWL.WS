{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
procedure writeAllSymbols();
begin
  var watchListNum: integer;
  var fileHandle, bar: integer;
  fileHandle := FileOpen( 'I:\list.txt' );
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    FileWrite( fileHandle, WatchListSymbol (watchListNum));
  end;
  FileClose( fileHandle );
end;
///////////////////////////////////////////////////////////////////////////////
procedure PrintLastPrice();
begin
  var watchListNum: integer;
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    //Print( GetSymbol + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) ) );
    Print( GetSymbol + #9 + FormatFloat( '#', SMA( BarCount-1, #Volume, 132) / 1000 ) );
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program


//writeAllSymbols((;
PrintLastPrice();


