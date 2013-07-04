{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

var bar: integer;

if( SMA(BarCount-1, #Volume, BarCount-1) < 5000 ) then
  exit;

for bar := 2 to BarCount-3 do
begin
  // Take care of the big gaps at opening (avg. does not work here)
  if( LastBar(bar+1) or LastBar(bar) or LastBar(bar-1) or LastBar(bar-2)  ) then
    continue;
    
  var avgHigh, avgLow, avgRange: float;

  // Find averages for neighboring 4 bars (2 left, 2 right)
  avgHigh := (PriceHigh(bar-2) + PriceHigh(bar-1) + PriceHigh(bar+1) + PriceHigh(bar+2))/4;
  avgLow := (PriceLow(bar-2) + PriceLow(bar-1) + PriceLow(bar+1) + PriceLow(bar+2))/4;
  avgRange := avgHigh - avgLow;
  
  // Test for a UP Tail
  if( PriceHigh(bar) > (avgHigh + 3*avgRange) ) then
  begin
    var reasonableHigh: float;
    reasonableHigh := avgHigh + avgRange;
    reasonableHigh := Max( reasonableHigh, PriceOpen(bar) );
    reasonableHigh := Max( reasonableHigh, PriceClose(bar) );
    DrawLine( bar-1, reasonableHigh, bar+1, reasonableHigh, 0, 009, 0 );
    SetBackgroundColor( bar, 679 );
  end;
  
  // Test for a DOWN Tail
  if( PriceLow(bar) < (avgLow - 3*avgRange) ) then
  begin
    var reasonableLow: float;
    reasonableLow := avgHigh + avgRange;
    reasonableLow := Min( reasonableLow, PriceOpen(bar) );
    reasonableLow := Min( reasonableLow, PriceClose(bar) );
    DrawLine( bar-1, reasonableLow, bar+1, reasonableLow, 0, 009, 0 );
    SetBackgroundColor( bar, 976 );
  end;
end;
  


