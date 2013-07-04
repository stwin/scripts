{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
function ReadDevSeries (fileName: string; devSeries: integer): integer;
begin
  var fileHandle, lastUpdatedBar: integer;

  lastUpdatedBar := -1;
  fileHandle := FileOpen (fileName);

  var init: boolean = false;

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, devStr: String;
    var bar: integer;
    var dev: float;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    devStr := GetToken (line, 1, ',');
    bar := DateToBar(StrToDate(dateStr));
    dev := StrToFloat(devStr);
    try
    begin
      SetSeriesValue( bar, devSeries, dev );
      if( (init = false) and (dev > 0.0001) ) then
      begin
        var gobackbar: integer;
        for gobackbar := 30 to bar do
          SetSeriesValue( gobackbar, devSeries, dev );
        init := true;
      end;
      lastUpdatedBar := bar;
    end;
    except
    end;
  end;

  FileClose (fileHandle);
  if( lastUpdatedBar < 0 ) then
    lastUpdatedBar := -1;
  Result := lastUpdatedBar;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

if (Not IsDaily) then
begin
  ShowMessage ('Runs only on Daily data');
  abort;
end;
var fileName: string = 'D:\WL\ChannelDaily\' + GetSymbol + '.txt';
var devSeries: integer;
var lastUpdatedBar: integer;

devSeries := CreateSeries ();
lastUpdatedBar := ReadDevSeries( fileName, devSeries );

if( lastUpdatedBar <> BarCount-1 ) then
begin
  abort;
end;

var ema11Series, ema22Series, upperSeries, lowerSeries: integer;

ema11Series := EMASeries( #close, 11 );
ema22Series := EMASeries( #close, 22 );
upperSeries := MultiplySeries( ema22Series, AddSeriesValue(devSeries,1) );
lowerSeries := MultiplySeries( ema22Series, SubtractValueSeries(1,devSeries) );

{
PlotSeries( upperSeries, 0, 9, #thin );
PlotSeries( lowerSeries, 0, 9, #thin );
PlotSeries( ema22Series, 0, 9, #thin );
 // Bollinger Bands
ema11Series := sMASeries( #close, 22 );
ema22Series := sMASeries( #close, 22 );
upperSeries := BBandUpperSeries( #Close, 22, 1.5 );
lowerSeries := BBandLowerSeries( #Close, 22, 1.5 );
 }
 
PlotSeries( upperSeries, 0, #Teal, #thin );
PlotSeries( lowerSeries, 0, #Teal, #thin );
PlotSeries( ema11Series, 0, 777, #thin );
PlotSeries( ema22Series, 0, #Maroon, #thin );

DrawLabel ('ChannelWidth ('
   + IntToStr(90)
   + ', '
   + FormatFloat('#', ( 2 * @devSeries[BarCount-1] * 100 ) )
   + '%): '
   + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
   #Black);

var chWidth : integer;
chWidth := MultiplySeriesValue( devSeries, 200 );
PlotSeries( chWidth, CreatePane(60,false,true), 500, #thin );


var Bar: integer;
var ema22, ema11, upper, lower: float;
var lastLongPosition, lastShortPosition: integer;
var totalProfit, longBuyPrice, shortSellPrice: float;

totalProfit := 0;

for Bar := BarCount-88 to BarCount-1 do begin

    ema22 := GetSeriesValue( Bar, ema22Series );
    ema11 := GetSeriesValue( Bar, ema11Series );
    upper := GetSeriesValue( Bar, upperSeries );
    lower := GetSeriesValue( Bar, lowerSeries );
    

    if( LastLongPositionActive ) then
    begin
      if SellAtLimit( Bar, upper, lastLongPosition, 'Upper Channel Hit' ) then
      begin
        var profit : float = 100*(upper-longBuyPrice)/longBuyPrice;
        Print('Long  Profit = ' + FormatFloat( '#.00', Profit ) );printflush;
        totalProfit := totalProfit + profit;
      end;
    end
    else
    begin
      if( BuyAtLimit( Bar, ema11, 'Bought at EMA11' ) ) then
        lastLongPosition := LastPosition;
        longBuyPrice := ema11;
    end;
    
    if( LastShortPositionActive ) then
    begin
      if CoverAtLimit( Bar, lower, lastShortPosition, 'Lower Channel Hit' ) then
      begin
        var profit : float = 100*(shortSellPrice-lower)/shortSellPrice;
        Print('Short Profit = ' + FormatFloat( '#.00', Profit ) );printflush;
        totalProfit := totalProfit + profit;
      end;
    end
    else
    begin
      if( ShortAtLimit( Bar, ema11, 'Shorted at EMA11' ) ) then
        lastShortPosition := LastPosition;
        shortSellPrice := ema11;
    end;
end;

PrintStatus( 'Profit = ' + FormatFloat( '#.00', totalProfit ) );

