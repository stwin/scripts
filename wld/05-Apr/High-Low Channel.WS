
//*******************************************************************
// HLC Histogram (Not flat)
procedure PlotHLCHist;
begin
  var MPane: integer;
  MPane := CreatePane( 100, true, true );
  DrawLabel( 'High-Low Channel - Histogram', MPane );
  PlotSeries( #High, MPane, #Black, #ThickHist );
  PlotSeries( #Low, MPane, #White, #ThickHist );
end;

//*******************************************************************
// HLC Histogram (Flat)
procedure PlotHLCFlatHist;
begin
  var MPane2, MHist: integer;
  MPane2 := CreatePane( 100, true, true );
  DrawLabel( 'High-Low Channel - Flat Histogram', MPane2 );
  MHist := SubtractSeries( #High, #Low);
  PlotSeries( MHist, MPane2, #Black, #ThickHist );
end;

//*******************************************************************
// HLC Channel
procedure PlotHLC;
begin
  var MPane: integer;
  MPane := CreatePane( 100, true, true );
  DrawLabel( 'High-Low Channel', MPane );
  PlotSeries( #High, MPane, #Red, #Thin );
  PlotSeries( #Low, MPane, #Red, #Thin );
  var Bar: integer;
  for Bar := 1 to BarCount - 1 do
  begin
    DrawDiamond (Bar-1, PriceHigh(Bar-1), Bar-1, PriceLow(Bar-1),
                Bar, PriceLow(Bar), Bar, PriceHigh(Bar),
                MPane, #Red, #Thin, #Red, false);
  end;
end;

//*******************************************************************
// HL Band
procedure PlotHLBand;
begin
  var Bar: integer;
  for Bar := 1 to BarCount - 1 do
  begin
    var color : integer;
    color := 666;
    DrawDiamond (Bar-1, PriceHigh(Bar-1), Bar-1, PriceLow(Bar-1),
                Bar, PriceLow(Bar), Bar, PriceHigh(Bar),
                0, color, #Thin, color, true);
  end;
end;


//*******************************************************************
// MACD
procedure PlotMACD;
begin
  var MHistMACD, MPaneMACD : integer;
  MHistMACD := SubtractSeries( MACDSeries( #Close ), EMASeries( MACDSeries( #Close ), 9 ) );
  MPaneMACD := CreatePane( 100, true, true );
  PlotSeries( MACDSeries( #Close ), MPaneMACD, #Red, #Thick );
  PlotSeries( EMASeries( MACDSeries( #Close ), 9 ), MPaneMACD, #Blue, #Thin );
  PlotSeries( MHistMACD, MPaneMACD, #Black, #Histogram );
  DrawLabel( 'MACD and 9 period Signal Line', MPaneMACD );
end;

//*******************************************************************
// myMACD
procedure PlotMyMACD (val1, val2, val3 : integer);
begin
  var MHistMACD, MPaneMACD, MMACD, MMACDSignal : integer;
  MMACD := SubtractSeries ( EMASeries(#Close,val1), EMASeries(#Close,val2));
  var i : integer;
  for i := 0 to 25 do
  begin
    @MMACD[i] := 0;
  end;
  MMACDSignal := EMASeries( MMACD, val3 );
  MHistMACD := SubtractSeries( MMACD, MMACDSignal );
  MPaneMACD := CreatePane( 100, true, true );

  var Bar, Color: integer;
  Color := 363;
  //PlotSeries( MHistMACD, MPaneMACD, Color, #Thickhist );
  PlotSeries( MHistMACD, MPaneMACD, Color, #Thin );
  for Bar := 1 to BarCount - 1 do
  begin
    DrawDiamond (Bar-1, @MHistMACD[Bar-1], Bar-1, 0,
                Bar, 0, Bar, @MHistMACD[Bar],
                MPaneMACD, Color, #Thin, Color, true);
  end;
  PlotSeries( MMACD, MPaneMACD, #Red, #Thick );
  PlotSeries( MMACDSignal, MPaneMACD, #Blue, #Thin );
  DrawLabel( 'MACD ('+IntToStr(val1)+','+IntToStr(val2)+','+IntToStr(val3)+')', MPaneMACD );
end;

//*******************************************************************
// Main
PlotMACD;
//PlotMyMACD (8,17,9);
PlotMyMACD (12,26,9);
//PlotHLC;
//PlotHLBand;
//PlotHLCHist;
//PlotHLCFlatHist;


// SMA & EMA
PlotSeries( SMASeries(#close,10), 0, #Red, #Thin );
PlotSeries( EMASeries(#close,10), 0, #Blue, #Thin );
//PlotSeries( #close, 0, #aqua, #Thin );


