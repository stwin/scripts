{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
// This will find stocks which became more than 10 times in last 2 years
// It will print their rate of change
procedure PrintRateOfChange ();
begin
  var watchListNum: integer;
  var timesChange: float = 10;
  var backDays: integer = 2*252;
  var numDays: integer;
  
  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );

      if( BarCount < backDays) then
        numDays := BarCount
      else
        numDays := backDays;
      var highestPrice: float = Highest (BarCount-1, #High, numDays-1);
      var highestPriceBar: integer = HighestBar (BarCount-1, #High, numDays-1);
      var lowestPrice: float = Lowest (highestPriceBar-1, #Low, BarCount-numDays);
      var lowestPriceBar: integer = LowestBar (highestPriceBar-1, #Low, BarCount-numDays);

      if( lowestPrice < 4 ) then
        lowestPrice := 4;
      var factor: float;
      factor := highestPrice / lowestPrice;

      if( factor > timesChange ) then
      begin
        var rateOfChange: float = 0;
        var range: integer;
        range := (highestPriceBar-lowestPriceBar+1);
        if( range <> 0 ) then
           rateOfChange := factor * backDays / range;
        Print( GetSymbol + #9 + FormatFloat( '##.##', rateOfChange ) + #9 +
                FormatFloat( '##.##', factor ) + #9 + IntToStr( range ) + #9 +
                FormatFloat( '##.##', highestPrice ) + #9 +
                FormatFloat( '##.##', lowestPrice )); PrintFlush;
      end

    except
      continue;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1 := GetTickCount;

PrintRateOfChange();

n2 := GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

