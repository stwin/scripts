(*Description...
<html><b>mytext</b>
<i>italic</i>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( false );

{$I 'myScreenCommon'}
{$I 'myEarnings' }
{$I 'myNhNl'}

//______________________________________________________________________________
//______________________________________________________________________________


var SeriesHandlers: array[0..19] of integer;
var SeriesHandlersComVariant: ComVariantArray;

// Creat all series required
SeriesHandlers[0] := CreateSeries;  // mainEmaSeries
SeriesHandlers[1] := CreateSeries;  // upperChannelSeries
SeriesHandlers[2] := CreateSeries;  // lowerChannelSeries
SeriesHandlers[3] := CreateSeries;  // channelWidthPercentSeries
SeriesHandlers[4] := CreateSeries;  // macdSeries
SeriesHandlers[5] := CreateSeries;  // macdSignalSeries
SeriesHandlers[6] := CreateSeries;  // macdHistogramSeries
SeriesHandlers[7] := CreateSeries;  // stochSlowSeries
SeriesHandlers[8] := CreateSeries;  // stochFastSeries

SeriesHandlersComVariant := SeriesHandlers;

// Invoke CSharp Script and calculate all indiciators
var csScripting: ComVariant = CreateOleObject( 'WLExtra.Scripting' );
var compilerRes: integer = csScripting.CompileFile ( 'CsScripts\PlayingAroundACorePosition.cs' );
if ( compilerRes = -1 ) then
  exit;
Print ( 'CompilerResult = ' + IntToStr(compilerRes) );  PrintFlush;
var instanceId: integer = csScripting.CreateInstance ( 'MyScript.MyClass' );
//csScripting.RunMethod ( instanceId, 'PlayingAroundACorePositionTest' );
csScripting.RunMethod1 ( instanceId, 'PlayingAroundACorePositionInit', IWealthLabAddOn3 );
csScripting.RunMethod1 ( instanceId, 'GetAllSeries', SeriesHandlersComVariant );


// Assign some readable names to the indicators
var mainEmaSeries: integer = SeriesHandlers[0];
var upperChannelSeries: integer = SeriesHandlers[1];
var lowerChannelSeries: integer = SeriesHandlers[2];
var channelWidthPercentSeries: integer = SeriesHandlers[3];
var mmacdSeries: integer = SeriesHandlers[4];
var macdSignalSeries: integer = SeriesHandlers[5];
var macdHistogramSeries: integer = SeriesHandlers[6];
var stochSlowSeries: integer = SeriesHandlers[7];
var stochFastSeries: integer = SeriesHandlers[8];

SetDescription( channelWidthPercentSeries, 'ElderChannelWidthPercent' );


//__________________________________________
// Now plot all indicators

HideVolume;
VolumeColor ();
PlotVolume( 30 );

DisplayPercentChangeForLast5Bars ();
PlotSeries ( mainEmaSeries, 0, #Maroon, #thin );

PlotSeries (upperChannelSeries, 0, #Teal, #thin);
PlotSeries (lowerChannelSeries, 0, #Teal, #thin);

MyDrawLabel ('ChannelWidth ('
     + FormatFloat('#', ( @channelWidthPercentSeries[BarCount-1] ) )
     + '%): '
     + FormatFloat('#.##', @upperChannelSeries[BarCount-1]-@lowerChannelSeries[BarCount-1]),
     #Black);

PlotMACD( true );
//if ( IsDaily or IsWeekly ) then
//    PlotNHNLSeriesV2( 40, 0 );
PlotStochastic (7, 30, 70);

//__________________________________________



// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );


// Earning Dates
displayEarnings();

MyDrawLabel( '(OHLC) = '
          + FormatFloat( '0.00', PriceOpen(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceHigh(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceLow(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceClose(BarCount-1) ), 036 );




var expEma22: float;
var expElderChannelWidth: float;     {
if ( isTrainingMode ) then
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
end;                                  }

var bar: integer;
var buyPrice, shortPrice: float;
for bar := Barcount-252 to Barcount-2 do
begin
  expEma22 := 2 * @mainEmaSeries[bar] - @mainEmaSeries[bar-1];
  expElderChannelWidth := expEma22 / 100 * (2 * @channelWidthPercentSeries[bar] - @channelWidthPercentSeries[bar-1] );
  buyPrice := expEma22 - 0.5 * expElderChannelWidth;
  shortPrice := expEma22 + 0.5 * expElderChannelWidth;
  
  if ( LastPositionActive ) then
  begin
    SellAtLimit ( Bar+1, expEma22, #All, 'Sell at ema' );
    CoverAtLimit ( Bar+1, expEma22, #All, 'Cover at ema' );
  end;
  if ( Not LastPositionActive ) then
  begin
    BuyAtLimit ( Bar+1, buyPrice, 'buy at lowerch' );
    ShortAtLimit ( Bar+1, shortPrice, 'short at upperch' );
  end;
  //Print ( Inttostr(bar) );
end;
{$I 'WinLossBackground'}  WinLossBackground(1);
procedure ProfitPane;
begin
  var Bar, ProfitPane, ProfitSeries: integer;
  ProfitPane := CreatePane( 60, false, true );
  SetPaneMinMax( ProfitPane, 0, 0 );
  ProfitSeries := CreateSeries;
  for Bar := 0 to BarCount - 1 do
  begin
    SetSeriesValue( Bar, ProfitSeries, Equity( Bar ) );
    if ( Equity(Bar) < 0 ) then
      SetSeriesBarColor( Bar, ProfitSeries, 600 )
    else
      SetSeriesBarColor( Bar, ProfitSeries, 060 );
  end;
  PlotSeries( ProfitSeries, ProfitPane, #Green, #ThickHist );
  DrawLabel( 'System Profit', ProfitPane );
end;
ProfitPane;



// For saving image
if( myUtil.GetBoolParam( 'SaveChart' ) ) then
  SaveChart();

DisplayDay ();

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );



