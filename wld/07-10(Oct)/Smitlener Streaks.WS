(*Description...
Based on Damir Smitlener's article "Where Is The Weakest Link?" in the December 2004 issue of <i>Stocks and Commodities</i> magazine, p. 42.

<br>
<br></p><hr><b>Trading System Rules:  </b>
<br>1. Buy a small position upon detecting 2 consecutive lower closes.
<br>2. Add a position each time you detect the condition above.
<br>3. Exit all positions when upon detecting 2 consecutive higher closes.
<br>4. In case of limited cash, choose the trade with the lowest 14-day RSI
<br>
<br><hr><b>Notes: </b>
<br>1. The author talks about "red" and "green" streaks without defining exactly what he means by red and green.  I took this to mean that red is a lower close than the previous bar, and green is a higher close.   (When using candlestick coloring, you can have a "red" bar - a close lower than the open - even though the close is greater than the previous close.)
<br>
<br>2. By selecting the "SetShare/PositionSize Value" for the Position Sizing control, the ChartScript increases the size as positions are added.  Control the initial bet and number of positions by adjusting the constants.
<br>
<br>3. The system works rather well, but trades often.  As explained in the article, risk is controlled by sizing (small).   If you decide to trade this system or a variant of it, you'll need a low-commission broker.

*)
{{$NO_AUTO_EXECUTE}
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




const DOLLARSIZE = 2000;
const MAXPOSITIONS = 3;
const FMT = '0.000';
var Bar, p, APCount: integer;
var CondIn, CondOut: boolean;
var FinalSize, fRSI: float;

EnableTradeNotes( true, true, true );
for Bar := 2 to BarCount - 1 do
begin
{ Exit Logic - exit all position after two consecutive up closes }
  CondOut := ( PriceClose( Bar ) > PriceClose( Bar - 1 ) )
         and ( PriceClose( Bar - 1 ) > PriceClose( Bar - 2 ) );

  if CondOut then
    SellAtMarket( Bar + 1, #All, '' )
  else
  begin
    CondIn := ( PriceClose( Bar ) < PriceClose( Bar - 1 ) )
          and ( PriceClose( Bar - 1 ) < PriceClose( Bar - 2 ) );

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
      if BuyAtMarket( Bar + 1, 'RSI: ' + FormatFloat( FMT, fRSI ) ) then
        SetPositionPriority( LastPosition, -fRSI );
    end;
  end;
end;
AddScanColumn( 'RSI', RSI( BarCount - 1, #Close, 14 ) );


