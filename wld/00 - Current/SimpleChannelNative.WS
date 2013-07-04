{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );


//______________________________________________________________________________
//________ A L T E R N A T I V E   T O   S Y S T E M    M E T H O D S __________
//______________________________________________________________________________
//______________________________________________________________________________
// my version of MACD - allows to change periods. This should be preferred
// instead of the default one.
//
function myMACDSeries( series, period1, period2: integer ): integer;
begin
  var bar: integer;
  var sName: string;
  var value: float;

  sName := 'myMACD(' + GetDescription( series ) + ',' + IntToStr( period1 ) + ',' + IntToStr( period2 ) + ')';
  Result := FindNamedSeries( sName );
  if Result >= 0 then
    exit;
  Result := CreateNamedSeries( sName );
  for bar := Round( Max( Period1, Period2 ) ) to BarCount - 1 do
  begin
    value := EMA( bar, series, period1 ) - EMA( Bar, Series, Period2 );
    SetSeriesValue( bar, Result, value );
  end;
end;
//______________________________________________________________________________
// support function for the above series function (myMACDSeries)
//
function myMACD( bar, series, period1, period2: integer ): float;
begin
  Result := GetSeriesValue( bar, myMACDSeries( Series, Period1, Period2 ) );
end;


//______________________________________________________________________________
// The EMA series starts at 1st Bar.
// An alternate version is above
//
function BetterEMASeries( Series, period: integer ): integer;
begin
  var MA, bar: integer;
  var C: float;

  MA := CreateNamedSeries( '' );
  C := 2/(1+period);

  // First locate nonzero bar in the original series (generally 0th bar)
  // (Sometimes original series may not have first few bars)
  for bar := 0 to BarCount-1 do
  begin
    if( @Series[bar] <> 0) then
      break;
  end;
  // Initialize first bar in MA series with first (nonzero)bar in the original Series
  @MA[bar] := @Series[bar];

  // Fill rest of the bars of MA Series
  for bar := bar+1 to BarCount-1 do
  begin
    @MA[bar] := C * @Series[bar] + (1-C) * @MA[bar-1];
  end;

  Result := MA;
end;

//______________________________________________________________________________




//______________________________________________________________________________
//____________________ H E L P E R   M E T H O D S _____________________________
//______________________________________________________________________________
//______________________________________________________________________________
// Returns the day of a bar as string
//
function GetDayStr( bar: integer ): String;
begin
  var str: String = 'Holiday';
  var dayAsInt: integer = DayOfWeek( bar );
  if( dayAsInt = #Monday ) then
    str := 'Monday'
  else if( dayAsInt = #Tuesday ) then
    str := 'Tuesday'
  else if( dayAsInt = #Wednesday ) then
    str := 'Wednesday'
  else if( dayAsInt = #Thursday ) then
    str := 'Thursday'
  else if( dayAsInt = #Friday ) then
    str := 'Friday';
  Result := str;
end;
//______________________________________________________________________________
// Format given Volume for good display
//
function FormatVolume( vol: float ): string;
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
  Result := text;
end;
//______________________________________________________________________________
// Changes bar colors depending on whether it has increased or decreased
// Used for MACD Histograms
//
procedure ColorSeriesRedGreen ( series: integer );
begin
  var Bar: integer;
  for Bar := 1 to BarCount - 1 do
    if @series[bar] > @series[bar-1] then
      SetSeriesBarColor( Bar, series, 050 )
    else
      SetSeriesBarColor( Bar, series, 600 );
end;
//______________________________________________________________________________
// Draws Label in bigger font on the price pane
//
var myDrawLabelX: integer = 38;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 7, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;
//______________________________________________________________________________
// For a Series, plot area with label
//
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
//______________________________________________________________________________
// Get the elder channel deviation - used for ElderChannel
//
function getElderChannelDeviation( endBar, period, loopbackmonth, cutoffPercent : integer): float;
begin
  var bar: integer;
  var loopbackbar: integer;

  if isDaily then
    loopbackbar := loopbackmonth * 22
  else
    loopbackbar := loopbackmonth * 4;

  // Get out if less than required bars
  if( endBar < ( period + loopbackbar + 1 ) ) then
  begin
    Result := 0;
    exit;
  end;

  // First get an approximate value for deviation
  var deviation: float = 0;
  for bar := endBar-9 to endBar do // last 10 days
  begin
    var range: float;
    range := Max (PriceClose (bar) - EMA (bar, #Close, period),
                  EMA (bar, #Close, period) - PriceClose (bar));
    if (range < 0) then
      Abort;
    deviation := deviation + range;
  end;
  deviation := deviation / 10; // Avg deviation
  deviation := deviation / EMA(endBar, #Close, period); // as fraction of EMA

  // fit on last couple of months by iteration, to get a good value of deviation
  var countLoop: integer;
  var percentIn: integer;
  percentIn := 0;
  countLoop := 0;
  while ((countLoop < 20) and (percentIn < cutoffPercent)) do
  begin
    countLoop := countLoop + 1;
    var totalIn : integer = 0;
    for bar := endBar-loopbackbar+1 to endBar do
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

  Result := deviation;
end;

//______________________________________________________________________________
// Color the Volume bars
//
procedure VolumeColor ();
begin
  var Bar: integer;
  for Bar := 0 to BarCount - 1 do
    if PriceClose( Bar ) > PriceOpen( Bar ) then
      SetSeriesBarColor( Bar, #Volume, #Green )
    else
      SetSeriesBarColor( Bar, #Volume, #Red );
end;
//______________________________________________________________________________
// Save the chart
//
procedure SaveChartWithSize( width, height: integer );
begin
  var fileName: String;
  var Bar: integer;
  //PrintStatus( 'SaveChart: First you should zoom in, then print' );
  if (IsDaily) then
  begin
    fileName := GetSymbol + '-daily-' + IntToStr( GetMonth( BarCount-1 ) );
  end
  else if (IsWeekly) then
  begin
    fileName := GetSymbol + '-weekly';
  end
  else begin
    fileName := GetSymbol + '-unknownTimeFrame';
  end;

  SetColorScheme (050, 800, 222, 999, 887, 799);

  fileName :=  'C:\ST\WLE\Images\' + fileName + '.bmp';
  SaveChartImage( fileName, width, height, 'BMP' );

  var str: String = GetDayStr( BarCount-1 );
  var dateInfo: string = DateToStr( getDate( BarCount-1 ) ) + '  ' + GetDayStr( BarCount-1 );

end;
//______________________________________________________________________________
// Save the chart
//
procedure SaveChart ();
begin
  SaveChartWithSize( 1024, 768 );
end;

//______________________________________________________________________________
//____________ M Y   P L O T T I N G   F U N C T I O N S _______________________
//______________________________________________________________________________
//______________________________________________________________________________
//______________________________________________________________________________
// Plots ElderChannel on the Fly
//
procedure PlotElderChannelOnTheFly2( pane, period: integer; loopbackmonth, cutoffPercent : integer );
begin
  var deviation: float;

  deviation := getElderChannelDeviation (BarCount-1, period, loopbackmonth, cutoffPercent);

  var upperSeries, lowerSeries: integer;
  upperSeries := MultiplySeriesValue (BetterEMASeries(#close, period), (1+deviation));
  lowerSeries := MultiplySeriesValue (BetterEMASeries(#close, period), (1-deviation));

  SetDescription( upperSeries, 'ElderUpperSeries' );
  SetDescription( lowerSeries, 'ElderLowerSeries' );

  PlotSeries (upperSeries, pane, #Teal, #thin);
  PlotSeries (lowerSeries, pane, #Teal, #thin);

  if( pane = 0 ) then
  begin
    MyDrawLabel ('ChannelWidth ('
       + IntToStr(cutoffPercent)
       + ', '
       + FormatFloat('#', 2*deviation*100)
       + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
       #Black);
  end
  else
  begin
    DrawLabel ('ChannelWidth ('
       + IntToStr(cutoffPercent)
       + ', '
       + FormatFloat('#', 2*deviation*100)
       + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
       pane);
  end;
end;
//______________________________________________________________________________
procedure PlotElderChannelOnTheFly( period: integer; loopbackmonth, cutoffPercent : integer );
begin
  PlotElderChannelOnTheFly2( 0, period, loopbackmonth, cutoffPercent );
end;

//______________________________________________________________________________
// Used for detecting MACD Divergence
//
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
//______________________________________________________________________________
// Used for detecting MACD Divergence
//
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

//______________________________________________________________________________
// Plots MACD Series including bearish and bullish divergences
//
procedure PlotMACD2( paneHeight, val1, val2, val3 : integer; plotDivergence: boolean);
begin
  var MMacd, MMacdSignal, MHistMACD, macdh, macdPane : integer;
  MMacd := myMACDSeries( #Close, val1, val2 );
  MMacdSignal := EMASeries( MMacd, val3 );
  MHistMACD := SubtractSeries( MMacd, MMacdSignal );
  macdh := MultiplySeriesValue( MHistMACD, 3 ); // Magnify a bit
  macdPane := CreatePane( paneHeight, false, true );
  PlotSeriesLabel( MMacd, macdPane, #Red, #Thick, 'MACD ('+IntToStr(val1)+','+IntToStr(val2)+')' );
  PlotSeriesLabel( MMacdSignal, macdPane, #Blue, #Thin, 'MACD Signal ('+','+IntToStr(val3)+')' );
  DrawHorzLine( 0, macdPane, #Olive, #Thin );

  PlotSeries( macdh, macdPane, #Black, #Histogram);
  ColorSeriesRedGreen( macdh );

  if( not plotDivergence ) then
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
              barBottomLast, GetSeriesValue(barBottomLast,macdh)*0.98, MacdPane, lineColor, #Thick);
       MyDrawLabel ('Bullish Divergence', #Blue);
    end;
    if (peakLast < peak2ndLast)
      and (PriceHigh(barPeakLast) > PriceHigh(barPeak2ndLast))
      then
    begin  // bearish divergence
       DrawLine (barPeak2ndLast, PriceHigh(barPeak2ndLast)*1.02,
              barPeakLast, PriceHigh(barPeakLast)*1.02, 0, lineColor, #Thick);
       DrawLine (barPeak2ndLast, GetSeriesValue(barPeak2ndLast,macdh)*1.02,
              barPeakLast, GetSeriesValue(barPeakLast,macdh)*1.02, MacdPane, lineColor, #Thick);
       MyDrawLabel ('Bearish Divergence', #Blue);
    end;
  except
  end;
end;

//______________________________________________________________________________
procedure PlotMACD (val1, val2, val3 : integer; plotDivergence: boolean);
begin
  PlotMACD2( 60, val1, val2, val3, plotDivergence );
end;
//______________________________________________________________________________
// Plot Stochastic
//
procedure PlotStochastic (period, line1, line2: integer);
begin
  var slowK, slowD, stochasticPane : integer;
  stochasticPane := CreatePane( 60, false, true );
  slowK := StochDSeries (period, 3);
  slowD := SMASeries (slowK, 3);

  DrawHorzLine( line1, stochasticPane, #Olive, #Thin );
  DrawHorzLine( line2, stochasticPane, #Olive, #Thin );
  PlotSeriesLabel( StochKSeries (period+3), stochasticPane, #Gray, #Thin, 'Stochastic' );
  PlotSeriesLabel( slowK, stochasticPane, #red, #Thick, 'Slow K ('+IntToStr(period)+',3)' );
  PlotSeriesLabel( slowD, stochasticPane, #Blue, #Thin, 'Slow D(3)' );
end;

//______________________________________________________________________________
// Displays Day on the price pane
//
procedure DisplayDay ();
begin
  var str: String = GetDayStr( BarCount-1 );
  DrawText (str, 0, 80, 18, #Black, 8);
end;
//______________________________________________________________________________
// Display Volume infomration of last bar
//
procedure DisplayVolume ();
begin
  var text: String = FormatVolume( Volume(BarCount-1) );
  MyDrawLabel ('Volume: ' + text, #Black);
end;
//______________________________________________________________________________
// Display Percent Changes for Last 5 Bars
//
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

//______________________________________________________________________________
//______________________________________________________________________________

try
  if( IsWeekly ) then
  begin
    HideVolume;
    MyDrawLabel( 'EMA: 13, 26', #Black );
    PlotSeries( BetterEMASeries( #close, 13), 0, 777, #thin );
    PlotSeries( BetterEMASeries( #close, 26), 0, #Maroon, #thin );
    PlotElderChannelOnTheFly( 26, 12, 90 );
    PlotMACD( 12, 26, 9, true );
    PlotStochastic( 7, 20, 80 );
  end
  else if( IsDaily ) then
  begin
    DisplayPercentChangeForLast5Bars();
    PlotSeries( BetterEMASeries( #close, 11 ), 0, 777, #thin );
    PlotSeries( BetterEMASeries( #close, 22 ), 0, #Maroon, #thin );
    PlotElderChannelOnTheFly( 22, 6, 90 );
    DisplayVolume();
    VolumeColor();
    MyDrawLabel( 'EMA: 11, 22', #Black );
    PlotMACD( 12, 26, 9, true );
    PlotStochastic( 7, 20, 80 );
    DisplayDay ();
  end;

except
end;


// For saving image
// SaveChart();


