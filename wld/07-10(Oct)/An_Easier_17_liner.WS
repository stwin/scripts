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
PlotElderChannelOnTheFly( 22, 6, 90 );
//------------------------------------------------------------------------------


var Bar: integer;
for Bar := FirstActualBar + 90 to BarCount - 1 do
  if (Lowest(Bar, ROCSeries(#Close, 1), 2) > 0) then
    SellAtMarket(Bar + 1, #All, '')
  else if (52 * Highest(Bar, ROCSeries(#Close, 1), 3) < 15 + 12 * StdDev(Bar, ROCSeries(#Close, 1), 31))
    and (3 * LinearRegSlope(Bar, ROCSeries(#Close, 1), 3) < 19)
    and (Highest(Bar - 1, RSISeries(#Close, 31), 31) > 60)
    and (46 * StdError(Bar, #Close, 31) > PriceClose(Bar))
    and (53 * SMA(Bar, #Volume, 31) > 24 * Volume(Bar))
    and (PriceOpen(Bar) > PriceLow(Bar))
    and (3 * ATRP(Bar, 31) > 7)
    then begin
      var Priority: float = TurnUp(Bar, #Close) + TurnDown(Bar, #Close) - ROC(Bar, #Close, 4);
      Priority := Priority + PriceHigh(Bar) / PriceLow(Bar) + PriceHigh(Bar) / PriceLow(Bar - 1);
      if BuyAtMarket(Bar + 1, FloatToStr(Priority)) then
        SetPositionPriority(LastPosition, Priority);
    end;


PlotSeries( SMASeries( #Volume, 31), 1, 777, #thin );

var ROCPANE: integer;
ROCPane := CreatePane( 75, true, true );
PlotSeries( ROCSeries( #Close, 1 ), ROCPane, 005, #ThickHist );

var ATRPPANE: integer;
ATRPPane := CreatePane( 75, true, true );
PlotSeries( ATRPSeries( 31 ), ATRPPane, 005, #ThickHist );


