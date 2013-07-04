(*Description...
based on previous work of Cone (Smitlener Streaks) and klemenv (Smitlener Streak ver.4) 

*)
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
for Bar := FirstActualBar + 4 to BarCount - 2 do  // Alert has been turned off
  if Lowest(Bar, ROCSeries(#Close, 1), 2) > 0 then
    SellAtMarket(Bar + 1, #All, '')
  else
    if Highest(Bar, ROCSeries(#Close, 1), 3) < 1 then
      if BuyAtMarket(Bar + 1, FloatToStr(-ROC(Bar, #Close, 4))) then
        SetPositionPriority(LastPosition, -ROC(Bar, #Close, 4));
        

var ROCPANE: integer;
ROCPane := CreatePane( 75, true, true );
PlotSeries( ROCSeries( #Close, 1 ), ROCPane, 005, #ThickHist );

