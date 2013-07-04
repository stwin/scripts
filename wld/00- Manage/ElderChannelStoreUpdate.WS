{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
{$I 'myScreenCommon'}

var notProcessed : TList = TList.Create;

//______________________________________________________________________________
// Returns the last bar in the Elder Channel Deviation file
//
function getLastBarInDev( var fileHandle: integer ): integer;
begin
  var countLines, lastUpdatedBar: integer;
  var lastLine: String;

  countLines := 0;
  lastUpdatedBar := -1;

  while not FileEOF (fileHandle) do
  begin
    countLines := countLines + 1;
    lastLine := FileRead (fileHandle);
  end;

  if( countLines = 0 ) then
    lastUpdatedBar := -1
  else
  begin
    try
      var date : integer = StrToDate( GetToken( lastLine, 0, ',' ) );
      lastUpdatedBar := DateToBar( date );

      // Exit when inconsistency is discovered
      if( lastUpdatedBar = -1 ) then
      begin
        //PlaySound( 'D:\WL\WLD30\Alert1.wav' );
        //ShowMessage( 'Exiting: There is a problem: lastUpdatedBar = -1 even '
         //           + 'though there is valid data in the file. ' +
        //            #10#13 + 'line=' + lastLine + '== (Symbol = '
        //            + GetSymbol + ')' );
        //abort;
        notProcessed.Add( GetSymbol );
        Print( GetSymbol );
        Result := -2;
        exit;
      end;
      
      // Verify that the stored last date is earlier than the date of the last bar
      if( date > GetDate( BarCount-1 ) ) then
      begin
        ShowMessage( 'Exiting: There is a problem: ' + IntToStr(date) + ' > '
                    + IntToStr( GetDate( BarCount-1 ) )
                    + ' (Symbol = ' + GetSymbol + ')' );
        abort;
      end;
      
    except
      ShowMessage( 'Exiting: There is a problem: lastLine = ' + lastLine
                    + ' (Symbol = ' + GetSymbol + ')' );
      abort;
    end;
  end;
  Result := lastUpdatedBar;
end;
//______________________________________________________________________________
// Calculates new Elder Channel Deviation values
//
procedure CalculateNewDevValues( lastUpdatedBar, devSeries, period, loopbackbars, cutoffPercent: integer );
begin
  var watchListNum, startBar: integer;

  startBar := lastUpdatedBar+1;

  var bar: integer;
  for bar := startBar to BarCount-1 do
  begin
    var deviation: float;
    deviation := getElderChDeviation( bar, period, loopbackbars, cutoffPercent );
    //Print( 'deviation  = ' + FloatToStr( deviation ));   PrintFlush;
    @DevSeries[ bar ] := deviation ;
  end;
end;
//______________________________________________________________________________
//  Write the new Elder Channel Deviations to the file
//
procedure WriteNewDevValues( fileHandle: integer; lastUpdatedBar, devSeries: integer );
begin
  var bar: integer;
  for bar := lastUpdatedBar+1 to BarCount-1 do
  begin
    var date: integer;
    date := GetYear(bar) * 10000 + GetMonth(bar) * 100 + GetDay(bar);
    FileWrite( fileHandle, DateToStr( date )
                + ',' + FloatToStr( @devSeries[bar] ) );
  end;
end;
//______________________________________________________________________________
//  Update Elder Channel Deviation file
//
procedure updateElderChannelDatabase( dir, symSuffix: string;
                            period, loopbackbars, cutoffPercent: integer );
begin
  var watchListNum: integer = 0;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries ( WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    var fileName: string = dir + '\' + GetSymbol + symSuffix + '.txt';
    var lastUpdatedBar: integer;
    var fileHandle: integer;

    fileHandle := FileOpen( fileName );

    // Do not use ReadDevSeries of mycommon, that requires EnableSync to be true
    lastUpdatedBar := getLastBarInDev( fileHandle );
    
    if( lastUpdatedBar = -2 ) then
      continue;
    
    if( lastUpdatedBar <> BarCount-1 ) then
    begin
      var devSeries: integer = CreateSeries ();
      CalculateNewDevValues( lastUpdatedBar, devSeries, period, loopbackbars, cutoffPercent );
      WriteNewDevValues( fileHandle, lastUpdatedBar, devSeries );
      ClearIndicators();
    end;
    FileClose( fileHandle );
  end;
  RestorePrimarySeries;
end;

//______________________________________________________________________________
//______________________________________________________________________________


if( IsDaily ) then
begin
  updateElderChannelDatabase( 'D:\WLE\ChannelDaily', '-CD', 22, 132, 90 );
end;

if( IsWeekly ) then
begin
  updateElderChannelDatabase( 'D:\WLE\ChannelWeekly', '-CW', 22, 132, 90 );
end;

var iter: integer;
var sym, symList: string;
symList := '';
for iter := 0 to notProcessed.Count - 1 do
begin
  sym := notProcessed.Item( iter );
  symList := symList + ' | ' + sym;
  Print( sym );
end;
Print( symList );  PrintFlush;

PlaySound( 'D:\WL\WLD30\Alert1.wav' );
ShowMessage( 'Following symbols could not be processed. '
              + #10 + #13 + symList );


