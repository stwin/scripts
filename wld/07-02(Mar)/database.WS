//______________________________________________________________________________
//
// This Class implements functions to read from different databases
//______________________________________________________________________________
//

type Database = class
private
protected
public
  lastError: integer;
  connection, recordSet: ComVariant;
  databaseType: string; // Should be "MsAccess", "MsSqlServer"

  constructor Create();
  
  // Connect and Close
  procedure ConnectMsAccess( dbPathName: String );
  procedure ConnectMsSqlServer( dbServer, database: String );
  procedure Close();

  // Raw Operations
  procedure ExecSql( sqlQueryStr: String );
  function GetRecordsetFromSqlQuery( sqlQueryStr : String ) : COMVariant;
  function GetLastSqlError(): integer;
  
  // Some convenience methods ( basically sql statemetns )
  procedure ClearTable( tablename: String );
  procedure DeleteTable( tableName: String );
  
  // Some handy methods ( build WL TList from ADO recordset )
  function getResultsInTList( fieldPrimary: string ): TList;
  function getResultsInTListWithData( fieldPrimary: string ): TList;

  // Testing of the Class
  procedure Test1();
end;



//______________________________________________________________________________
constructor  Database.Create();
begin
  connection := null;
  recordSet := null;
  databaseType := '';
  lastError := 0;
end;

//______________________________________________________________________________
// Input example: dbPathName = 'C:\Temp\abc.mdb'
procedure Database.ConnectMsAccess( dbPathName: String );
begin
  var connectionString: String;
  var retval: integer;
  try
    connection := CreateOLEObject('ADODB.Connection');
    recordSet := CreateOLEObject('ADODB.Recordset');
    connectionString := 'Provider=Microsoft.JET.OLEDB.4.0;Data Source =''' + dbPathName +'''';
    Print( 'ConnectionString=' + connectionString );   // Debug
    retval := connection.Open( connectionString );
    lastError := connection.State;
    databaseType := 'MsAccess';
  except
    lastError := -1;
  end;
end;

//______________________________________________________________________________
// Input example:  dbServer = 'mymachine\sqlexpress', database = 'wealthlabdb'
procedure Database.ConnectMsSqlServer( dbServer, database: String );
begin
  var connectionString: String;
  var retval: integer;
  try
    connection := CreateOLEObject('ADODB.Connection');
    recordSet := CreateOLEObject('ADODB.Recordset');
    connectionString := 'Provider=SQLOLEDB.1;Integrated Security=SSPI;'
                     + 'Data Source=' + dbServer + ';Initial Catalog=' + database;
    Print( 'ConnectionString=' + connectionString );    // Debug
    retval := connection.Open( connectionString );
    lastError := connection.State;
    databaseType := 'MsSqlServer';
  except
    lastError := -1;
  end;
end;
//______________________________________________________________________________
// Close the connection to the database
procedure Database.Close();
begin
  try
    if( recordSet.State = 1 ) then
      recordSet.Close();
    connection.Close();
    lastError := 1;
  except
    lastError := -1;
  end;
end;
//______________________________________________________________________________
procedure Database.ExecSql( sqlQueryStr: String );
begin
  try
    recordSet := connection.Execute( sqlQueryStr );
    lastError := 1;
  except
    lastError := -1;
  end;
end;
//______________________________________________________________________________
function Database.GetRecordsetFromSqlQuery( sqlQueryStr : String ) : COMVariant;
begin
  try
    if( recordSet.State = 1 ) then
      recordSet.Close();
    recordSet.Open( sqlQueryStr, connection );
    Result := recordSet;
    lastError := 1;
  except
    lastError := -1;
  end;
end;
//______________________________________________________________________________
function Database.GetLastSqlError(): integer;
begin
  try
    if( recordSet.State = 1 )then
      recordSet.Close();
    recordSet.Open( 'SELECT @@error', connection );
    recordSet.movefirst();
    if recordSet.eof() = false then
    begin
      Result := recordSet.Fields(0.0).Value;
      recordSet.Close();
      lastError := 1;
    end
    else
    begin  // Should never come here
      ShowMessage( 'Could not get last SQL error.' );
      lastError := -1;
      abort;
    end;
  except   // Should not get exception unless the connection is broken
    ShowMessage( 'Could not get last SQL error. Exception occured.' );
    lastError := -1;
    abort;
  end;
end;
//______________________________________________________________________________
procedure Database.ClearTable( tableName: String );
begin
  try
    recordSet := connection.Execute( 'TRUNCATE TABLE ' + tableName );
    lastError := 1;
  except
    lastError := -1;
  end;
end;
//______________________________________________________________________________
procedure Database.DeleteTable( tableName: String );
begin
  try
    recordSet := connection.Execute( 'DROP TABLE ' + tableName );
    lastError := 1;
  except
    lastError := -1;
  end;
end;

//______________________________________________________________________________
function Database.getResultsInTList( fieldPrimary: string ): TList;
begin
  var lst: TList = TList.Create;
  while( not recordSet.EOF ) do
  begin
    var val: string = Trim(recordSet.Fields(fieldPrimary).value);
    lst.Add( val );
    recordSet.MoveNext();
  end;
  Result := lst;
end;

//______________________________________________________________________________
function Database.getResultsInTListWithData( fieldPrimary: string ): TList;
begin
  var lst: TList = TList.Create;
  while( not recordSet.EOF ) do
  begin
    var val: string = Trim(recordSet.Fields(fieldPrimary).value);
    var fieldCount: integer;
    var data, sep: string;
    data := '';
    sep := '';
    for fieldCount := 0 to recordSet.Fields.Count-1 do
    begin
      if fieldCount > 0 then sep := ',';
      var t1: variant = recordSet.Fields[fieldCount].value;
      try
        data := data + sep + Trim(t1);
      except
        data := data + sep + FloatToStr(t1);
      end;
    end;
    lst.AddData( val, data );
    recordSet.MoveNext();
  end;
  Result := lst;
end;

//______________________________________________________________________________
procedure Database.Test1();
begin
  var db: Database = Database.Create;
  db.ConnectMsAccess( 'C:\Temp\abc.mdb' );
  //db.ConnectMsSqlServer( 'mybox\db1', 'wlsql' );
  print('Result of Connect = ' + IntToStr(db.lastError));
  db.ExecSql( 'DROP TABLE StocksTest' );
  print('Result of ExecSql(DROP) = ' + IntToStr(db.lastError));
  var sqlStr: string = 'CREATE TABLE StocksTest ('
        + 'Sym char(10),'
        + 'Date1 int,'
        + 'OpenPrice float,'
        + 'HighPrice float,'
        + 'LowPrice float,'
        + 'ClosePrice float,'
        + 'Volume int)';
  print( sqlStr ); printflush;
  db.ExecSql( sqlStr );
  print('Result of ExecSql(CREATE) = ' + IntToStr(db.lastError));

  var bar: integer;

  for bar := 0 to BarCount - 1 do
  begin
    var sqlStr: string = 'INSERT INTO StocksTest VALUES (' +
          + '''' +  GetSymbol + ''','
          + IntToStr( GetDate( bar ) ) + ','
          + FormatFloat( '0.00', PriceOpen(bar)) + ','
          + FormatFloat( '0.00', PriceHigh(bar)) + ','
          + FormatFloat( '0.00', PriceLow(bar)) + ','
          + FormatFloat( '0.00', PriceClose(bar)) + ','
          + FormatFloat( '0', Volume(bar)) + ')';
    //Print( sqlStr ); PrintFlush;
    db.ExecSql( sqlStr );
    if( db.lastError < 0 ) then begin Print( 'Error occured + '+IntToStr(db.GetLastSqlError())); abort; end;
  end;
end;
//______________________________________________________________________________
//______________________________________________________________________________

//
// Sample SQL Statements
//
// DROP TABLE customer.
// CREATE TABLE customer (First_Name char(50), Last_Name char(50), Address char(50), \\
//              City char(50), Country char(25), Birth_Date date)
// ALTER TABLE Customer ADD PRIMARY KEY (SID);
// INSERT INTO Store_Information (store_name, Sales, Date) VALUES ('Los Angeles', 900, 'Jan-10-1999')
//

//
// TEST CODE
//
//var db: Database = Database.Create;
//db.Test1();










