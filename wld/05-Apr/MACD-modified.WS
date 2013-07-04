
{$NO_AUTO_EXECUTE}

var MPane, MHist, MPane1, MHist1: integer;
var Bar, p: integer;
MHist := SubtractSeries( MACDSeries( #Close ), EMASeries( MACDSeries( #Close ), 9 ) );
MHist1 := SubtractSeries( MACDSeries( #Close ), EMASeries( MACDSeries( #Close ), 9 ) );
MPane := CreatePane( 100, true, true );
PlotSeries( MACDSeries( #Close ), MPane, #Red, #Thick );
PlotSeries( EMASeries( MACDSeries( #Close ), 9 ), MPane, #Blue, #Thin );
PlotSeries( MHist, MPane, #Black, #Histogram );
DrawLabel( 'MACD and 9 period Signal Line', MPane );
for Bar := 20 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    p := LastPosition;
    if CrossUnder( Bar, MACDSeries( #Close ), EMASeries( MACDSeries( #Close ), 9 ) ) then
    begin
      SellAtMarket( Bar+1, p, '' );
    end;
  end
  else
  begin
    if not LastPositionActive then
    begin
      if (CrossOver( Bar, MACDSeries( #Close ), EMASeries( MACDSeries( #Close ), 9 )) ) then
      begin
          if ((PriceLow (Bar) < PriceHigh (Bar-1)) And
              (PriceLow (Bar) >= PriceLow (Bar-1)) And
              (PriceHigh(Bar) >= PriceHigh(Bar-1)) ) Then
          begin
           BuyAtMarket( Bar+1, '0' );
          end;
      end;
    end;
  end;
end;
