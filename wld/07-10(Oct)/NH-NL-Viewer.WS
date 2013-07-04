{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( true );
                              // TODO NOT COMPLETE
//______________________________________________________________________________
//______________________________________________________________________________

var SeriesHandlers: array[0..19] of integer;
var SeriesHandlersComVariant: ComVariantArray;

// Creat all series required
SeriesHandlers[0] := CreateSeries;  // NHSeries
SeriesHandlers[1] := CreateSeries;  // NLSeries
SeriesHandlers[2] := CreateSeries;  // NHNLSeries

SeriesHandlersComVariant := SeriesHandlers;

// Invoke CSharp Script and calculate all indiciators
var csScripting: ComVariant = CreateOleObject( 'WLExtra.Scripting' );
var compilerRes: integer = csScripting.CompileFile ( 'CsScripts\NH-NL-Viewer.cs' );
if ( compilerRes = -1 ) then
  exit;
Print ( 'CompilerResult = ' + IntToStr(compilerRes) );  PrintFlush;
var instanceId: integer = csScripting.CreateInstance ( 'MyScript.MyClass' );
//csScripting.RunMethod ( instanceId, 'NHNLViewerTest' );
csScripting.RunMethod1 ( instanceId, 'NHNLViewerInit', IWealthLabAddOn3 );
csScripting.RunMethod1 ( instanceId, 'GetAllSeries', SeriesHandlersComVariant );


// Assign some readable names to the indicators
var NHSeries: integer = SeriesHandlers[0];
var NLSeries: integer = SeriesHandlers[1];
var NHNLSeries: integer = SeriesHandlers[1];



//__________________________________________
// Now plot all indicators


var myUtil: ComVariant = CreateOleObject( 'WLExtra.Util' );
var rootDir: string = myUtil.GetRootDir();



//______________________________________________________________________________
// Returns the day of a bar as string
//
function getDayStr( bar: integer ): String;
begin
  var str: String = 'Holiday';
  var dayAsInt: integer = DayOfWeek( bar );
  if( dayAsInt = #Monday ) then
    str := 'Monday'
  else if( dayAsInt = #Tuesday ) then
    str := 'Tuesday'
  else if( dayAsInt = #Wednesday ) then
    str := 'Wednesday'
  else if( dayAsInt = #Thursday ) then
    str := 'Thursday'
  else if( dayAsInt = #Friday ) then
    str := 'Friday';
  Result := str;
end;
///////////////////////////////////////////////////////////////////////////////
procedure SaveChartWithSize( width, height: integer );
begin
  var fileName: String;
  var Bar: integer;
  //PrintStatus( 'SaveChart: First you should zoom in, then print' );
  if (IsDaily) then
  begin
    fileName := GetSymbol + '-daily-' + IntToStr( GetMonth( BarCount-1 ) );
  end
  else if (IsWeekly) then
  begin
    fileName := GetSymbol + '-weekly';
  end
  else begin
    fileName := GetSymbol + '-unknownTimeFrame';
  end;

  SetColorScheme (050, 800, 222, 999, 887, 799);

  fileName :=  rootDir + '\Images\' + fileName + '.bmp';
  SaveChartImage( fileName, width, height, 'BMP' );

  var str: String = getDayStr( BarCount-1 );
  var dateInfo: string = DateToStr( getDate( BarCount-1 ) ) + '  ' + getDayStr( BarCount-1 );

  var image: ComVariant;
  image := CreateOleObject( 'WLExtra.Image' );
  image.Open( fileName );
  image.DrawRectangle( 7, 19, 120, 37, 999, 0, 999 );
  image.DrawText( dateInfo, 7, 19, 0, 10 );
  image.Save( fileName, 'bmp' );
  image.Close();

end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Main Program
var fileName: string;
var paneNHNL_Line, paneNHNL_Hist: integer;
var lastUpdatedBar, tradingDays: integer;

paneNHNL_Line := CreatePane( 100, false, false);
paneNHNL_Hist := CreatePane( 100, false, false );

DrawHorzLine (0, paneNHNL_Line, #Olive, #Thin);
DrawHorzLine (300, paneNHNL_Line, 887, #Thin);
DrawHorzLine (600, paneNHNL_Line, 887, #Thin);
DrawHorzLine (-300, paneNHNL_Line, 887, #Thin);
PlotSeriesLabel( NHSeries , paneNHNL_Line, #Green, #Thin, 'Number of 52-week High' );
PlotSeriesLabel( NLSeries , paneNHNL_Line, #Red, #Thin, 'Number of 52-week Low' );

DrawHorzLine (0, paneNHNL_Hist, #Olive, #Thin);
DrawHorzLine (300, paneNHNL_Hist, 887, #Thin);
DrawHorzLine (600, paneNHNL_Hist, 887, #Thin);
DrawHorzLine (-300, paneNHNL_Hist, 887, #Thin);
PlotSeriesLabel( NHNLSeries, paneNHNL_Hist, 222, #Histogram, '52-week NHNL Index' );
var NHNLSeries2: integer = AddSeriesValue( NHNLSeries, 0 );
PlotSeries( NHNLSeries2, paneNHNL_Hist, 000, #Thin );


HideVolume;


//SaveChartWithSize( 1200, 768 ); // For one year
SaveChartWithSize( 1024, 768 );

