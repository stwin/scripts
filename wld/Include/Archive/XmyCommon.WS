
// Use this COM object to access extra functionalities
var wlExtraUtil: ComVariant = CreateOleObject( 'WLE.Util' );

//______________________________________________________________________________
//________ O V E R R I D I N G   S Y S T E M    D E F A U L T S ________________
//______________________________________________________________________________

//______________________________________________________________________________
// Overriding the in-built CreateSeries for performance reasons
//
function CreateSeries2(): integer;
begin
  Result := CreateNamedSeries('');
  SetDescription(Result, 'Series-' + IntToStr(Result)); // set unique name
end;
//______________________________________________________________________________



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
// An alternate version is below
//
// Update 11/15: I don't know what this function acheives compared to the
// BetterEMASeries2. If possible get rid of this function in future.
//
function BetterEMASeries( Series, period: integer ): integer;
begin
  var MA, bar: integer;
  var C: float;

  MA := AddSeriesValue(EMASeries( Series, period ), 0);
  C := 2/(1+period);
  bar := 0;

  for bar := 0 to BarCount-1 do
  begin
    if( @Series[bar] <> 0) then
      break;
  end;

  @MA[bar] := @Series[bar];

  for bar := bar+1 to period do
  begin
    @MA[bar] := C * @Series[bar] + (1-C) * @MA[bar-1];
  end;
  Result := MA;
end;
//______________________________________________________________________________
// The EMA series starts at 1st Bar.
// An alternate version is above
//
function BetterEMASeries2( Series, period: integer ): integer;
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
// Converts an integer to string with at least two digits (padding 0 if required)
//
function IntToStrTwoDigit( num: integer ): string;
begin
  if( num < 10 ) then
    Result := '0' + IntToStr( num )
  else
    Result := IntToStr( num );
end;
//______________________________________________________________________________
// Mod of integers and return as integer
//
function ModInt( dividend, divisor: integer ): integer;
begin
  Result := Trunc( dividend Mod divisor );
end;
//______________________________________________________________________________
// Calculates number of days ( including weekend and holidays days )
// between two dates
//
function DaysBetweenDates( startDate, endDate: integer ): integer;
begin
  var year1, month1, day1, year2, month2, day2: integer;
  year1 := Trunc(startDate / 10000);
  month1 :=  ModInt( startDate, 10000 ) / 100;
  day1 := ModInt( startDate, 100 );
  year2 := Trunc(endDate / 10000);
  month2 :=  ModInt( endDate, 10000 ) / 100;
  day2 := ModInt( endDate, 100 );
  var m: array[1..12] of integer;
  m[1] := 0;
  m[2] := 31;
  m[3] := 59;
  m[4] := 90;
  m[5] := 120;
  m[6] := 151;
  m[7] := 181;
  m[8] := 212;
  m[9] := 243;
  m[10] := 274;
  m[11] := 304;
  m[12] := 334;

  var totalDays1, totalDays2: integer;
  totalDays1 := Trunc(year1 * 365.25) + m[month1] + day1;
  if( ModInt(year1, 4) = 0 ) and (month1 <= 2) then
    totalDays1 := totalDays1 - 1;
  totalDays2 := Trunc(year2 * 365.25) + m[month2] + day2;
  if( ModInt(year2, 4) = 0 ) and (month2 <= 2) then
    totalDays2 := totalDays2 - 1;
  Result := totalDays2 - totalDays1;
end;
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
    Dec( maxLoopLimit );
    if( maxLoopLimit <= 0 ) then break;
    try
      bar := DateToBar( date );
      Inc( count );
    except
    end;
    if( bar <> -1 ) then
      break;
    Dec( date );
  end;
  Result := bar;
end;
//______________________________________________________________________________
function WeeklyBarFromDailyDate2(Date: integer): integer;
begin
  var Bar: integer;
  var Left: integer = FirstActualBar;
  var Right: integer = BarCount;
  var D: integer = 0;
  if IsWeekly then D := DaysBetweenDates(18991231, Date) mod 7;
  if IsMonthly then D := Date mod 100;
  repeat
    Bar := (Left + Right) div 2;
    if DaysBetweenDates(GetDate(Bar), Date) <= D then Right := Bar else Left := Bar + 1;
  until Left >= Right;
  Result := Right;
end;
//______________________________________________________________________________
// Returns the day of a bar as string
//
function getDayStr( bar: integer ): String;
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
// Use PlotSymbolColoredCandle for speed
// This function is kept for historical reasons and for understanding the logic
// behind PlotSymbolColoredCandle
procedure PlotSymbolColoredCandle2 (symbol: String; pane, upBarColor, downBarColor: integer);
begin
  SetPrimarySeries (symbol);
  var bar: integer;
  var redHigh, redOpen, redClose, redLow: integer;
  var greenHigh, greenOpen, greenClose, greenLow: integer;
  redHigh := CreateNamedSeries( '' );
  redOpen := CreateNamedSeries( '' );
  redClose := CreateNamedSeries( '' );
  redLow := CreateNamedSeries( '' );
  greenHigh := CreateNamedSeries( '' );
  greenOpen := CreateNamedSeries( '' );
  greenClose := CreateNamedSeries( '' );
  greenLow := CreateNamedSeries( '' );
  for bar := 0 to BarCount -1 do
  begin
    if (PriceClose (bar) > PriceOpen (bar)) then
    begin
      SetSeriesValue (bar, greenOpen, PriceOpen (bar));
      SetSeriesValue (bar, greenHigh, PriceHigh (bar));
      SetSeriesValue (bar, greenLow, PriceLow (bar));
      SetSeriesValue (bar, greenClose, PriceClose (bar));
      SetSeriesValue (bar, redOpen, PriceClose (bar));
      SetSeriesValue (bar, redHigh, PriceClose (bar));
      SetSeriesValue (bar, redLow, PriceClose (bar));
      SetSeriesValue (bar, redClose, PriceClose (bar));
    end
    else
    begin
      SetSeriesValue (bar, redOpen, PriceOpen (bar));
      SetSeriesValue (bar, redHigh, PriceHigh (bar));
      SetSeriesValue (bar, redLow, PriceLow (bar));
      SetSeriesValue (bar, redClose, PriceClose (bar));
      SetSeriesValue (bar, greenOpen, PriceClose (bar));
      SetSeriesValue (bar, greenHigh, PriceClose (bar));
      SetSeriesValue (bar, greenLow, PriceClose (bar));
      SetSeriesValue (bar, greenClose, PriceClose (bar));
    end;
  end;
  PlotSyntheticSymbol (symbol, redOpen, redHigh, redLow, redClose,
          pane, downBarColor, #Candle);
  PlotSyntheticSymbol (symbol, greenOpen, greenHigh, greenLow, greenClose,
          pane, upBarColor, #Candle);
  RestorePrimarySeries;
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
procedure saveChart2( name: string; width, height: integer; title: string);
begin
  SaveChartImage( name, width, height, 'bmp' );
  var cmd1: string = 'cmd /C ""H:\Program Files\ImageMagick-6.2.8-Q16\convert.exe" '
   + name + ' -fill white -stroke white  -draw "rectangle 6,6,300,42" '
   + name + '"';
  //Print( cmd1 ); PrintFlush;
  RunProgram( cmd1, true );
  cmd1 := 'cmd /C ""H:\Program Files\ImageMagick-6.2.8-Q16\convert.exe" '
   + name + '  -font Arial -pointsize 20 -fill black -stroke black'
   + ' -strokewidth 1 -draw "text 6,26 \"' + title + '\"" ' + name + '"';
  //Print( cmd1 ); PrintFlush;
  RunProgram( cmd1, true );
end;
//______________________________________________________________________________




//______________________________________________________________________________
//_________________ C U S T O M   I N D I C A T O R S __________________________
//______________________________________________________________________________





//______________________________________________________________________________
//____________ M Y   P L O T T I N G   F U N C T I O N S _______________________
//______________________________________________________________________________
//______________________________________________________________________________
//______________________________________________________________________________
// Plots Noise Band. Used for StopLoss.Abort
//
procedure PlotNoiseBand (lbPeriod: integer);
begin
  var bar, noiseSeries: integer;
  var maxNoiseSeries: integer;

  noiseSeries := CreateSeries;
  maxNoiseSeries := CreateSeries;

  for bar := lbPeriod to BarCount - 1 do
  //for bar := Barcount-10 to BarCount - 1 do
  begin
    var lbBar: integer;
    var maxNoise, totalNoise, avgNoise: float;
    var upNoise, downNoise: float;

    maxNoise := 0;
    totalNoise := 0;
    for lbBar := bar-lbPeriod+1 to bar do
    begin
      if (Priceclose(lbBar) > PriceOpen(lbBar)) then
      begin
        upNoise := PriceHigh (lbBar) - PriceClose (lbBar);
        downNoise := PriceOpen (lbBar) - PriceLow (lbBar);
      end
      else
      begin
        upNoise := PriceHigh (lbBar) - PriceOpen (lbBar);
        downNoise := PriceClose (lbBar) - PriceLow (lbBar);
      end;
      totalNoise := totalNoise + upNoise + downNoise;
      if (upNoise > maxNoise) then
        maxNoise := upNoise;
      if (downNoise > maxNoise) then
        maxNoise := downNoise;
    end;
    avgNoise := totalNoise / (2*lbPeriod); // avg penetration
    SetSeriesValue (bar, noiseSeries, 2*avgNoise);
    SetSeriesValue (bar, maxNoiseSeries, maxNoise);
    //Print (FloatToStr (totalPenetration) + '  ' + FloatToStr (avgPenetration));PrintFlush;
  end;
  PlotSeries (SubtractSeries(#low,noiseSeries), 0, #blue, #thin);
  PlotSeries (AddSeries(#high,noiseSeries), 0, #blue, #thin);
  PlotSeries (SubtractSeries(#low,maxNoiseSeries), 0, #red, #thin);
  PlotSeries (AddSeries(#high,maxNoiseSeries), 0, #red, #thin);
end;
//______________________________________________________________________________
// Plots Safe Zone for Long Postions. Used for StopLoss.Abort
//
procedure PlotSafeZoneLong (lbPeriod: integer; mFactor: float);
begin
  var bar, safeZoneSeries: integer;
  safeZoneSeries := CreateSeries;

  for bar := lbPeriod to BarCount - 1 do
  //for bar := Barcount-10 to BarCount - 1 do
  begin
    var lbBar, count: integer;
    var avgPenetration, totalPenetration: float;

    totalPenetration := 0;
    count := 0;
    for lbBar := bar-lbPeriod+1 to bar do
    begin
      if (PriceLow(lbBar) < PriceLow(lbBar-1)) then
      begin
        count := count + 1;
        totalPenetration := totalPenetration + (PriceLow(lbBar-1) - PriceLow(lbBar));
      end;
    end;
    if (count = 0 ) then
      avgPenetration := 0 // avg penetration
    else
      avgPenetration := totalPenetration / count; // avg penetration
    SetSeriesValue (bar, safeZoneSeries, PriceLow(bar)-mFactor*avgPenetration);
    //Print (FloatToStr (totalPenetration) + '  ' + FloatToStr (avgPenetration));PrintFlush;
  end;
  PlotSeriesLabel (safeZoneSeries, 0, #blue, #thin, 'SafeZoneLong');
end;
//______________________________________________________________________________
// Plots Safe Zone for Short Postions. Used for StopLoss.Abort
//
procedure PlotSafeZoneShort (lbPeriod: integer; mFactor: float);
begin
  var bar, safeZoneSeries: integer;
  safeZoneSeries := CreateSeries;

  for bar := lbPeriod to BarCount - 1 do
  //for bar := Barcount-10 to BarCount - 1 do
  begin
    var lbBar, count: integer;
    var avgPenetration, totalPenetration: float;

    totalPenetration := 0;
    count := 0;
    for lbBar := bar-lbPeriod+1 to bar do
    begin
      if (PriceHigh(lbBar) > PriceHigh(lbBar-1)) then
      begin
        count := count + 1;
        totalPenetration := totalPenetration + (PriceHigh(lbBar) - PriceHigh(lbBar-1));
      end;
    end;
    if (count = 0 ) then
      avgPenetration := 0 // avg penetration
    else
      avgPenetration := totalPenetration / count; // avg penetration
    SetSeriesValue (bar, safeZoneSeries, PriceHigh(bar)+mFactor*avgPenetration);
    //Print (FloatToStr (totalPenetration) + '  ' + FloatToStr (avgPenetration));PrintFlush;
  end;
  PlotSeriesLabel (safeZoneSeries, 0, #blue, #thin, 'SafeZoneShort');
end;
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
// Plots Elder Ray
//
procedure PlotElderRay (period: integer);
begin
  var bullPowerSeries, bearPowerSeries, pane1, pane2 : integer;

  bullPowerSeries := SubtractSeries (#high, EMASeries(#close, period));
  //bearPowerSeries := SubtractSeries ( #low, EMASeries(#close, period) );
  bearPowerSeries := SubtractSeries (EMASeries(#close, period), #low );

  pane1 := CreatePane( 60, false, true );
  pane2 := CreatePane( 60, false, true );
  //PlotSeriesLabel ( bullPowerSeries, pane1, #black, #histogram, 'Bull Power' );
  PlotSeriesLabel ( bullPowerSeries, pane1, #black, #Thin, 'Bull Power' );
  //PlotSeriesLabel ( bearPowerSeries, pane2, #black, #histogram, 'Bear Power' );
  PlotSeriesLabel ( bearPowerSeries, pane2, #black, #Thin, 'Bear Power' );
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
// Plots Bollinger Band
//
procedure PlotBollingerBand (period: integer; sd: float);
begin
  PlotSeries( BBandLowerSeries( #Close, period, sd ), 0, 631, #Dotted);
  PlotSeries( BBandUpperSeries( #Close, period, sd ), 0, 631, #Dotted);
  PlotSeries( SMASeries (#close, period), 0, #Maroon, #thin);
end;
//______________________________________________________________________________
// Keltner Channel   TODO
procedure PlotKeltnerChannel( emaPeriod, atrPeriod: integer; deviationMultiplier: float);
begin
  var emaClose: integer = EMASeries( #Close, emaPeriod );
  var kATR: integer = ATRSeries( atrPeriod );
  var kUpper: integer = AddSeries( emaClose, MultiplySeriesValue( kATR, deviationMultiplier ) );
  var kLower: integer = SubtractSeries( emaClose, MultiplySeriesValue( kATR, deviationMultiplier ) );
  PlotSeriesLabel( kUpper, 0, 842, #Thin, 'Keltner Channel' );
  PlotSeries( kLower, 0, 842, #Thin );
  //PlotSeriesLabel( MultiplySeriesValue( kATR, 2*kN ), ePane, #Red, #Thin, 'KCWidth' );
  PlotSeries( emaClose, 0, 610, #Thin );
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
// Plot 2nd Differential - This plots dy/dy (dy/dy)
//
procedure Plot2ndDifferential (period, line1, line2: integer);
begin
  var bar, series, pane : integer;
  pane := CreatePane( 60, false, true );
  series := CreateSeries ();

  for bar := 1 to BarCount-1 do
  begin
    SetSeriesValue (bar, series, PriceClose(bar)-PriceClose(bar-1));
  end;

  //DrawHorzLine( line1, pane, #Olive, #Thin );
  //DrawHorzLine( line2, pane, #Olive, #Thin );
  //DrawHorzLine( 50, pane, #Olive, #Thin );
  PlotSeriesLabel ( series, pane, #Red, #Histogram, 'MySeries(' + IntToStr(period)+')' );
end;
//______________________________________________________________________________
// Plot Force Index
//
procedure PlotForceIndex (period : integer);
begin
  var forceIndexSeries, forceIndexSmoothedSeries, pane : integer;
  var bar: integer;
  forceIndexSeries := CreateSeries ();
  for bar := 1 to BarCount - 1 do
  begin
    var value: float;
    value := (PriceClose(bar) - PriceClose(bar-1)) * Volume(bar);
    SetSeriesValue (bar, forceIndexSeries, value);
  end;

  forceIndexSmoothedSeries := EMASeries (forceIndexSeries, period);

  pane := CreatePane( 60, false, true );
  DrawHorzLine( 0, pane, #Olive, #Thin );
  PlotSeriesLabel( forceIndexSmoothedSeries, pane, #blue, #Thin, 'Force Index ('+IntToStr(period)+')');
end;

//______________________________________________________________________________
// Plot Price Change
//
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

//______________________________________________________________________________
// Plot Price Oscillator
//
procedure PlotPriceOscillator (period : integer);
begin
  var priceOscillatorSeries, priceOscillatorSmoothedSeries, pane : integer;

  priceOscillatorSeries := MultiplySeriesValue ( DivideSeries (
          SubtractSeries(#close, EMASeries(#close, period)),
          EMASeries(#close, period)), 100);

  priceOscillatorSmoothedSeries := EMASeries (priceOscillatorSeries, 10);

  pane := CreatePane( 60, false, true );
  DrawHorzLine( 0, pane, #Olive, #Thin );
  PlotSeriesLabel( priceOscillatorSmoothedSeries, pane, #Blue, #Thin, 'Smoothed (10)' );
  PlotSeriesLabel( priceOscillatorSeries, pane, #Red, #Thin, 'Price Oscillator ('+IntToStr(period)+')' );
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
procedure PlotVolume_experimental( height: integer );
begin
  var volumePane: integer = CreatePane( height, false, true );
  var myVol: integer = CreateNamedSeries( 'MyVolume' );
  var bar: integer;
  for bar := 0 to BarCount-1 do
  begin
    var num1: float;
    num1 := @#volume[bar];
    if( num1 > 1000000 ) then
      num1 := 1000000 * ( Log10( @#volume[bar] / 10000 )-2);
    @myVol[bar] := num1;
    if PriceClose( bar ) > PriceOpen( bar ) then
      SetSeriesBarColor( bar, myVol, #Green )
    else
      SetSeriesBarColor( bar, myVol, #Red );
  end;
  var zeroSeries: integer = AddSeriesValue( myVol, 0 );
  @zeroSeries[BarCount-1] := 0;
  SetDescription( zeroSeries, 'Volume' );
  DrawHorzLine( 1000000, volumePane, 900, #Thin );
  PlotSeries( zeroSeries, volumePane, #Black, #Histogram );
  PlotSeriesLabel( myVol, volumePane, #Black, #ThickHist,'Volume' );
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
procedure PlotSymbolInNewPane( symbol: String );
begin
  var newPane: integer;
  newPane := CreatePane( 60, true, true );
  PlotSymbolColoredCandle( symbol, newpane, 050, 700);
  // Print some infos
  var color: integer;
  if( PriceClose( BarCount-1 ) > PriceClose( BarCount-2 ) ) then
    color := #Green
  else
    color := #Red;
  DrawText (symbol, newpane, 5, 2, color, 10);
  var change, changePer: float;
  change := PriceClose (BarCount-1) - PriceClose (BarCount-2);
  changePer := change / PriceClose (BarCount-2) * 100;
  DrawText( FormatFloat( '0.##', change ) + ' (' + FormatFloat  ('0.##', changePer ) + '%)', newpane, 5, 20, color, 8);
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

  drawBelowPrice := wlExtraUtil.getBoolParam( 'SP500AtBottom' );

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

