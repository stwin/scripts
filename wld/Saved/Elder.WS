{$NO_AUTO_EXECUTE}
var tick1: integer = GetTickCount();
UseUpdatedEma (true);


//==============================================================================
// Invoke CSharp Script and calculate all indiciators
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\Elder.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.ElderInit( IWealthLabAddOn3 );
//==============================================================================

{$I 'myScreenCommon'}
{$I 'mynhnl'}
{$I 'PlotMACD'}
{$I 'PlotElderChOnTheFly'}

//______________________________________________________________________________

//if( (GetSymbol() = 'SP-500') or (GetSymbol() = 'DJ-30') or (GetSymbol() = 'COMPQX') ) then
 // HideVolume
//else
  VolumeColor();

try
  if( IsWeekly ) then
  begin
    PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
    PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
    PlotMACD( true );
    PlotElderChOnTheFly( 22, 132, 90 );
  end
  else if( IsDaily ) then
  begin
    DisplayPercentChangeForLast5Bars();
    PlotSeries( EMASeries( #close, 11 ), 0, 777, #thin );
    PlotSeries( EMASeries( #close, 22 ), 0, #Maroon, #thin );
    //PlotSeries( EMASeries( #Volume, 2 ), 1, #Maroon, #thin );
    PlotElderChOnTheFly( 22, 132, 90 );
    //PlotBollingerBand( 22, 2.7 );
    //DisplayVolume();
    PlotMACD( true );
    //if( WatchListName <> '' ) then
    //  PlotNHNLSeriesV2( 40, 0 );
    //PrintPosition();

    PlotStochastic( 7, 20, 80 );
 end;

except
  on e: Exception do
  DrawText( 'Exception occured: ' + e.Message, 0, 250, 50, #Red, 16 );
end;

// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );

// For saving image
//SaveChart();
//SaveChartWithSize( 1620, 1215 );
//SaveChartImage( 'D:\WLE\Images\' + GetSymbol + '.gif', 1024, 768, 'gif' );

DisplayDay ();

// Color background
try
  var date: integer = 20050902;
  var bar: integer = DateToBar( date );
  //SetBackgroundColor(	bar, 874 );
except
end;


Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );


