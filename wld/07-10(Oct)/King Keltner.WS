(*Description...
This trading system is fully disclosed in the book "Building Winning Trading Systems with TradeStation," by George Pruitt and John R. Hill. The system is based on one originally developed by Chester Keltner, hence the name.

Pruitt and Hill are the principals of Futures Truth, the independent trading system testing company. In that capacity they have seen and forward tested literally thousands of trading systems and have developed informed opinions about what works and what doesn't work in the markets. Their recommendations thus merit consideration.

The price trend is defined by the 40-day simple moving average of the average daily price, (H+L+C)/3. The channel boundaries are established at a multiple of one times the 40-day simple moving average of the ATR above and below the price SMA. Enter a trade position the next day on the side of the price trend at the channel, stop. Exit a position when the price returns to its SMA, stop.

This system is not optimized but clearly could benefit from it since the parameters were originally set for the futures markets. Inspection of stock trade logs revealed that trades were being exited and entered on the same bar and the code was restructured to preclude this. The SMA period could be adjusted to better track stock price action. The channel half-width, W, could be adjusted to better contain more of the price action. Inspection of the charts reveals that some trades are being entered after the price gaps outside of the channel. This violates the spirit if not the rules of the system and may be suppressed by requiring the high/low price to be inside the channel on signal day. These conditions may be activated by removing the comment braces {} around them in the code. 

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
PlotElderChOnTheFly( 26, 132, 90 );
//------------------------------------------------------------------------------


var Bar,kSMA,UpBnd,LoBnd,per1:integer;
var W:float;
W:=1.0; {channel halfwidth,ATR}
per1:=40; {period of price and band SMAs}
kSMA:=SMASeries(#AverageC,per1);
UpBnd:=AddSeries(kSMA,MultiplySeriesValue
  (ATRSeries(per1),W));
LoBnd:=SubtractSeries(kSMA,MultiplySeriesValue
  (ATRSeries(per1),W));

for Bar:=per1 to BarCount-1 do
begin

  {Exit trades}
  if LastPositionActive then
  begin
    if PositionLong(LastPosition) then
      SellAtStop(Bar+1,@kSMA[Bar],LastPosition,'');
    if PositionShort(LastPosition) then
      CoverAtStop(Bar+1,@kSMA[Bar],LastPosition,'');
  end
  else

  {Enter trades}
  begin
    if @kSMA[Bar]>@kSMA[Bar-1] then
      {if PriceHigh(Bar)<@UpBnd[Bar] then}
        BuyAtStop(Bar+1,@UpBnd[Bar],'');
    if @kSMA[Bar]<@kSMA[Bar-1] then
      {if PriceLow(Bar)>@LoBnd[Bar] then}
        ShortAtStop(Bar+1,@LoBnd[Bar],'');
  end;
end;

{Plotting}
PlotSeriesLabel(kSMA,0,066,#Thick, 'Price SMA');
PlotSeriesLabel(UpBnd,0,#Blue,#Dotted, 'Up Band');
PlotSeriesLabel(LoBnd,0,#Blue,#Dotted, 'Lo Babd');
//DrawLabel('Price SMA - solid line',0);
//Drawlabel('Up/LoBand - dotted line',0);


