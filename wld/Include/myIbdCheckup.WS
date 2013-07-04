//{$I 'myScreenCommon'}
//______________________________________________________________________________
//              S T O C K C H E C K U P   L I B R A R Y
//______________________________________________________________________________

// Global Variables
var __defaultStockCheckupDir: string = myUtil.GetWlRegistryKey('IbdCheckupCurrent') + '\Ascii';
var __stockCheckupDir: string = __defaultStockCheckupDir;
var __stockCheckupCurrentSymbol: string = '';

var __overallRating, __attractivenessRating: integer;
var __technicalRating, __groupsTechnicalRating: integer;
var __fundamentalRating, __groupsFundamentalRating: integer;
var __EPS: integer;
var __industryGroup: string;

///////--------------------- File Format -------------------
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

//______________________________________________________________________________
// Reads the file and initializes global variables
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
  __EPS := 0;

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
      __attractivenessRating := StrToInt( valueStr )
    else if ( key = 'EarningsPerShare(EPS)Rating' ) then
      __EPS := StrToInt( valueStr )
    else if ( key = 'IndustryGroup' ) then
      __industryGroup := valueStr;

  end;
  FileClose (fileHandle);

  __stockCheckupCurrentSymbol := GetSymbol;
end;
//______________________________________________________________________________
// Update Stock Checkup Dir
//
procedure updateStockCheckupDir( dir: string );
begin
  __stockCheckupDir := dir;
  __stockCheckupCurrentSymbol := '';   // Reset symbol, so that it reads again
end;
//______________________________________________________________________________
// Update Stock Checkup Dir
//
procedure updateStockCheckupDirDefault();
begin
  __stockCheckupDir := __defaultStockCheckupDir;
  __stockCheckupCurrentSymbol := '';   // Reset symbol, so that it reads again
end;
//______________________________________________________________________________
function OverallRating: integer;
begin
  stockCheckupInit();
  Result := __overallRating;
end;
//______________________________________________________________________________
function TechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __technicalRating;
end;
//______________________________________________________________________________
function GroupsTechnicalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsTechnicalRating;
end;
//______________________________________________________________________________
function FundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __fundamentalRating;
end;
//______________________________________________________________________________
function GroupsFundamentalRating: integer;
begin
  stockCheckupInit();
  Result := __groupsFundamentalRating;
end;
//______________________________________________________________________________
function AttractivenessRating: integer;
begin
  stockCheckupInit();
  Result := __attractivenessRating;
end;
//______________________________________________________________________________
function industryGroup: string;
begin
  stockCheckupInit();
  Result := __industryGroup;
end;
//______________________________________________________________________________
function EearningPerShare: integer;
begin
  stockCheckupInit();
  Result := __EPS;
end;
//______________________________________________________________________________
//       S T O C K C H E C K U P   L I B R A R Y   E N D S
//______________________________________________________________________________


//______________________________________________________________________________
procedure DisplaySomeBasicFundamentals();
begin
  var fundamentalRatingStr: String = '';
  var EPSStr: String = '';

  var startYear: integer = 2005;
  var startMonth: integer = 11;
  var endYear: integer = GetYear( BarCount-1 );
  var endMonth: integer = GetMonth( BarCount-1 );
  var currentYear: integer = startYear;
  var currentMonth: integer = startMonth;
  
  while( (currentYear*100+currentMonth) < (endYear*100+endMonth) ) do
  begin
    var dir : string;
    dir := myUtil.GetWlRegistryKey('IbdDir') + '\IbdCheckup-' + IntToStr(currentYear)
          + '-' + FormatFloat('00',currentMonth) + '\Ascii';
    updateStockCheckupDir( dir );
    FundamentalRatingStr := FundamentalRatingStr + ' ' + FormatFloat('00',FundamentalRating() );
    EPSStr := EPSStr + ' ' + FormatFloat('00',EearningPerShare() );
    
    if( currentMonth mod 3 = 0 ) then
    begin
      FundamentalRatingStr := FundamentalRatingStr + '  ';
      EPSStr := EPSStr + '  ';
    end;
    
    if( currentMonth = 12 ) then
    begin
      currentYear := currentYear + 1;
      currentMonth := 1;
    end
    else
    begin
      currentMonth := currentMonth + 1;
    end;
  end;

  updateStockCheckupDirDefault();

  if( FundamentalRatingStr <> '' ) then
    MyDrawLabel ( 'FR: ' + FundamentalRatingStr, #Black);
  if( EPSStr <> '' ) then
    MyDrawLabel ( 'EP: ' + EPSStr, #Black);
end;
//______________________________________________________________________________
//______________________________________________________________________________

//DisplaySomeBasicFundamentals();


