(*Description...
I found this script in one of my working folders and remembered how interesting it was.  The script test the theory that "all gaps are eventually closed".  It looks for substantial down gaps, and enters the next day at market.  It attempts to close an open position at the limit price of the pre-gap bar low.

The script can manage multiple open positions if there are several successive gap downs.

The script reports on the number of gaps, and the percentage of gaps that were closed.

*)
var GAPDOWN, GAPCLOSE: float;
var GAPUPS, GAPUPSCLOSED, BAR, BAR2, P: integer;

GapUps := 0;
GapUpsClosed := 0;
for Bar := 20 to BarCount - 1 do
begin
  for p := 0 to PositionCount - 1 do
    if PositionActive( p ) then
      SellAtLimit( Bar + 1, GetPositionData( p ), p, '' );
  GapDown := PriceLow( Bar - 1 ) - PriceHigh( Bar );
  if GapDown > ATR( Bar, 20 ) then
  begin
    Inc( GapUps );
    GapClose := PriceLow( Bar - 1 );
    BuyAtMarket( Bar + 1, '' );
    SetPositionData( LastPosition, GapClose );
    SetBarColor( Bar, #Blue );
    SetBarColor( Bar - 1, #Blue );
    for Bar2 := Bar + 1 to BarCount - 1 do
    begin
      if PriceHigh( Bar2 ) >= GapClose then
      begin
        Inc( GapUpsClosed );
        Break;
      end;
    end;
    if Bar < BarCount then
      if Bar2 < BarCount then
        DrawLine( Bar - 1, GapClose, Bar2, GapClose, 0, #Blue, #Dotted );
  end;
end;

DrawLabel( IntToStr( GapUps ) + ' Gap Downs', 0 );
if GapUps > 0 then
  DrawLabel( IntToStr( GapUpsClosed ) + ' Closed (' + FormatFloat( '#0.0%', GapUpsClosed * 100 / GapUps ) + ')', 0 );
  
