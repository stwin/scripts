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
///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////
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
procedure GenerateElderChannelWatchList (newWatchList: String;
                          period, loopbackmonth, cutoffPercent: integer; isPercent: boolean);
begin
  var watchListNum: integer;

  if (Not IsDaily) and (Not IsWeekly) then
  begin
    ShowMessage ('Runs only on Daily or Weekly data');
    abort;
  end;

  // Clear the new watch list if it exists
  if( isPercent ) then
  begin
    WatchListClear (newWatchList + '-P');
    WatchListClear (newWatchList + '-P-20');
    WatchListClear (newWatchList + '-P-30');
    WatchListClear (newWatchList + '-P-50');
  end
  else
  begin
    WatchListClear (newWatchList + '-');
    WatchListClear (newWatchList + '-06-10');
    WatchListClear (newWatchList + '-10-15');
    WatchListClear (newWatchList + '-15-1000');
  end;

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 200 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // skip if price < 4 or volume < 10000
    if ((PriceClose(Barcount-1) < 4) or (Volume(BarCount-1) < 10000)) then
      continue;

    // skip if above the fast ema
    //if( PriceLow(BarCount-1) > EMA(BarCount-1, #close, 11) ) then
    //  continue;

    var deviation, channelRange, channelRangePercent: float;

    deviation := getElderChannelDeviation (period, loopbackmonth, cutoffPercent);
    channelRange := EMA(BarCount-1, #close, period) * 2 * deviation;
    channelRangePercent := 2 * deviation * 100;

    var localWatchList: String;

    localWatchList := newWatchList;

    //if( channelRangePercent >= 20 ) then begin
    //Print( GetSymbol
    //    + #9 + Formatfloat( '#.##', channelRangePercent )
    //    + #9 + Formatfloat( '#.##', SMA(BarCount-1, #Volume, 22) )
    //    + #9 + Formatfloat( '#.##', PriceClose(BarCount-1) )
    //    + #9 + FormatFloat( '#.##', channelRange )
    //    ); PrintFlush();                      end;

    if (isPercent) then
    begin
      if (channelRangePercent >= 50) then
        localWatchList := newWatchList + '-P-50'
      else if (channelRangePercent >= 30) then
        localWatchList := newWatchList + '-P-30'
      else if (channelRangePercent >= 20) then
        localWatchList := newWatchList + '-P-20'
      else
        localWatchList := newWatchList + '-P';

      WatchListAddSymbol (localWatchList, '', GetSymbol);
    end
    else
    begin
      if ((channelRange >= 6) and (channelRange < 10)) then
        localWatchList := newWatchList + '-06-10'
      else if ((channelRange >= 10) and (channelRange < 15)) then
        localWatchList := newWatchList + '-10-15'
      else if ((channelRange >= 15) and (channelRange < 1000)) then
        localWatchList := newWatchList + '-15-1000'
      else
        localWatchList := newWatchList + '-';
      WatchListAddSymbol (localWatchList, '', GetSymbol)
    end;

    //Print (GetSymbol + '   ' + FloatToStr(channelRange) + '  ' + FloatToStr(deviation));   PrintFlush;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure GenerateElderWatchLists (newWatchList: String;
                          period, loopbackmonth, cutoffPercent: integer; isPercent: boolean);
begin
  var BaseWatchList: string;
  var n1, n2: integer;
  n1:= GetTickCount;
  GenerateElderChannelWatchList (newWatchList, period, loopbackmonth, cutoffPercent, isPercent);
  n2:= GetTickCount;
  ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');
end;
///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////
// This plots dy/dy (dy/dy)
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
///////////////////////////////////////////////////////////////////////////////
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
///////////////////////////////////////////////////////////////////////////////
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
      positionSize := StrToInt( GetToken( line, 1, ',' ) );
      entryDate := StrToInt( GetToken( line, 2, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 3, ',' ) );
      entryTotal := StrToFloat( GetToken( line, 4, ',' ) );
      targetPrice := StrToFloat( GetToken( line, 5, ',' ) );
      stopPrice := StrToFloat( GetToken( line, 6, ',' ) );

      currentPrice := PriceClose( BarCount-1 );
      currentTotal := positionSize * currentPrice;
      entryBar := DateToBar( entryDate );

      // Mark buy bar
      SetBackgroundColor (entryBar, #BlueBkg);
      AnnotateBar( 'B', entryBar, false, #Black, 7 );

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
      var buyStr, currStr, profitStr: String;

      buyStr := 'Bought ' + IntToStr( positionSize )
                        + ' X ' + FormatFloat( '#.#0', entryPrice )
                        + ' = ' + FormatFloat( '#,###.#0', entryTotal );
      currStr := 'Current ' + IntToStr( positionSize )
                        + ' X ' + FormatFloat( '#.#0', currentPrice )
                        + ' = ' + FormatFloat( '#,###.#0', currentTotal );

      profitStr := 'Profits in ' + IntToStr( BarCount-entryBar ) + ' days = '
                          + FormatFloat( '#,###.#0', currentTotal-entryTotal );

      MyDrawLabel( '', #Black );
      MyDrawLabel( buyStr, #Black );
      MyDrawLabel( currStr, #Black );
      if( currentTotal > entryTotal ) then
        MyDrawLabel( profitStr, #Green )
      else
        MyDrawLabel( profitStr, #Red );

      // Now some detailed printing in the debug window
      Print( buyStr );
      Print( currStr );
      Print( profitStr );
      Print ('');
      var bar: integer;
      for bar := entryBar to BarCount-1 do
      begin
        Print( DateToStr( GetDate( bar ) )
                  + '   ' + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize )
                  + '   ' + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize
                                                    - entryTotal ) );
      end;
      break;
    end;
  end;
  FileClose (file);

end;
///////////////////////////////////////////////////////////////////////////////
procedure PrintClosedPosition ();
begin
  var file: integer;
  var FileName: String = 'D:\WL\Manage\PositionsClosed.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');
    if (GetSymbol = symbolStr) then
    begin
      var entryDate, entryBar, exitDate, exitBar: integer;
      var entryPrice, exitPrice: float;
      entryDate := StrToInt( GetToken( line, 1, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 2, ',' ) );
      exitDate := StrToInt( GetToken( line, 3, ',' ) );
      exitPrice := StrToFloat( GetToken( line, 4, ',' ) );

      entryBar := DateToBar( entryDate );
      exitBar := DateToBar( exitDate );

      // Mark buy bar
      SetBackgroundColor (entryBar, 789);
      AnnotateBar( 'B', entryBar, false, #Black, 7 );
      SetBackgroundColor( exitBar, 779 );
      AnnotateBar( 'S', exitBar, true, #Black, 7 );

      DrawLine( entryBar-1, entryPrice, entryBar+1, entryPrice, 0, #Blue, #thin );
      DrawLine( exitBar-1, exitPrice, exitBar+1, exitPrice, 0, #Blue, #thin );
    end;
  end;
  FileClose (file);
end;
///////////////////////////////////////////////////////////////////////////////
procedure PrintPosition ();
begin
  PrintOpenPosition();
  PrintClosedPosition();
end;
///////////////////////////////////////////////////////////////////////////////
procedure GetNHNLSeries (fileName: string; var NHSeries: integer; var NLSeries: integer);
begin
  var fileHandle: integer;

  fileHandle := FileOpen (FileName);
  NHSeries := CreateSeries ();
  NLSeries := CreateSeries ();

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, numHighStr, numLowStr: String;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    numHighStr := GetToken (line, 1, ',');
    numLowStr := GetToken (line, 2, ',');

    try
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NHSeries, StrToFloat(numHighStr));
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NLSeries, StrToFloat(numLowStr));
    except
    end;

  end;
  FileClose (fileHandle);
end;

///////////////////////////////////////////////////////////////////////////////
procedure plotNHNLSeries();
begin
  var fileName: string;
  var NHSeries, NLSeries, NHNLSeries, pane1, pane2: integer;

  fileName := 'D:\WL\NH-NL.txt';

  GetNHNLSeries (fileName, NHSeries, NLSeries);

  NHNLSeries := SubtractSeries( NHSeries, NLSeries );
  pane1 := CreatePane( 20, false, false);
  //pane2 := CreatePane( 60, false, false );

  PlotSeriesLabel( NHSeries , pane1, #Green, #Thin, 'Number of 52-week High' );
  PlotSeriesLabel( NLSeries , pane1, #Red, #Thin, 'Number of 52-week Low' );

  //DrawHorzLine (0, pane2, #Olive, #Thin);
  //PlotSeriesLabel( NHNLSeries, pane2, #Black, #Histogram, '52-week NHNL Index' );
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
procedure SaveChart ();
begin
  var fileName: String;
  var Bar: integer;

  if (IsDaily) then
    fileName := GetSymbol + '-daily'
  else if (IsWeekly) then
    fileName := GetSymbol + '-weekly'
  else
    fileName := GetSymbol + '-unknownTimeFrame';

  SetColorScheme (050, 800, 222, 999, 887, 799);

  SaveChartImage('D:\WL\Images\' + fileName + '.bmp', 1024, 768, 'BMP' );
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

try
  if (IsWeekly) then
  begin
    MyDrawLabel ('EMA: 13, 26', #Black);
    PlotSeries (EMASeries (#close, 13), 0, 777, #thin);
    PlotSeries (EMASeries (#close, 26), 0, #Maroon, #thin);
    PlotElderChannel (26, 12, 90);
    PlotMACD (12, 26, 9, true);
    PlotPriceOscillator (22);
  end
  else if (IsDaily) then
  begin
    DisplayPercentChangeForLast5Bars ();
    PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
    PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);
    //PlotSeries (EMASeries (#Volume, 2), 1, #Maroon, #thin);
    PlotElderChannel (22, 6, 90);
    //PlotBollingerBand(22, 2);
    DisplayVolume ();
    MyDrawLabel ('EMA: 11, 22', #Black);
    PlotMACD (12, 26, 9, true);
    //PlotNHNLSeries();
    PlotStochastic (7, 20, 80);
    //PrintPosition ();
    //Plot2ndDifferential(22, 30, 70);
    //PlotRSI (10, 30, 70);
    //PlotPriceOscillator (22);
    //PlotForceIndex (2);
    //PlotPriceChange (2);
    //PlotElderRay (26);

    //PlotNoiseBand (20);
    //PlotSafeZoneLong (10, 2);
    //PlotSafeZoneShort (10, 2);

    //AddCommentary( '<' + 'meta http-equiv="refresh" content="0;url=http://finance.yahoo.com/q/pr?s=' + GetSymbol + '">' );
  end;

except
end;

SetColorScheme (050, 800, 222, 999, 777, 005);

// For generating list
//GenerateElderWatchLists ('Prac-MyE2'+'A', 22, 6, 90, false); // price range channel

//GenerateElderWatchLists ('Prac-MyE2'+'A', 22, 6, 90, true);  // percent channel
//GenerateElderWatchLists ( WatchListName, 22, 6, 90, true);  // percent channel

// For saving image
//SaveChart ();


{
Print( 'O = ' + FormatFloat( '#.##', PriceOpen(BarCount-1) ) );
Print( 'H = ' + FormatFloat( '#.##', PriceHigh(BarCount-1) ) );
Print( 'L = ' + FormatFloat( '#.##', PriceLow(BarCount-1) ) );
Print( 'C = ' + FormatFloat( '#.##', PriceClose(BarCount-1) ) );
Print( 'Change in one month = ' + FormatFloat( '#.##', 100*(PriceClose(BarCount-1)-PriceClose(BarCount-22))/PriceClose(BarCount-22) ) );
MyDrawLabel( 'Change in one month = ' + FormatFloat( '#.##', 100*(PriceClose(BarCount-1)-PriceClose(BarCount-22))/PriceClose(BarCount-22) ), #Black );
}
