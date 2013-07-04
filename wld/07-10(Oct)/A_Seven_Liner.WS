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
for Bar := FirstActualBar + 4 to BarCount - 1 do
  if Lowest(Bar, ROCSeries(#Close, 1), 2) > 0 then SellAtMarket(Bar + 1, #All, '')
  else if Highest(Bar, ROCSeries(#Close, 1), 3) <
          0.3 + 0.2 * HV(Bar, #Close, 20, 1) then
      if BuyAtMarket(Bar + 1, FloatToStr(-ROC(Bar, #Close, 4))) then
        SetPositionPriority(LastPosition, -ROC(Bar, #Close, 4));

var ROCPANE: integer;
ROCPane := CreatePane( 75, true, true );
PlotSeries( ROCSeries( #Close, 1 ), ROCPane, 005, #ThickHist );

var HVPane: integer;
HVPane := CreatePane( 75, true, true );
var HV1: integer;
HV1 := HVSeries( #Average, 20, 1 );
PlotSeriesLabel( HV1, HVPane, 905, #Thick, 'HV1=HV(#Average,20,1)' );



