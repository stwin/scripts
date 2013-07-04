{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

HideVolume;
{ Simple system based on Slow Stochastic }
var pane, SLOWK, SLOWD, BAR: integer;
pane := CreatePane( 120, false, true );
SlowK := StochDSeries( 10, 3 );
SlowD := SMASeries( SlowK, 3 );
for Bar := 0 to 15 do
begin
  @slowK[Bar] := 0;
  @slowD[Bar] := 0;
end;
DrawHorzLine( 20, pane, #Olive, #Thin );
DrawHorzLine( 80, pane, #Olive, #Thin );
PlotSeries( SlowK, pane, #Red, #Thick );
PlotSeries( SlowD, pane, #Blue, #Thin );
DrawText ('Slow K', pane, 5, 12, #Red, 8);
DrawText ('Slow D', pane, 5, 22, #Blue, 8);
for Bar := 20 to BarCount - 1 do
begin
  if not LastPositionActive then
  begin
    if CrossOver( Bar, SlowK, SlowD ) then
      //if (EMA (Bar, #close, 22) >= EMA (Bar - 1, #close, 22 ))
      //and (GetSeriesValue( Bar - 1, SlowK ) < 20)
      if GetSeriesValue( Bar - 1, SlowK ) < 20
      then
        BuyAtMarket( Bar + 1,  '');
  end
  else
  begin
    if CrossOverValue( Bar, SlowK, 80 ) then
    //if CrossUnder( Bar, SlowK, slowD ) then
      SellAtMarket( Bar + 1, LastPosition, '' );
  end;
end;
PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);

