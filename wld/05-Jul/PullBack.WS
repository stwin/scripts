{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
const Period = 4;
var Bar, h: integer;
var Pullback, BullishBar: boolean;
var PullDown, BearishBar: boolean;

{ "Bullish" bars will have values less than 0.25 }
h := DivideSeries(
      SubtractSeries( #High, #Close ),
      SubtractSeries( #High, #Low ) );

for Bar := Period to BarCount - 1 do
begin
  // Pull Back
  if not Pullback then
    Pullback := PriceLow( Bar ) <= Lowest( Bar - 1, #Low, 3 );

  BullishBar := @h[Bar] < 0.25;
  if Pullback and BullishBar then
  begin
    SetBarColor( Bar, #Blue );
    if PriceClose( Bar ) >= Highest( Bar - 1, #High, Period ) then
    begin
      SetBackgroundColor( Bar, 779 );
      Pullback := false; // ignore signals until next pullback
    end;
  end;

  // Pull Down
  if not PullDown then
    PullDown := PriceHigh( Bar ) >= Highest( Bar - 1, #High, 3 );

  BearishBar := @h[Bar] > 0.75;
  if PullDown and BearishBar then
  begin
    SetBarColor( Bar, 422 );
    if PriceClose( Bar ) <= Lowest( Bar - 1, #Low, Period ) then
    begin
      SetBackgroundColor( Bar, 977 );
      PullDown := false; // ignore signals until next pullback
    end;
  end;
end;


