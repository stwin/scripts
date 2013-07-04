(*Description...
<html><b>mytext</b>
<i>italic</i>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );
ChangeScale( #Daily );
{$I 'myScreenCommon'}
{$I 'myElderChSaved' }
//{$I 'myOption'}
//{$I 'myEarnings' }
//{$I 'myNhNl'}

//______________________________________________________________________________
//______________________________________________________________________________

HideVolume;
VolumeColor ();
PlotVolume( 50 );

try
    //PlotFewBarsOfSP500();
    DisplayPercentChangeForLast5Bars ();
    PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
    PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);

    PlotElderChannelFromSavedDev();
    //PlotElderChannelOnTheFly( 22, 6, 90);
    //PlotBollingerBand( 22, 2.7 );
    //DisplayVolume ();
    //MyDrawLabel ('EMA: 11, 22', #Black);

    PlotMACD( true );
    //PlotNHNLSeriesV2( 40, 0 );
    PrintPosition ();
    
    PlotStochastic (7, 30, 70);
except
  DrawText( 'Exception occured', 0, 150, 50, #Red, 16 );
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );

// Color background
try
  var date: integer = 20050204;
  var bar: integer = DateToBar( date );
  SetBackgroundColor(	bar, 874 );
except
end;

{
var bs: integer;
var st: integer = StochDSeries(7,3);
for bs := 20 to BarCount-1 do
begin
  if (( @st[bs] <= 30 ) and ( @st[bs-1] > 30 ) ) then
    SetBackgroundColor(	bs, 897 );
  if (( @st[bs] >= 70 ) and ( @st[bs-1] < 70 ) ) then
    SetBackgroundColor(	bs, 889 );
end;
}


// Earning Dates
//displayEarnings();
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


