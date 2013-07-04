{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );

{$I 'mycommon'}
{$I 'mynhnl'}


///////////////////////////////////////////////////////////////////////////////

if( (GetSymbol() = 'SP-500') or (GetSymbol() = 'DJ-30') or (GetSymbol() = 'COMPQX') ) then
  HideVolume
else
  VolumeColor();

try
  if( IsWeekly ) then
  begin
    //MyDrawLabel( 'EMA: 13, 26', #Black );
    PlotSeries( BetterEMASeries( #close, 13), 0, 777, #thin );
    PlotSeries( BetterEMASeries( #close, 26), 0, #Maroon, #thin );
    PlotElderChannelOnTheFly( 26, 12, 90 );
    PlotMACD( 12, 26, 9, true );
    PlotPriceOscillator( 22 );
  end
  else if( IsDaily ) then
  begin
    DisplayPercentChangeForLast5Bars();
    PlotSeries( BetterEMASeries( #close, 11 ), 0, 777, #thin );
    PlotSeries( BetterEMASeries( #close, 22 ), 0, #Maroon, #thin );
    //PlotSeries( BetterEMASeries( #Volume, 2 ), 1, #Maroon, #thin );
    PlotElderChannelOnTheFly( 22, 6, 90 );
    //PlotBollingerBand( 22, 2 );
    //DisplayVolume();
    //MyDrawLabel( 'EMA: 11, 22', #Black );
    PlotMACD( 12, 26, 9, true );
    PlotNHNLSeries();
    PlotStochastic( 7, 20, 80 );
    PrintPosition();
    //MarkFedResMeet();
    //Plot2ndDifferential( 22, 30, 70 );
    //PlotRSI( 10, 30, 70 );
    //PlotPriceOscillator( 22 );
    //PlotForceIndex( 2 );
    //PlotPriceChange( 2 );
    //PlotElderRay( 26 );

    //PlotNoiseBand( 20 );
    //PlotSafeZoneLong( 10, 2 );
    //PlotSafeZoneShort( 10, 2 );

    //AddCommentary( '<' + 'meta http-equiv="refresh" content="0;url=http://finance.yahoo.com/q/pr?s=' + GetSymbol + '">' );
  end;

except
end;


// For saving image
SaveChart();
//SaveChartWithSize( 1620, 1215 );
//SaveChartImage( 'D:\WL\Images\' + GetSymbol + '.gif', 1024, 768, 'gif' );

DisplayDay ();


{
Print( 'O = ' + FormatFloat( '#.##', PriceOpen(BarCount-1) ) );
Print( 'H = ' + FormatFloat( '#.##', PriceHigh(BarCount-1) ) );
Print( 'L = ' + FormatFloat( '#.##', PriceLow(BarCount-1) ) );
Print( 'C = ' + FormatFloat( '#.##', PriceClose(BarCount-1) ) );
Print( 'Change in one month = ' + FormatFloat( '#.##', 100*(PriceClose(BarCount-1)-PriceClose(BarCount-22))/PriceClose(BarCount-22) ) );
MyDrawLabel( 'Change in one month = ' + FormatFloat( '#.##', 100*(PriceClose(BarCount-1)-PriceClose(BarCount-22))/PriceClose(BarCount-22) ), #Black );
}
