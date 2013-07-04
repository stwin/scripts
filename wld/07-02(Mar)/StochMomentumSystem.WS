{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'myScreenCommon'}
{$I 'myElderChSaved' }
{$I 'mynhnl'}

//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
VolumeColor();
PlotSeries( EMASeries( #close, 13), 0, 777, #thin );
PlotSeries( EMASeries( #close, 26), 0, #Maroon, #thin );
PlotElderChannelFromSavedDev();
PlotMACD (true);
PlotNHNLSeriesV2( 40, 0 );
PlotStochastic (7, 30, 70);
DisplayDay ();

//------------------------------------------------------------------------------

var NHSeries : integer = GetExternalSeries( 'NH-NL', #High );
var NLSeries : integer = GetExternalSeries( 'NH-NL', #Low );
//var upperChSeries : integer = FindNamedSeries( 'ElderUpperSeries' );
var chWidthPerSeries : integer = FindNamedSeries( 'ElderChannelWidthPercent' );
var ema22Series : integer = EMASeries( #Close, 22 );
var StochSeries : integer = StochDSeries( 7, 3 );
var chWidthSeries : integer = MultiplySeries( MultiplySeriesValue(chWidthPerSeries,0.01), ema22Series );

var bar: integer;
for bar := BarCount-50 to BarCount - 1 do
begin
  var nh, nl, upperCh, stoch, chWidth, chWidthPer, ema22, target, stop, iniStop: float;
  nh := @NHSeries[bar];
  nl := @NLSeries[bar];
  //upperCh := @upperChSeries[bar];
  chWidth := @chWidthSeries[bar];
  chWidthPer := @chWidthPerSeries[bar];
  ema22 := @ema22Series[bar];
  stoch := @stochSeries[bar];

  if LastPositionActive then
  begin
    if ((bar = PositionEntryBar(LastPosition)) and (iniStop > PriceLow(bar)) ) then
    begin
      Print( IntToStr(LastPosition) + #9 + FormatFloat('0.00',PositionEntryPrice(LastPosition))
            + #9 + FormatFloat('0.00',iniStop) );
      SellAtMarket(Bar + 1, LastPosition, 'Already stop hit');
    end
    else
    begin
      target := PositionEntryPrice(LastPosition) + 1.0 * chWidth;
      stop := iniStop;
      if( (PriceClose(bar)-PositionEntryPrice(LastPosition)) > 0.2*chWidth ) then
        stop := PositionEntryPrice(LastPosition);

      Print( IntToStr(LastPosition) + #9 + FormatFloat('0.00',PositionEntryPrice(LastPosition))
            + #9 + FormatFloat('0.00',iniStop)
            + #9 + FormatFloat('0.00',stop) + #9 + FormatFloat('0.00',target) );

      if ( Bar + 1 >= PositionEntryBar(LastPosition) + 2 ) then
        SellAtMarket(Bar + 1, LastPosition, '2 days')
      else if PriceHigh(Bar) >= target then
        SellAtMarket(Bar + 1, LastPosition, 'Target Hit')
      else
        SellAtStop(Bar + 1, stop, LastPosition, 'StopLoss');
    end;
  end
  else
  begin
    if ( (PriceClose(bar) > 6) and
         ( SMA(bar,#Volume,22) > 100000 ) and
         ( chWidthPer > 20 ) and
         ( nh - nl > 50 ) and
        ( EMA(Bar, #Close, 22) > EMA(Bar - 1, #Close, 22) ) and
        ( (StochD(Bar, 7, 3) >= 70) and (StochD(Bar-1,7,3) < 70) ) ) then
    begin
      iniStop := Lowest(Bar, #Low, 3);
      //if ( (PriceClose(bar)-iniStop) > (0.2*chWidth) ) then
      //  iniStop := PriceClose(bar) - 0.2 * chWidth;
      BuyAtMarket(Bar + 1, 'Up Day');
    end;
  end;
end;


