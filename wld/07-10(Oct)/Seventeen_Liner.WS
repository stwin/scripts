(*Description...
same as 'A sixteen-liner', with one more filtering rule... 
<br>now more than 200% APR  with a Sharpe Ratio &gt; 2.5
<br>
<br>based on previous work of
<br><a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/profile?user=DrKoch">DrKoch</a> (<a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/editsystem?id=39189">A Seven-Liner</a>)
<br><a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/profile?user=gbeltrame">gbeltrame</a> (<a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/editsystem?id=39128">An eight-liner</a>)

<br><a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/profile?user=Cone">Cone</a> (<a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/editsystem?id=35373">Smitlener Streaks</a>)
<br><a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/profile?user=klemenv">klemenv</a> (<a href="http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/editsystem?id=35553">Smitlener Streak ver.4</a>)
<br>
<br>main changes:
<br>
<br>  * filtering criteria:
<br>    - dont enter if price is recovering 'too fast' (computing short-term slope of ROC)

<br>    - dont enter if the line chart is 'too straight' (checking normalized error of a linear fit: StdError/Close - see note below) 
<br>    - dont enter if today's Volume is 'too high' (compared to its SMA)
<br>    - dont enter if last several bars were 'too weak' (looking at highest RSI value)
<br>    - dont enter if today's candlestick is 'too bullish' (whiteline, without lower shadow)
<br>    - dont enter if volatility is 'too low' (measured by ATRP - see note below)
<br>
<br>    note: using StdError alone (or using ATR instead of ATRP) would invalidate backtesting (simulated past trading history would change after a stock split)
<br>    this is to warn current users of 'Safe Gainer' or 'LongTermTrend' or 'StdErrPullBack', currently among 20 most popular scripts <img src="images/smileys/wink.gif" border="0" height="15" width="15">
<br>

<br>  * [multiple] positions management, based on both ActivePositions and Priority
<br>
<br>
<br>has been optimized for the WL100 benchmark watchlist,
<br>but seems to perform well on any watchlist with many symbols (100 or more...)

*)
{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'myScreenCommon'}


//______________________________________________________________________________
//
//------------------------------------------------------------------------------


//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
VolumeColor();
PlotSeries( EMASeries( #close, 13), 0, 777, #thin );
PlotSeries( EMASeries( #close, 26), 0, #Maroon, #thin );
PlotElderChannelOnTheFly( 26, 12, 90 );
//------------------------------------------------------------------------------

var Bar, i, n: integer;
for Bar := FirstActualBar + 31 to BarCount - 1 do
  if Lowest(Bar, ROCSeries(#Close, 1), 2) > 0 then SellAtMarket(Bar + 1, #All, '')
  else if (52 * Highest(Bar, ROCSeries(#Close, 1), 3) < 15 + 12 * StdDev(Bar, ROCSeries(#Close, 1), 31))
    and (3 * LinearRegSlope(Bar, ROCSeries(#Close, 1), 3) < 19)
    and (Highest(Bar - 1, RSISeries(#Close, 31), 31) > 60)
    and (46 * StdError(Bar, #Close, 31) > PriceClose(Bar))
    and (53 * SMA(Bar, #Volume, 31) > 24 * Volume(Bar))
    and (PriceOpen(Bar) > PriceLow(Bar))
    and (3 * ATRP(Bar, 31) > 7) then
    begin
      var Priority: float = TurnUp(Bar, #Close) + TurnDown(Bar, #Close) - ROC(Bar, #Close, 4);
      n := 1 + ActivePositionCount; if n > 16 then n := 1;
      if n < Priority then n := trunc(Priority);
      for i := 1 to n do
        if BuyAtMarket(Bar + 1, FloatToStr(Priority - i)) then SetPositionPriority(LastPosition, Priority - i);
    end;
    
PlotSeries( SMASeries( #Volume, 31), 1, 777, #thin );

var ROCPANE: integer;
ROCPane := CreatePane( 75, true, true );
PlotSeries( ROCSeries( #Close, 1 ), ROCPane, 005, #ThickHist );

var ATRPPANE: integer;
ATRPPane := CreatePane( 75, true, true );
PlotSeries( ATRPSeries( 31 ), ATRPPane, 005, #ThickHist );



