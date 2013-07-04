WatchListSelect( 'Indexes-SP500' );

//==============================================================================
// Initialize CSharp Script
//REM: var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
//REM: var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\Everything.cs' );
//REM: if ( AsString(myclass) = '' ) then Abort;
//REM: myclass.EverythingInit( IWealthLabAddOn3 );
//==============================================================================

var equitySeries: integer;
var virtualEquitySeries: integer;
var investSeries: integer;
var depositSeries: integer;
var equitySeriesColor: integer = 575;
///var equitySeriesColor: integer = 054;
var virtualEquitySeriesColor: integer = 054;

//______________________________________________________________________________
procedure MarkMondays (Series, color: integer);
begin
  var bar: integer;

  for bar := 0 to BarCount-1 do
  begin
    if (GetSeriesValue (bar, Series) <> 0) then
      break;
  end;

  for bar := bar to BarCount-1 do
  begin
    if (DayOfWeek (bar) = #Monday) then
      SetSeriesBarColor (bar, Series, color);
  end;
end;
//______________________________________________________________________________
procedure PlotChangeAsHisto( paneSize, series: integer; upColor, downColor: integer);
begin
  var equityChangePane, newSeries, monthlyGainSeries: integer;
  var bar: integer;

  equityChangePane := CreatePane (paneSize, false, true);
  newSeries := CreateNamedSeries( 'EquityChange' );
  monthlyGainSeries := CreateNamedSeries( 'MonthlyGain' );

  for bar := 0 to BarCount-1 do
  begin
    if (GetSeriesValue (bar, Series) <> 0) then
      break;
  end;

  var monthlyGain: float = 0;
  for bar := bar+1 to BarCount-1 do
  begin
    if (GetMonth(bar) <> GetMonth(bar-1)) then
      monthlyGain := 0;
    var change: float;
    change := GetSeriesValue(bar, series) - GetSeriesValue(bar-1, series);
    monthlyGain := monthlyGain + change;
    SetSeriesValue (bar, monthlyGainSeries, monthlyGain);
    SetSeriesValue (bar, newSeries, change);
    //if (change > 0) then
    //  SetSeriesBarColor (bar, newSeries, upColor)
    //else
    //  SetSeriesBarColor (bar, newSeries, downColor);
    if (monthlyGain > 0) then
      SetSeriesBarColor (bar, monthlyGainSeries, 696)
    else
      SetSeriesBarColor (bar, monthlyGainSeries, 966);
  end;

  DrawHorzLine (0, equityChangePane, #Olive, #Thin);
  PlotSeries (monthlyGainSeries, equityChangePane, #Blue, #ThickHist);
  PlotSeries (newSeries, equityChangePane, 000, #Histogram);
  DrawLabel ('Change In Equity', equityChangePane);

  for Bar := 0 to BarCount - 1 do
  begin
    //SetPaneBackgroundColor( Bar, equityChangePane, 988 );
  end;

end;

//______________________________________________________________________________
procedure colorTradingPhases();
begin
  var file: integer;
  var FileName: String = 'D:\WL\Manage\Phases.csv';
  if( not isDaily ) then
    exit;

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line: String;
    var barStart, barEnd, color: integer;
    var bar: integer;

    //20050725,20050809,977,Swing-RiskMgmt
    line := FileRead (file);
    barStart := DateToBar( StrToInt( GetToken (line, 0, ',') ) );
    barEnd := DateToBar( StrToInt( GetToken (line, 1, ',') ) );
    color := StrToInt( GetToken (line, 2, ','));

    for bar := barStart to barEnd do
    begin
      //SetBackgroundColor( bar, color );
      SetPaneBackgroundColor( Bar, 2, color );
    end;
  end;
  FileClose (file);
end;
//______________________________________________________________________________
function readEquitySeries (FileName: String): integer;
begin
  var file: integer;
  var EquitySeries: integer;
  var cumuDeposit: float = 0;
  var initialInvest: float = 31500;
  var bar, lastValidBar: integer;

  EquitySeries := CreateSeries();
  investSeries := CreateSeries();
  depositSeries := CreateSeries();

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, dateStr, equityStr: String;
    var equityVal : float;
    var deposit: float;


    line := FileRead (file);
    dateStr := GetToken (line, 0, ',');
    bar := DateToBar(StrToDate(dateStr));
    if (bar <> -1) then
    begin
      equityStr := GetToken (line, 1, ',');
      equityVal := StrToFloat (equityStr);
      try
        deposit := StrToFloat( GetToken( line, 2, ',' ) );
        if( Abs(deposit) < 0.1 ) then
        begin
          deposit := 0; // Not to be displayed
        end
        else
        begin
          cumuDeposit := cumuDeposit + deposit;
          SetSeriesValue(bar, depositSeries, deposit);
        end;
      except
      end;

      SetSeriesValue(bar, EquitySeries, equityVal);
      SetSeriesValue(bar, investSeries, initialInvest+cumuDeposit );
      lastValidBar := bar;
    end;
  end;
  FileClose (file);

  // fill the gaps
  var lastEquityVal: float = 0;
  for bar := 0 to BarCount-1 do
  begin
    if (@EquitySeries[bar] <> 0) then
      lastEquityVal := @EquitySeries[bar]
    else
      @EquitySeries[bar] := lastEquityVal;
  end;

  // Get virtual equity series
  virtualEquitySeries := CreateSeries();
  var virtualCumuDeposit : float = 0;
  for bar := BarCount-1 downto 0 do
  begin
    @virtualEquitySeries[bar] := @EquitySeries[bar] + virtualCumuDeposit;
    virtualCumuDeposit := virtualCumuDeposit + @depositSeries[bar];
    //Print(DateToStr( GetDate( Bar ) ) + '        ' + FloatToStr( virtualCumuDeposit ) + '        ' + FloatToStr(@depositSeries[bar]));
  end;

  Result := EquitySeries;
end;
//______________________________________________________________________________
procedure adjustPastBars();
begin
  var bar, beginBar: integer;
  for bar := 0 to BarCount-1 do
  begin
    if( @equitySeries[bar] <> 0 ) then
      break;
  end;
  beginBar := bar;
  for bar := 0 to beginBar-1 do
  begin
    @virtualEquitySeries[bar] := @virtualEquitySeries[beginBar] - 1;
    @equitySeries[bar] := @equitySeries[beginBar] - 1;
    SetSeriesBarColor( bar, virtualEquitySeries, -1 );
    SetSeriesBarColor( bar, equitySeries, -1 );
  end;
  for bar := beginBar to BarCount-1 do
  begin
    SetSeriesBarColor( bar, virtualEquitySeries, virtualEquitySeriesColor );
    SetSeriesBarColor( bar, equitySeries, equitySeriesColor );
  end;
end;
//______________________________________________________________________________
procedure MarkDeposits( equitySeries, pane: integer );
begin
  var bar: integer;

  for bar := 0 to BarCount-1 do
  begin
    if( @depositSeries[bar] <> 0 ) then
    begin
      DrawImage( 'DownArrow', pane, bar, @equitySeries[bar]+500, true);
      AnnotateChart( FloatToStr(@depositSeries[bar]), pane, bar, @equitySeries[bar]+1000, 009, 8 );
    end;
  end;
end;
//______________________________________________________________________________
// The EMA series starts at 1st nonZero Bar.
//------------------------------------------------------------------------------
function BetterEMASeries( Series, period: integer ): integer;
begin
  var MA, bar: integer;
  var C: float;

  MA := CreateSeries();
  C := 2/(1+period);

  for bar := 0 to BarCount-1 do
  begin
    if( @Series[bar] <> 0) then
      break;
  end;
  
  if ( bar = BarCount ) then
  begin
    Result := MA;
    exit;
  end;

  @MA[bar] := @Series[bar];

  for bar := bar+1 to BarCount-1 do
  begin
    @MA[bar] := C * @Series[bar] + (1-C) * @MA[bar-1];
  end;
  Result := MA;
end;
//______________________________________________________________________________
//______________________________________________________________________________
HideVolume;

var FileName: String;
//REM: if( myclass.GetBoolParam('TrainingMode') ) then
//REM:   fileName := myclass.GetRootDir() + '\docs\Training07\Rec_Equity.csv'
  var rootDir: String;
  rootDir := 'C:\ST\WLE';
  fileName := rootDir + '\Manage\EquityCurve.csv';
//REM: else
//REM:   fileName := myclass.GetRootDir() + '\docs\Trading\Rec_Equity.csv';

var EquityPane: integer;


equitySeries := readEquitySeries (FileName);
//adjustPastBars( );

PlotChangeAsHisto (100, virtualEquitySeries, #Green, #Red);

EquityPane := CreatePane (600, false, true);
//SetPaneMinMax (EquityPane, 29000, 100000);
//SetPaneMinMax (EquityPane, 0, 50000);

// Plot as thick histogram
DrawText ('Equity Curve', EquityPane, 7, 2, #Green, 12);
//REM: DrawText ( DateToStr(GetDate(BarCount-1)) + ' ' + myclass.GetDayStr(BarCount-1), EquityPane, 7, 22, #Black, 10);

PlotSeries( virtualEquitySeries, EquityPane, virtualEquitySeriesColor, #ThickHist);
//PlotSeries( virtualEquitySeries, EquityPane, virtualEquitySeriesColor, #Thin );
//PlotArea( virtualEquitySeries, EquityPane, virtualEquitySeriesColor, 030 );

// Draw min and max lines
var minSeries: integer = CreateSeries;
var maxSeries: integer = CreateSeries;
var ii: integer;
for ii := 0 to BarCount-1 do
begin
   @minSeries[ii] := 0.01;
   @maxSeries[ii] := 50000;
end;
PlotSeries( minSeries, EquityPane, 700, #Thin );
PlotSeries( maxSeries, EquityPane, 700, #Thin );


//PlotSeries( EquitySeries, EquityPane, equitySeriesColor, #ThickHist );
//PlotSeries( EquitySeries, EquityPane, equitySeriesColor, #Thin );
//PlotArea( EquitySeries, EquityPane, equitySeriesColor, equitySeriesColor );


//MarkDeposits( EquitySeries, EquityPane );

//MarkMondays (EquitySeries, 141);
//MarkMondays (virtualEquitySeries, 141);

//PlotSeries( investSeries, EquityPane, 009, #Thick );

// Plot a moving average
var period: integer = 22;
DrawText ('Moving Average (' + IntToStr(period) +')', EquityPane, 5, 37, #Blue, 9);
PlotSeries (BetterEMASeries (virtualEquitySeries, period), EquityPane, #Blue, #Thin);


//PlotIndexes ();
//REM: {$I 'myNhNl'}
//REM: PlotNHNLSeriesV2( 100, 0);
//colorTradingPhases();

//DrawHorzLine( 20000, EquityPane, #Olive, #Thin );
//DrawHorzLine( 22500, EquityPane, #Olive, #Thin );
//DrawHorzLine( 25500, EquityPane, #Olive, #Thin );
//DrawHorzLine( 30000, EquityPane, #Olive, #Thin );
//DrawHorzLine( 31500, EquityPane, #Olive, #Thin );
//DrawHorzLine( 35000, EquityPane, #Olive, #Thin );
//DrawHorzLine( 39000, EquityPane, #Olive, #Thin );

//SetColorScheme (999, 999, 222, 777, 666, 005);
// Make the price pane white
var Bar: integer;
for Bar := 0 to BarCount - 1 do
begin
  SetPaneBackgroundColor (Bar, 0, 999);
end;


// Draw some indicators for SP-500
PlotSeries( EMASeries( #Close, 13), 0, 777, #Thin );
PlotSeries( EMASeries( #Close, 26), 0, #Maroon, #Thin );
//PlotElderChOnTheFly( 26, 132, 90 );

//AddFutureBars( 20 );

//SaveChartWithSize( 1700, 1215 );
//SaveChartWithSize( 1024, 876 );

//AddFutureBars( 66 );


