(*Wizard...
*S|Enter Long next Bar at Market`BuyAtMarket( Bar + 1, <#RuleSet> );
``Basic Long Entries`9``0`0`0`|StochD is Oversold`if @<#StochDSer>[Bar] < <#Oversold Level> then
`<#StoPane> := CreatePane( 75, true, true );
PlotSeries( <#StochDSer>, <#StoPane>, #Blue, #Thin );
DrawLabel( 'StochD(<#Period>)', <#StoPane> );
DrawHorzLine( <#Overbought Level>, <#StoPane>, #Silver, #Dotted );
DrawHorzLine( <#Oversold Level>, <#StoPane>, #Silver, #Dotted );
`Stochastics (StochD)`225`<#StochDSer> := StochDSeries( <#Period>, <#Smooth> );
`4`4`2`10^Period^0^`3^Smooth^0^`80^Overbought Level^1^`20^Oversold Level^1^`StochDSer~StochDSer~0~`StoPane~StoPane~0~`|EMA Moving Up`if EMA( Bar, <#Price>, <#Period> ) > EMA( Bar - <#Lookback>, <#Price>, <#Period> ) then
`PlotSeries( EMASeries( <#Price>, <#Period> ), 0, #Red, #Thick );
`Exponential Moving Average`50``4`3`0`#Close^Price^2^`200^Period^0^`1^Lookback^0^`|Exit Long Percentage Profit Target`<#TargetPrice> := PositionEntryPrice( p ) * <#Target>;
SellAtLimit( Bar + 1, <#TargetPrice>, p, 'Profit Target' );
``Basic Long Exits`18`<#Target> := 1 + ( <#Target Pct> / 100 );
`1`1`2`10^Target Pct^1^`Target~Target~1~`TargetPrice~TargetPrice~1~`|Exit Long next Bar at Market`SellAtMarket( Bar + 1, p, '' );
``Basic Long Exits`13``1`0`0`|Price Crosses above Upper Bollinger Band`if CrossOver( Bar, <#Price>, <#BBUp> ) then
`PlotSeries( <#BBUp>, 0, 559, #Thick );
`Bollinger Bands`1`<#BBUp> := BBandUpperSeries( <#BBand Series>, <#BBand Period>, <#BBand Std Dev> );
`4`4`1`#Close^Price^2^`#Close^BBand Series^2^`20^BBand Period^0^`2^BBand Std Dev^1^`BBUp~BBUp~0~`|Exit Long Percentage Stop Loss`<#StopPrice> := PositionEntryPrice( p ) * <#Stop>;
SellAtStop( Bar + 1, <#StopPrice>, p, 'Stop Loss' );
``Basic Long Exits`17`<#Stop> := 1 - ( <#Stop Pct> / 100 );
`1`1`2`5^Stop Pct^1^`Stop~Stop~1~`StopPrice~StopPrice~1~`|
*)
var StochDSer, StoPane, BBUp: integer;
var Target, TargetPrice, Stop, StopPrice: float;
var Bar, p: integer;
StochDSer := StochDSeries( 10, 3 );
Target := 1 + ( 10 / 100 );
BBUp := BBandUpperSeries( #Close, 20, 2 );
Stop := 1 - ( 5 / 100 );
StoPane := CreatePane( 75, true, true );
PlotSeries( StochDSer, StoPane, #Blue, #Thin );
DrawLabel( 'StochD(10)', StoPane );
DrawHorzLine( 80, StoPane, #Silver, #Dotted );
DrawHorzLine( 20, StoPane, #Silver, #Dotted );
PlotSeries( EMASeries( #Close, 200 ), 0, #Red, #Thick );
PlotSeries( BBUp, 0, 559, #Thick );
for Bar := 200 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    p := LastPosition;
    TargetPrice := PositionEntryPrice( p ) * Target;
    SellAtLimit( Bar + 1, TargetPrice, p, 'Profit Target' );
    if CrossOver( Bar, #Close, BBUp ) then
    begin
      SellAtMarket( Bar + 1, p, '' );
    end;
    StopPrice := PositionEntryPrice( p ) * Stop;
    SellAtStop( Bar + 1, StopPrice, p, 'Stop Loss' );
  end
  else
  begin
    if not LastPositionActive then
    begin
      if @StochDSer[Bar] < 20 then
      begin
        if EMA( Bar, #Close, 200 ) > EMA( Bar - 1, #Close, 200 ) then
        begin
          BuyAtMarket( Bar + 1, '0' );
        end;
      end;
    end;
  end;
end;
