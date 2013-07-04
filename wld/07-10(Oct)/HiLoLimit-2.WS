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
//PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
//PlotElderChOnTheFly( 26, 132, 90 );
//------------------------------------------------------------------------------

// Edited by pklaerner 7/31/2003
// Added wrap-around RSI filter to only initiate trades
// in 'buying' zone - limits brokerage commissions since
// orders only placed in relevant zones.

// Basic HiLoLimit Trader (friendly)
// by DrKoch 2004-03-15

// include three modules from Code Library (www)
// or Indicator directory (WLD)
// {$I 'BandTrader'}
{$I 'Plot Equity'}
{$I 'HiLoLimit'}
{$I 'WinLossBackground'}

//// Variables
var HLRSI_length: integer;
var HLRSI_Buy, HLRSI_Sell: float;
HLRSI_length := 5; // Length of RSI data
HLRSI_Buy := 35; // Buying area threshold
HLRSI_Sell:=50; // Selling area threshold
var lookback_period, hilo_level, timeout: integer;
var minrange, profit_target: float;
var hilo_s, hs, ls: integer; // Series
var limitPrice: float;
var P: integer; // Positions

//// Parameters
lookback_period := 14; // number of bars to look back for Highest/Lowest determination
hilo_level := -10; // calculate limit this level *below* Lowest
minrange := 0.0; // unused here, useful for Intraday Data or low volume data
profit_target := 1.7; // was 1.7 // Profit Target in percent
timeout := 5; // was 7 // Timeout in Bars
// Calculate Highest and Lowest (for Graphics only)
hs := HighestSeries( #High, lookback_period );
ls := LowestSeries( #low, lookback_period );

// Calculate HiLo level series (uses Highest/Lowest internally)
hilo_s := HiLoLimitSeries(lookback_period, hilo_level, minrange);


// Plot Highest and Lowest
PlotSeriesLabel(hs, 0, #Green, #Thin,
    'Highest(' + IntToStr(lookback_period) + ')');
PlotSeriesLabel(ls, 0, #Blue, #Thin,
    'Lowest(' + IntToStr(lookback_period) + ')');

// Plot Limit in red
PlotSeriesLabel(hilo_s, 0, 955, #Thin,
    'Limit := Lowest - (Hi - Lo) * ' + FloatToStr(hilo_level/100));

// Plot Limit used in Bandtrader (Limit price from yesterday)
PlotSeriesLabel(OffsetSeries( hilo_s, -1), 0, #Red, #Thick,
    'Limit Price');

//// Band Violation Trading System
// contains BuyAtLimit() commands
// BandTrader(hilo_s, profit_target, timeout);

begin
  var Bar: integer;

  InstallProfitTarget ( profit_target );
  for Bar := 0 to BarCount() - 1 do begin

    ApplyAutoStops( Bar );

    limitPrice := GetSeriesValue(Bar, hilo_s);
    if limitPrice = 0.0 then continue;

if (RSI(Bar,#close,HLRSI_length)<=HLRSI_Buy) then
    BuyAtLimit(Bar + 1, limitPrice, 'HiLo Band Buy');;;
    // close positions that get too old
    for P := 0 to PositionCount - 1 do begin
      if PositionActive( P ) then begin
        if bar + 1 - PositionEntryBar( p ) >= timeout then begin
        if PriceClose(bar)>1.001*PositionEntryPrice( p) then
        SellAtMarket( Bar + 1, P, 'HiLo DaysExpired' );
        if (RSI(Bar,#close,HLRSI_length)>=HLRSI_Sell) then
        SellAtMarket( Bar + 1, P, 'HiLo DaysExpired' );;
        end;
      end;
    end;
  end;
end;

//// Visualize Results
// show profits as background color
WinLossBackground(2);

