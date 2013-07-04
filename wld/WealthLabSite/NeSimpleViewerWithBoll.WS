{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
//HideVolume;
{$I 'MACDEx'}
//Print (''); // Clear the debug window

///////////////////////////////////////////////////////////////////////////////
// Draws Label in bigger font on the price pane
var myDrawLabelX: integer = 45;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 5, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
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
end;


///////////////////////////////////////////////////////////////////////////////
procedure PlotBollingerBand (period: integer; sd: float);
begin
  PlotSeries( BBandLowerSeries( #Close, period, sd ), 0, #Teal+1, #Thin);
  PlotSeries( SMASeries (#close, period), 0, #Maroon, #thin);
  PlotSeries( BBandUpperSeries( #Close, period, sd ), 0, #Teal+1, #Thin);
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
procedure PlotPriceChange (period : integer);
begin
  var series, smoothedSeries, pane : integer;
  var bar: integer;
  series := CreateSeries ();
  for bar := 1 to BarCount - 1 do
  begin
    var value: float;
    value := PriceClose(bar) - PriceClose(bar-1);
    SetSeriesValue (bar, series, value);
  end;

  smoothedSeries := EMASeries (series, period);

  pane := CreatePane( 60, false, true );
  DrawHorzLine( 0, pane, #Olive, #Thin );
  //PlotSeriesLabel( series, pane, #green, #Thin, 'PriceChange');
  PlotSeriesLabel( smoothedSeries, pane, #blue, #Thin, 'EMA ('+IntToStr(period)+')');
end;

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
    PlotSeries (SMASeries (#close, 10), 0, 777, #thin);
    //PlotSeries (SMASeries (#close, 20), 0, #Maroon, #thin);
    PlotBollingerBand(22, 2);
    DisplayVolume ();
    MyDrawLabel ('SMA: 10, 20', #Black);
    PlotMACD (12, 26, 9, true);
    PlotStochastic (7, 20, 80);
except
end;

SetColorScheme (050, 800, 222, 999, 887, 799);

