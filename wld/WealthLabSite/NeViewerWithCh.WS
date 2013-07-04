{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
{$I 'MACDEx'}

///////////////////////////////////////////////////////////////////////////////
// Draws Label in bigger font on the price pane
var myDrawLabelX: integer = 45;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 5, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;

///////////////////////////////////////////////////////////////////////////////
procedure PlotAreaLabel (Series, Pane, Color : integer; label: String);
begin
  var bar: integer;
  PlotSeriesLabel ( Series, Pane, Color, #Thin, label );
  for bar := 1 to BarCount - 1 do
  begin
    DrawDiamond (bar-1, @Series[bar-1], bar-1, 0,
                bar, 0, bar, @Series[bar],
                Pane, Color, #Thin, Color, true);
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure getBottom (var bar: integer; var bottomLast: float;
                     var barBottomLast: integer; macdh: integer);
begin
  for bar := bar downto 0 do
  begin
    if (@macdh[bar] < 0) then
      break;
  end;
  // Now we are pointing to a negative entry
  bottomLast := @macdh[bar];
  barBottomLast := bar;
  for bar := bar-1 downto 0 do
  begin
    if (@macdh[bar] >= 0) then
      break;
    if (@macdh[bar] < bottomLast) then
    begin
      bottomLast := @macdh[bar];
      barBottomLast := bar;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure getPeak (var bar: integer; var peakLast: float;
                     var barPeakLast: integer; macdh: integer);
begin
  for bar := bar downto 0 do
  begin
    if (@macdh[bar] > 0) then
      break;
  end;
  // Now we are pointing to a positive entry
  peakLast := @macdh[bar];
  barPeakLast := bar;
  for bar := bar-1 downto 0 do
  begin
    if (@macdh[bar] <= 0) then
      break;
    if (@macdh[bar] > peakLast) then
    begin
      peakLast := @macdh[bar];
      barPeakLast := bar;
    end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
function getElderChannelDeviation (period: integer; loopbackmonth, cutoffPercent : integer): float;
begin
  var deviation: float;
  var bar: integer;

  // First get an approximate value for deviation
  deviation := 0;
  for bar := BarCount-10 to Barcount-1 do // last 10 days
  begin
    var range: float;
    range := Max (PriceHigh (bar) - EMA (bar, #Close, period),
                  EMA (bar, #Close, period) - PriceLow (bar));
    if (range < 0) then
      Abort;
    deviation := deviation + range;
  end;
  deviation := deviation / 10; // Avg deviation
  deviation := deviation / EMA(BarCount-1, #Close, period); // as fraction of EMA

  // fit on last couple of months by iteration, to get a good value of deviation
  var countLoop: integer;
  var percentIn: integer;
  percentIn := 0;
  countLoop := 0;
  while ((countLoop < 20) and (percentIn < cutoffPercent)) do
  begin
    countLoop := countLoop + 1;
    var totalIn, loopbackbar: integer;
    totalIn := 0;
    if isDaily then loopbackbar := loopbackmonth * 22
    else loopbackbar := loopbackmonth * 4;
    for bar := BarCount-loopbackbar to Barcount-1 do
    begin
      if ((PriceClose(bar) < (EMA (bar, #Close, period) *(1+deviation)))
          and (PriceClose(bar) > (EMA (bar, #Close, period) * (1-deviation)))
          ) then
        totalIn := totalIn + 1;
    end;
    percentIn := 100*totalIn / loopbackbar;
    if (percentIn < cutoffPercent) then
      deviation := deviation * 1.1;
    //Print (IntToStr(percentIn) + '  ' + IntToStr (totalIn) + '  ' + '   ' + floatToStr(deviation));printflush();
  end;

  // return deviation
  Result := deviation;
end;
///////////////////////////////////////////////////////////////////////////////
procedure PlotElderChannel (period: integer; loopbackmonth, cutoffPercent : integer);
begin
  var deviation: float;

  deviation := getElderChannelDeviation (period, loopbackmonth, cutoffPercent);

  var upperSeries, lowerSeries: integer;
  upperSeries := MultiplySeriesValue (EMASeries(#close, period), (1+deviation));
  lowerSeries := MultiplySeriesValue (EMASeries(#close, period), (1-deviation));

  PlotSeries (upperSeries, 0, #Teal, #thin);
  PlotSeries (lowerSeries, 0, #Teal, #thin);

  MyDrawLabel ('ChannelWidth ('
     + IntToStr(cutoffPercent)
     + ', '
     + FormatFloat('#', 2*deviation*100)
     + '%): '
     + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
     #Black);
end;
///////////////////////////////////////////////////////////////////////////////
procedure PlotMACD (val1, val2, val3 : integer; plotDivergence: boolean);
begin
  var MHistMACD, macdh, pane : integer;
  MHistMACD := SubtractSeries( MACDExSeries( #Close, val1, val2 ), EMASeries( MACDExSeries( #Close, val1, val2 ), val3 ) );
  macdh := MultiplySeriesValue (MHistMACD, 3);
  pane := CreatePane( 60, false, true );
  PlotSeriesLabel( MACDExSeries( #Close, val1, val2 ), pane, #Red, #Thick,
    'MACD ('+IntToStr(val1)+','+IntToStr(val2)+','+IntToStr(val3)+')' );
  PlotSeriesLabel( EMASeries( MACDExSeries( #Close, val1, val2 ), val3 ), pane, #Blue, #Thin, 'MACD Signal' );
  DrawHorzLine( 0, pane, #Olive, #Thin );
  PlotSeries( macdh, pane, #Black, #Histogram);

  if (not plotDivergence) then
    exit;
  // Draw MACD Divergence
  try
    var bar: integer;
    var bottomLast, bottom2ndLast: float;  // Values in macdh series
    var barBottomLast, barBottom2ndLast: integer;
    var lineColor: integer = #Aqua;

    bar := BarCount - 1;

    getBottom (bar, bottomLast, barBottomLast, macdh);
    getBottom (bar, bottom2ndLast, barBottom2ndLast, macdh);

    var peakLast, peak2ndLast: float;
    var barPeakLast, barPeak2ndLast: integer;

    bar := BarCount - 1;

    getPeak (bar, peakLast, barPeakLast, macdh);
    getPeak (bar, peak2ndLast, barPeak2ndLast, macdh);

    if (bottomLast > bottom2ndLast)
      and (PriceLow(barBottomLast) < PriceLow(barBottom2ndLast))
      then
    begin  // bullish divergence
       DrawLine (barBottom2ndLast, PriceLow(barBottom2ndLast)*0.98,
              barBottomLast, PriceLow(barBottomLast)*0.98, 0, lineColor, #Thick);
       //Print (FloatToStr( bottomLast ));
       DrawLine (barBottom2ndLast, GetSeriesValue(barBottom2ndLast,macdh)*0.98,
              barBottomLast, GetSeriesValue(barBottomLast,macdh)*0.98, pane, lineColor, #Thick);
       MyDrawLabel ('Bullish Divergence', #Blue);
    end;
    if (peakLast < peak2ndLast)
      and (PriceHigh(barPeakLast) > PriceHigh(barPeak2ndLast))
      then
    begin  // bearish divergence
       DrawLine (barPeak2ndLast, PriceHigh(barPeak2ndLast)*1.02,
              barPeakLast, PriceHigh(barPeakLast)*1.02, 0, lineColor, #Thick);
       DrawLine (barPeak2ndLast, GetSeriesValue(barPeak2ndLast,macdh)*1.02,
              barPeakLast, GetSeriesValue(barPeakLast,macdh)*1.02, pane, lineColor, #Thick);
       MyDrawLabel ('Bearish Divergence', #Blue);
    end;
  except
  end;
end;


///////////////////////////////////////////////////////////////////////////////
procedure PlotStochastic (period, line1, line2: integer);
begin
  var slowK, slowD, pane : integer;
  pane := CreatePane( 60, false, true );
  slowK := StochDSeries (period, 3);
  slowD := SMASeries (slowK, 3);

  DrawHorzLine( line1, pane, #Olive, #Thin );
  DrawHorzLine( line2, pane, #Olive, #Thin );
  PlotSeriesLabel( StochKSeries (period+3), pane, #Gray, #Thin, 'Stochastic' );
  PlotSeriesLabel( slowK, pane, #red, #Thick, 'Slow K ('+IntToStr(period)+',3)' );
  PlotSeriesLabel( slowD, pane, #Blue, #Thin, 'Slow D(3)' );
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure DisplayDay ();
begin
  var str: String;
  if (DayOfWeek (BarCount-1) = #Monday) then
    str := 'Monday'
  else if (DayOfWeek (BarCount-1) = #Tuesday) then
    str := 'Tuesday'
  else if (DayOfWeek (BarCount-1) = #Wednesday) then
    str := 'Wednesday'
  else if (DayOfWeek (BarCount-1) = #Thursday) then
    str := 'Thursday'
  else if (DayOfWeek (BarCount-1) = #Friday) then
    str := 'Friday'
  else
    str := 'Holiday';

  DrawText (str, 0, 80, 18, #Black, 8);
end;
DisplayDay ();
///////////////////////////////////////////////////////////////////////////////
procedure DisplayVolume ();
begin
  var text: String;
  if (Volume(BarCount-1) > 1000000) then
  begin
    if (Volume(BarCount-1) < 5000000) then
      text := FormatFloat('#.#', Volume(BarCount-1)/1000000) + ' M'
    else
      text := FormatFloat('#', Volume(BarCount-1)/1000000) + ' M'
  end
  else if (Volume(BarCount-1) > 1000) then
    text := FormatFloat('#', Volume(BarCount-1)/1000) + ' K'
  else
    text := FormatFloat('#', Volume(BarCount-1));

  MyDrawLabel ('Volume: ' + text, #Black);
end;
///////////////////////////////////////////////////////////////////////////////
procedure DisplayPercentChangeForLast5Bars ();
begin
  var count: integer;
  var text: String;
  var firstTime: boolean;

  firstTime := true;
  text := 'Change(%): ';

  for count := BarCount-5 to BarCount-1 do
  begin
    var val: float;
    val := (PriceClose(count)-PriceClose(count-1))*100/PriceClose(count-1);
    //val := (PriceHigh(count)-PriceLow(count))*100/PriceLow(count);
    //val := (PriceClose(count)-PriceOpen(count))*100/PriceOpen(count);
    if (firstTime) then
    begin
      text :=  text + ' ' + FormatFloat('#0.00', val);
      firstTime := false;
    end
    else
      text :=  text + ',  ' + FormatFloat('#0.00', val);
  end;
  MyDrawLabel (text, #Black);
end;
///////////////////////////////////////////////////////////////////////////////
procedure VolumeColor ();
begin
  var Bar: integer;
  for Bar := 0 to BarCount - 1 do
    if PriceClose( Bar ) > PriceOpen( Bar ) then
      SetSeriesBarColor( Bar, #Volume, #Green )
    else
      SetSeriesBarColor( Bar, #Volume, #Red );
end;
VolumeColor ();
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

try
    DisplayPercentChangeForLast5Bars ();
    PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
    PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);
    PlotElderChannel (22, 6, 90);
    DisplayVolume ();
    MyDrawLabel ('EMA: 11, 22', #Black);
    PlotMACD (12, 26, 9, true);
    PlotStochastic (7, 20, 80);
except
end;

SetColorScheme (050, 800, 222, 999, 887, 799);
