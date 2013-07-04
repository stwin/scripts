{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

//______________________________________________________________________________
var watchListNum: integer;

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

  //if( Pos( 'Optionable', GetSymbol ) = 0 ) then
  begin
    print( GetSymbol
        + #9 + FloatTostr(PriceClose(Barcount-1))
        + #9 + FloatTostr(Lowest( BarCount-1, #Volume, 22))
        + #9 + FloatTostr(SMA( BarCount-1, #Volume, 22))
     );
    //printflush();
  end;

end;

