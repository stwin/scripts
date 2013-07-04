{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );
{$I 'myScreenCommon'}
{$I 'myElderChSaved' }
//{$I 'myearnings' }
{$I 'mynhnl'}

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

if( BarCount < 150 ) then
  exit;

HideVolume;
VolumeColor ();
PlotVolume( 50 );

DisplayPercentChangeForLast5Bars ();
PlotSeries (EMASeries (#close, 11), 0, 777, #thin);
PlotSeries (EMASeries (#close, 22), 0, #Maroon, #thin);
PlotElderChannelFromSavedDev();
PlotMACD (true);
PlotNHNLSeriesV2( 40, 0 );
PlotStochastic (7, 30, 70);
DisplayDay ();

var NHSeries : integer = GetExternalSeries( 'NH-NL', #High );
var NLSeries : integer = GetExternalSeries( 'NH-NL', #Low );
//var upperChSeries : integer = FindNamedSeries( 'ElderUpperSeries' );
var chWidthPerSeries : integer = FindNamedSeries( 'ElderChannelWidthPercent' );
var ema22Series : integer = EMASeries( #Close, 22 );
var chWidthSeries : integer = MultiplySeries( MultiplySeriesValue(chWidthPerSeries,0.01), ema22Series );

var bar: integer;
for bar := 100 to BarCount - 1 do
begin
  var nh, nl, upperCh, chWidth, chWidthPer, ema22, target, stop, iniStop: float;
  nh := @NHSeries[bar];
  nl := @NLSeries[bar];
  //upperCh := @upperChSeries[bar];
  chWidth := @chWidthSeries[bar];
  chWidthPer := @chWidthPerSeries[bar];
  ema22 := @ema22Series[bar];
  
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
      target := ema22 + 0.4 * chWidth;
      stop := iniStop;
      if( (PriceClose(bar)-PositionEntryPrice(LastPosition)) > 0.2*chWidth ) then
        stop := PositionEntryPrice(LastPosition);

      Print( IntToStr(LastPosition) + #9 + FormatFloat('0.00',PositionEntryPrice(LastPosition))
            + #9 + FormatFloat('0.00',iniStop)
            + #9 + FormatFloat('0.00',stop) + #9 + FormatFloat('0.00',target) );

      if ( Bar + 1 >= PositionEntryBar(LastPosition) + 10 ) then
        SellAtMarket(Bar + 1, LastPosition, '10 days')
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
        ( StochD(Bar, 7, 3) < 30 ) ) then
    begin
      iniStop := Lowest(Bar, #Low, 5);
      if ( (PriceClose(bar)-iniStop) > (0.2*chWidth) ) then
        iniStop := PriceClose(bar) - 0.2 * chWidth;
      if PriceClose(Bar) < PriceOpen(Bar) then
        BuyAtStop(Bar + 1, PriceHigh(Bar), 'Down Day')
      else
        BuyAtMarket(Bar + 1, 'Up Day');
    end;
  end;
end;

