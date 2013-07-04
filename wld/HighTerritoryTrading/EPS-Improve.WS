{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
//HideVolume;
{$I 'MACDEx'}
//Print (''); // Clear the debug window

///////////////////////////////////////////////////////////////////////////////
////////////// S T O C K C H E C K U P   L I B R A R Y ////////////////////////
///////////////////////////////////////////////////////////////////////////////

var __stockCheckupDir: string = 'I:\IBD\IbdCheckup-2005-11\Ascii';
var __stockCheckupCurrentSymbol: string = '';

var __overallRating, __attractivenessRating: integer;
var __technicalRating, __groupsTechnicalRating: integer;
var __fundamentalRating, __groupsFundamentalRating: integer;
var __EPS: integer;

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
//EarningsPerShare(EPS)Rating,31
//RelativePriceStrength(RS)Rating,28
//IndustryGroupRelativeStrength(GrpRS)Rating,A+
//Sales+ProfitMargins+ROE(SMR)Rating,C
//Accumulation/Distribution(Acc/Dis)Rating,B

///////////////////////////////////////////////////////////////////////////////
procedure stockCheckupInit( symbol: string );
begin
  if( __stockCheckupCurrentSymbol = symbol ) then
    exit;

  var fileHandle: integer;
  var fileName: string;

  __overallRating           := 0;
  __attractivenessRating    := 0;
  __technicalRating         := 0;
  __groupsTechnicalRating   := 0;
  __fundamentalRating       := 0;
  __groupsFundamentalRating := 0;
  __EPS := 0;

  fileName := __stockCheckupDir + '\' + symbol + '.csv';

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
      __attractivenessRating := StrToInt( valueStr )
    else if ( key = 'EarningsPerShare(EPS)Rating' ) then
      __EPS := StrToInt( valueStr );

  end;
  FileClose (fileHandle);

  __stockCheckupCurrentSymbol := symbol;
end;
///////////////////////////////////////////////////////////////////////////////
function fundamentalImproveScore( symbol: string) : integer;
begin
  var fr1, fr2, eps1, eps2: integer;
  
  __stockCheckupDir := 'I:\IBD\IbdCheckup-2005-11\Ascii';
  __stockCheckupCurrentSymbol := '';
  stockCheckupInit( symbol );
  fr1 := __fundamentalRating;
  eps1 := __EPS;

  __stockCheckupDir := 'I:\IBD\IbdCheckup-2005-12\Ascii';
  __stockCheckupCurrentSymbol := '';
  stockCheckupInit( symbol );
  fr2 := __fundamentalRating;
  eps2 := __EPS;

  __stockCheckupCurrentSymbol := '';
  Result := fr2 - fr1 + eps2 - eps1;
  if( (fr1 = 0)  or (eps1 = 0) ) then
    Result := 0;
end;
///////////////////////////////////////////////////////////////////////////////
//////////// S T O C K C H E C K U P   L I B R A R Y   E N D S ////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

      ///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure ScanForFundaImprove();
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
      var symbol : string = WatchListSymbol( watchListNum );
      var score : integer = fundamentalImproveScore( symbol );
      if( score > 5 ) then
      begin
        Print( symbol + #9 + IntToStr( score ) );
        //PrintFlush;
      end;
    except
      continue;
    end;
  end;
end;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

//printInfo();

ScanForFundaImprove();




