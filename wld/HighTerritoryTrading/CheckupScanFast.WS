{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

var MyGetSymbol: string;

///////////////////////////////////////////////////////////////////////////////
////////////// S T O C K C H E C K U P   L I B R A R Y ////////////////////////
///////////////////////////////////////////////////////////////////////////////

var __stockCheckupDir: string = 'I:\IBD\IbdCheckup-2005-11\Ascii';
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

///////////////////////////////////////////////////////////////////////////////
procedure stockCheckupInit();
begin
  if( __stockCheckupCurrentSymbol = MyGetSymbol ) then
    exit;
  
  var fileHandle: integer;
  var fileName: string;

  __overallRating           := 0;
  __attractivenessRating    := 0;
  __technicalRating         := 0;
  __groupsTechnicalRating   := 0;
  __fundamentalRating       := 0;
  __groupsFundamentalRating := 0;

  fileName := __stockCheckupDir + '\' + MyGetSymbol + '.csv';

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

  __stockCheckupCurrentSymbol := MyGetSymbol;
end;
///////////////////////////////////////////////////////////////////////////////
function OverallRating: integer;
begin
  stockCheckupInit();
  Result := __overallRating;
end;
///////////////////////////////////////////////////////////////////////////////
function TechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __technicalRating;
end;
///////////////////////////////////////////////////////////////////////////////
function GroupsTechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsTechnicalRating;
end;
///////////////////////////////////////////////////////////////////////////////
function FundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __fundamentalRating;
end;
///////////////////////////////////////////////////////////////////////////////
function GroupsFundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsFundamentalRating;
end;
///////////////////////////////////////////////////////////////////////////////
function AttractivenessRating: integer;
begin
  stockCheckupInit();
  Result := __attractivenessRating;
end;
///////////////////////////////////////////////////////////////////////////////
procedure printInfo();
begin
  Print( 'OverallRating = ' + IntToStr( OverallRating ) );
  Print( 'TechnicalRating = ' + IntToStr( TechnicalRating ) );
  Print( 'GroupsTechnicalRating = ' + IntToStr( GroupsTechnicalRating ) );
  Print( 'FundamentalRating = ' + IntToStr( FundamentalRating ) );
  Print( 'GroupsFundamentalRating = ' + IntToStr( GroupsFundamentalRating ) );
  Print( 'AttractivenessRating = ' + IntToStr( AttractivenessRating ) );
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
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
    MyGetSymbol := WatchListSymbol (watchListNum);
    
    if( true
      //and ( TechnicalRating > 90 )
      and ( FundamentalRating > 80 )
      ) then
    Print( MyGetSymbol
        //+ #9 + IntToStr( TechnicalRating )
        + #9 + IntToStr( FundamentalRating ) );
{    Print( MyGetSymbol
        + ',' + IntToStr( TechnicalRating )
        + ',' + IntToStr( FundamentalRating )
        + ',' + IntToStr( GroupsTechnicalRating )
        + ',' + IntToStr( GroupsFundamentalRating )
        + ',' + IntToStr( AttractivenessRating )
        + ',' + IntToStr( OverallRating ) ); }
    //PrintFlush;
  end;
end;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

MyGetSymbol := GetSymbol;

//printInfo();

PrintRatingsForWatchlist();


