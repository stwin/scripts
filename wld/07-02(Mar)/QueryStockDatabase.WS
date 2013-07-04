{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'database'}
//{$I 'mycommon'}
//{$I 'myElderChSaved' }
//{$I 'myoption'}
//{$I 'myearnings' }
//{$I 'mynhnl'}
{$I 'Date Study II'}

//______________________________________________________________________________
procedure printTList( list: TList);
begin
  var num: integer;
  Print( 'Total count = ' + IntToStr( list.Count ) );
  for num := 0 to list.Count-1 do
  begin
    Print( list.Item( num ) );
  end;
end;

//______________________________________________________________________________
procedure printTListWithData( list: TList);
begin
  var num: integer;
  Print( 'Total count = ' + IntToStr( list.Count ) );
  for num := 0 to list.Count-1 do
  begin
    Print( list.Item( num ) + #9 + list.Data( num ) );
  end;
end;

//______________________________________________________________________________
procedure TListToWatchlist( list: TList; newWatchList: string);
begin
  var num: integer;
  // Clear the new watch list if it exists
  WatchListClear (newWatchList);
  for num := 0 to list.Count-1 do
  begin
    WatchListAddSymbol(newWatchList, '', list.Item( num ));
  end;
end;

//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

var sqlStr: string;
var db: Database = Database.Create;
db.ConnectMsSqlServer( 'blackbox\db1', 'wlsql' );
print('Result of Connect = ' + IntToStr(db.lastError));

var date: string = IntToStr( GetDate(BarCount-1) );
var date1M: string = IntToStr(SubTradingDays( BarCount-1, -30 ));
var date3M: string = IntToStr(SubTradingDays( BarCount-1, -90 ));
Print( date );
Print( date1M );
Print( date3M );

{
sqlStr := 'SELECT * FROM Stocks INNER JOIN SP600 ON Stocks.Sym = SP600.Sym WHERE ' +
  'C >= 6 and AvgVol >= 100000 and BarCount >= 120 and ElChPer >= 20'
//  'ATH >= ' + date
  + ' ORDER BY Stocks.Sym';
}
sqlStr := 'SELECT * FROM Stocks WHERE ' +
  'C >= 6 and AvgVol >= 100000 and ElChPer >= 20' +
  'and High3m > 20050503 and Stoch7 < 30';



  
Print( sqlStr ); PrintFlush;
db.ExecSql( sqlStr );
if( db.lastError < 0 ) then begin Print( 'Error occured + '+IntToStr(db.GetLastSqlError())); abort; end;

var lst: TList = db.getResultsInTList( 'Sym' );
//printTList( lst );
//var lst: TList = db.getResultsInTListWithData( 'Sym' );
//printTListWithData( lst );
Print( 'Total count = ' + IntToStr( lst.Count ) );
TListToWatchlist( lst, 'B-Database' );




