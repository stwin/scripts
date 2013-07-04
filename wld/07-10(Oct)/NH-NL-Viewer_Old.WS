{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( true );
//C hangeScale( #Daily );

var myUtil: ComVariant = CreateOleObject( 'WLExtra.Util' );
var rootDir: string = myUtil.GetRootDir();

///////////////////////////////////////////////////////////////////////////////
function ReadNHNLSeries (fileName: string; NHSeries, NLSeries: integer): integer;
begin
  var fileHandle, lastUpdatedBar: integer;

  lastUpdatedBar := -1;
  fileHandle := FileOpen (fileName);

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, numHighStr, numLowStr: String;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    numHighStr := GetToken (line, 1, ',');
    numLowStr := GetToken (line, 2, ',');
    lastUpdatedBar := DateToBar(StrToDate(dateStr));

    try
      SetSeriesValue (lastUpdatedBar, NHSeries, StrToFloat(numHighStr));
      SetSeriesValue (lastUpdatedBar, NLSeries, StrToFloat(numLowStr));
    except
    end;

  end;
  FileClose (fileHandle);
  if( lastUpdatedBar < 0 ) then
    lastUpdatedBar := -1;
  Result := lastUpdatedBar;
end;

///////////////////////////////////////////////////////////////////////////////
procedure UpdateNHNLSeries( lastUpdatedBar, tradingDays, NHSeries, NLSeries: integer );
begin
  var watchListNum, startBar: integer;

  startBar := lastUpdatedBar+1;
  if (startBar < (tradingDays+1)) then
    startBar := tradingDays+1;

  SingleCalcMode ( true );
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(Trunc(100*IntToStr(watchListNum)/IntToStr(WatchListCount))) +
        '% (' + IntToStr(WatchListCount) + ') ' +  WatchListSymbol (watchListNum));

    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    var bar: integer;
    for bar := startBar to BarCount-1 do
    begin
      if( PriceHigh(bar) > Highest( bar-1, #High, tradingDays ) ) then
        @NHSeries[ bar ] := @NHSeries[ bar ] + 1 ;
      if( PriceLow(bar) < Lowest( bar-1, #Low, tradingDays ) ) then
        @NLSeries[ bar ] := @NLSeries[ bar ] + 1;
    end;
  end;
  SingleCalcMode ( false );
  ClearIndicators;
  RestorePrimarySeries;
end;
///////////////////////////////////////////////////////////////////////////////
procedure WriteNHNLSeries( fileName: string; lastUpdatedBar, NHSeries, NLSeries: integer );
begin
  var fileHandle, bar: integer;
  fileHandle := FileOpen (fileName);
  for bar := lastUpdatedBar+1 to BarCount-1 do
  begin
    var date: integer;
    date := GetYear(bar) * 10000 + GetMonth(bar) * 100 + GetDay(bar);
    FileWrite( fileHandle, DateToStr( date )
                + ',' + IntToStr( Trunc( GetSeriesValue( bar, NHSeries) ) )
                + ',' + IntToStr( Trunc( GetSeriesValue( bar, NLSeries) ) ) );
  end;
  FileClose( fileHandle );
end;
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
var NHSeries, NLSeries, NHNLSeries, paneNHNL_Line, paneNHNL_Hist: integer;
var lastUpdatedBar, tradingDays: integer;

if ( IsDaily ) then
begin
  fileName := rootDir + '\NH-NL-Daily.txt';
  tradingDays := 252;
end
else if ( IsWeekly ) then
begin
  fileName := rootDir + '\NH-NL-Weekly.txt';
  tradingDays := 52;
end
else if ( IsMonthly ) then
begin
  fileName := rootDir + '\NH-NL-Monthly.txt';
  tradingDays := 12;
end
else
  abort;

NHSeries := CreateSeries ();
NLSeries := CreateSeries ();

lastUpdatedBar := ReadNHNLSeries (fileName, NHSeries, NLSeries);

if( lastUpdatedBar <> BarCount-1 ) then
begin
  UpdateNHNLSeries( lastUpdatedBar, tradingDays, NHSeries, NLSeries );
  WriteNHNLSeries( fileName, lastUpdatedBar, NHSeries, NLSeries );
  var date1: integer = GetYear(lastUpdatedBar+1) * 10000 + GetMonth(lastUpdatedBar+1) * 100 + GetDay(lastUpdatedBar+1);
  var date2: integer = GetYear(BarCount-1) * 10000 + GetMonth(BarCount-1) * 100 + GetDay(BarCount-1);
  PrintStatus( 'Updated: ' + DateToStr( date1 ) + ' to ' + DateToStr( date2 ) );
end;

NHNLSeries := SubtractSeries( NHSeries, NLSeries );

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
//SaveChartWithSize( 1024, 768 );

