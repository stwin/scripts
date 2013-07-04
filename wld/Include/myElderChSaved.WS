
EnableSynch( true ); // This is must

// NOTE: if there is too much DELAY, then use ElderChannelUpdate script to
// update the channelDaily database

//{$I 'myScreenCommon'}
//var tick1: integer = GetTickCount();

var elderChannelWidth, elderChannelWidthPercent : integer;
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
    devSeries := CreateSeries;
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
  var period, loopbackbar, cutoffPercent: integer;
  var modifiedSymbol, dir, fileSuffix: string;
  
  period := 22;
  loopbackbar := 132;
  cutoffPercent := 90;
    
  if( IsDaily ) then
    modifiedSymbol := GetSymbol + '-CD'
  else if( IsWeekly ) then
    modifiedSymbol := GetSymbol + '-CW'
  else
    exit;

  var devSeries: integer;
  var lastUpdatedBar: integer;

  lastUpdatedBar := ReadDevSeries( modifiedSymbol, devSeries );

  // modify the 0s in the start
  var bar: integer;
  for bar := 0 to lastUpdatedBar do
    if( @devSeries[bar] <> 0 ) then
      break;
  if( bar > 0 ) then
  begin
    var val : float = @devSeries[bar];
    for bar := bar-1 downto 0 do
      @devSeries[bar] := val;
  end;

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

  // Plot upper and lower series
  var emaSlowSeries: integer;
  emaSlowSeries := EMASeries(#close, period);
  elderChannelUpperSeries := MultiplySeries( emaSlowSeries, AddSeriesValue(devSeries,1));
  elderChannelLowerSeries := MultiplySeries( emaSlowSeries, SubtractValueSeries(1,devSeries));
  
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

//PlotElderChannelFromSavedDev();

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );

