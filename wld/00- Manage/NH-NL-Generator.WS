{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
//Pre-Cache
var HighSeriesOfSeries : Array[0..10000] of integer;
var LowSeriesOfSeries : Array[0..10000] of integer;
var w : integer;

for w := 0 to WatchlistCount-1 do
begin
  PrintStatus ('Loading: ' + IntToStr(w) + ' ' + WatchListSymbol( w ));
  try
    HighSeriesOfSeries[w] := GetExternalSeries( WatchListSymbol( w ), #High );
    LowSeriesOfSeries[w] := GetExternalSeries( WatchListSymbol( w ), #Low );
  except
    Print ('Data could not be loaded for :' + WatchListSymbol(w)); PrintFlush;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
procedure Gen52WeekHiLoData (fileName: String; startBar, endBar: integer);
begin
  const tradingDays = 252;
  var Bar, W : integer;
  var fileHandle: integer;
  var numYearHigh, numYearLow : integer;

  fileHandle := FileCreate (fileName);
  
  if (startBar < (tradingDays+1)) then
    startBar := tradingDays+1;
  if (endBar > (BarCount-1)) then
    endBar := BarCount-1;
  if (startBar > endBar) then
    exit;
  
  //for Bar := tradingDays+1 to BarCount-1 do
  for Bar := startBar to endBar do
  begin
    var date: integer;
    date := GetYear(Bar) * 10000 + GetMonth(Bar) * 100 + GetDay(Bar);
    numYearHigh := 0;
    numYearLow := 0;
    PrintStatus ('Processing: ' + DateToStr(date));
    for W := 0 to WatchListCount - 1 do
    begin
      try // Some new stocks may not have old data, like GOOG in 2/2/2004
        if GetSeriesValue(Bar,HighSeriesOfSeries[W]) > Highest( Bar-1, HighSeriesOfSeries[W], tradingDays ) then
          numYearHigh := numYearHigh+1;
        if GetSeriesValue(Bar,LowSeriesOfSeries[W]) < Lowest( Bar-1, LowSeriesOfSeries[W], tradingDays ) then
          numYearLow := numYearLow+1;
      except
      end;
    end;
    FileWrite (fileHandle, DateToStr(date)+','+IntToStr(numYearHigh)+','+IntToStr(numYearLow));
  end;
  FileClose (fileHandle);
end;

///////////////////////////////////////////////////////////////////////////////
// Main Program
var fileName: String;
var n1, n2: integer;

n1:= GetTickCount;
fileName := 'D:\WLE\temp\NH-NL-Generated.txt';

Gen52WeekHiLoData (fileName, BarCount-10, BarCount-1);

n2:= GetTickCount;
ShowMessage ('Took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

