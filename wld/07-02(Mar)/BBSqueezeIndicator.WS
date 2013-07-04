{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'VolumeColor'}

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

const period = 20;
var emaClose: integer = EMASeries( #Close, period );
PlotSeries( emaClose, 0, 610, #Thin );

var ePane: integer = CreatePane( 60, false, true );

// Keltner
const kLength = period;
const kN = 2.5;
var kATR: integer = ATRSeries(kLength);
var kUpper: integer = AddSeries( emaClose, MultiplySeriesValue( kATR, kN ) );
var kLower: integer = SubtractSeries( emaClose, MultiplySeriesValue( kATR, kN ) );
PlotSeriesLabel( kUpper, 0, 842, #Thin, 'Keltner Channel' );
PlotSeries( kLower, 0, 842, #Thin );
PlotSeriesLabel( MultiplySeriesValue( kATR, 2*kN ), ePane, #Red, #Thin, 'KCWidth' );

// Bollinger
const bbLength = period;
const bbN = 2;
var sDev: integer = STDDevSeries( emaClose, period );
var bbUpper: integer = AddSeries( emaClose, MultiplySeriesValue( sDev, bbN ) );
var bbLower: integer = SubtractSeries( emaClose, MultiplySeriesValue( sDev, bbN ) );
//PlotSeriesLabel( bbUpper, 0, #Teal, #Thin, 'Bollinger Band' );
//PlotSeries( bbLower, 0, #Teal, #Thin );
PlotSeriesLabel( MultiplySeriesValue( sDev, 2*bbN ), ePane, #Green, #Thin, 'BBWidth' );


// Momentum and Signal
var mPane: integer = CreatePane( 60, false, true );
var mSeries: integer = MomentumSeries( #Close, period );

PlotSeries( MultiplySeriesValue( #Close, 0 ), mPane, 000, #Thin );
PlotSeriesLabel( mSeries, mPane, 000, #ThickHist, 'Momentum' );

var bar: integer;
for bar := 1 to BarCount-1 do
begin
  if( @bbUpper[bar] < @kUpper[bar] ) then
  begin
    DrawCircle( 5, mPane, bar, 0, 900, #Thick );
    DrawCircle( 7, mPane, bar, 0, 900, #Thick );
  end;
  if( @bbUpper[bar] >= @kUpper[bar] ) then
  begin
    DrawCircle( 5, mPane, bar, 0, #Blue, #Thick );
    DrawCircle( 7, mPane, bar, 0, #Blue, #Thick );
  end;
  if( CrossUnder( bar, bbUpper, kUpper ) ) then
  begin
    SetBackgroundColor( bar, #RedBkg );
  end;
  if( CrossOver( bar, bbUpper, kUpper ) ) then
  begin
    SetBackgroundColor( bar, #BlueBkg );
  end;
  if( @mSeries[bar] >= 0 ) then
  begin
    if( @mSeries[bar] > @mSeries[bar-1] ) then
      SetSeriesBarColor( bar, mSeries, 090 )
    else
      SetSeriesBarColor( bar, mSeries, 060 );
  end
  else
    if( @mSeries[bar] < @mSeries[bar-1] ) then
      SetSeriesBarColor( bar, mSeries, 950 )
    else
      SetSeriesBarColor( bar, mSeries, 620 );
end;

VolumeColor;
//HideVolume;
//HidePaneLines;

