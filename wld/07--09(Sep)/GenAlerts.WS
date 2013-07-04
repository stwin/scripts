{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
//______________________________________________________________________________
// First Excel Library
//------------------------------------------------------------------------------

var XLW: ComVariant;
var XL: ComVariant;
var XLWfound: boolean;
//______________________________________________________________________________
//------------------------------------------------------------------------------
function OpenExcelFile ( dir, fileName: string; sheetNum: integer ) : ComVariant;
begin
  var XLS: ComVariant = CreateOleObject('Excel.Sheet');
  XL := XLS.Application;
  XL.ScreenUpdating := false;
  var j: integer;
  XLWfound := false;
  if XL.Visible then
    // Excel already running
    for j := 1 to XL.WorkBooks.Count do
      if XL.WorkBooks(j).Name = fileName then
      begin
        // Workbook already open
        XLWfound := true;
        XLW := XL.WorkBooks(j);
        break;
      end;
  if not XLWfound then
  begin
    var File: COMVariant = CreateOleObject('Scripting.FileSystemObject');
    if not File.FileExists(dir + fileName) then
    begin
      ShowMessage('File "' + dir + fileName + '" not found');
      exit;
    end;
    XLW := XL.WorkBooks.Open(dir + fileName);
  end;
  XLS := XLW.WorkSheets(sheetNum);
  Result := XLS;
end;

//______________________________________________________________________________
//------------------------------------------------------------------------------
procedure ExcelCleanup;
begin
  XL.ScreenUpdating := true;
  if not XLWfound then XLW.Close(true);
  if not XL.Visible then XL.Quit();
end;

//______________________________________________________________________________
//______________________________________________________________________________

//==============================================================================
// Initialize CSharp Script
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\Everything.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.EverythingInit( IWealthLabAddOn3 );
//==============================================================================

//______________________________________________________________________________
//------------------------------------------------------------------------------
//
// You can also load Alerts from a text file having Wealth-Lab Developer 2.1's Alert
// file format. The text record format uses a semi-colon field separator as follows:
//
//        Symbol;PositionType;Shares;OrderType;AlertPrice
//
// where case sensitivity is preserved for Symbol (only), and valid field values
// are shown below.
//
// Symbol	        Alphanumeric sequence of characters, excluding semi-colons
// PositionType	  Buy, Sell, Short, or Cover
// Shares	        An integer value.  Floating point values are interpreted as zero
// OrderType	    Limit or Stop
// AlertPrice	    A floating point number
//
// Example
//
// ABC;Buy;500;Limit;32.49
// SP H4;Buy;2;Limit;1302.25
//

//______________________________________________________________________________
//------------------------------------------------------------------------------
procedure processBuySellAlerts ( fileHandle: integer; symbol, alertType, alerts: string; expEma, expElChWidth: float );
begin
  var aCount: integer;
  for aCount := 0 to 10 do
  begin
    var tok: string = GetToken ( alerts, aCount, ',' );
    if ( tok = '' ) then
      break;
    var alert : string = Trim ( tok );
    var shares : string = GetToken ( alert, 0, '@' );
    var chW: float = StrToFloat( GetToken ( alert, 1, '@' ) );
    var limitLevel: float = expEma + chW * expElChWidth / 100;
    var line: string =  symbol + ';' + alertType + ';' + shares + ';Limit;' + FormatFloat( '#.##', limitLevel ) ;
    Print ( line );
    FileWrite(fileHandle, line);
  end;
end;

//______________________________________________________________________________
//------------------------------------------------------------------------------
procedure processSymbol ( fileHandle: integer; symbol, buyAlerts, sellAlerts: string );
begin
  var bar: integer;
  EnableSynch ( false ); SetPrimarySeries ( symbol ); myclass.SetPrimarySeries ( false );

  var ema22Series: integer = EMASeries (#close, 22);
  var mainEmaSeries: integer = ema22Series; //SMASeries ( ema22Series, 5);
  var devSeries: integer = CreateSeries();

  // Get the deviation series
  myclass.Everything_GetChannelDeviationSeries( 22, 132, 90, devSeries );

  //devSeries := SMASeries ( devSeries, 5 );
  var elderChannelWidthSeries : integer = MultiplySeries ( mainEmaSeries, MultiplySeriesValue( devSeries, 2 ) );

  var expEma22: float = 2 * @mainEmaSeries[BarCount-1] - @mainEmaSeries[BarCount-2];
  var expElderChannelWidth: float = 2 * @elderChannelWidthSeries[BarCount-1] - @elderChannelWidthSeries[BarCount-2];

  if ( buyAlerts <> '' ) then // buy alerts
  begin
    processBuySellAlerts ( fileHandle, symbol, 'Buy', buyAlerts, expEma22, expElderChannelWidth );
  end;
  if ( sellAlerts <> '' ) then // sell alerts
  begin
    processBuySellAlerts ( fileHandle, symbol, 'Sell', sellAlerts, expEma22, expElderChannelWidth );
  end;

  RestorePrimarySeries (); myclass.RestorePrimarySeries ( );
end;

//______________________________________________________________________________
//------------------------------------------------------------------------------
const dir = 'D:\WLE\Alerts\';
const XLName = 'StockStudy_TAACP.xlsx';
var TXTName: string = 'Alerts-' + IntToStr(GetDate(BarCount-1)) + '.txt';
const delim = #9;

var XLS: ComVariant = OpenExcelFile ( dir, XLNAme, 1 );

try
  var fh: integer = FileOpen(dir + TXTName);
  var row: integer;
  for row := 2 to 100 do
  begin
    var s1, s2, s3: string;
    s1 := XLS.Cells(row,1).Text;
    s2 := XLS.Cells(row,2).Text;
    s3 := XLS.Cells(row,3).Text;
    if ( s1 = '' ) then
      break;
    //Print ( IntToStr(row) + #9 + s1 + #9 + s2 + #9 + s3  ); PrintFlush;
    processSymbol ( fh, s1, s2, s3 );
  end;
  FileClose(fh);
finally
  ExcelCleanup;
end;

//______________________________________________________________________________

