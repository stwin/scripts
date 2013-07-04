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
// Changes bar colors depending on whether it has increased or decreased
// Used for MACD Histograms
//------------------------------------------------------------------------------
procedure ColorSeriesRedGreenBlue ( macdh: integer );
begin
  var Bar: integer;
  var emas: integer;
  if( IsDaily() ) then
    emas := EMASeries( #Close, 22 )
  else
    emas := EMASeries( #Close, 26 );
  for Bar := 1 to BarCount - 1 do
    if( (@macdh[bar] > @macdh[bar-1]) and (@emas[bar] > @emas[bar-1]) ) then
      SetSeriesBarColor( Bar, macdh, 070 )
    else if( (@macdh[bar] < @macdh[bar-1]) and (@emas[bar] < @emas[bar-1]) ) then
      SetSeriesBarColor( Bar, macdh, 800 )
    else
      SetSeriesBarColor( Bar, macdh, 009 );
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
  //ColorSeriesRedGreen( macdh );
  ColorSeriesRedGreenBlue( macdh );

  // Impulse
  var emaUp, macdhUp: boolean;
  var impulse: string;
  var emaPeriod, emaSlow: integer;
  if( IsDaily ) then emaPeriod := 22 else emaPeriod := 26;
  emaSlow := EMASeries( #Close, emaPeriod );
  emaUP := @emaSlow[BarCount-1] > @emaSlow[BarCount-2];
  macdhUp := @macdh[BarCount-1] > @macdh[BarCount-2];
  if( emaUp and macdhUp ) then
    impulse := 'Green'
  else if( (not emaUp) and (not macdhUp) ) then
    impulse := 'Red'
  else
    impulse := 'Blue';
  DrawLabel( 'Impulse: ' + impulse, macdPane );

  // MACD Divergence
  if( not plotDivergence ) then
    exit;
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

