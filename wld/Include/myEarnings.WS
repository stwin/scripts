//{$I 'myScreenCommon'}
//______________________________________________________________________________
//              E A R N I N G S   L I B R A R Y
//______________________________________________________________________________

// Global Variables
var __defaultEarningsDir: string = rootDir + '\fundamentals\Earnings\earningsBySymbol';
var __aolEarningsDir: string = rootDir + '\fundamentals\Earnings\AolEarning\ascii';

// Variables which will be initialized
var __earnings:       string = '';
var __futureEarnings: string = '';
var __nextEarning:    string = '';
var __pastEarnings:   string = '';
var __lastEarning:    string = '';


//______________________________________________________________________________
procedure __addEarningDatesFromFile( list: TList; fileName: string );
begin
  var fileHandle: integer = FileOpen (fileName);
  var line: string = FileRead (fileHandle);
  FileClose (fileHandle);

  var token: string;
  var count: integer = 0;
  token := GetToken( line, 0, ',' );
  while( token <> '' ) do
  begin
    list.Add( token );
    count := count + 1;
    token := GetToken( line, count, ',' );
  end;
end;
//______________________________________________________________________________
function __readEarnings(): TList;
begin
  var list: TList = TList.Create;
  __addEarningDatesFromFile( list, __defaultEarningsDir + '\' + GetSymbol + '.csv' );
  __addEarningDatesFromFile( list, __aolEarningsDir + '\' + GetSymbol + '.csv' );
  Result := list;
end;
//______________________________________________________________________________
procedure __initEarningsLibrary();
begin
  var num: integer;
  var list: TList;
  var futureEarningsList: TList = TList.Create;
  var pastEarningsList: Tlist = Tlist.Create;
  
  list := __readEarnings();
  for num := 0 to list.Count-1 do
  begin
    var str: string = list.Item( num );
    __earnings := __earnings + str + ' ';
    if( StrToInt( str ) > getDate( BarCount-1 ) ) then
    begin
      futureEarningsList.Add( str );
      __futureEarnings := __futureEarnings + str + ' ';
    end
    else
    begin
      pastEarningsList.Add( str );
      __pastEarnings := __pastEarnings + str + ' ';
    end;
    var bar: integer = DateToBar( StrToInt( str ) );
    if( IsWeekly ) then
      bar := WeeklyBarFromDailyDate( StrToInt( str ) );
    if( bar <> -1 ) then
    begin
      DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
      //DrawImage( 'test', 0, bar, PriceLow(bar)*0.99, true);
      //DrawImage( 'Circle4x4', 0, bar, PriceLow(bar)*0.99, true);
      //DrawCircle(4, 0, bar, PriceLow(bar), #Black, #Thin);
    end;
  end;
  
  // Find __nextEaring and __pastEarning
  if( futureEarningsList.Count <> 0 ) then
  begin
    futureEarningsList.SortNumeric();
    __nextEarning := futureEarningsList.Item(0);
  end;
  if( pastEarningsList.Count <> 0 ) then
  begin
    pastEarningsList.SortNumeric();
    __lastEarning := pastEarningsList.Item( pastEarningsList.Count()-1 );
  end;
  
  // Free Resources
  futureEarningsList.Free();
  pastEarningsList.Free();
  list.Free();
end;
//______________________________________________________________________________
procedure displayEarnings();
begin
  __initEarningsLibrary();

  //if( __earnings <> '' ) then
  //  Print ( 'Earnings: ' + __earnings );

  //if( __futureEarnings <> '' ) then
  //  MyDrawLabel( 'Future Earning Dates: ' + __futureEarnings, #Blue );

  //if( __lastEarning <> '' ) then
  //  MyDrawLabel( 'Last Earning Date: ' + DateToStr(StrToInt(__lastEarning)), #Blue );

  if( IsDaily() and ( __nextEarning <> '' ) ) then
  begin
    var days: integer = myUtil.WeekDaysBetweenDates( GetDate(BarCount-1), StrToInt(__nextEarning) );
    if( days > 10 ) then
      MyDrawLabel( 'Next Earning Date(' + IntToStr(days) + '): ' + DateToStr(StrToInt(__nextEarning)), #Blue )
    else
      MyDrawLabel( '>>>-------> Next Earning Date(' + IntToStr(days) + '): ' + DateToStr(StrToInt(__nextEarning)), #Red );
  end;
end;
//______________________________________________________________________________
function lastEarning(): string;
begin
  __initEarningsLibrary();
  Result := __lastEarning;
end;

//______________________________________________________________________________
function nextEarning(): string;
begin
  __initEarningsLibrary();
  Result := __nextEarning;
end;

//______________________________________________________________________________
//readEarnings;
//displayEarnings;
