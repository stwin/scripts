
// This is just to see the Chart, nothing else

var tick1: integer = GetTickCount();

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure DisplayPercentChangeForLast5Bars (selecteBar: integer);
begin
  var count, startCount: integer;
  var text: String;
  var firstTime: boolean;
  firstTime := true;
  text := 'Change(%): ';

  startCount := selecteBar - 4;
  if (startCount < 0) then
    startCount := 0;

  for count := startCount to selecteBar do
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
  DrawText (text, 0, 100, 20, #Blue, 12);
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure DisplayPercentChangeForLast5BarsAtTheirPlace (selecteBar: integer);
begin
  var count, startCount: integer;
  var text: String;
  var firstTime: boolean;
  firstTime := true;
  text := 'Change(%): ';

  startCount := selecteBar - 4;
  if (startCount < 0) then
    startCount := 0;

  var drawUp : boolean;
  drawUp := true;
  for count := startCount to selecteBar do
  begin
    var val: float;
    val := (PriceClose(count)-PriceOpen(count))*100/PriceOpen(count);
    text := ' ' + FormatFloat('#0.00', val);
    AnnotateBar (text, count,  drawUp, #blue, 08);
    drawUp := not drawUp;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure DisplayCompanyName;
begin
  var FileName: String;
  var file: integer;

  FileName := 'D:\WL\Manage\SecurityNames.csv';
  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr, companyName: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');
    if ( 0 = CompareText(symbolStr, GetSymbol)) then
    begin
      companyName := Copy (line, Length(symbolStr)+2, Length(line)-Length(symbolStr)-1);
      DrawText (companyName, 0, 100, 20, #gray, 12);
      break;
    end;
  end;
  FileClose (file);
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure AnnotateChartBasedOnWatchlistName;
begin
  if not isDaily then
    exit;
  var monthStr, dayStr, yearStr: string;
  var bar: integer;
  try
  begin
    monthStr := Copy (WatchListName, 1, 2);
    dayStr := Copy (WatchListName, 3, 2);
    yearStr := Copy(IntToStr(CurrentDate), 1, 4);  // returns 2005
    bar := DateToBar ( StrToInt (yearStr+monthStr+dayStr));

    if (PriceOpen(bar) < PriceClose(bar)) then
      AnnotateBar (dayStr, bar,  true, #blue, 08)
    else
      AnnotateBar (dayStr, bar,  false, #blue, 08);

    DisplayPercentChangeForLast5Bars (bar+2);
  end;
  except
  end;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

//var Bar: integer;
var text: String;

DisplayPercentChangeForLast5Bars (BarCount-1);
//DisplayCompanyName;
//AnnotateChartBasedOnWatchlistName;

// Display Volume and Price in bold
text := 'Volume: ' + FormatFloat('###,###,###', Volume(BarCount-1))
              + '    Price: ' + FormatFloat('#.00', PriceClose(BarCount-1));
//DrawText (text, 0, 100, 20, #Blue, 12);


{
PlotSeries (SMASeries(#close,20), 0, #Red, #thin);
PlotSeries (SMASeries(#close,10), 0, #Blue, #thin);
PlotSeries (BBandLowerSeries(#close, 10, 2), 0, 962, #thick);
PlotSeries (BBandUpperSeries(#close, 10, 2), 0, 962, #thick);
}

Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );

