(*Description...
<b>test</b>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma (true);
EnableSynch( true );
ChangeScale( #Weekly );

//==============================================================================
// Invoke CSharp Script and calculate all indiciators
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\ScreenOneWeekly.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.ScreenOneWeeklyInit( IWealthLabAddOn3 );
//==============================================================================


//{ 4$4 I 'myScreenCommon'}
 var RootDir: string = myclass.GetRootDir();
var IsTrainingMode: boolean = myclass.GetBoolParam( 'TrainingMode' );

var bar: integer;
var myDrawLabelX: integer = 38;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 7, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;
 procedure VolumeColor ();
begin
  var Bar: integer;
  for Bar := 0 to BarCount - 1 do
    if PriceClose( Bar ) > PriceOpen( Bar ) then
      SetSeriesBarColor( Bar, #Volume, #Green )
    else
      SetSeriesBarColor( Bar, #Volume, #Red );
end;
 procedure PlotVolume( height: integer );
begin
  var volumePane: integer = CreatePane( height, false, true );
  var zeroSeries: integer = AddSeriesValue( #Volume, 0 );
  @zeroSeries[BarCount-1] := 0;
  SetDescription( zeroSeries, 'Volume' );
  PlotSeries( zeroSeries, volumePane, #Black, #Histogram );
  PlotSeriesLabel( #Volume, volumePane, #Black, #ThickHist,'Volume' );
end;
procedure PlotStochastic (period, line1, line2: integer);
begin
  var slowK, slowD, stochasticPane : integer;
  stochasticPane := CreatePane( 60, false, true );
  SetPaneMinMax ( stochasticPane, 0, 100 );
  slowK := StochDSeries (period, 3);
  slowD := SMASeries (slowK, 3);

  // First draw elder channel width series, if  that is available.
  var elderChWidthSeries: integer = FindNamedSeries( 'ElderChannelWidthPercent' );
  if( elderChWidthSeries <> -1 ) then
  begin
    PlotSeriesLabel( elderChWidthSeries, stochasticPane, #Teal, #Thin, 'ChannelWidth' );
  end;

  // Now the main series
  var lineColor: integer = 558;
  DrawHorzLine( 20, stochasticPane, lineColor, #Thin );
  DrawHorzLine( 80, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line1, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line2, stochasticPane, lineColor, #Thin );
  PlotSeriesLabel( slowD, stochasticPane, #Blue, #Thin, 'Slow D(3)' );
  PlotSeriesLabel( slowK, stochasticPane, #red, #Thick, 'Slow K ('+IntToStr(period)+',3)' );
end;

//______________________________________________________________________________
var mainIndustry, mainIndustrySymbol, subIndustry, subIndustrySymbol: string;
var market, marketName: string;
myclass.GetIndustryGroupInfo ( GetSymbol, MainIndustry, MainIndustrySymbol, SubIndustry, SubIndustrySymbol );
myclass.GetMarketSymbol ( GetSymbol, market, marketName );

//______________________________________________________________________________
procedure PlotSecondarySeries( paneHeight: integer; symbol: string; title: string );
begin
  var marketPane: integer = CreatePane( paneHeight, false, true );
  DrawLabel( ' ', marketPane ); // blank label to create space
  DrawLabel( ' ', marketPane ); // blank label to create space

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
  myclass.ScreenOneWeekly_GetAllSeries2( emaFastSeries, emaSlowSeries, upperSeries, lowerSeries,
    greenOpen, greenHigh, greenLow, greenClose, mmacd, macdSignal, macdh, macdhColor, macdOffset,
    impulseStr );

  // Plot MACD stuffs
  // Faded Colors = 955, 559, 884, 373, 955
  PlotSeries( mmacd, marketPane, 900, #Thick );
  PlotSeries( macdSignal, marketPane, 009, #Thin );
  DrawHorzLine( macdOffset, marketPane, 550, #Thin );
  for bar := 1 to BarCount-1 do
    DrawLine( bar, @macdh[bar], bar, macdOffset, marketPane, AsInteger(@macdhColor[bar]), #Thin );
  DrawLabel( 'Impulse: ' + impulseStr, marketPane );

  // plot some info and indicators
  PlotSymbol( GetSymbol, marketPane, 700, #Candle );
  PlotSyntheticSymbol( GetSymbol, greenOpen, greenHigh, greenLow, greenClose, marketPane, 050, #Candle );
  PlotSeries( emaFastSeries, marketPane, 777, #Thin );
  PlotSeries( emaSlowSeries, marketPane, #Maroon, #Thin );
  PlotSeries( upperSeries, marketPane, #Teal, #thin );
  PlotSeries( lowerSeries, marketPane, #Teal, #thin );

  DrawText( title, marketPane, 5, 5, #Black, 10 );
  DrawLabel ('ChannelWidth ('
       + FormatFloat('#', ( 100 * (@upperSeries[BarCount-1]-@lowerSeries[BarCount-1]) / @emaSlowSeries[BarCount-1] ) ) + '%): '
       + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
       marketPane);

  RestorePrimarySeries(); myclass.RestorePrimarySeries ( );
end;
//______________________________________________________________________________


// Create all series required
var mainEmaSeries: integer = CreateSeries;
var upperChannelSeries: integer = CreateSeries;
var lowerChannelSeries: integer = CreateSeries;
var channelWidthPercentSeries: integer = CreateNamedSeries ( 'ElderChannelWidthPercent' );
var mmacdSeries: integer = CreateSeries;
var macdSignalSeries: integer = CreateSeries;
var macdHistogramSeries: integer = CreateSeries;
var stochSlowSeries: integer = CreateSeries;
var stochFastSeries: integer = CreateSeries;

myclass.ScreenOneWeekly_GetAllSeries( mainEmaSeries, upperChannelSeries, lowerChannelSeries,
      channelWidthPercentSeries, mmacdSeries, macdSignalSeries, macdHistogramSeries,
      stochSlowSeries, stochFastSeries );


//______________________________________________________________________________
//______________________________________________________________________________
// Now plot all indicators



VolumeColor();
HideVolume();
PlotVolume( 30 );

MyDrawLabel ( myclass.BasicFundamentalString( GetSymbol ), 000 );
MyDrawLabel ( myclass.MembershipString( GetSymbol ), 000 );
PlotSeries (EMASeries (#Close, 11), 0, 777, #Thin);
PlotSeries (mainEMASeries, 0, #Maroon, #Thin);

PlotSeries (upperChannelSeries, 0, #Teal, #thin);
PlotSeries (lowerChannelSeries, 0, #Teal, #thin);
MyDrawLabel ('ChannelWidth ('
     + FormatFloat('#', ( @channelWidthPercentSeries[BarCount-1] ) )
     + '%): '
     + FormatFloat('#.##', @upperChannelSeries[BarCount-1]-@lowerChannelSeries[BarCount-1]),
     #Black);


//Plot MACD
var mmacd : integer = CreateSeries;
var mmacdSignal : integer = CreateSeries;
var mmacdh : integer = CreateSeries;
var mmacdhColor : integer = CreateSeries;
var impulseStr: string;
var IsBullishDev, IsBearishDiv: boolean;
var BullBar1, BullBar2, BearBar1, BearBar2: integer;

myclass.GetMacdSeriesWithDiv ( mmacd, mmacdSignal, mmacdh, mmacdhColor, impulseStr,
         IsBullishDev, BullBar1, BullBar2, IsBearishDiv, BearBar1, BearBar2 );

var macdPane : integer = CreatePane( 40, false, true );
PlotSeriesLabel( mmacd, macdPane, #Red, #Thick, 'MACD' );
PlotSeriesLabel( MMacdSignal, macdPane, #Blue, #Thin, 'MACD Signal' );
DrawHorzLine( 0, macdPane, #Olive, #Thin );
for bar := 1 to BarCount-1 do
  DrawLine( bar, @mmacdh[bar], bar, 0, macdPane, AsInteger(@mmacdhColor[bar]), #Thin );
DrawLabel( 'Impulse: ' + impulseStr, macdPane );
if ( IsBullishDev ) then
begin
 DrawLine( BullBar1, PriceLow(BullBar1)*0.98, BullBar2, PriceLow(BullBar2)*0.98, 0, #Aqua, #Thick );
 DrawLine( BullBar1, @mmacdh[BullBar1]*0.98, BullBar2, @mmacdh[BullBar2]*0.98, MacdPane,  #Aqua, #Thick );
 MyDrawLabel( 'Bullish Divergence', #Blue );
end;
if ( IsBearishDiv ) then
begin
 DrawLine( BearBar1, PriceHigh(BearBar1)*1.02, BearBar2, PriceHigh(BearBar2)*1.02, 0, #Aqua, #Thick );
 DrawLine( BearBar1, @mmacdh[BearBar1]*1.02, BearBar2, @mmacdh[BearBar2]*1.02, MacdPane,  #Aqua, #Thick );
 MyDrawLabel( 'Bearish Divergence', #Blue );
end;


//PrintClosedPosition();

// Industry
PlotSecondarySeries( 150, subIndustrySymbol, subIndustrySymbol + ' || ' + mainIndustry + ' || ' + subIndustry );
DrawText( SubIndustry, 0, 130, 20, 000, 10);  // draws on price pane

// Market
PlotSecondarySeries( 150, market, market + ' (' + marketName + ') Weekly' );



// Mark highest bar
SingleCalcMode(true);
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );
SingleCalcMode(false);


try
  var date: integer = 20050829;
  var bar: integer = DateToBar( date );
  //SetBackgroundColor(	bar, 874 );
except
end;

//------------------------- Earning Dates --------------------------------------
var EarningSeries: integer = CreateSeries;
var NextEarningDaysLeft, NextEarningIntDate: integer;
myclass.GetEarningDates ( GetSymbol, IsWeekly, EarningSeries, NextEarningDaysLeft, NextEarningIntDate );
for bar := 0 to BarCount-1 do
  if ( @EarningSeries[bar] > 0.5 )  then
    DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
if( IsDaily() and ( NextEarningIntDate <> 0 ) ) then
  if ( NextEarningDaysLeft > 10 ) then
    MyDrawLabel( 'Next Earning Date(' + IntToStr(NextEarningDaysLeft) + '): ' + DateToStr( NextEarningIntDate ), #Blue )
  else
    MyDrawLabel( '>>>-------> Next Earning Date(' + IntToStr(NextEarningDaysLeft) + '): ' + DateToStr( NextEarningIntDate ), #Red );


//------------------------- For saving image -----------------------------------
//if( myclass.GetBoolParam( 'SaveChart' ) ) then
//  SaveChart ();



//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );


