{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

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


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var Bar, lastPos: integer;

for Bar := 22*6 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    lastPos := LastPosition;
    SellAtLimit( Bar + 1, 1.5 * PositionEntryPrice( lastPos ), lastPos, 'Target' );
    {
    SellAtStop( Bar + 1, StopPrice, lastPos, StopStr );
    // If it has been 5 days, sell it
    if( ( Bar - PositionEntryBar( lastPos ) ) = 5-1 ) then
    begin
      SellAtMarket( Bar + 1, lastPos, '5 day');
    end;
    }
  end
  else
  begin
    if not LastPositionActive then
    begin
      if( Volume( bar ) < 30000 ) or ( PriceClose( bar ) < 4.0 )
          or ( PriceClose( bar ) > 6.0 ) then
        continue;
      var percentChange : float;
      percentChange := 100 * ( PriceClose( bar ) - PriceClose( bar-1 ) ) / PriceClose( bar-1 );
      if( percentChange >= 10 ) and ( HighestBar( bar, #Close, 66 ) = bar ) then
      begin
        BuyAtMarket( Bar + 1, 'Value Buy' );
      end;
    end;
  end;
end;


PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);
//PlotElderChannel (22, 6, 90);

