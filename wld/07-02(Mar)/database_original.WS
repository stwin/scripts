{$NO_AUTO_EXECUTE}
///////////////////////////////////////////////////////////////////////////////
//
// READING AND WRITING ACCESS DATABASES
//
///////////////////////////////////////////////////////////////////////////////

Type WLAccess = class
private
   Status: Integer;
   CR: Integer;
   DBName: String;
   DB, rs: ComVariant;

   Function DBExecute(SQL: String): integer;
   Function DBReturnStr(SQL: String): string;
   Function DBReturnInt(SQL: String): Integer;
   Function DBReturnFlt(SQL: String): Float;

protected
public
  // DB Functions
  Function OpenDB(DBPathName: String): Integer;
  Function OpenDB2(DBPathName: String): Integer;
  Function CloseDB(): Integer;

  //Entire Row Functions
  Function InsertRowIntID(Tablename,KeyFieldName: String; KeyValue: Integer): Integer;
  Function InsertRowStrID(Tablename,KeyFieldName: String; KeyValue: String): Integer;
  Function DeleteRowIntID(Tablename,KeyFieldName: String; KeyValue: Integer): Integer;
  Function DeleteRowStrID(Tablename,KeyFieldName,KeyValue: String): Integer;

  //Getting Field Values
  Function GetIntFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Integer;
  Function GetIntFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Integer;
  Function GetStrFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): String;
  Function GetStrFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): String;
  Function GetFltFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Float;
  Function GetFltFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Float;
  Function GetDateFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Integer;
  Function GetDateFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Integer;

  //Setting Field Values
  Function SetIntFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: Integer): Integer;
  Function SetIntFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Integer): Integer;
  Function SetStrFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName, FieldValue: String): Integer;
  Function SetStrFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName, FieldValue: String): Integer;
  Function SetFltFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: Float): Integer;
  Function SetFltFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Float): Integer;
  Function SetDateFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: integer): Integer;
  Function SetDateFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Integer): Integer;

  // Misc
  Function ClearTable(Tablename: String): integer;
  Function RunRawSQL(SQL: String): integer;
end;



////////////////////////////////////////////////////////
Function WLAccess.OpenDB(DBPathName: String): Integer;
////////////////////////////////////////////////////////
begin
try
   Begin
   var connstring: String;
   var retval: integer;
   DB := CreateOLEObject('ADODB.Connection');
   rs := CreateOLEObject('ADODB.Recordset');
   connstring := 'Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;'
                  + 'Initial Catalog=wlsql;Data Source=blackbox\db1';
   Print( 'ConnectionString=' + connstring );
   retval := DB.Open(connstring);
   Result := DB.State;
      end;
except
    Result := 0;
end;
end;
////////////////////////////////////////////////////////
Function WLAccess.OpenDB2(DBPathName: String): Integer;
////////////////////////////////////////////////////////
begin
try
   Begin
   var connstring: String;
   var retval: integer;
   DB := CreateOLEObject('ADODB.Connection');
   rs := CreateOLEObject('ADODB.Recordset');
   connstring := 'Provider=Microsoft.JET.OLEDB.4.0;Data Source =''' ;
   connstring := connstring + DBPathName +'''';
   Print( 'ConnectionString=' + connstring );
   retval := DB.Open(connstring);
   Result := DB.State;
      end;
except
    Result := 0;
end;
end;

////////////////////////////////////////////////////////
Function WLAccess.DBExecute(SQL: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
    if DB.State = 0 then begin
    Result := 0;
    abort;
    end;
    DB.Execute(SQL);
         Result := 1;
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.DBReturnStr(SQL: String): String;

////////////////////////////////////////////////////////
Begin
   Try
   Begin
   var retVal: integer;
   if rs.State() = 1 then rs.close();
         rs.open(SQL, DB);
         rs.movefirst();
         if rs.eof() = false then begin
         Result := rs.Fields(0.0).Value;
         rs.close();
         end else begin
         Result := '';
         rs.close();
         end;

   end;
   except
         Try
         rs.close();
         except
         end;
         Result := '';
   end;
   end;
////////////////////////////////////////////////////////
Function WLAccess.DBReturnInt(SQL: String): Integer;

////////////////////////////////////////////////////////
Begin
   Try
   Begin
   if rs.State() = 1 then rs.close();
         rs.open(SQL, DB);
         rs.movefirst();
         if rs.eof() = false then begin
         Result := rs.Fields(0.0).Value;
         rs.close();
         end else begin
         Result := 1;
         rs.close();
         end;

   end;
   except
         Try
         rs.close();
         except
         end;
         Result := 0;
   end;
   end;
   ////////////////////////////////////////////////////////
Function WLAccess.DBReturnFlt(SQL: String): Float;

////////////////////////////////////////////////////////
Begin
   Try
   Begin
   if rs.State() = 1 then rs.close();
         rs.open(SQL, DB);
         rs.movefirst();
         if rs.eof() = false then begin
         Result := rs.Fields(0.0).Value;
         rs.close();
         end else begin
         Result := 1.0;
         rs.close();
         end;

   end;
   except
         Try
         rs.close();
         except
         end;
         Result := 0;
   end;
   end;
////////////////////////////////////////////////////////
Function WLAccess.CloseDB(): Integer;
////////////////////////////////////////////////////////
begin
try
   Begin
   Result := DB.Close;
   Result := 1;
   end;
except
   Result := 0;
end;
end;


////////////////////////////////////////////////////////
Function WLAccess.InsertRowIntID(Tablename, KeyFieldName: String; KeyValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Insert into [' + Tablename + ']([' + KeyFieldName + ']) Values (' + IntToStr(KeyValue) + ')';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.InsertRowStrID(Tablename, KeyFieldName, KeyValue: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Insert into [' + Tablename + ']([' + KeyFieldName + ']) Values (''' + KeyValue + ''')';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;

////////////////////////////////////////////////////////
Function WLAccess.DeleteRowIntID(Tablename,KeyFieldName: String; KeyValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Delete From [' + Tablename + '] Where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.DeleteRowStrID(Tablename,KeyFieldName, KeyValue: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
    SQL := 'Delete From [' + Tablename + '] Where [' + KeyFieldName + '] = ''' + KeyValue + '''';
    Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetIntFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From [' + Tablename + '] Where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBReturnInt(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetIntFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From [' + Tablename + '] Where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBReturnInt(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.GetStrFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): String;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From [' + Tablename + '] Where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBReturnStr(SQL);
   end;
   except
         Result := '';
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.GetStrFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): String;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From [' + Tablename + '] Where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBReturnStr(SQL);
   end;
   except
         Result := '';
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetFltFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Float;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From [' + Tablename + '] Where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBReturnFlt(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetFltFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Float;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select [' + FieldName + '] From ' + Tablename + ' Where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBReturnFlt(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetDateFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select Int(Format([' + FieldName + '],"yyyymmdd")) as [' + FieldName + '] From ' + Tablename + ' Where ' + KeyFieldName + ' = ' + IntToStr(KeyValue);
   Result := DBReturnInt(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
 Function WLAccess.GetDateFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   var retVal: integer;
   SQL := 'Select Int(Format([' + FieldName + '],"yyyymmdd")) as [' + FieldName + '] From ' + Tablename + ' Where ' + KeyFieldName + ' = ''' + KeyValue + '''';
   Result := DBReturnInt(SQL);
   end;
   except
         Result := 0;
   end;
end;
 ////////////////////////////////////////////////////////
 Function WLAccess.SetIntFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ' + IntToStr(FieldValue) + ' where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;

////////////////////////////////////////////////////////
 Function WLAccess.SetIntFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ' + InttoStr(FieldValue) + ' where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
 ////////////////////////////////////////////////////////
  Function WLAccess.SetStrFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName, FieldValue: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
      SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ''' + FieldValue + ''' where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.SetStrFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName, FieldValue: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
       SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ''' + FieldValue + ''' where [' + KeyFieldName + '] = ''' + KeyValue + '''';
    Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
 ////////////////////////////////////////////////////////
 Function WLAccess.SetFltFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: Float): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ' + FloatToStr(FieldValue) + ' where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;

////////////////////////////////////////////////////////
 Function WLAccess.SetFltFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Float): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = ' + FloatToStr(FieldValue) + ' where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
 ////////////////////////////////////////////////////////
 Function WLAccess.SetDateFieldValueIntID(Tablename, KeyFieldName: String; KeyValue: Integer; FieldName: String; FieldValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = #' + DateToStr(FieldValue) + '# where [' + KeyFieldName + '] = ' + IntToStr(KeyValue);
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;

////////////////////////////////////////////////////////
 Function WLAccess.SetDateFieldValueStrID(Tablename, KeyFieldName, KeyValue, FieldName: String; FieldValue: Integer): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Update [' + Tablename + '] Set [' + Fieldname + '] = #' + DatetoStr(FieldValue) + '# where [' + KeyFieldName + '] = ''' + KeyValue + '''';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.Cleartable(Tablename: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   var SQL: String;
   SQL := 'Delete From [' + Tablename + ']';
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
Function WLAccess.RunRawSQL(SQL: String): Integer;

////////////////////////////////////////////////////////
begin
   Try
   Begin
   Result := DBExecute(SQL);
   end;
   except
         Result := 0;
   end;
end;
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
var c: Integer;
var ret: string;
var flt: float;
Var db: WLAccess;
db := WLAccess.create;

c := db.OpenDB( 'mydb.dbo.Book');

//c := db.OpenDB('C:\Temp\Test.mdb');
print('Result of OpenDB = ' + IntToStr(c));
if c = 0 then abort;
{
c := db.InsertRowStrID('StrKeyTable','KeyField','MyKey1');
print('Result of InsertRowStrID = ' + IntToStr(c));
c := db.InsertRowIntID('IntKeyTable','KeyField',1);
print('Result of InsertRowIntID = ' + IntToStr(c));
c := db.SetStrFieldValueIntID('IntKeyTable','KeyField', 1, 'StrField','Testing 1 2 3');
print('Result of SetStrFieldValueIntID = ' + IntToStr(c));
c := db.SetFltFieldValueIntID('IntKeyTable','KeyField', 1, 'dblField',0.77356);
print('Result of SetfltFieldValueIntID = ' + IntToStr(c));
c := db.SetDateFieldValueIntID('IntKeyTable','KeyField', 1, 'DateField',19990701);
print('Result of SetDateFieldValueIntID = ' + IntToStr(c));
ret := db.GetStrFieldValueIntID('IntKeyTable','KeyField',1,'StrField');
print('Result of GetStrFieldValueIntID = ' + ret);
flt := db.GetFltFieldValueIntID('IntKeyTable','KeyField',1,'dblField');
print('Result of GetfltFieldValueIntID = ' + FloatToStr(flt));
c := db.GetDateFieldValueIntID('IntKeyTable','KeyField',1,'DateField');
print('Result of GetDateFieldValueIntID = ' + DateToStr(c));
//c := db.DeleteRowIntID('IntKeyTable','KeyField',1);
//print('Result of DeleteRowIntID = ' + IntToStr(c));
//c := db.DeleteRowStrID('StrKeyTable','KeyField','MyKey1');
//print('Result of DeleteRowStrID = ' + IntToStr(c));
}
db.closeDB;
//db.Free;




   //connstring := 'Driver={SQL Native Client};Server=blackbox\db1;'
   //         + 'Database=mydb;Uid=wealthlab;Pwd=wealthlab;';





