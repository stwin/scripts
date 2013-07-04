{$NO_AUTO_EXECUTE}

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function isNewLow (Bar, Period: integer): boolean;
begin
  var count: integer;
  result := true;
  if (BarCount < 5) then
  begin
    result := false;
    exit;
  end;
  if (BarCount < Period) then
    Period := BarCount-1;
  for count := 1 to Period do
  begin
    if (PriceLow (Bar) > PriceLow (Bar-count)) then
      result := false;
  end;
end;

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

var Bar, startBar: integer;


startBar := BarCount - 20;
if (startBar < 20) then
  startBar := 20;

//startBar := 40;

for Bar := startBar to BarCount - 1 do
begin
    if LastPositionActive then
      CoverAtClose (Bar, LastPosition, '');

    var priceChange1, priceChange2, priceChange3: float;
    priceChange1 := (PriceClose(Bar)-PriceOpen(Bar))*100/PriceOpen(Bar);
    priceChange2 := (PriceClose(Bar-1)-PriceOpen(Bar-1))*100/PriceOpen(Bar-1);
    priceChange3 := (PriceClose(Bar-2)-PriceOpen(Bar-2))*100/PriceOpen(Bar-2);

    // Entry Rules
    if (priceChange1 < -1.0) // Current Bar
        And (priceChange2 < -1.0) // Last Bar
        And (priceChange3 < -1.0) // 2nd Last Bar
      Then
    begin
      if (isNewLow (Bar, 30)) then
        ShortAtMarket (Bar+1, '');
        //ShowMessage ('Shorted');
    end;
end;
