{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( true );
ChangeScale( #Daily );
///////////////////////////////////////////////////////////////////////////////
function ReadUpDownSeries (fileName: string; UpSeries, DownSeries: integer): integer;
begin
  var fileHandle, lastUpdatedBar: integer;

  lastUpdatedBar := -1;
  fileHandle := FileOpen (fileName);

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, numUpStr, numDownStr: String;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    numUpStr := GetToken (line, 1, ',');
    numDownStr := GetToken (line, 2, ',');
    lastUpdatedBar := DateToBar(StrToDate(dateStr));

    try
      SetSeriesValue (lastUpdatedBar, UpSeries, StrToFloat(numUpStr));
      SetSeriesValue (lastUpdatedBar, DownSeries, StrToFloat(numDownStr));
    except
    end;

  end;
  FileClose (fileHandle);
  if( lastUpdatedBar < 0 ) then
    lastUpdatedBar := -1;
  Result := lastUpdatedBar;
end;

///////////////////////////////////////////////////////////////////////////////
procedure UpdateUpDownSeries( lastUpdatedBar, UpSeries, DownSeries: integer );
begin
  var watchListNum, startBar: integer;

  startBar := lastUpdatedBar+1;
  if (startBar < 1) then
    startBar := 1;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    var bar: integer;
    for bar := startBar to BarCount-1 do
    begin
      //if( Volume(bar) < 60000 ) then
      //  continue;
      //if( PriceClose(bar) < 6 ) then
      //  continue;
      if( PriceClose(bar) > PriceClose(bar-1) ) then
        @UpSeries[ bar ] := @UpSeries[ bar ] + 1 ;
      if( PriceClose(bar) < PriceClose(bar-1) ) then
        @DownSeries[ bar ] := @DownSeries[ bar ] + 1;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure WriteUpDownSeries( fileName: string; lastUpdatedBar, UpSeries, DownSeries: integer );
begin
  var fileHandle, bar: integer;
  fileHandle := FileOpen (fileName);
  for bar := lastUpdatedBar+1 to BarCount-1 do
  begin
    var date: integer;
    date := GetYear(bar) * 10000 + GetMonth(bar) * 100 + GetDay(bar);
    FileWrite( fileHandle, DateToStr( date )
                + ',' + IntToStr( Trunc( GetSeriesValue( bar, UpSeries) ) )
                + ',' + IntToStr( Trunc( GetSeriesValue( bar, DownSeries) ) ) );
  end;
  FileClose( fileHandle );
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Main Program
var fileName: string;
var UpSeries, DownSeries, UpDownDiffSeries, paneUpDownLine, paneUpDownHist: integer;
var lastUpdatedBar: integer;

fileName := 'D:\WL\Up-Down.txt';

UpSeries := CreateSeries ();
DownSeries := CreateSeries ();

lastUpdatedBar := ReadUpDownSeries (fileName, UpSeries, DownSeries);

if( lastUpdatedBar <> BarCount-1 ) then
begin
  UpdateUpDownSeries( lastUpdatedBar, UpSeries, DownSeries );
  WriteUpDownSeries( fileName, lastUpdatedBar, UpSeries, DownSeries );
  //var date1: integer = GetYear(lastUpdatedBar+1) * 10000 + GetMonth(lastUpdatedBar+1) * 100 + GetDay(lastUpdatedBar+1);
  //var date2: integer = GetYear(BarCount-1) * 10000 + GetMonth(BarCount-1) * 100 + GetDay(BarCount-1);
  //PrintStatus( 'Updated: ' + DateToStr( date1 ) + ' to ' + DateToStr( date2 ) );
end;

UpDownDiffSeries := SubtractSeries( UpSeries, DownSeries );
paneUpDownLine := CreatePane( 100, false, false);
paneUpDownHist := CreatePane( 100, false, false );

PlotSeriesLabel( UpSeries , paneUpDownLine, #Green, #Thin, 'Number of Ups' );
PlotSeriesLabel( DownSeries , paneUpDownLine, #Red, #Thin, 'Number of Downs' );

DrawHorzLine (0, paneUpDownHist, #Olive, #Thin);
PlotSeriesLabel( UpDownDiffSeries, paneUpDownHist, #Black, #Histogram, 'Net Ups' );



