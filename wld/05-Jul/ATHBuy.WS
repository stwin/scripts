{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
// Draws Label in bigger font on the price pane
var myDrawLabelX: integer = 45;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 5, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;
///////////////////////////////////////////////////////////////////////////////
function getElderChannelDeviation (currentBar, period: integer;
                loopbackmonth, cutoffPercent : integer): float;
begin
  var deviation: float;
  var bar: integer;

  // First get an approximate value for deviation
  deviation := 0;
  for bar := currentBar-9 to currentBar do // last 10 days
  begin
    var range: float;
    range := Max (PriceHigh (bar) - EMA (bar, #Close, period),
                  EMA (bar, #Close, period) - PriceLow (bar));
    if (range < 0) then
      Abort;
    deviation := deviation + range;
  end;
  deviation := deviation / 10; // Avg deviation
  deviation := deviation / EMA(currentBar, #Close, period); // as fraction of EMA

  // fit on last couple of months by iteration, to get a good value of deviation
  var countLoop: integer;
  var percentIn: integer;
  percentIn := 0;
  countLoop := 0;
  while ((countLoop < 20) and (percentIn < cutoffPercent)) do
  begin
    countLoop := countLoop + 1;
    var totalIn, loopbackbar: integer;
    totalIn := 0;
    if isDaily then loopbackbar := loopbackmonth * 22
    else loopbackbar := loopbackmonth * 4;
    for bar := currentBar-loopbackbar-1 to currentBar do
    begin
      if ((PriceClose(bar) < (EMA (bar, #Close, period) *(1+deviation)))
          and (PriceClose(bar) > (EMA (bar, #Close, period) * (1-deviation)))
          ) then
        totalIn := totalIn + 1;
    end;
    percentIn := 100*totalIn / loopbackbar;
    if (percentIn < cutoffPercent) then
      deviation := deviation * 1.1;
    //Print (IntToStr(percentIn) + '  ' + IntToStr (totalIn) + '  ' + '   ' + floatToStr(deviation));printflush();
  end;

  // return deviation
  Result := deviation;
end;
///////////////////////////////////////////////////////////////////////////////
procedure PlotElderChannel (period: integer; loopbackmonth, cutoffPercent : integer);
begin
  var deviation: float;

  deviation := getElderChannelDeviation (BarCount-1, period, loopbackmonth, cutoffPercent);

  var upperSeries, lowerSeries: integer;
  upperSeries := MultiplySeriesValue (EMASeries(#close, period), (1+deviation));
  lowerSeries := MultiplySeriesValue (EMASeries(#close, period), (1-deviation));

  PlotSeries (upperSeries, 0, #Teal, #thin);
  PlotSeries (lowerSeries, 0, #Teal, #thin);

  MyDrawLabel ('ChannelWidth ('
     + IntToStr(cutoffPercent)
     + ', '
     + FormatFloat('#', 2*deviation*100)
     + '%): '
     + FormatFloat('#.##', @upperSeries[BarCount-1]-@lowerSeries[BarCount-1]),
     #Black);
end;
///////////////////////////////////////////////////////////////////////////////
function trendIsUp (currentBar: integer): boolean;
begin
  var bar: integer;
  Result := true;
  for bar := currentBar - 14 to currentBar do
  begin
    if( EMA( bar, #Close, 22 ) < EMA( bar-1, #Close, 22 ) ) then
    begin
      Result := false;
      break;
    end;
  end
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

var TargetPrice, StopPrice: float;
var TargetStr, StopStr: String;
var Bar, lastPos: integer;

for Bar := 22*6 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    lastPos := LastPosition;
    SellAtLimit( Bar + 1, TargetPrice, lastPos, TargetStr );
    SellAtStop( Bar + 1, StopPrice, lastPos, StopStr );
    // If it has been 5 days, sell it
    if( ( Bar - PositionEntryBar( lastPos ) ) = 5-1 ) then
    begin
      SellAtMarket( Bar + 1, lastPos, '5 day');
    end;
  end
  else
  begin
    if not LastPositionActive then
    begin
      if( Volume( bar ) < 10000 ) or ( PriceClose( bar ) < 4.0 ) then
        continue;
      var isGreen, isHammer: boolean;
      if( PriceClose( bar ) > PriceOpen( bar ) ) then
        isGreen := true
      else
        isGreen := false;
      var downTail, body, upTail: float;
      if( isGreen ) then
      begin
        upTail := PriceHigh( bar ) - PriceClose( bar );
        body := PriceClose( bar ) - PriceOpen( bar );
        downTail := PriceOpen( bar ) - PriceLow( bar );
      end
      else
      begin
        upTail := PriceHigh( bar ) - PriceOpen( bar );
        body := PriceOpen( bar ) - PriceClose( bar );
        downTail := PriceClose( bar ) - PriceLow( bar );
      end;
      if( (downTail > 2*body) and (downTail > 2*upTail) ) then
        isHammer := true
      else
        isHammer := false;
      if  ( isHammer )
          //and trendIsUp( bar )   // up trend
          //and (HighestBar( bar, #High, bar-1 ) > bar-10 ) // highest bar very close by
          and (PriceHigh( bar ) > EMA( bar, #Close, 22 )) // above slow ema
          and (PriceClose( bar ) < EMA( bar, #Close, 11 )) // below fast ema
          then
      begin
        BuyAtMarket( Bar + 1, 'Value Buy' );
        TargetPrice := PriceClose( bar ) * 1.02;
        StopPrice := PriceClose( bar ) * 0.96;
        TargetStr := 'Target: ' + FormatFloat( '#.##', TargetPrice );
        StopStr := 'Stoploss: ' + FormatFloat( '#.##', StopPrice );

        {
        var deviation, channelRange: float;
        deviation := getElderChannelDeviation( bar, 22, 6, 90 );
        TargetPrice :=  PriceClose( bar ) * (1 + deviation/2);
        StopPrice := PriceClose( bar ) * (1 - deviation/2);
        TargetStr := 'Target: ' + FormatFloat( '#.##', deviation )
                            + ': ' + FormatFloat( '#.##', TargetPrice );
        StopStr := 'Stoploss : ' + FormatFloat( '#.##', deviation )
                            + ': ' + FormatFloat( '#.##', StopPrice );
        }
        SellAtLimit( Bar + 1, TargetPrice, lastPos, TargetStr );
        SellAtStop( Bar + 1, StopPrice, lastPos, StopStr );
        //Print( GetSymbol + ' = ' + TargetStr + ' = ' + StopStr );
      end;
    end;
  end;
end;

PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);
PlotElderChannel (22, 6, 90);


