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

  drawBelowPrice := myclass.GetBoolParam( 'SP500AtBottom' );

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
PlotFewBarsOfSP500;
