(*Description...
This trading system is disclosed in the book "Trade Like a Hedge Fund" by James Altucher. It is one of a series called "The Wednesday Reversal" by the author.   The trading rules are: 

o Buy QQQ when the low of Tuesday is 5 percent less than the high from Monday (the wide-range condition) and the low of Tuesday is less than the low from Monday.  Buy at the open on Wednesday.
o Sell QQQ when two consecutive up closes occur.  Sell at the close of the second day.

This system is meant to trade only QQQ but....  Wednesdays are highlighted with background color on the chart.
   

*)
var Bar :integer;

for Bar:=2 to BarCount-1 do
begin

if DayOfWeek(Bar) = #Wednesday then
  SetBackGroundColor(Bar,#Yellow);

{-----Exit Trade-----}
if LastPositionActive then
  if PriceClose(Bar) > PriceClose(Bar-1) then
    if PriceClose(Bar-1) > PriceClose(Bar-2) then
      SellAtClose(Bar,LastPosition,'');

{-----Enter Trade-----}
if not LastPositionActive then
  if DayOfWeek(Bar) = #Tuesday then
    if PriceLow(Bar) <= 0.95*PriceHigh(Bar-1) then
      if PriceLow(Bar) < PriceLow(Bar-1) then
        BuyAtMarket(Bar+1,'');

end;
