{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
//
//             S T O C K C H E C K U P   L I B R A R Y
//______________________________________________________________________________

var __stockCheckupDir: string = 'I:\IBD\IbdCheckup-current\Ascii';
var __stockCheckupCurrentSymbol: string = '';

var __overallRating, __attractivenessRating: integer;
var __technicalRating, __groupsTechnicalRating: integer;
var __fundamentalRating, __groupsFundamentalRating: integer;

//Stock,Valueclick Inc
//CurrentPrice,$16.88
//Exchange,NMS
//IndustryGroup,Internet-E Commerce
//OverallRating,99
//TechnicalRating,97
//GroupsTechnicalRating,79
//FundamentalRating,95
//GroupsFundamentalRating,83
//AttractivenessRating,98

//______________________________________________________________________________
//
procedure stockCheckupInit();
begin
  if( __stockCheckupCurrentSymbol = GetSymbol ) then
    exit;
  
  var fileHandle: integer;
  var fileName: string;

  __overallRating           := 0;
  __attractivenessRating    := 0;
  __technicalRating         := 0;
  __groupsTechnicalRating   := 0;
  __fundamentalRating       := 0;
  __groupsFundamentalRating := 0;

  fileName := __stockCheckupDir + '\' + GetSymbol + '.csv';

  fileHandle := FileOpen (fileName);

  while not FileEOF (fileHandle) do
  begin
    var line, key, valueStr: String;

    line := FileRead (fileHandle);
    if( line = '' ) then
      break;
    key := GetToken (line, 0, ',');
    if( key = '' ) then
      break;
    valueStr := GetToken( line, 1, ',' );
    valueStr := Trim( valueStr );

    if( key = 'OverallRating' ) then
      __overallRating  := StrToInt( valueStr )
    else if ( key = 'TechnicalRating' ) then
      __technicalRating := StrToInt( valueStr )
    else if ( key = 'GroupsTechnicalRating' ) then
      __groupsTechnicalRating := StrToInt( valueStr )
    else if ( key = 'FundamentalRating' ) then
      __fundamentalRating := StrToInt( valueStr )
    else if ( key = 'GroupsFundamentalRating' ) then
      __groupsFundamentalRating := StrToInt( valueStr )
    else if ( key = 'AttractivenessRating' ) then
      __attractivenessRating := StrToInt( valueStr );

  end;
  FileClose (fileHandle);

  __stockCheckupCurrentSymbol := GetSymbol;
end;
//______________________________________________________________________________
//
function OverallRating: integer;
begin
  stockCheckupInit();
  Result := __overallRating;
end;
//______________________________________________________________________________
//
function TechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __technicalRating;
end;
//______________________________________________________________________________
//
function GroupsTechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsTechnicalRating;
end;
//______________________________________________________________________________
//
function FundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __fundamentalRating;
end;
//______________________________________________________________________________
//
function GroupsFundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsFundamentalRating;
end;
//______________________________________________________________________________
//
function AttractivenessRating: integer;
begin
  stockCheckupInit();
  Result := __attractivenessRating;
end;
//______________________________________________________________________________
//
procedure printInfo();
begin
  Print( 'OverallRating = ' + IntToStr( OverallRating ) );
  Print( 'TechnicalRating = ' + IntToStr( TechnicalRating ) );
  Print( 'GroupsTechnicalRating = ' + IntToStr( GroupsTechnicalRating ) );
  Print( 'FundamentalRating = ' + IntToStr( FundamentalRating ) );
  Print( 'GroupsFundamentalRating = ' + IntToStr( GroupsFundamentalRating ) );
  Print( 'AttractivenessRating = ' + IntToStr( AttractivenessRating ) );
end;
//______________________________________________________________________________
//______________________________________________________________________________
//
procedure getFundamentals(var marketCap: float; var sharesOut: float);
begin
  var fileHandle: integer;
  var line, marketCapStr, sharesOutStr: string;

  fileHandle := FileOpen( 'D:\WL\fundamentals\combinedstats\' + GetSymbol + '.csv' );
  if( FileEOF( fileHandle ) ) then
  begin
    marketCap := 0;
    sharesOut := 0;
    exit;
  end;

  //MarketCapitalization,7.4B
  //SharesOutstanding,137M

  line := FileRead (fileHandle);
  marketCapStr := GetToken( line, 1, ',' );

  line := FileRead (fileHandle);
  sharesOutStr := GetToken( line, 1, ',' );

  FileClose( fileHandle );
  //Print( marketCapStr + '  ' + sharesOutStr );
  var n: integer;
  n := Pos( 'B', marketCapStr );
  if( n = 0 ) then
  begin
    marketCap := StrToFloat( Copy( marketCapStr, 0, Length( marketCapStr )-1 ) );
  end
  else
  begin
    marketCap := 1000 * StrToFloat( Copy( marketCapStr, 0, Length( marketCapStr )-1 ) );
  end;
  
  n := Pos( 'B', sharesOutStr );
  if( n = 0 ) then
  begin
    sharesOut := StrToFloat( Copy( sharesOutStr, 0, Length( sharesOutStr )-1 ) );
  end
  else
  begin
    sharesOut := 1000 * StrToFloat( Copy( sharesOutStr, 0, Length( sharesOutStr )-1 ) );
  end
end;
//
//______________________________________________________________________________
//
procedure PrintRatingsForWatchlist();
begin
  if (Not IsDaily) then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  var watchListNum: integer;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    var marCap, sharesOut: float;
    getFundamentals( marCap, sharesOut );

    Print( GetSymbol
        + ',' + FormatFloat( '0.##', PriceClose( BarCount-1 ) )
        + ',' + FormatFloat( '0.##', Volume( BarCount-1 ) )
        + ',' + FormatFloat( '0.##', marCap )
        + ',' + FormatFloat( '0.##', sharesOut )
        + ',' + IntToStr( FundamentalRating )
        + ',' + IntToStr( TechnicalRating )
        + ',' + IntToStr( GroupsTechnicalRating )
        + ',' + IntToStr( GroupsFundamentalRating )
        + ',' + IntToStr( AttractivenessRating )
        + ',' + IntToStr( OverallRating ) );

    //PrintFlush;
  end;
end;


//______________________________________________________________________________
//______________________________________________________________________________
//
// Main Program

//printInfo();

PrintRatingsForWatchlist();



