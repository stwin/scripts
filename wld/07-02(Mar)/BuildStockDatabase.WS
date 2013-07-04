{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'database'}
{$I 'mycommon'}
//{$I 'myElderChSaved' }
//{$I 'myoption'}
//{$I 'myearnings' }
//{$I 'mynhnl'}

//______________________________________________________________________________
function getSqlCompatibleString( str: string ): string;
begin
  var fstr: string = '';
  var count: integer;
  fstr := GetToken( str, 0, '''' );
  for count := 1 to 100 do
  begin
    var token: string;
    token := GetToken( str, count, '''' );
    if( token = '' ) then
      break
    else
      fstr := fstr + '''''' + token;
  end;
  Result := fstr;
end;
//______________________________________________________________________________
procedure populateStandardDatabase();
begin
  var tableName: string = 'Stocks';
  var db: Database = Database.Create;
  db.ConnectMsSqlServer( 'blackbox\db1', 'wlsql' );
  print('Result of Connect = ' + IntToStr(db.lastError));
  db.ExecSql( 'DROP TABLE ' + tableName );
  print('Result of ExecSql(DROP) = ' + IntToStr(db.lastError));
  var sqlStr: string = 'CREATE TABLE ' + tableName + ' ('
        + 'Sym varchar(10),'
        + 'O float,'          // Open
        + 'H float,'
        + 'L float,'
        + 'C float,'
        + 'V int,'
        + 'BarCount int,'
        + 'AvgVol int,'
        + 'ElChPer int,'
        + 'High3m int,'
        + 'Low3m int,'
        + 'ATH int,'
        + 'High52w int,'
        + 'Low52w int,'
        + 'EMA11 float,'
        + 'EMA22 float,'
        + 'EMA44 float,'
        + 'EMA130 float,'
        + 'RSI9 float,'
        + 'RSI14 float,'
        + 'STOCH7 float,'
        + 'Name varchar(100),'
        + 'lastCol int, uniqueId int IDENTITY(1,1))' ;   // LastCol is dummy
  print( sqlStr ); printflush;
  db.ExecSql( sqlStr );
  print('Result of ExecSql(CREATE) = ' + IntToStr(db.lastError));

  var watchListNum: integer;
  var countRows: integer = 0;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum+1) + '/' + IntToStr(WatchListCount) + ' ' +  WatchListSymbol (watchListNum));
    ClearIndicators();
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    if( BarCount < 150 ) then continue;
    sqlStr := 'INSERT INTO ' + tableName + ' VALUES (' +
          + '''' +  GetSymbol + ''','
          + FormatFloat( '0.00', PriceOpen(BarCount-1)) + ','
          + FormatFloat( '0.00', PriceHigh(BarCount-1)) + ','
          + FormatFloat( '0.00', PriceLow(BarCount-1)) + ','
          + FormatFloat( '0.00', PriceClose(BarCount-1)) + ','
          + FormatFloat( '0', Volume(BarCount-1)) + ','               // Volume
          + IntToStr( BarCount ) + ','                                // BarCount
          + FormatFloat( '0', SMA(BarCount-1, #Volume, 22)) + ','     // AvgVol
          + FormatFloat( '0', 100*2*getElderChannelDeviation(BarCount-1, 22, 6, 90)) + ',' // ElChPer
          + IntToStr( GetDate(HighestBar(BarCount-1,#High,66))) + ',' // High3m
          + IntToStr( GetDate(LowestBar(BarCount-1,#Low,66))) + ','   // Low3m
          + IntToStr( GetDate(HighestBar(BarCount-1,#High,BarCount-1))) + ','   // ATH
          + IntToStr( GetDate(HighestBar(BarCount-1,#Low,252))) + ',' // High52w
          + IntToStr( GetDate(LowestBar(BarCount-1,#Low,252))) + ','  // Low52w
          + FormatFloat( '0.00', EMA(BarCount-1, #Close, 11)) + ','     // EMA11
          + FormatFloat( '0.00', EMA(BarCount-1, #Close, 22)) + ','     // EMA22
          + FormatFloat( '0.00', EMA(BarCount-1, #Close, 44)) + ','     // EMA44
          + FormatFloat( '0.00', EMA(BarCount-1, #Close, 130)) + ','     // EMA130
          + FormatFloat( '0.00', RSI(BarCount-1, #Close, 9)) + ','     //
          + FormatFloat( '0.00', RSI(BarCount-1, #Close, 14)) + ','     //
          + FormatFloat( '0.00', StochD(BarCount-1, 7, 3)) + ','     //
          + '''' +  getSqlCompatibleString(GetSecurityName) + ''','   // Security Name
          + '1 )';                                                    // LastCol
    //Print( sqlStr ); PrintFlush;
    db.ExecSql( sqlStr );
    if( db.lastError < 0 ) then begin Print( 'Error occured + '+IntToStr(db.GetLastSqlError())); abort; end;
    Inc( countRows );
  end;
  RestorePrimarySeries;
  Print( 'Number of rows added : ' + IntToStr(countRows) ); PrintFlush;
end;
//______________________________________________________________________________
procedure populateTempDatabase();
begin
  var tableName: string = 'Temp';
  var db: Database = Database.Create;
  db.ConnectMsSqlServer( 'blackbox\db1', 'wlsql' );
  print('Result of Connect = ' + IntToStr(db.lastError));
  db.ExecSql( 'DROP TABLE ' + tableName );
  print('Result of ExecSql(DROP) = ' + IntToStr(db.lastError));
  var sqlStr: string = 'CREATE TABLE ' + tableName + ' ('
        + 'Sym varchar(10),'
        + 'upEMA11 int,'
        + 'upEMA22 int,'
        + 'upEMA44 int,'
        + 'upEMA130 int,'
        + 'lastCol int, uniqueId int IDENTITY(1,1))' ;   // LastCol is dummy
  print( sqlStr ); printflush;
  db.ExecSql( sqlStr );
  print('Result of ExecSql(CREATE) = ' + IntToStr(db.lastError));

  var watchListNum: integer;
  var countRows: integer = 0;

  function TestGreaterThan( fVal: float ): integer;
  begin
    if( fVal > 0.0 ) then
      Result := 1
    else
      Result := 0;
  end;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum+1) + '/' + IntToStr(WatchListCount) + ' ' +  WatchListSymbol (watchListNum));
    ClearIndicators();
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    if( BarCount-1 < 140 ) then continue;
    sqlStr := 'INSERT INTO ' + tableName + ' VALUES (' +
          + '''' +  GetSymbol + ''','
          + IntToStr( TestGreaterThan( EMA(BarCount-1, #Close, 11) - EMA(BarCount-2, #Close, 11) )) + ','     // EMA11
          + IntToStr( TestGreaterThan( EMA(BarCount-1, #Close, 22) - EMA(BarCount-2, #Close, 22) )) + ','     // EMA22
          + IntToStr( TestGreaterThan( EMA(BarCount-1, #Close, 44) - EMA(BarCount-2, #Close, 44) )) + ','     // EMA44
          + IntToStr( TestGreaterThan( EMA(BarCount-1, #Close, 130) - EMA(BarCount-2, #Close, 130) )) + ','     // EMA130
          + '1 )';                                                    // LastCol
    //Print( sqlStr ); PrintFlush;
    db.ExecSql( sqlStr );
    if( db.lastError < 0 ) then
    begin
      Print( 'Error occured(' + IntToStr(countRows) + ')[' + sqlStr + '] '
                + IntToStr(db.GetLastSqlError()));
      abort;
    end;
    Inc( countRows );
  end;
  RestorePrimarySeries;
  Print( 'Number of rows added : ' + IntToStr(countRows) ); PrintFlush;
end;
//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

populateStandardDatabase();
populateTempDatabase();


