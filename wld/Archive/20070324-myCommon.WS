
// Use this COM object to access extra functionalities
//var myUtil: ComVariant = CreateOleObject( 'WLExtra.Util' );

//______________________________________________________________________________
// Get Weekly bar on a weekly chart from a daily date
//
function WeeklyBarFromDailyDate( date: integer ): integer;
begin
  const maxDays = 5;
  var bar, count, maxLoopLimit: integer;
  bar := -1;
  count := 0;
  maxLoopLimit := 100;
  while count <> maxDays do
  begin
    maxLoopLimit := maxLoopLimit-1;
    if( maxLoopLimit <= 0 ) then break;
    try
      bar := DateToBar( date );
      count := count + 1;
    except
    end;
    if( bar <> -1 ) then
      break;
    date := date - 1;
  end;
  Result := bar;
end;
//______________________________________________________________________________
// Returns the day of a bar as string
//
function getDayStr( bar: integer ): String;
begin
  var str: String = 'Holiday';
  var dayAsInt: integer = DayOfWeek( bar );
  case dayAsInt of
    #Monday:    str := 'Monday';
    #Tuesday:   str := 'Tuesday';
    #Wednesday: str := 'Wednesday';
    #Thursday:  str := 'Thursday';
    #Friday:    str := 'Friday';
  end;
  Result := str;
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
  while ((countLoop < 200) and (percentIn < cutoffPercent)) do
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
    //Print( AsString(CountLoop) + #9 + IntToStr(percentIn) + '  ' + IntToStr (totalIn) + '  ' + '   ' + floatToStr(deviation));printflush();
    //Print( AsString(countLoop) + #9 + AsString(deviation
  end;

  Result := deviation;
end;
//______________________________________________________________________________
// This is a faster version of the original function PlotSymbolColoredCandle
// ( now called PlotSymbolColoredCandle2 )
// speed improvement : more than 10 times or more, depends on # of bars
procedure PlotSymbolColoredCandle (symbol: String; pane, upBarColor, downBarColor: integer);
begin
  var Bar, O, H, L, C: integer;
  var diff, Series_1_0, Series_0_1, O_alt : integer;
  SetPrimarySeries( symbol );

  diff := SubtractSeries( #Close, #Open );
  Series_1_0 := AddSeriesValue( DivideSeries( diff,
                    MultiplySeriesValue( AbsSeries( diff ), 2 ) ), 0.5 );
  Series_0_1 := SubtractValueSeries( 1, Series_1_0 );
  O_alt := MultiplySeries( #Close, Series_0_1 );

  O := AddSeries( MultiplySeries( Series_1_0, #Open ), O_alt );
  H := AddSeries( MultiplySeries( Series_1_0, #High ), O_alt );
  L := AddSeries( MultiplySeries( Series_1_0, #Low ), O_alt );
  C := #Close;

  PlotSymbol( symbol, pane, downBarColor, #Candle );
  PlotSyntheticSymbol( symbol, O, H, L, C, pane, upBarColor, #Candle );
  DrawLabel( symbol, pane );
  RestorePrimarySeries;
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

  fileName :=  'D:\WL\Images\' + fileName + '.bmp';
  SaveChartImage( fileName, width, height, 'BMP' );

  var str: String = getDayStr( BarCount-1 );
  var dateInfo: string = DateToStr( getDate( BarCount-1 ) ) + '  ' + getDayStr( BarCount-1 );

  var image: ComVariant;
  image := CreateOleObject( 'WLExtra.Image' );
  image.Open( fileName );
  image.DrawRectangle( 7, 19, 120, 37, 999, 0, 999 );
  image.DrawText( dateInfo, 7, 19, 0, 10 );
  image.Save( fileName, 'bmp' );
  image.Close();

  //dateInfo := '\"' + dateInfo + '\"';
  //RunProgram( 'D:\WL\Manage\saveImageClean.bat ' + fileName + ' ' + dateInfo, true );

end;
//______________________________________________________________________________
// Save the chart
//
procedure SaveChart ();
begin
  SaveChartWithSize( 1024, 768 );
end;
//______________________________________________________________________________


//______________________________________________________________________________
// Plots ElderChannel on the Fly
//
procedure PlotElderChannelOnTheFly2( pane, period: integer; loopbackmonth, cutoffPercent : integer );
begin
  var deviation: float;

  deviation := getElderChannelDeviation (BarCount-1, period, loopbackmonth, cutoffPercent);

  var upperSeries, lowerSeries: integer;
  upperSeries := MultiplySeriesValue (EMASeries(#close, period), (1+deviation));
  lowerSeries := MultiplySeriesValue (EMASeries(#close, period), (1-deviation));

  SetDescription( upperSeries, 'ElderUpperSeries' );
  SetDescription( lowerSeries, 'ElderLowerSeries' );
  
  PlotSeries (upperSeries, pane, #Teal, #thin);
  PlotSeries (lowerSeries, pane, #Teal, #thin);
  
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
procedure PlotMACD2( paneHeight: integer; plotDivergence: boolean);
begin
  var MMacd, MMacdSignal, MHistMACD, macdh, macdPane : integer;
  MMacd := MACDSeries( #Close );
  MMacdSignal := EMASeries( MMacd, 9 );
  MHistMACD := SubtractSeries( MMacd, MMacdSignal );
  macdh := MultiplySeriesValue( MHistMACD, 3 ); // Magnify a bit
  macdPane := CreatePane( paneHeight, false, true );
  PlotSeriesLabel( MMacd, macdPane, #Red, #Thick, 'MACD' );
  PlotSeriesLabel( MMacdSignal, macdPane, #Blue, #Thin, 'MACD Signal' );
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
procedure PlotMACD( plotDivergence: boolean);
begin
  PlotMACD2( 60, plotDivergence );
end;
//______________________________________________________________________________
// Plots Bollinger Band
//
procedure PlotBollingerBand (period: integer; sd: float);
begin
  PlotSeries( BBandLowerSeries( #Close, period, sd ), 0, 631, #Dotted);
  PlotSeries( BBandUpperSeries( #Close, period, sd ), 0, 631, #Dotted);
  PlotSeries( SMASeries (#close, period), 0, #Maroon, #thin);
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

  // First draw elder channel width series, if  that is available.
  var elderChWidthSeries: integer = FindNamedSeries( 'ElderChannelWidthPercent' );
  if( elderChWidthSeries <> -1 ) then
  begin
    PlotSeriesLabel( elderChWidthSeries, stochasticPane, #Teal, #Thin, 'ChannelWidth' );
  end;

  // Now the main series
  var lineColor: integer = 558;
  DrawHorzLine( 20, stochasticPane, lineColor, #Thin );
  DrawHorzLine( 80, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line1, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line2, stochasticPane, lineColor, #Thin );
  if( BarCount > 85 ) then
  begin
    //AnnotateChart(	'Over Bought', stochasticPane, BarCount-80, 91, 000, 8 );
    //AnnotateChart(	'Over Sold', stochasticPane, BarCount-80, 18, 000, 8 );
  end;
  //PlotSeriesLabel( StochKSeries (period+3), stochasticPane, #Gray, #Thin, 'Stochastic' );
  PlotSeriesLabel( slowD, stochasticPane, #Blue, #Thin, 'Slow D(3)' );
  PlotSeriesLabel( slowK, stochasticPane, #red, #Thick, 'Slow K ('+IntToStr(period)+',3)' );
end;
//PlotStochastic (8, 20, 80);
//______________________________________________________________________________
// Plot RSI
//
procedure PlotRSI (period, line1, line2: integer);
begin
  var rsiId, pane : integer;
  pane := CreatePane( 60, false, true );
  rsiId := RSISeries( #Close, period );

  DrawHorzLine( line1, pane, #Olive, #Thin );
  DrawHorzLine( line2, pane, #Olive, #Thin );
  DrawHorzLine( 50, pane, #Olive, #Thin );
  PlotSeriesLabel ( rsiId, pane, #Red, #Thick, 'RSI(' + IntToStr(period)+')');
end;
//______________________________________________________________________________
// Plots Volume with custome size pane
//
procedure PlotVolume( height: integer );
begin
  var volumePane: integer = CreatePane( height, false, true );
  var zeroSeries: integer = AddSeriesValue( #Volume, 0 );
  @zeroSeries[BarCount-1] := 0;
  SetDescription( zeroSeries, 'Volume' );
  PlotSeries( zeroSeries, volumePane, #Black, #Histogram );
  PlotSeriesLabel( #Volume, volumePane, #Black, #ThickHist,'Volume' );
end;
//______________________________________________________________________________
// Print Open Positions
//
procedure PrintOpenPosition ();
begin
  var file: integer;
  var FileName: String = 'D:\WL\Manage\Positions.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');

    if (GetSymbol = symbolStr) then
    begin
      var positionSize, entryDate, entryBar: integer;
      var entryPrice, entryTotal, targetPrice, stopPrice: float;
      var currentPrice, currentTotal: float;
      var tradeType: string;
      tradeType := GetToken( line, 1, ',' );
      positionSize := StrToInt( GetToken( line, 2, ',' ) );
      entryDate := StrToInt( GetToken( line, 3, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 4, ',' ) );
      entryTotal := StrToFloat( GetToken( line, 5, ',' ) );
      stopPrice := StrToFloat( GetToken( line, 6, ',' ) );
      targetPrice := StrToFloat( GetToken( line, 7, ',' ) );

      currentPrice := PriceClose( BarCount-1 );
      currentTotal := positionSize * currentPrice;
      entryBar := DateToBar( entryDate );
      if( entryBar = -1 ) then
        exit;

      // Mark buy bar
      //SetBackgroundColor (entryBar, #BlueBkg);
      //AnnotateBar( 'B', entryBar, false, #Black, 7 );

      // Mark entryPrice, targetPrice and stopPrice
      var startBar: integer;
      if( entryBar < BarCount-2 ) then
        startBar := entryBar
      else
        startBar := BarCount-2;
      DrawLine( startBar, entryPrice, BarCount-1, entryPrice, 0, #Black, #thin );
      DrawLine( startBar, targetPrice, BarCount-1, targetPrice, 0, #Black, #thin );
      DrawLine( startBar, stopPrice, BarCount-1, stopPrice, 0, #Black, #thin );

      // Now some printing
      var entryStr, currStr, profitStr: String;
      
      entryStr := 'Entry   ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', entryPrice )
                        + ' = ' + FormatFloat( '#,###.#0', entryTotal );
      currStr := 'Current ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', currentPrice )
                        + ' = ' + FormatFloat( '#,###.#0', currentTotal );

      profitStr := 'Profits in ' + IntToStr( BarCount-entryBar ) + ' days = '
                          + FormatFloat( '#,###.#0', currentTotal-entryTotal );

      MyDrawLabel( '', #Black );
      MyDrawLabel( entryStr, #Black );
      MyDrawLabel( currStr, #Black );
      if( currentTotal > entryTotal ) then
        MyDrawLabel( profitStr, #Green )
      else
        MyDrawLabel( profitStr, #Red );

      // Now some detailed printing in the debug window
      Print( entryStr );
      Print( currStr );
      Print( profitStr );
      Print ('');
      var bar: integer;
      for bar := entryBar to BarCount-1 do
      begin
        Print( DateToStr( GetDate( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize - entryTotal ) );
      end;
      break;
    end;
  end;
  FileClose (file);
end;
//______________________________________________________________________________
// Print Closed Positions
//
procedure PrintClosedPosition ();
begin
  var file: integer;
  //var FileName: String = 'D:\WL\Manage\PositionsClosed.csv';
  var FileName: String = 'D:\WL\docs\Training-07\PositionsClosed.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do begin
    var line, symbolStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');
    if (GetSymbol = symbolStr) then begin
      var entryDateStr, entryPriceStr, exitDateStr, exitPriceStr, tradeType, splitInfoStr: string;
      entryDateStr   := GetToken( line, 1, ',' );
      entryPriceStr := GetToken( line, 2, ',' );
      exitDateStr    := GetToken( line, 3, ',' );
      exitPriceStr  := GetToken( line, 4, ',' );
      tradeType     := GetToken( line, 5, ',' );
      splitInfoStr  := GetToken( line, 6, ',' );

      var entryBar, exitBar: integer;
      var entryPrice, exitPrice: float;
      
      entryBar := DateToBar( StrToInt( entryDateStr ) );
      if( IsWeekly ) then
        entryBar := WeeklyBarFromDailyDate( StrToInt( entryDateStr ) );
      if( entryBar = -1 ) then // entryBar is in future i.e. you are studying history
        continue;
      entryPrice := StrToFloat( entryPriceStr );
      
      if( exitDateStr = '' ) then begin // Position not yet closed
        exitBar := 0;
        exitPrice := PriceClose( 0 );
      end else begin // For closed positions
        exitBar := DateToBar( StrToInt( exitDateStr ) );
        if( IsWeekly ) then
          exitBar := WeeklyBarFromDailyDate( StrToInt( exitDateStr ) );
        if( exitBar = -1 ) then   // Closed Position in future
          exitBar := 0;
        exitPrice := StrToFloat( exitPriceStr );
      end;

      if( splitInfoStr <> '1' ) then begin
        var split: float = StrToFloat( splitInfoStr );
        entryPrice := entryPrice / split;
        exitPrice  := exitPrice / split;
      end;

      var annotateColor: integer = 009;

      if( entryBar = exitBar ) then begin
        SetBackgroundColor (entryBar, 886);
      end else begin
        if( tradeType = 'L' ) then begin
          SetBackgroundColor (entryBar, 988);
          SetBackgroundColor( exitBar, 798 );
        end else begin
          SetBackgroundColor (entryBar, 798);
          SetBackgroundColor( exitBar, 988 );
        end;
      end;
      // Annotate Bars
      if( tradeType = 'L' ) then begin
        AnnotateBar( 'B', entryBar, false, annotateColor, 7 );
        AnnotateBar( 'S', exitBar, true, annotateColor, 7 );
      end else begin
        AnnotateBar( 'T', entryBar, true, annotateColor, 7 );
        AnnotateBar( 'C', exitBar, false, annotateColor, 7 );
      end;

      DrawLine( entryBar-1, entryPrice, entryBar+1, entryPrice, 0, #Blue, #thin );
      DrawLine( exitBar-1, exitPrice, exitBar+1, exitPrice, 0, #Blue, #thin );
    end;
  end;
  FileClose (file);
end;
//______________________________________________________________________________
// Print Positions
//
procedure PrintPosition ();
begin
  PrintOpenPosition();
  PrintClosedPosition();
end;
//______________________________________________________________________________
procedure PlotFewBarsOfSP500();
begin
  var lastBarScaledPrice, howClose, factor: float;
  var showBars, o, h, l, c: integer;
  var monthsOnScreen, showBarsMonth: integer;
  var drawBelowPrice: boolean = true;

  if( GetSymbol = 'SP-500' ) then
    exit;

  // readjustable parameters
//  drawBelowPrice := false;
  monthsOnScreen := 6;
  showBarsMonth := 2;
  howClose := 0;  // How close SP-500 should be to the main Price on the last bar
                     // Should be between 0 and 1

  //drawBelowPrice := myUtil.getBoolParam( 'SP500AtBottom' );

  if( drawBelowPrice ) then
  begin
    lastBarScaledPrice := howClose * PriceClose( BarCount-1 ) +
                      (1-howClose) * Lowest( BarCount-1, #Low, 22 * monthsOnScreen );
  end
  else
  begin
    lastBarScaledPrice := howClose * PriceClose( BarCount-1 ) +
                      (1-howClose) * Highest( BarCount-1, #Low, 22 * monthsOnScreen );
  end;

  SetPrimarySeries ( 'SP-500' );

  factor := lastBarScaledPrice / PriceClose( BarCount-1 );
  showBars := 22 * showBarsMonth;
  o := #Open;
  h := #High;
  l := #Low;
  c := #Close;

  RestorePrimarySeries;

  var util: ComVariant;
  util := CreateOleObject( 'WLExtra.PaintHook' );

  util.PlotFewBars( IWealthLabAddOn3, showBars, factor, 476, 956, o, h, l, c );
end;
//______________________________________________________________________________
// Displays Day on the price pane
//
procedure DisplayDay ();
begin
  var str: String = getDayStr( BarCount-1 );
  DrawText (str, 0, 80, 18, #Black, 8);
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

