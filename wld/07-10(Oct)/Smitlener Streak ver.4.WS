(*Description...
I played a little with Smitlener Streak system that Cone developed. 
<br>
<br>I have tried to do it more friendly for guys with lower starting capital, e.g. 10000$.  It works particulary well on SP100. Also good on Nasdaq.
<br>
<br>System enters after three consecutive lows instead of two.
<br>
<br>Instead of placing BuyAtMarket(bar+1) it is buying at limit price set at tommorow open price less one fourth of ATR(7) ( BuyAtLimit(OpenPrice(bar+1)-ATR(7)/4 ...)
<br>
<br>On long term doesn't affect profitability, but somehow decrease max drawdown on short term.

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
PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
PlotElderChannelOnTheFly( 22, 6, 90 );
//------------------------------------------------------------------------------



const DOLLARSIZE = 2000;
const MAXPOSITIONS = 3;
const FMT = '0.000';
var Bar, p, APCount: integer;
var CondIn, CondOut: boolean;
var FinalSize, fRSI: float;
var Price, ExitPrice: float;

EnableTradeNotes( true, true, true );
for Bar := 3 to BarCount - 2 do
begin
{ Exit Logic - exit all position after two consecutive up closes }
  CondOut := ( PriceClose( Bar ) > PriceClose( Bar - 1 ) )
         and ( PriceClose( Bar - 1 ) > PriceClose( Bar - 2 ) );

  if CondOut then
    SellAtMarket( Bar + 1, #All, '' )
  else
  begin
    CondIn := ( PriceClose( Bar ) < PriceClose( Bar - 1 ) )
          and ( PriceClose( Bar - 1 ) < PriceClose( Bar - 2 ) )
          and ( PriceClose( Bar - 2 ) < PriceClose( Bar - 3 ) );

    APCount := ActivePositionCount;
    if APCount = 0 then
      FinalSize := DOLLARSIZE
    else if APCount <= MAXPOSITIONS then
      FinalSize := DOLLARSIZE * ( APCount + 1 )
    else
      CondIn := false;

    if CondIn then
    begin
    { $imulator Priority given to the lowest RSI (most oversold) }
      SetPositionSize( FinalSize );
      fRSI := RSI( Bar, #Close, 14 );

      // Modified this to avoid peeking
      Price := PriceClose(Bar) - ATR(Bar,7)/4;

      if BuyAtLimit( Bar + 1, Price, 'RSI: ' + FormatFloat( FMT, fRSI ) ) then
        SetPositionPriority( LastPosition, -fRSI );
    end;
  end;
end;
AddScanColumn( 'RSI', RSI( BarCount - 1, #Close, 14 ) );


