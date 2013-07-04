{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

var bar, startBar: integer;

//startBar := 1;
startBar := DateToBar(20010102);

for bar := startBar to BarCount-1 do
begin
  var change: float;

  // A big drop
  change := 100*(PriceClose(bar-1)-PriceLow(bar))/PriceClose(bar-1);
  if( change > 4 ) then
  begin
    Print( IntToStr(GetDate( bar )) + #9 + FormatFloat( '0.00', change ) ); PrintFlush();
    SetBackgroundColor( bar, 960 );
    if( LastPositionActive ) then
      SellAtMarket( bar, LastPosition, 'Big Drop' )
    else
      BuyAtMarket( bar, 'Big Drop' );
  end;
  
  // A big rise
  change := 100*(PriceHigh(bar)-PriceClose(bar-1))/PriceClose(bar-1);
  if( change > 4 ) then
  begin
    Print( IntToStr(GetDate( bar )) + #9 + FormatFloat( '0.00', change ) ); PrintFlush();
    SetBackgroundColor( bar, 960 );
    if( LastPositionActive ) then
      SellAtMarket( bar, LastPosition, 'Big Rise' )
    else
      BuyAtMarket( bar, 'Big Rise' );
  end;
end;

var closePrev, dropSeries, riseSeries, zeroS, fiveS: integer;
closePrev := OffsetSeries( #Close, -1 );
riseSeries := MultiplySeriesValue( DivideSeries( SubtractSeries(#High, closePrev), closePrev ), 100 );
dropSeries := MultiplySeriesValue( DivideSeries( SubtractSeries(closePrev, #Low), closePrev ), 100 );
SetDescription( riseSeries, 'RiseSeries' );
SetDescription( dropSeries, 'DropSeries' );
zeroS := MultiplySeriesValue( #Low, 0 );
fiveS := AddSeriesValue( zeroS, 5 );
var tinyPane: integer = CreatePane( 60, false, false );
PlotSeries( riseSeries, tinyPane, 162, 0 );
PlotSeries( dropSeries, tinyPane, 611, 0 );
PlotSeries( zeroS, tinyPane, 000, 0 );
PlotSeries( fiveS, tinyPane, 000, 0 );

