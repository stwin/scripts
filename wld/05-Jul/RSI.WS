{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

HideVolume;

var pane, rsiId, bar: integer;
pane := CreatePane( 120, false, true );
rsiId := RSISeries( #close, 14 );
for bar := 0 to 10 do
begin
  @rsiId[Bar] := 0;
end;
DrawHorzLine( 30, pane, #Olive, #Thin );
DrawHorzLine( 70, pane, #Olive, #Thin );
PlotSeries( rsiId, pane, #Red, #Thick );
DrawText ('RSI', pane, 5, 12, #Red, 8);
for Bar := 20 to BarCount - 1 do
begin
  if not LastPositionActive then
  begin
    if CrossUnderValue( Bar, rsiId, 50 ) then
        BuyAtMarket( Bar + 1,  '');
  end
  else
  begin
    if CrossUnderValue( Bar, rsiId, 70 ) then
      SellAtMarket( Bar + 1, LastPosition, '' );
  end;
end;

PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);


