{$NO_AUTO_EXECUTE}
//============= Invoke CSharp Script and calculate all indiciators  ===========
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\ScreenMarket.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.ScreenMarketInit( IWealthLabAddOn3 );
//==============================================================================
var mainIndustry, mainIndustrySymbol, subIndustry, subIndustrySymbol: string;
myclass.ScreenMarket_GetStockIndustryInfo ( MainIndustry, MainIndustrySymbol, SubIndustry, SubIndustrySymbol );

var bar: integer; var myDrawLabelX: integer = 38;
//______________________________________________________________________________
procedure PlotSecondarySeries( paneHeight: integer; symbol: string; title: string );
begin
  SetPrimarySeries( symbol ); myclass.SetPrimarySeries ( true );

  var emaFastSeries: integer = CreateSeries;
  var emaSlowSeries: integer = CreateSeries;
  var upperSeries: integer = CreateSeries;
  var lowerSeries: integer = CreateSeries;
  var greenHigh: integer = CreateSeries;
  var greenOpen: integer = CreateSeries;
  var greenClose: integer = CreateSeries;
  var greenLow: integer = CreateSeries;
  var mmacd: integer = CreateSeries;
  var macdSignal: integer = CreateSeries;
  var macdh: integer = CreateSeries;
  var macdhColor: integer = CreateSeries;
  var macdOffset: float = 0;
  var impulseStr: string;

  myclass.ScreenMarket_GetAllSeries2( emaFastSeries, emaSlowSeries, upperSeries, lowerSeries,
    greenOpen, greenHigh, greenLow, greenClose, mmacd, macdSignal, macdh, macdhColor, macdOffset,
    impulseStr );

  var marketPane: integer = CreatePane( paneHeight, false, true );
  PlotSeries( mmacd, marketPane, 900, #Thick );
  PlotSeries( macdSignal, marketPane, 009, #Thin );
  DrawHorzLine( macdOffset, marketPane, 550, #Thin );
  for bar := 1 to BarCount-1 do
    DrawLine( bar, @macdh[bar], bar, macdOffset, marketPane, AsInteger(@macdhColor[bar]), #Thin );

  PlotSymbol( GetSymbol, marketPane, 600, #Candle );
  PlotSyntheticSymbol( GetSymbol, greenOpen, greenHigh, greenLow, greenClose, marketPane, 040, #Candle );
  PlotSeries( emaFastSeries, marketPane, 777, #Thin );
  PlotSeries( emaSlowSeries, marketPane, #Maroon, #Thin );
  PlotSeries( upperSeries, marketPane, #Teal, #thin );
  PlotSeries( lowerSeries, marketPane, #Teal, #thin );

  DrawLabel( ' ', marketPane );
  DrawLabel( ' ', marketPane );
  DrawText( title, marketPane, 5, 5, #Black, 10 );
  DrawLabel( myclass.GetStrPercentChangeForLast5Bars(), marketPane );
  DrawLabel ('ChannelWidth (' + FormatFloat('#', ( 100 * (@upperSeries[BarCount-1]-@lowerSeries[BarCount-1]) / @emaSlowSeries[BarCount-1] ) ) + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]), marketPane);
  DrawLabel( 'Impulse: ' + impulseStr, marketPane );

  RestorePrimarySeries(); myclass.RestorePrimarySeries ( );
end;

//---------Plot in Primary Pane ---- EMA and Channel ---------------------------
var SlowEmaSeries: integer = CreateSeries;
var MainEmaSeries: integer = CreateSeries;
var UpperChannelSeries: integer = CreateSeries;
var LowerChannelSeries: integer = CreateSeries;
var ChannelStr: string;
myclass.ScreenMarket_GetBasicSeries( slowEmaSeries, mainEmaSeries, upperChannelSeries, lowerChannelSeries, channelStr );
SingleCalcMode(true); AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 ); SingleCalcMode(false);
PlotSeries( slowEmaSeries, 0, 777, #Thin );
PlotSeries( mainEMASeries, 0, #Maroon, #Thin );
PlotSeries( upperChannelSeries, 0, #Teal, #thin );
PlotSeries( lowerChannelSeries, 0, #Teal, #thin );
DrawText( myclass.GetStrPercentChangeForLast5Bars(), 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
DrawText( channelStr, 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
HideVolume;

//---------------------------- Plot MACD ---------------------------------------
var mmacd : integer = CreateSeries;
var mmacdSignal : integer = CreateSeries;
var mmacdh : integer = CreateSeries;
var mmacdhColor : integer = CreateSeries;
var impulseStr: string;
var IsBullishDev, IsBearishDiv: boolean;
var BullBar1, BullBar2, BearBar1, BearBar2: integer;
myclass.GetMacdSeriesWithDiv ( mmacd, mmacdSignal, mmacdh, mmacdhColor, impulseStr, IsBullishDev, BullBar1, BullBar2, IsBearishDiv, BearBar1, BearBar2 );
var macdPane : integer = CreatePane( 60, false, true );
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
  {
//---------------------------- Plot NHNL----------------------------------------
var Sym: string; if(IsDaily)then Sym := 'NH-NL-Daily' else if(IsWeekly)then Sym := 'NH-NL-Weekly' else abort;
var NHSeries : integer = GetExternalSeries( Sym, #High );
var NLSeries : integer = GetExternalSeries( Sym, #Low );
var PaneNHNL : integer = CreatePane( 60, false, false);
SetPaneMinMax( PaneNHNL, 0, 800 );
var fedSeries: integer = CreateNamedSeries( 'FedResMeet' );
myclass.GetFedResMeetSeries ( fedSeries );
PlotSeriesLabel( fedSeries, PaneNHNL, #Blue, #Histogram, 'Fed. Res. Meet' );
DrawHorzLine (0, PaneNHNL, 779, #Thin); DrawHorzLine (300, PaneNHNL, 779, #Thin);
DrawHorzLine (600, PaneNHNL, 779, #Thin); DrawHorzLine (-300, PaneNHNL, 779, #Thin);
PlotSeriesLabel( NHSeries,  PaneNHNL, #Green, #Thin, 'Number of 52-week High' );
PlotSeriesLabel( NLSeries,  PaneNHNL, #Red, #Thin, 'Number of 52-week Low' );

//---------------------------- Plot Stochastic ---------------------------------
{
var StochSlowSeries : integer = CreateSeries;
var StochFastSeries : integer = CreateSeries;
myclass.ScreenMarket_GetStochSeries ( stochSlowSeries, stochFastSeries );
var stochasticPane : integer = CreatePane( 60, false, true );
SetPaneMinMax ( stochasticPane, 0, 100 );
DrawHorzLine( 20, stochasticPane, 558, #Thin );
DrawHorzLine( 80, stochasticPane, 558, #Thin );
DrawHorzLine( 30, stochasticPane, 558, #Thin );
DrawHorzLine( 70, stochasticPane, 558, #Thin );
PlotSeriesLabel( stochFastSeries, stochasticPane, #Blue, #Thin, 'Stoch Fast Series' );
PlotSeriesLabel( stochSlowSeries, stochasticPane, #red, #Thick, 'Stoch Slow Series' );

//-------------------------- Print Position ------------------------------------
var EntryBar, EntryColor, ExitBar, ExitColor: integer;
myclass.PrintClosedPosition ( GetSymbol, IsWeekly, EntryBar, EntryColor, ExitBar, ExitColor );
SetBackgroundColor( EntryBar, EntryColor );
SetBackgroundColor( ExitBar, ExitColor );
 }
//---------------------------- Industry Plottings ----------------------------------

//PlotSecondarySeries( 200, subIndustrySymbol, subIndustrySymbol + ' || ' + mainIndustry + ' || ' + subIndustry );

