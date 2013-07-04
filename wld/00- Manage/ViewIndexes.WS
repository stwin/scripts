
{
procedure PlotSymbolColoredCandle (symbol: String; pane, upBarColor, downBarColor: integer);
begin
  var Bar, O, H, L, C : integer;
  SetPrimarySeries( symbol );

  O := #Open;
  H := O;
  L := AddSeriesValue( H, 0 );
  C := AddSeriesValue( L, 0 );

  for Bar := 0 to BarCount -1 do
    if @#Close[Bar] < @#Open[Bar] then
    begin
      @H[Bar] := @#High[Bar];
      @L[Bar] := @#Low[Bar];
      @C[Bar] := @#Close[Bar];
    end;

  PlotSymbol( symbol, pane, upBarColor, #Candle );
  PlotSyntheticSymbol( symbol, O, H, L, C, pane, downBarColor, #Candle );
  RestorePrimarySeries;

end;
}
///////////////////////////////////////////////////////////////////////////////
procedure PlotSymbolColoredCandle (symbol: String; pane, upBarColor, downBarColor: integer);
begin
  SetPrimarySeries (symbol);
  var bar: integer;
  var redHigh, redOpen, redClose, redLow: integer;
  var greenHigh, greenOpen, greenClose, greenLow: integer;
  redHigh := CreateSeries;
  redOpen := CreateSeries;
  redClose := CreateSeries;
  redLow := CreateSeries;
  greenHigh := CreateSeries;
  greenOpen := CreateSeries;
  greenClose := CreateSeries;
  greenLow := CreateSeries;
  for bar := 0 to BarCount -1 do
  begin
    if (PriceClose (bar) > PriceOpen (bar)) then
    begin
      SetSeriesValue (bar, greenOpen, PriceOpen (bar));
      SetSeriesValue (bar, greenHigh, PriceHigh (bar));
      SetSeriesValue (bar, greenLow, PriceLow (bar));
      SetSeriesValue (bar, greenClose, PriceClose (bar));
      SetSeriesValue (bar, redOpen, PriceOpen (bar));
      SetSeriesValue (bar, redHigh, PriceOpen (bar));
      SetSeriesValue (bar, redLow, PriceOpen (bar));
      SetSeriesValue (bar, redClose, PriceOpen (bar));
    end
    else
    begin
      SetSeriesValue (bar, redOpen, PriceOpen (bar));
      SetSeriesValue (bar, redHigh, PriceHigh (bar));
      SetSeriesValue (bar, redLow, PriceLow (bar));
      SetSeriesValue (bar, redClose, PriceClose (bar));
      SetSeriesValue (bar, greenOpen, PriceOpen (bar));
      SetSeriesValue (bar, greenHigh, PriceOpen (bar));
      SetSeriesValue (bar, greenLow, PriceOpen (bar));
      SetSeriesValue (bar, greenClose, PriceOpen (bar));
    end;
  end;
  PlotSyntheticSymbol (symbol, redOpen, redHigh, redLow, redClose,
          pane, downBarColor, #Candle);
  PlotSyntheticSymbol (symbol, greenOpen, greenHigh, greenLow, greenClose,
          pane, upBarColor, #Candle);

  // Print some infos
  var color: integer;
  if( PriceClose( BarCount-1 ) > PriceClose( BarCount-2 ) ) then
    color := #Green
  else
    color := #Red;
  DrawText (GetSymbol, pane, 5, 2, color, 10);
  var change, changePer: float;
  change := PriceClose (BarCount-1) - PriceClose (BarCount-2);
  changePer := change / PriceClose (BarCount-2) * 100;
  DrawText( FormatFloat( '0.##', change ) + ' (' + FormatFloat  ('0.##', changePer ) + '%)', pane, 5, 20, color, 8);
  RestorePrimarySeries;
end;

///////////////////////////////////////////////////////////////////////////////
procedure PlotIndex (symbol: String);
begin
var pane: integer;
  pane := CreatePane (200, true, true);
  PlotSymbolColoredCandle (symbol, pane, 050, 700);
end;
///////////////////////////////////////////////////////////////////////////////
// Main Program
HideVolume;

//PlotIndex ('DJ-30');
//PlotIndex ('NDX--X');
//PlotIndex ('COMPQX');
PlotIndex ('SP-500');

