
//______________________________________________________________________________
// Get the elder channel deviation - used for ElderChannel
//
function GetElderChDeviation( EndBar, Period, LoopBackBar, CutOffPercent : integer): float;
begin
  var bar: integer;

  // Get out if less than required bars
  if( EndBar < ( loopbackbar + 1 ) ) then
  begin
    Result := 0;
    exit;
  end;

  var ValueSeries: integer = EMASeries( #Close, Period );

  // First get an approximate value for deviation
  var deviation, range, totalRange, absDev: float;
  totalRange := 0;
  for bar := EndBar-9 to EndBar do // last 10 days
  begin
    range := Abs( @#Close[bar] - @ValueSeries[bar] );
    totalRange := totalRange + range;
  end;
  absDev := totalRange / 10; // Avg absolute deviation
  deviation := absDev / @ValueSeries[EndBar];  // deviation as a fraction of ValueSeries

  // fit on last couple of months by iteration, to get a good value of deviation
  var countLoop, percentIn, totalIn: integer;
  percentIn := 0;
  countLoop := 0;
  while ((countLoop < 200) and (percentIn < CutOffPercent)) do
  begin
    countLoop := countLoop + 1;
    totalIn := 0;
    for bar := EndBar-LoopBackBar+1 to EndBar do
    begin
      if ((@#Close[bar] < (@ValueSeries[bar] *(1+deviation)))
          and (@#Close[bar] > (@ValueSeries[bar] * (1-deviation)))
          ) then
        totalIn := totalIn + 1;
    end;
    percentIn := 100*totalIn / loopbackbar;
    if (percentIn < CutOffPercent) then
      deviation := deviation * 1.1;
    //Print( 'countLoop=' + AsString(CountLoop) + #9 + IntToStr(percentIn)
    //      + '  ' + IntToStr (totalIn) + '  ' + '   ' + floatToStr(deviation));printflush();
  end;
  Result := deviation;
end;
//______________________________________________________________________________
// Plots ElderChannel on the Fly
//
procedure PlotElderChOnTheFly2( Pane, Period, LoopBackBar, CutOffPercent: integer );
begin
  var deviation: float;
  var slowEmaSeries, upperSeries, lowerSeries: integer;

  slowEmaSeries := EMASeries( #Close, Period );
  deviation := GetElderChDeviation( BarCount-1, Period, LoopBackBar, CutOffPercent );
  upperSeries := MultiplySeriesValue( slowEmaSeries, (1+deviation) );
  lowerSeries := MultiplySeriesValue( slowEmaSeries, (1-deviation) );


  // First few bars
  var bar: integer;
  for bar := 0 to period-1 do
  begin
    @upperSeries[bar] := @upperSeries[period];
    @lowerSeries[bar] := @lowerSeries[period];
  end;

  SetDescription( upperSeries, 'ElderUpperSeries' );
  SetDescription( lowerSeries, 'ElderLowerSeries' );

  PlotSeries( upperSeries, Pane, #Teal, #thin );
  PlotSeries( lowerSeries, Pane, #Teal, #thin );

  if( pane = 0 ) then
  begin
    MyDrawLabel ('ChannelWidth ('
       + IntToStr(cutoffPercent) + ', '
       + FormatFloat('#', 2*deviation*100) + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
       #Black);
  end
  else
  begin
    DrawLabel ('ChannelWidth ('
       + IntToStr(cutoffPercent) + ', '
       + FormatFloat('#', 2*deviation*100) + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
       pane);
  end;
end;
//______________________________________________________________________________
procedure PlotElderChOnTheFly( Period, LoopBackBar, CutOffPercent: integer );
begin
  PlotElderChOnTheFly2( 0, Period, LoopBackBar, CutOffPercent );
end;


