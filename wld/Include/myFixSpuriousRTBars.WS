{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );


procedure FixSpuriousRTBars();
begin
  var bar: integer;

  for bar := 2 to BarCount-3 do
  begin
    // Take care of the big gaps at opening (avg. does not work here)
    if( LastBar(bar+1) or LastBar(bar) or LastBar(bar-1) or LastBar(bar-2) ) then
      continue;

    var avgHigh, avgLow, avgRange: float;

    // Find averages for neighboring 4 bars (2 left, 2 right)
    avgHigh := (PriceHigh(bar-2) + PriceHigh(bar-1) + PriceHigh(bar+1) + PriceHigh(bar+2))/4;
    avgLow := (PriceLow(bar-2) + PriceLow(bar-1) + PriceLow(bar+1) + PriceLow(bar+2))/4;
    avgRange := avgHigh - avgLow;

    // Test for a UP Tail
    if( PriceHigh(bar) > (avgHigh + 3*avgRange) ) then
    begin
      var reasonableHigh: float;
      var actualHigh: float = PriceHigh( bar );
      reasonableHigh := avgHigh + avgRange;
      reasonableHigh := Max( reasonableHigh, PriceOpen(bar) );
      reasonableHigh := Max( reasonableHigh, PriceClose(bar) );
      DrawLine( bar-1, actualHigh, bar+1, actualHigh, 0, 009, 0 );
      @#High[bar] := reasonableHigh;
      //SetBackgroundColor( bar, 679 );
    end;

    // Test for a DOWN Tail
    if( PriceLow(bar) < (avgLow - 3*avgRange) ) then
    begin
      var reasonableLow: float;
      var actualLow: float = PriceLow( bar );
      reasonableLow := avgHigh + avgRange;
      reasonableLow := Min( reasonableLow, PriceOpen(bar) );
      reasonableLow := Min( reasonableLow, PriceClose(bar) );
      DrawLine( bar-1, actualLow, bar+1, actualLow, 0, 009, 0 );
      @#Low[bar] := reasonableLow;
      //SetBackgroundColor( bar, 976 );
    end;
  end;
end;

FixSpuriousRTBars();

{$I 'mycommon'}
VolumeColor();
PlotSeries( BetterEMASeries( #close, 13), 0, 777, #thin );
PlotSeries( BetterEMASeries( #close, 26), 0, #Maroon, #thin );
PlotElderChannelOnTheFly( 26, 12, 90 );

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

