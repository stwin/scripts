{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
procedure PlotFewBarsOfSP500_v2();
begin
  var minPrice, lastPrice, factor, constantPrice: float;
  var bar, showBars, o, h, l, c: integer;
  var monthsOnScreen, showBarsMonth: integer;

  // readjustable parameters
  monthsOnScreen := 5;
  showBarsMonth := 2;

  minPrice := Lowest( BarCount-1, #Low, 22 * monthsOnScreen );
  lastPrice := PriceClose( BarCount-1 );

  SetPrimarySeries ( 'SP-500' );

  factor := ( minPrice + lastPrice ) / ( 2 * PriceClose( BarCount-1 ) );
  showBars := 22 * showBarsMonth;
  constantPrice := minPrice * 0.99;

  o := CreateNamedSeries( '' );
  h := CreateNamedSeries( '' );
  l := CreateNamedSeries( '' );
  c := CreateNamedSeries( '' );

  // Set appropriate values for the bars to display
  for bar := BarCount-showBars to BarCount -1 do
  begin
    SetSeriesValue( bar, o, PriceOpen( bar ) * factor );
    SetSeriesValue( bar, h, PriceHigh( bar ) * factor );
    SetSeriesValue( bar, l, PriceLow( bar ) * factor );
    SetSeriesValue( bar, c, PriceClose( bar ) * factor );
  end;

  // we don't want candles for these bars (but it will still appear as a line)
  for bar := 0 to BarCount-showBars do
  begin
    SetSeriesValue( bar, o, constantPrice );
    SetSeriesValue( bar, h, constantPrice );
    SetSeriesValue( bar, l, constantPrice );
    SetSeriesValue( bar, c, constantPrice );
  end;

  PlotSyntheticSymbol( '', o, h, l, c, 0, 779, #Candle );

  // Now try to hide the above displayed line by painting it by background color
  for bar := BarCount-showBars to BarCount-1 do
  begin
    SetSeriesValue( bar, o, constantPrice );
    SetSeriesValue( bar, h, constantPrice );
    SetSeriesValue( bar, l, constantPrice );
    SetSeriesValue( bar, c, constantPrice );
  end;

  PlotSyntheticSymbol( '', o, h, l, c, 0, 999, #Candle );

  RestorePrimarySeries;
end;

//______________________________________________________________________________
procedure PlotFewBarsOfSP500();
begin
  var lastBarScaledPrice, howClose, factor: float;
  var showBars, o, h, l, c: integer;
  var monthsOnScreen, showBarsMonth: integer;

  // readjustable parameters
  monthsOnScreen := 5;
  showBarsMonth := 2;
  howClose := 0.25;  // How close SP-500 should be to the main Price on the last bar
                     // Should be between 0 and 1

  lastBarScaledPrice := howClose * PriceClose( BarCount-1 ) +
                        (1-howClose) * Lowest( BarCount-1, #Low, 22 * monthsOnScreen );

  SetPrimarySeries ( 'SP-500' );

  factor := lastBarScaledPrice / PriceClose( BarCount-1 );
  showBars := 22 * showBarsMonth;
  o := #Open;
  h := #High;
  l := #Low;
  c := #Close;

  RestorePrimarySeries;

  var util: ComVariant;
  util := CreateOleObject( 'WLExtra.Utility' );

  util.PlotFewBars( IWealthLabAddOn3, showBars, factor, 476, 956, o, h, l, c );
end;
//______________________________________________________________________________
//______________________________________________________________________________


PlotFewBarsOfSP500_v2;
PlotFewBarsOfSP500;
