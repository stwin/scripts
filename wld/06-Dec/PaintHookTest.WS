
  var minPrice, lastPrice, factor: float;
  var showBars, o, h, l, c: integer;
  var monthsOnScreen, showBarsMonth: integer;

  // readjustable parameters
  monthsOnScreen := 5;
  showBarsMonth := 2;

  minPrice := Lowest( BarCount-1, #Low, 22 * monthsOnScreen );
  lastPrice := PriceClose( BarCount-1 );

  SetPrimarySeries ( 'SP-500' );

  factor := ( minPrice + lastPrice ) / ( 2 * PriceClose( BarCount-1 ) );
  showBars := 22 * showBarsMonth;
  o := #Open;
  h := #High;
  l := #Low;
  c := #Close;

  RestorePrimarySeries;

  var util: ComVariant;
  util := CreateOleObject( 'WLExtra.Utility' );

  //util.PlotFewBars( IWealthLabAddOn3, showBars, factor, 040, 600, o, h, l, c );
  util.PlotFewBars( IWealthLabAddOn3, showBars, factor, 476, 956, o, h, l, c );


