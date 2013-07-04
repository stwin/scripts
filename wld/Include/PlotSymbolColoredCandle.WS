//______________________________________________________________________________
// This is a faster version of the original function PlotSymbolColoredCandle
// ( now called PlotSymbolColoredCandle2 )
// speed improvement : more than 10 times or more, depends on # of bars
procedure PlotSymbolColoredCandle( pane, upBarColor, downBarColor: integer );
begin
  var Bar, O, H, L, C: integer;
  var diff, Series_1_0, Series_0_1, O_alt : integer;

  diff := SubtractSeries( #Close, #Open );
  Series_1_0 := AddSeriesValue( DivideSeries( diff,
                    MultiplySeriesValue( AbsSeries( diff ), 2 ) ), 0.5 );
  Series_0_1 := SubtractValueSeries( 1, Series_1_0 );
  O_alt := MultiplySeries( #Close, Series_0_1 );

  O := AddSeries( MultiplySeries( Series_1_0, #Open ), O_alt );
  H := AddSeries( MultiplySeries( Series_1_0, #High ), O_alt );
  L := AddSeries( MultiplySeries( Series_1_0, #Low ), O_alt );
  C := #Close;

  PlotSymbol( GetSymbol, pane, downBarColor, #Candle );
  PlotSyntheticSymbol( GetSymbol, O, H, L, C, pane, upBarColor, #Candle );
  //DrawLabel( symbol, pane );
end;

