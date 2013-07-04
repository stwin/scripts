{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'myScreenCommon'}


//______________________________________________________________________________
//
//------------------------------------------------------------------------------


//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
VolumeColor();
PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
PlotElderChOnTheFly( 26, 132, 90 );
//------------------------------------------------------------------------------


{ This System takes advantage of future information!
It buys and sells at the market open on the same bar that it examines closing price! }
{
var BAR: integer;
for Bar := 1 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    if PriceClose( Bar ) < PriceClose( Bar - 1 ) then
      SellAtMarket( Bar, LastPosition(), '');

  end
  else
  begin
    if PriceClose( Bar ) > PriceClose( Bar - 1 ) then
      BuyAtMarket( Bar, '' );
  end;
end;
}

var B: integer;
for Bar := 1 to BarCount - 1 do
begin
  if PriceClose( Bar ) > PriceOpen( Bar ) then
  begin
    BuyAtMarket( Bar, '' );
    SellAtClose( Bar, LastPosition, '' );
  end;
end;


