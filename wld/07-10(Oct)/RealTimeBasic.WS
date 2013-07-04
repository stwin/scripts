(*Description...
<html><b>mytext</b>
<i>italic</i>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );

//==============================================================================
// Initialize CSharp Script
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\RealTimeBasic.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.RealTimeBasicInit( IWealthLabAddOn3 );
//==============================================================================

var bar: integer;
var myDrawLabelX: integer = 38;

//---------Plot in Primary Pane ---- EMA and Channel ---------------------------
var SlowEmaSeries: integer = CreateSeries;
var MainEmaSeries: integer = CreateSeries;
var UpperChannelSeries: integer = CreateSeries;
var LowerChannelSeries: integer = CreateSeries;
var ChannelWidthPercentSeries: integer = CreateSeries;  // Used in stochastic
var ChannelStr: string;
myclass.RealTimeBasic_GetBasicSeries( slowEmaSeries, mainEmaSeries, upperChannelSeries, lowerChannelSeries, channelWidthPercentSeries, channelStr );
DrawText( AsString(GetTime(BarCount-1)), 0, 77, 18, #Black, 8);
DrawText( myclass.GetDayStr( BarCount-1 ), 0, 104, 18, #Black, 8); // Displays Day on the price pane
PlotSeries( slowEmaSeries, 0, 777, #Thin );
PlotSeries( mainEMASeries, 0, #Maroon, #Thin );
PlotSeries( upperChannelSeries, 0, #Teal, #thin );
PlotSeries( lowerChannelSeries, 0, #Teal, #thin );
//DrawText( myclass.GetStrPercentChangeForLast5Bars(), 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
DrawText( channelStr, 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
//DrawText( myclass.GetStrOHLC, 0, 7, myDrawLabelX, 036, 10 ); myDrawLabelX := myDrawLabelX + 15;

{//------------------------- Earning Dates --------------------------------------
var EarningSeries: integer = CreateSeries;
var EarningStr: string;
var EarningStrColor: integer;
myclass.GetEarningSeriesDaily ( GetSymbol, EarningSeries, EarningStr, EarningStrColor );
for bar := 0 to BarCount-1 do
  if ( @EarningSeries[bar] > 0.5 )  then
    DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
DrawText( EarningStr, 0, 7, myDrawLabelX, EarningStrColor, 10 ); myDrawLabelX := myDrawLabelX + 15;
}
//----------------------------- Volume -----------------------------------------
//HideVolume();
for Bar:=0 to BarCount-1 do if PriceClose(Bar) > PriceOpen(Bar) then SetSeriesBarColor(Bar,#Volume,#Green) else SetSeriesBarColor(Bar,#Volume,#Red);
{var volumePane: integer = CreatePane( 50, false, true );
var VolumeSeries2: integer = MultiplySeriesValue( #Volume, 0 ); @VolumeSeries2[BarCount-1] := 0;
PlotSeries( VolumeSeries2, volumePane, #Black, #Histogram );
PlotSeriesLabel( #Volume, volumePane, #Black, #ThickHist,'Volume' );
}
//---------------------------- Plot MACD ---------------------------------------
var mmacd : integer = CreateSeries;
var mmacdSignal : integer = CreateSeries;
var mmacdh : integer = CreateSeries;
var mmacdhColor : integer = CreateSeries;
var impulseStr: string;
var IsBullishDev, IsBearishDiv: boolean;
var BullBar1, BullBar2, BearBar1, BearBar2: integer;
myclass.GetMacdSeriesWithDiv ( mmacd, mmacdSignal, mmacdh, mmacdhColor, impulseStr, IsBullishDev, BullBar1, BullBar2, IsBearishDiv, BearBar1, BearBar2 );
var macdPane : integer = CreatePane( 40, false, true );
PlotSeriesLabel( mmacd, macdPane, #Red, #Thick, 'MACD' );
PlotSeriesLabel( MMacdSignal, macdPane, #Blue, #Thin, 'MACD Signal' );
DrawHorzLine( 0, macdPane, #Olive, #Thin );
for bar := 1 to BarCount-1 do SetSeriesBarColor( bar, mmacdh, AsInteger(@mmacdhColor[bar]) );
PlotSeries( mmacdh, macdPane, #Black, #Histogram);
DrawLabel( 'Impulse: ' + impulseStr, macdPane );
if ( IsBullishDev ) then begin
 DrawLine( BullBar1, PriceLow(BullBar1)*0.98, BullBar2, PriceLow(BullBar2)*0.98, 0, #Aqua, #Thick );
 DrawLine( BullBar1, @mmacdh[BullBar1]*0.98, BullBar2, @mmacdh[BullBar2]*0.98, MacdPane,  #Aqua, #Thick );
 DrawText( 'Bullish Divergence', 0, 7, myDrawLabelX, 009, 10 ); myDrawLabelX := myDrawLabelX + 15;
end;
if ( IsBearishDiv ) then begin
 DrawLine( BearBar1, PriceHigh(BearBar1)*1.02, BearBar2, PriceHigh(BearBar2)*1.02, 0, #Aqua, #Thick );
 DrawLine( BearBar1, @mmacdh[BearBar1]*1.02, BearBar2, @mmacdh[BearBar2]*1.02, MacdPane,  #Aqua, #Thick );
 DrawText( 'Bearish Divergence', 0, 7, myDrawLabelX, 009, 10 ); myDrawLabelX := myDrawLabelX + 15;
end;

{//---------------------------- Plot NHNL----------------------------------------
var NHSeries : integer = GetExternalSeries( 'NH-NL-Daily', #High );
var NLSeries : integer = GetExternalSeries( 'NH-NL-Daily', #Low );
var PaneNHNL : integer = CreatePane( 40, false, false);
SetPaneMinMax( PaneNHNL, 0, 800 );
var fedSeries: integer = CreateNamedSeries( 'FedResMeet' );
myclass.GetFedResMeetSeries ( fedSeries );
PlotSeriesLabel( fedSeries, PaneNHNL, #Blue, #Histogram, 'Fed. Res. Meet' );
DrawHorzLine (0, PaneNHNL, 779, #Thin); DrawHorzLine (300, PaneNHNL, 779, #Thin);
DrawHorzLine (600, PaneNHNL, 779, #Thin); DrawHorzLine (-300, PaneNHNL, 779, #Thin);
PlotSeriesLabel( NHSeries,  PaneNHNL, #Green, #Thin, 'Number of 52-week High' );
PlotSeriesLabel( NLSeries,  PaneNHNL, #Red, #Thin, 'Number of 52-week Low' );
}
//---------------------------- Plot Stochastic ---------------------------------
var StochSlowSeries : integer = CreateSeries;
var StochFastSeries : integer = CreateSeries;
myclass.RealTimeBasic_GetStochSeries ( stochSlowSeries, stochFastSeries );
var stochasticPane : integer = CreatePane( 60, false, true );
SetPaneMinMax ( stochasticPane, 0, 100 );
PlotSeriesLabel( channelWidthPercentSeries, stochasticPane, #Teal, #Thin, 'ChannelWidth' );
DrawHorzLine( 20, stochasticPane, 558, #Thin );
DrawHorzLine( 80, stochasticPane, 558, #Thin );
DrawHorzLine( 30, stochasticPane, 558, #Thin );
DrawHorzLine( 70, stochasticPane, 558, #Thin );
PlotSeriesLabel( stochFastSeries, stochasticPane, #Blue, #Thin, 'Stoch Fast Series' );
PlotSeriesLabel( stochSlowSeries, stochasticPane, #red, #Thick, 'Stoch Slow Series' );

//-------------------------- MISC Stuffs ---------------------------------------
//PrintClosedPosition();

// Mark highest bar
SingleCalcMode(true); AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 ); SingleCalcMode(false);

  {
var expEma22: float;
var expElderChannelWidth: float;
if ( myclass.GetBoolParam('TrainingMode') ) then
begin
  // Training - estimate for the last bar
  expEma22 := 2 * @mainEmaSeries[BarCount-2] - @mainEmaSeries[BarCount-3];
  expElderChannelWidth :=  expEma22 / 100 * (2 * @channelWidthPercentSeries[BarCount-2] - @channelWidthPercentSeries[BarCount-3] );
  MyDrawLabel( 'Estimation for last bar (Training)', 0 );
end
else
begin
  // Trading - estimate for upcoming bar
  expEma22 := 2 * @mainEmaSeries[BarCount-1] - @mainEmaSeries[BarCount-2];
  expElderChannelWidth := expEma22 / 100 * (2 * @channelWidthPercentSeries[BarCount-1] - @channelWidthPercentSeries[BarCount-2] );
  MyDrawLabel( 'Estimation for upcoming bar (Trading)', 0 );
end;

var i: integer;
for i := -4 to 4 do
begin
  var level: float;
  level := expEma22 + i * 0.25 * expElderChannelWidth;
  DrawLine( BarCount-3, level, BarCount-1, level, 0, 000, #Thin );
  AnnotateChart(	FormatFloat( '0.00', level ), 0, BarCount-50, level, 0, 8);
  if ( i < 0 ) then
  begin
    //BuyAtLimit ( BarCount, level, IntToStr(i*25) );
  end;
  if ( i > 0 ) then
  begin
    //ShortAtLimit ( BarCount, level, IntToStr(i*25) );
  end;
end;
}
       {
var bar: integer;
var buyPrice, shortPrice: float;
for bar := 200 to Barcount-2 do
begin
  expEma22 := 2 * @mainEmaSeries[bar-1] - @mainEmaSeries[bar-2];
  expElderChannelWidth := expEma22 / 100 * (2 * @channelWidthPercentSeries[bar-1] - @channelWidthPercentSeries[bar-2] );
  buyPrice := expEma22 - 0.5 * expElderChannelWidth;
  shortPrice := expEma22 + 0.5 * expElderChannelWidth;
  
  if ( LastPositionActive ) then
  begin
    if ( PositionLong ( LastPosition ) ) then
        SellAtLimit ( Bar+1, expEma22, LastPosition, 'Sell at ema' )
    else
      CoverAtLimit ( Bar+1, expEma22, LastPosition, 'Cover at ema' );
  end;
  if ( Not LastPositionActive ) then
  begin
    BuyAtLimit ( Bar+1, buyPrice, 'buy at lowerch' );
    ShortAtLimit ( Bar+1, shortPrice, 'short at upperch' );
  end;
  Print ( Inttostr(bar) );
end;
      }


//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );



