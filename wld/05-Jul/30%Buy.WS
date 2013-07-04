{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var StopPrice: float;
var StopStr: String;
var Bar, lastPos: integer;

var magicPercent: float;

magicPercent := 30;

for Bar := 44 to BarCount - 1 do
begin
  if LastPositionActive then
  begin
    lastPos := LastPosition;
    if( LastLongPositionActive ) then
      SellAtClose( bar, lastPos, 'cover');
      
    if( LastShortPositionActive ) then
      CoverAtClose( bar, lastPos, 'cover');
    {
    //if( PriceClose( bar ) > PositionEntryPrice( lastPos )) then
    //  StopPrice := PositionEntryPrice( lastPos );
    SellAtStop( Bar + 1, StopPrice, lastPos, 'stoploss' );
    // If it has been 5 days, sell it
    if( ( Bar - PositionEntryBar( lastPos ) ) = 5-1 ) then
    begin
      SellAtMarket( Bar + 1, lastPos, '5 day');
    end;
    }
  end
  else
  begin
    if not LastPositionActive then
    begin
      var percentChange: float;
      percentChange := 100 * (PriceClose( bar ) - PriceClose( bar-1 )) / PriceClose( bar-1 );
      if (PriceClose( bar ) > PriceOpen( bar )) // green bar
          and (percentChange > magicPercent)   // cutoff change
          then
      begin
        var inBar: integer;
        var unexpected: boolean = true;
        for inBar := bar-22 to bar-1 do
        begin
          var pChange: float;
          pChange := 100 * (PriceClose( inBar ) - PriceClose( inBar-1 )) / PriceClose( inBar-1 );
          if( pChange > magicPercent ) then
            unexpected := false;
        end;
        if unexpected then
        begin
          if( PriceOpen( Bar+1 ) > PriceClose( Bar )) then
            ShortAtMarket( Bar + 1, 'magicPercent Buy' )
          else
            BuyAtMarket( Bar + 1, 'magicPercent Buy' )
          //StopPrice := (PriceClose( bar ) + PriceOpen( bar )) / 2;
        end;
      end;
    end;
  end;
end;

PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);


