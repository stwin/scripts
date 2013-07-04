
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
procedure  DisplayPercentChangeForLast5Bars;
begin
var count: integer;
var text: String;
var firstTime: boolean;
firstTime := true;
text := 'Change(%): ';
for count := BarCount-5 to BarCount-1 do
begin
  var val: float;
  val := (PriceClose(count)-PriceClose(count-1))*100/PriceClose(count-1);
  if (firstTime) then
  begin
    text :=  text + ' ' + FormatFloat('#0.00', val);
    firstTime := false;
  end
  else
    text :=  text + ',  ' + FormatFloat('#0.00', val);
end;
DrawText (text, 0, 5, 45, #Blue, 12);
text := 'Volume: ' + FormatFloat('###,###,###', Volume(BarCount-1))
              + '    Price: ' + FormatFloat('#.00', PriceClose(BarCount-1));
DrawText (text, 0, 5, 65, #Blue, 12);
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure DisplayCompanyName;
begin
  var FileName: String;
  var file: integer;

  FileName := 'D:\WL\Manage\CompanyNames.csv';
  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr, companyName: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');
    if ( 0 = CompareText(symbolStr, GetSymbol)) then
    begin
      companyName := Copy (line, Length(symbolStr)+2, Length(line)-Length(symbolStr)-1);
      DrawText (companyName, 0, 100, 1, #black, 12);
      break;
    end;
  end;
  FileClose (file);
end;
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

SetColorScheme (050, 800, 222, 999, 888, 005);

var s: string = GetSymbol;
if IsWeekly then
  s := s + '-weekly';
if IsDaily then
  s := s + '-daily';


DisplayPercentChangeForLast5Bars;
//DisplayCompanyName;

//SaveChartImage('D:\WL\Images\' + s + '.bmp', 1024, 768/2, 'BMP' );
SaveChartImage('D:\WL\Images\' + s + '.bmp', 1024, 768, 'BMP' );

