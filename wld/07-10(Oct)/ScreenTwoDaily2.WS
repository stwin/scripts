{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );
//C hangeScale( #Daily );
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
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\ScreenTwoDaily.cs' );
myclass.ScreenTwoDailyInit( IWealthLabAddOn3 );
myclass.ScreenTwoDaily_GetAllSeries( SeriesHandlersComVariant );


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
PlotVolume( 50 );

var ema11: integer = EMASeries (#close, 11);
var ema22: integer = EMASeries (#close, 22);

try
    //PlotFewBarsOfSP500();
    DisplayPercentChangeForLast5Bars ();
    PlotSeries ( ema11, 0, 777, #thin);
    PlotSeries ( mainEmaSeries, 0, #Maroon, #thin);

    PlotSeries (upperChannelSeries, 0, #Teal, #thin);
    PlotSeries (lowerChannelSeries, 0, #Teal, #thin);
    MyDrawLabel ('ChannelWidth ('
         + FormatFloat('#', ( @channelWidthPercentSeries[BarCount-1] ) )
         + '%): '
         + FormatFloat('#.##', @upperChannelSeries[BarCount-1]-@lowerChannelSeries[BarCount-1]),
         #Black);

    //PlotElderChOnTheFly( 22, 132, 90);
    //PlotBollingerBand( 22, 2.7 );
    //DisplayVolume ();

    PlotMACD( true );
    PlotNHNLSeriesV2( 40, 0 );
    //PrintPosition ();

    PlotStochastic (7, 30, 70);
except
  on e: Exception do
  DrawText( 'Exception occured: ' + e.Message, 0, 300, 50, #Red, 16 );
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );

// Color background
try
  var date: integer = 20050902;
  var bar: integer = DateToBar( date );
  //SetBackgroundColor(	bar, 874 );
except
end;



// Earning Dates
displayEarnings();
//MyDrawLabel( 'Last Earning Date: ' + lastEarning(), #Green );

MyDrawLabel( '(OHLC) = '
          + FormatFloat( '0.00', PriceOpen(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceHigh(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceLow(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceClose(BarCount-1) ), 036 );



// For saving image
if( myUtil.GetBoolParam( 'SaveChart' ) ) then
  SaveChart();

DisplayDay ();

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );


