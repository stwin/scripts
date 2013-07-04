(*Description...
<html><b>mytext</b>
<i>italic</i>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );
{$I 'myScreenCommon'}
{$I 'myEarnings' }
{$I 'myNhNl'}

//______________________________________________________________________________
var mainEmaSeries: integer;
var elderChannelWidth, elderChannelWidthPercent: integer;
var elderChannelUpperSeries, elderChannelLowerSeries: integer;

//______________________________________________________________________________
// Reads the Elder Channel Deviation Series and returns it
// Note:- Symbol Synchronization must be enabled. Use EnableSync.
//
function ReadDevSeries( modifiedSymName: string; var devSeries: integer ): integer;
begin
  var lastUpdatedBar: integer;
  //Print( 'modifiedSymbol2  = ' +  modifedSymName );   PrintFlush;

  try
    devSeries := GetExternalSeries( modifiedSymName, #Close );
    SynchSeries( modifiedSymName );
    var bar: integer;
    for bar := BarCount-1 downto 1 do
    //Print( 'here2' );   PrintFlush;
    begin
      if( @devSeries[bar] <> @devSeries[bar-1] ) then
      begin
        lastUpdatedBar := bar;
        break;
      end;
    end;
  except
    devSeries := CreateNamedSeries('');
    lastUpdatedBar := -1;
  end;

  if( lastUpdatedBar < 0 ) then
    lastUpdatedBar := -1;
  //Print( 'lastUpdatedBar  = ' + FloatToStr( lastUpdatedBar ));   PrintFlush;
  Result := lastUpdatedBar;
end;

//______________________________________________________________________________
// Updates the rest of the bars with Elder Channel Deviation
//
procedure UpdateDevSeries( lastUpdatedBar, devSeries, period, loopbackbar, cutoffPercent: integer );
begin
  var watchListNum, startBar: integer;
  //var defaultStartDays: integer = period + loopbackmonth * 22 + 1;

  startBar := lastUpdatedBar+1;
  //if (startBar < defaultStartDays) then
  //  startBar := defaultStartDays;

  var bar: integer;
  for bar := startBar to BarCount-1 do
  begin
    var deviation: float;
    deviation := getElderChDeviation( bar, period, loopbackbar, cutoffPercent );
    @DevSeries[ bar ] := deviation ;
  end;
end;
//______________________________________________________________________________
// Plots Elder Channel, if possible then from the stored deviations (including
// updating on the fly), or else on the fly.
// Note:- Symbol Synchronization must be enabled. Use EnableSync.
//------------------------------------------------------------------------------
procedure PlotElderChannelFromSavedDev();
begin
  var bar: integer;
  var modifiedSymbol, dir, fileSuffix: string;
  modifiedSymbol := '';

  if( IsDaily ) then
    modifiedSymbol := GetSymbol + '-CD'
  else if( IsWeekly ) then
    modifiedSymbol := GetSymbol + '-CW';

  var devSeries: integer;
  var lastUpdatedBar: integer;

  if ( modifiedSymbol <> '' ) then
  begin
    lastUpdatedBar := ReadDevSeries( modifiedSymbol, devSeries );
    // modify the 0s in the start
    for bar := 0 to lastUpdatedBar do
      if( @devSeries[bar] <> 0 ) then
        break;
    if( bar > 0 ) then
    begin
      var val : float = @devSeries[bar];
      for bar := bar-1 downto 0 do
        @devSeries[bar] := val;
    end;
  end
  else
  begin
    devSeries := CreateNamedSeries( '' );
    lastUpdatedBar := -1;
  end;

  Print ( AsString(BarCount-1) + #9 + AsString(lastUpdatedBar) );

  var period: integer = 22;
  var loopbackbar: integer = 132;
  var cutoffPercent: integer = 90;

  // Update bars if required
  if( lastUpdatedBar <> BarCount-1) then
  begin
    if( LastUpdatedBar = -1 ) then
    begin
      var deviation : float = getElderChDeviation( BarCount-1, period, loopbackbar, cutoffPercent );
      devSeries := AddSeriesValue( devSeries, deviation );
    end
    else
    begin
      UpdateDevSeries( lastUpdatedBar, devSeries, period, loopbackbar, cutoffPercent );
    end;
  end;

  devSeries := SMASeries ( devSeries, 5 );

  // Plot upper and lower series
  elderChannelUpperSeries := MultiplySeries( mainEmaSeries, AddSeriesValue(devSeries,1));
  elderChannelLowerSeries := MultiplySeries( mainEmaSeries, SubtractValueSeries(1,devSeries));

  // First few bars
  for bar := 0 to period-1 do
  begin
    @elderChannelUpperSeries[bar] := @elderChannelUpperSeries[period];
    @elderChannelLowerSeries[bar] := @elderChannelLowerSeries[period];
  end;

  SetDescription( elderChannelUpperSeries, 'ElderUpperSeries' );
  SetDescription( elderChannelLowerSeries, 'ElderLowerSeries' );

  PlotSeries (elderChannelUpperSeries, 0, #Teal, #thin);
  PlotSeries (elderChannelLowerSeries, 0, #Teal, #thin);

  MyDrawLabel ('ChannelWidth ('
     + IntToStr(cutoffPercent)
     + ', '
     + FormatFloat('#', ( 2 * @devSeries[BarCount-1] * 100 ) )
     + '%): '
     + FormatFloat('#.##', @elderChannelUpperSeries[BarCount-1]-@elderChannelLowerSeries[BarCount-1]),
     #Black);

  //if( IsDaily ) then
  //begin
    elderChannelWidth := SubtractSeries( elderChannelUpperSeries, elderChannelLowerSeries );
    elderChannelWidthPercent := MultiplySeriesValue( devSeries, 200 );
    SetDescription( elderChannelWidthPercent, 'ElderChannelWidthPercent' );
    //var chWidthPane : integer = CreatePane(20,false,true);
    //PlotSeries( AddSeriesValue(MultiplySeriesValue(chWidth,0), 20), chWidthPane, 555, #thin );
    //PlotSeries( elderChannelWidthPercent, chWidthPane, 500, #thin );
  //end;
end;
//______________________________________________________________________________
//______________________________________________________________________________

HideVolume;
VolumeColor ();
PlotVolume( 50 );

//var ema11: integer = EMASeries (#close, 11);
var ema22: integer = EMASeries (#close, 22);
mainEmaSeries := SMASeries ( ema22, 5);

try
    DisplayPercentChangeForLast5Bars ();
    //PlotSeries ( ema22, 0, 777, #thin);
    PlotSeries ( mainEmaSeries, 0, #Maroon, #thin);

    PlotElderChannelFromSavedDev();

    PlotMACD( true );
    try
      PlotNHNLSeriesV2( 40, 0 );
    except
      on e: Exception do
      MyDrawLabel( 'Could not draw NH-NL', 090 );
    end;
      PrintPosition ();
    
    PlotStochastic (7, 30, 70);
except
  on e: Exception do
  DrawText( 'Exception occured: ' + e.Message, 0, 300, 50, #Red, 16 );
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );


// Earning Dates
displayEarnings();

MyDrawLabel( '(OHLC) = '
          + FormatFloat( '0.00', PriceOpen(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceHigh(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceLow(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceClose(BarCount-1) ), 036 );


{
var expEma22: float;
var expElderChannelWidth: float;
if ( isTrainingMode ) then
begin
  // Training - estimate for the last bar
  expEma22 := 2 * @mainEmaSeries[BarCount-2] - @mainEmaSeries[BarCount-3];
  expElderChannelWidth := 2 * @elderChannelWidth[BarCount-2] - @elderChannelWidth[BarCount-3];
  MyDrawLabel( 'Estimation for last bar (Training)', 0 );
end
else
begin
  // Trading - estimate for upcoming bar
  expEma22 := 2 * @mainEmaSeries[BarCount-1] - @mainEmaSeries[BarCount-2];
  expElderChannelWidth := 2 * @elderChannelWidth[BarCount-1] - @elderChannelWidth[BarCount-2];
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



// For saving image
if( myUtil.GetBoolParam( 'SaveChart' ) ) then
  SaveChart();

DisplayDay ();

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );


