{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );

{$I 'myScreenCommon'}
//{$I 'myFutures'}
{$I 'myfedresmeet'}

//______________________________________________________________________________
var mainEmaSeries: integer;


//====================== ELDER CHANNEL IMPLEMENTATION ==========================
// Elder Channel has been modified to smooth the curve

var elderChannelWidth, elderChannelWidthPercent: integer;
var elderChannelUpperSeries, elderChannelLowerSeries: integer;

//______________________________________________________________________________
// Reads the Elder Channel Deviation Series and returns it
// Note:- Symbol Synchronization must be enabled. Use EnableSync.
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
procedure UpdateDevSeries( lastUpdatedBar, devSeries, period, loopbackmonth, cutoffPercent: integer );
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
    deviation := getElderChannelDeviation( bar, period, loopbackmonth, cutoffPercent );
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
  var period, loopbackmonth, cutoffPercent: integer;
  var modifiedSymbol, dir, fileSuffix: string;

  if( IsDaily ) then
  begin
    period := 22;
    loopbackmonth := 6;
    cutoffPercent := 90;
    modifiedSymbol := GetSymbol + '-CD';
  end
  else
  if( IsWeekly ) then
  begin
    period := 26;
    loopbackmonth := 12;
    cutoffPercent := 90;
    modifiedSymbol := GetSymbol + '-CW';
  end
  else
  begin
    exit;
  end;

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
      var deviation : float = getElderChannelDeviation( BarCount-1, period, loopbackmonth, cutoffPercent );
      devSeries := AddSeriesValue( devSeries, deviation );
    end
    else
    begin
      UpdateDevSeries( lastUpdatedBar, devSeries, period, loopbackmonth, cutoffPercent );
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


//============================== NH-NL IMPLEMENTATION ==========================
// Read NH-NL directly

// Generate NH and NL Series
//
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
procedure ReadNHNLSeries_direct();
begin
  var  fileName : string;

  if ( IsDaily ) then
    fileName := 'D:\WLE\NH-NL-Daily.txt'
  else
    fileName := 'D:\WLE\NH-NL-Weekly.txt';

  var fileHandle: integer = FileOpen( fileName );
  var NHSeries: integer = CreateNamedSeries( 'NewHighSeries_direct' );
  var NLSeries: integer = CreateNamedSeries( 'NewLowSeries_direct' );

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, numHighStr, numLowStr: String;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    numHighStr := GetToken (line, 1, ',');
    numLowStr := GetToken (line, 2, ',');

    try
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NHSeries, StrToFloat(numHighStr));
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NLSeries, StrToFloat(numLowStr));
    except
    end;

  end;
  FileClose (fileHandle);
end;
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function NewHighSeries_direct(): integer;
begin
  var sName: string;
  var value: float;

  Result := FindNamedSeries( 'NewHighSeries_direct' );
  if Result >= 0 then
    exit;
  ReadNHNLSeries_direct();
  Result := FindNamedSeries( 'NewHighSeries_direct' );
end;
//------------------------------------------------------------------------------
function NewHigh_direct( bar, series, period1, period2: integer ): float;
begin
  Result := GetSeriesValue( bar, NewHighSeries_direct() );
end;
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function NewLowSeries_direct(): integer;
begin
  var sName: string;
  var value: float;

  Result := FindNamedSeries( 'NewLowSeries_direct' );
  if Result >= 0 then
    exit;
  ReadNHNLSeries_direct();
  Result := FindNamedSeries( 'NewLowSeries_direct' );
end;
//------------------------------------------------------------------------------
function NewLow_direct( bar, series, period1, period2: integer ): float;
begin
  Result := GetSeriesValue( bar, NewLowSeries_direct() );
end;

//______________________________________________________________________________
// Plot NH and NL Series
//------------------------------------------------------------------------------
procedure plotNHNLSeriesV2( paneSize, plotHisto: integer );
begin
  var NHSeries, NLSeries, NHNLSeries, paneNHNL_Line: integer;
  
  if ( (Not IsDaily) and (Not IsWeekly) ) then
    exit;

  NHSeries := NewHighSeries_direct();
  NLSeries := NewLowSeries_direct();

  paneNHNL_Line := CreatePane( paneSize, false, false);
  SetPaneMinMax( paneNHNL_Line, 0, 800 );

  // First FedResMeet, then other indicators
  PlotSeriesLabel( getFedResMeetSeries(), paneNHNL_Line, #Blue, #Histogram, 'Fed. Res. Meet' );

  DrawHorzLine (0, paneNHNL_Line, 779, #Thin);
  if ( IsDaily ) then
  begin
    DrawHorzLine (300, paneNHNL_Line, 779, #Thin);
    DrawHorzLine (600, paneNHNL_Line, 779, #Thin);
  end
  else
    DrawHorzLine (600, paneNHNL_Line, 779, #Thin);
    DrawHorzLine (1200, paneNHNL_Line, 779, #Thin);
  begin
  end;
  PlotSeriesLabel( NHSeries,  paneNHNL_Line, #Green, #Thin, 'Number of 52-week High' );
  PlotSeriesLabel( NLSeries,  paneNHNL_Line, #Red, #Thin, 'Number of 52-week Low' );

  if( plotHisto = 1 ) then
  begin
    var paneNHNL_Hist: integer = CreatePane( paneSize, false, false );
    SetPaneMinMax( paneNHNL_Line, -300, 800 );
    NHNLSeries := SubtractSeries( NHSeries, NLSeries );

    DrawHorzLine (0, paneNHNL_Hist, #Olive, #Thin);
    DrawHorzLine (300, paneNHNL_Hist, 887, #Thin);
    DrawHorzLine (600, paneNHNL_Hist, 887, #Thin);
    DrawHorzLine (-300, paneNHNL_Hist, 887, #Thin);
    PlotSeriesLabel( NHNLSeries, paneNHNL_Hist, #Black, #Histogram, '52-week NHNL Index' );
  end;
end;
//______________________________________________________________________________
// Plot NH and NL Series
//------------------------------------------------------------------------------
procedure plotNHNLSeries();
begin
  plotNHNLSeriesV2( 60, 0 );
end;
//______________________________________________________________________________


//====================== SPECIFIC TO THIS CHARTSCRIPT ==========================


//______________________________________________________________________________
//
//------------------------------------------------------------------------------
procedure FixSeriesEarlyBars( Series: integer );
begin
  var bar, nonZeroBar: integer;

  for nonZeroBar := 0 to BarCount - 1 do
  begin
    if( @Series[nonZeroBar] <> 0 ) then
      break;
  end;
  
  for bar := 0 to nonZeroBar - 1 do
    @Series[bar] := @Series[nonZeroBar];
    
end;


//______________________________________________________________________________
//______________________________________________________________________________

HideVolume;
VolumeColor ();
PlotVolume( 50 );

var ema11: integer = EMASeries (#close, 11);
var ema22: integer = EMASeries (#close, 22);
FixSeriesEarlyBars( ema11 );
FixSeriesEarlyBars( ema22 );
mainEmaSeries := SMASeries ( ema22, 5);

try
    DisplayPercentChangeForLast5Bars ();
    PlotSeries ( ema11, 0, 777, #thin);
    PlotSeries ( mainEmaSeries, 0, #Maroon, #thin);

    if ( IsIntraDay () or IsMonthly ) then
        PlotElderChannelOnTheFly( 22, 6, 90 )
    else
        PlotElderChannelFromSavedDev();

    PlotMACD( true );
    PlotNHNLSeriesV2( 40, 0 );
    PrintPosition ();

    PlotStochastic (7, 30, 70);
except
  on e: Exception do
  DrawText( 'Exception occured: ' + e.Message, 0, 300, 50, #Red, 16 );
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );


MyDrawLabel( '(OHLC) = '
          + FormatFloat( '0.00', PriceOpen(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceHigh(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceLow(BarCount-1) ) + ', '
          + FormatFloat( '0.00', PriceClose(BarCount-1) ), 036 );




// For saving image
//SaveChart();
//SaveChartWithSize( 1620, 1215 );
//SaveChartImage( 'D:\WLE\Images\' + GetSymbol + '.gif', 1024, 768, 'gif' );


DisplayDay ();

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );




