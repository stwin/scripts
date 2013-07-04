{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program
var Bar: integer;
for Bar := 200 to BarCount - 1 do

  if LastPositionActive then

    if Bar + 1 >= PositionEntryBar(LastPosition) + 10 then
      SellAtMarket(Bar + 1, LastPosition, '10 days')
    else if PriceHigh(Bar) >= BBandUpper(Bar, #Close, 20, 2) then
      SellAtMarket(Bar + 1, LastPosition, 'Upper Band')
    else
      SellAtStop(Bar + 1, GetPositionRiskStop(LastPosition), LastPosition, 'StopLoss')

  else

    if SMA(Bar, #Close, 200) > SMA(Bar - 1, #Close, 200) then
      if StochD(Bar, 10, 3) < 30 then
      begin
        SetRiskStopLevel(Lowest(Bar, #Low, 5) - 0.10);
        if PriceClose(Bar) < PriceOpen(Bar) then
          BuyAtStop(Bar + 1, PriceHigh(Bar), 'Down Day')
        else
          BuyAtMarket(Bar + 1, 'Up Day');
      end;


