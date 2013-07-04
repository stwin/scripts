(*Description...
Generates lists for autodownload of IbdCheckup

*)
{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );


///////////////////////////////////////////////////////////////////////////////
function IntToTwoCharStr( num: integer ): string;
begin
  var str: string = IntToStr( num );
  var len: integer = Length( str );
  if( len = 1 ) then
    str := '0' + str;
  Result := str;
end;
///////////////////////////////////////////////////////////////////////////////
procedure GenerateLists( dir: string; year, month, maxNum: integer );
begin
  if (Not IsDaily) then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  var watchListNum, filenum, day: integer;
  day := 1;
  filenum := -1;

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    if( watchListNum Mod maxNum = 0 ) then
    begin
      if( filenum <> -1 ) then
        FileClose( filenum );
      var fileName: string;
      fileName := dir + '\list' + IntToStr( year ) + IntToTwoCharStr( month )
                + IntToTwoCharStr( day ) + '.csv';
      filenum := FileCreate( fileName );
      Print( fileName );
      day := day + 1;
    end;
    FileWrite( filenum, WatchListSymbol (watchListNum) );
  end;
  FileClose( filenum );
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;
n1:= GetTickCount;

GenerateLists( 'I:\IBD\temp', 2007, 1, 280 );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

