{$NO_AUTO_EXECUTE}

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

procedure ForceIndex ();
begin
  var Smooth, MySeries, MyPane, Bar : integer;
  var x : float;

  {Smoothing parameter, Elder recommends 13 days.}
  Smooth := 13;
  MySeries := CreateSeries;

  for Bar := Smooth to BarCount - 1 do
  begin
    x := ( EMA(Bar, #Close, Smooth) - EMA(Bar-1, #Close, Smooth)) * #Volume;
    SetSeriesValue( Bar, MySeries, x );
  end;

  {Create new pane for Force Index oscillator and plot it.}
  MyPane := CreatePane( 75, false, true );
  PlotSeriesLabel( MySeries, MyPane, #Navy, #Thin, 'Force Index' );
  DrawHorzLine( 0, MyPane, #Red, #Thin );

  {A 22 day EMA included to maintain consistency with books diagrams.}
  PlotSeries( EMASeries( #Close, 22), 0, #Red, #Thin );
end;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure TripleScreenPullback5_10 ();
begin

var Bar: integer;
var Short: boolean;

const ShortMA = 100;
const LongMA = 200;

Short := true;

{ Create Trend Pane }
{ Plot Indicators }
PlotSeries( EMASeries( #close, LongMA ), 0, #Blue, 0 );
PlotSeries( EMASeries( #close, ShortMA ), 0, #Red, 0 );
PlotSeries( EMASeries( #close, 15 ), 0, #Blue, 1 );

{ Install AutoStops }
InstallProfitTarget( 5 );
InstallStopLoss( 10 );

{ Implement Trading Rules }
for Bar := LongMA to BarCount( ) - 1 do
begin
  ApplyAutoStops( Bar );
  if ( ROC( Bar, ADXSeries( 14 ), 10 ) > 0 ) then
   SetBackgroundColor( Bar, #GreenBkg )
  else
   SetBackgroundColor( Bar, #RedBkg );
  if LastPositionActive( ) then
  begin
    if PositionLong( LastPosition( ) ) then
    begin
      { exit if end of long term trend }
      if ROC( Bar, EMASeries(#close, ShortMA ), 10 ) < 0 then
        SellAtMarket( Bar + 1, LastPosition( ), 'Trend end' );
    end
    else
    begin
      if ROC( Bar, EMASeries( #close, ShortMA ), 10 ) > 0 then
        CoverAtMarket( Bar + 1, LastPosition( ), 'Trend end' );
    end;
  end
  else
  begin
    { Screen #1 -- Long term trend ( tide ) }
    if ( ROC( Bar, EMASeries( #close, LongMA ), 10 ) > 0 ) then
    begin
      { Screen #2 -- Short term setup ( wave ) }
      if ( CrossUnder( Bar, #low, EMASeries( #close, 15 ) ) )
      AND ( ROC( Bar, EMASeries( #close, ShortMA ), 10 ) > 0 )
      AND ( ROC( Bar, ADXSeries( 14 ), 10 ) > 0 ) then
      { Screen #3 -- Confirming entry ( ripple ) }
// BuyAtLimit( Bar + 1, PriceHigh( Bar ) + 0.01, '' );
       BuyAtStop( Bar + 1, PriceHigh( Bar ) + 0.01, '' );
    end;
    if ( ROC( Bar, EMASeries( #close, LongMA ), 10 ) < 0 ) then
    begin
      if ( CrossOver( Bar, #high, EMASeries( #close, 15 ) ) )
      AND ( ROC( Bar, EMASeries( #close, ShortMA ), 10 ) < 0 )
      AND ( ROC( Bar, ADXSeries( 14 ), 10 ) > 0 )
      AND ( Short ) then
// ShortAtLimit( Bar + 1, PriceLow( Bar ) - 0.01, '' );
       ShortAtStop( Bar + 1, PriceLow( Bar ) - 0.01, '' );
    end;
  end;
end;

end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure TripleScreenGlitch ();
begin

var XSTOP: float;
var BUYSETUP, SHORTSETUP: boolean;
var TREND, BAR, STOCHPANE: integer;
{ Color Background to depict long term trend }
Trend := EMASeries( #Close, 13 * 5 );
PlotSeries( Trend, 0, 531, #Thick );
for Bar := 60 to BarCount() - 1 do
begin
  if GetSeriesValue( Bar, Trend ) > GetSeriesValue( Bar - 1, Trend ) then
    SetBackgroundColor( Bar, #GreenBkg )
  else
    SetBackgroundColor( Bar, #RedBkg );
end;

{ Plot our screen 2 indicator ... Stochastics }
StochPane := CreatePane( 100, true, true );
PlotSeries( StochKSeries( 5 ), StochPane, #Purple, #Thin );
PlotSeries( StochDSeries( 5, 3 ), StochPane, #Gray, #Thin );

{ Color Bars for Stochastic Overbought/Oversold }
SetBarColors( #Black, #Black );
for Bar := 60 to BarCount - 1 do
begin
  if StochD( Bar, 5, 3 ) > 80 then
    SetBarColor( Bar, #Red )
  else if StochD( Bar, 5, 3 ) < 20 then
    SetBarColor( Bar, #Blue );
end;

{ Triple Screen Trading System }
BuySetup := false;
ShortSetup := false;
xStop := 0.0;
InstallBreakEvenStop( 3 );
InstallTrailingStop( 5, 50 );
for Bar := 60 to BarCount - 1 do
begin
  ApplyAutoStops( Bar );
  if not LastPositionActive then
  begin
    if EMA( Bar, #Close, 13 * 5 ) > EMA( Bar - 1, #Close, 13 * 5 ) then
    begin
      ShortSetup := false;
      if ( StochD( Bar, 5, 3 ) < 20 ) and CrossOver( Bar, StochKSeries( 5 ), StochDSeries( 5, 3 ) ) then
        BuySetup := true;
    end
    else
    begin
      BuySetup := false;
      if ( StochD( Bar, 5, 3 ) > 80 ) and CrossUnder( Bar, StochKSeries( 5 ), StochDSeries( 5, 3 ) ) then
        ShortSetup := true;
    end;
    if BuySetup then
      if BuyAtStop( Bar + 1, PriceHigh( Bar ) + ( 1 / 16 ), '') then
      begin
        BuySetup := false;
        xStop := PriceLow( Bar );
        if Bar < BarCount - 1 then
        begin
          if PriceLow( Bar + 1 ) < xStop then
            xStop := PriceLow( Bar + 1 );
        end;
        xStop := xStop - ( 1 / 16 );
      end;
    if ShortSetup then
      if ShortAtStop( Bar + 1, PriceLow( Bar ) - ( 1 / 16 ), '') then
      begin
        ShortSetup := false;
        xStop := PriceHigh( Bar );
        if Bar < BarCount - 1 then
        begin
          if PriceHigh( Bar + 1 ) > xStop then
            xStop := PriceHigh( Bar + 1 );
        end;
        xStop := xStop + ( 1 / 16 );
      end;
  end
  else
  begin
{ First apply our initial stop level exit }
    if PositionLong( LastPosition ) then
      SellAtStop( Bar + 1, xStop, LastPosition, 'Stop' )
    else
      CoverAtStop( Bar + 1, xStop, LastPosition, 'Stop' );
{ Second, see if we get a screen 2 exit }
    if LastPositionActive then
    begin
      if PositionLong( LastPosition ) then
      begin
        if StochD( Bar, 5, 3 ) > 80 then
          SellAtMarket( Bar + 1, LastPosition, 'Screen 2' );
      end
      else
      begin
        if StochD( Bar, 5, 3 ) < 20 then
          CoverAtMarket( Bar + 1, LastPosition, 'Screen 2' );
      end;
    end;
  end;
end;

end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure TripleScreenMarket;
begin

var TRENDPANE, BAR: integer;
{ Create Trend Pane }

TrendPane := CreatePane( 75, TRUE, TRUE );
DrawText( 'Trend Pane', TrendPane, 8, 4, #red, 10 );
Drawtext( 'SMA 200 slope', TrendPane, 8, 16, 822, 10 );
Drawtext( 'SMA 100 slope', TrendPane, 8, 38, #blue, 10 );

{ Plot Indicators }
PlotSeries( ROCSeries(SMASeries( #close, 200),10), TrendPane, 500, 0 );
PlotSeries( ROCSeries(SMASeries( #close, 100),10), TrendPane, #Blue, 0 );

PlotSeries( SMASeries( #close, 15), 0, 228, 1 );

DrawHorzLine( 0, TrendPane, #red, 2 );


{ Install AutoStops }

InstallProfitTarget( 10 );

{ Change profit target to 5 for the DOW... less volitility! }
{ SetSharecap( 5000 ); }

{ Implement Trading Rules }
for Bar := 212 to BarCount() - 1 do
begin

  ApplyAutoStops( Bar );

  if LastPositionActive() then
  begin

    if PositionLong( LastPosition() ) then
    begin

      { exit if end of long term trend }

      if ROC( Bar, SMASeries(#close, 100 ),10) < 0 then
        SellAtMarket( Bar + 1, LastPosition(), 'Trend end' );

    end
    else
    begin

      if ROC( Bar, SMASeries(#close, 100 ),10) > 0 then
        CoverAtMarket( Bar + 1, LastPosition(), 'Trend end' );

    end;
  end
  else
  begin

    { Screen #1 -- Long term trend ( tide ) }

    if ( ROC( Bar, SMASeries(#close, 200 ),10) > 0 ) then
    begin

      { Screen #2 -- Short term setup ( wave ) }

      if ( CrossUnder(Bar, #low, SMASeries( #close, 15)) )
      AND ( ROC( Bar, SMASeries(#close, 100 ),10) > 5 )
      AND ( ROC( Bar, adxSeries(14), 10) > 5 )
      AND ( ADX( Bar, 14 ) > 20 )
      AND ( PriceClose( Bar ) > 5.00 )
      { Screen #3 -- Confirming entry ( ripple ) }

      then BuyAtMarket( Bar+1, '');
    end;

    if ( ROC( Bar, SMASeries(#close, 200 ),10) < -5 ) then
    begin
      if ( CrossOver(Bar, #high, SMASeries( #close, 15)))
      AND ( ROC( Bar, SMASeries(#close, 100 ),10) < 0 )
      AND ( ROC( Bar, adxSeries(14), 10) > 5 )
      AND ( ADX( Bar, 14 ) > 20 )
      AND ( PriceClose( Bar ) > 5.00 )
      then ShortAtMarket( Bar+1, '');
    end;
  end;
end;


end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure TripleScreenSMABuyStop ();
begin

var TRENDPANE, BAR: integer;
{ Create Trend Pane }

TrendPane := CreatePane( 75, TRUE, TRUE );
DrawText( 'Trend Pane', TrendPane, 8, 4, #red, 10 );
Drawtext( 'SMA 200 slope', TrendPane, 8, 16, 822, 10 );
Drawtext( 'SMA 40 slope', TrendPane, 8, 38, #blue, 10 );

{ Plot Indicators }
PlotSeries( ROCSeries(SMASeries( #close, 200),10), TrendPane, 822, 2 );
PlotSeries( ROCSeries(SMASeries( #close, 40),10), TrendPane, #Blue, 0 );

PlotSeries( SMASeries( #close, 15), 0, 228, 1 );

DrawHorzLine( 0, TrendPane, #red, 2 );


{ Install AutoStops }

InstallBreakEvenStop( 20 );



{ SetSharecap( 5000 ); }

{ Implement Trading Rules }
for Bar := 212 to BarCount() - 1 do
begin

  ApplyAutoStops( Bar );

  if LastPositionActive() then
  begin

    if PositionLong( LastPosition() ) then
    begin

      { exit if end of long term trend }



      if ( ROC( Bar, SMASeries(#close, 40 ),10) < 0 ) then
        SellAtMarket( Bar + 1, LastPosition(), 'Trend end' );

      SellAtStop( Bar, ( Lowest( PositionEntryBar( LastPosition() ), #Low, 2 ) - 0.25), LastPosition( ), 'Initial Stop' );

    end
    else
    begin

      if ( ROC( Bar, SMASeries(#close, 40 ),10) > 0 ) then
        CoverAtMarket( Bar + 1, LastPosition(), 'Trend end' );

      CoverAtStop( Bar, ( Highest( PositionEntryBar( LastPosition() ), #High, 2 ) + 0.25), LastPosition( ), 'Initial Stop' );

    end;
  end
  else
  begin

    { Screen #1 -- Long term trend ( tide ) }

    if ( ROC( Bar, SMASeries(#close, 200 ),10) > 0 ) then
    begin

      { Screen #2 -- Short term setup ( wave ) }

      if ( CrossUnder(Bar, #low, SMASeries( #close, 15)) )
      AND ( ROC( Bar, SMASeries(#close, 40 ),10) > 0 )
      AND ( ROC( Bar, adxSeries(14), 10) > 0 )

      { Screen #3 -- Confirming entry ( ripple ) }

      then BuyAtStop( Bar+1, PriceHigh( Bar ) + 0.10, '');
    end;

    if ( ROC( Bar, SMASeries(#close, 200 ),10) < 0 ) then
    begin
      if ( CrossOver(Bar, #high, SMASeries( #close, 15)))
      AND ( ROC( Bar, SMASeries(#close, 40 ),10) < 0 )
      AND ( ROC( Bar, adxSeries(14), 10) > 0 )
      then ShortAtStop( Bar+1, PriceLow( Bar ) - 0.10, '');
    end;
  end;
end;


end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
procedure TripleScreenSMA ();
begin

var TRENDPANE, BAR: integer;
{ Create Trend Pane }

TrendPane := CreatePane( 75, TRUE, TRUE );
DrawText( 'Trend Pane', TrendPane, 8, 4, #red, 10 );
Drawtext( 'SMA 200 slope', TrendPane, 8, 16, 822, 10 );
Drawtext( 'SMA 100 slope', TrendPane, 8, 38, #blue, 10 );

{ Plot Indicators }
PlotSeries( ROCSeries(SMASeries( #close, 200),10), TrendPane, 500, 0 );
PlotSeries( ROCSeries(SMASeries( #close, 100),10), TrendPane, #Blue, 0 );

PlotSeries( SMASeries( #close, 15), 0, 228, 1 );

DrawHorzLine( 0, TrendPane, #red, 2 );


{ Install AutoStops }

InstallProfitTarget( 10 );
{ Change profit target to 5 for the DOW... less volitility! }
{ SetSharecap( 5000 ); }

{ Implement Trading Rules }
for Bar := 212 to BarCount() - 1 do
begin

  ApplyAutoStops( Bar );

  if LastPositionActive() then
  begin

    if PositionLong( LastPosition() ) then
    begin

      { exit if end of long term trend }

      if ROC( Bar, SMASeries(#close, 100 ),10) < 0 then
        SellAtMarket( Bar + 1, LastPosition(), 'Trend end' );

    end
    else
    begin

      if ROC( Bar, SMASeries(#close, 100 ),10) > 0 then
        CoverAtMarket( Bar + 1, LastPosition(), 'Trend end' );

    end;
  end
  else
  begin

    { Screen #1 -- Long term trend ( tide ) }

    if ( ROC( Bar, SMASeries(#close, 200 ),10) > 0 ) then
    begin

      { Screen #2 -- Short term setup ( wave ) }

      if ( CrossUnder(Bar, #low, SMASeries( #close, 15)) )
      AND ( ROC( Bar, SMASeries(#close, 100 ),10) > 0 )
      AND ( ROC( Bar, adxSeries(14), 10) > 0 )

      { Screen #3 -- Confirming entry ( ripple ) }

      then BuyAtLimit( Bar+1, PriceHigh( Bar ) + 0.10, '');
    end;

    if ( ROC( Bar, SMASeries(#close, 200 ),10) < 0 ) then
    begin
      if ( CrossOver(Bar, #high, SMASeries( #close, 15)))
      AND ( ROC( Bar, SMASeries(#close, 100 ),10) < 0 )
      AND ( ROC( Bar, adxSeries(14), 10) > 0 )
      then ShortAtLimit( Bar+1, PriceLow( Bar ) - 0.10, '');
    end;
  end;
end;

end;
///////////////////////////////////////////////////////////////////////////////

ForceIndex;

