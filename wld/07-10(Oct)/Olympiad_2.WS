{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma( true );
EnableSynch( true );

//==============================================================================
// Initialize CSharp Script
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\RealTimeBasic.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.RealTimeBasicInit( IWealthLabAddOn3 );
//==============================================================================

var bar: integer;
var myDrawLabelX: integer = 38;

//---------Plot in Primary Pane ---- EMA and Channel ---------------------------
var SlowEmaSeries: integer = CreateSeries;
var MainEmaSeries: integer = CreateSeries;
var UpperChannelSeries: integer = CreateSeries;
var LowerChannelSeries: integer = CreateSeries;
var ChannelWidthPercentSeries: integer = CreateSeries;  // Used in stochastic
var ChannelStr: string;
myclass.RealTimeBasic_GetBasicSeries( slowEmaSeries, mainEmaSeries, upperChannelSeries, lowerChannelSeries, channelWidthPercentSeries, channelStr );
DrawText( AsString(GetTime(BarCount-1)), 0, 77, 18, #Black, 8);
DrawText( myclass.GetDayStr( BarCount-1 ), 0, 104, 18, #Black, 8); // Displays Day on the price pane
PlotSeries( slowEmaSeries, 0, 777, #Thin );
PlotSeries( mainEMASeries, 0, #Maroon, #Thin );
PlotSeries( upperChannelSeries, 0, #Teal, #thin );
PlotSeries( lowerChannelSeries, 0, #Teal, #thin );
//DrawText( myclass.GetStrPercentChangeForLast5Bars(), 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
DrawText( channelStr, 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
//DrawText( myclass.GetStrOHLC, 0, 7, myDrawLabelX, 036, 10 ); myDrawLabelX := myDrawLabelX + 15;


//----------------------------- Volume -----------------------------------------
for Bar:=0 to BarCount-1 do if PriceClose(Bar) > PriceOpen(Bar) then SetSeriesBarColor(Bar,#Volume,#Green) else SetSeriesBarColor(Bar,#Volume,#Red);


  {
var expEma22: float;
var expElderChannelWidth: float;
if ( myclass.GetBoolParam('TrainingMode') ) then
begin
  // Training - estimate for the last bar
  expEma22 := 2 * @mainEmaSeries[BarCount-2] - @mainEmaSeries[BarCount-3];
  expElderChannelWidth :=  expEma22 / 100 * (2 * @channelWidthPercentSeries[BarCount-2] - @channelWidthPercentSeries[BarCount-3] );
  MyDrawLabel( 'Estimation for last bar (Training)', 0 );
end
else
begin
  // Trading - estimate for upcoming bar
  expEma22 := 2 * @mainEmaSeries[BarCount-1] - @mainEmaSeries[BarCount-2];
  expElderChannelWidth := expEma22 / 100 * (2 * @channelWidthPercentSeries[BarCount-1] - @channelWidthPercentSeries[BarCount-2] );
  MyDrawLabel( 'Estimation for upcoming bar (Trading)', 0 );
end;

var i: integer;
for i := -4 to 4 do
begin
  var level: float;
  level := expEma22 + i * 0.25 * expElderChannelWidth;
  DrawLine( BarCount-3, level, BarCount-1, level, 0, 000, #Thin );
  AnnotateChart(	FormatFloat( '0.00', level ), 0, BarCount-50, level, 0, 8);
  if ( i < 0 ) then
  begin
    //BuyAtLimit ( BarCount, level, IntToStr(i*25) );
  end;
  if ( i > 0 ) then
  begin
    //ShortAtLimit ( BarCount, level, IntToStr(i*25) );
  end;
end;
}

var bar: integer;
var buyPrice, shortPrice: float;
for bar := 200 to Barcount-2 do
begin
  expEma22 := 2 * @mainEmaSeries[bar-1] - @mainEmaSeries[bar-2];
  expElderChannelWidth := expEma22 / 100 * (2 * @channelWidthPercentSeries[bar-1] - @channelWidthPercentSeries[bar-2] );
  buyPrice := expEma22 - 0.5 * expElderChannelWidth;
  shortPrice := expEma22 + 0.5 * expElderChannelWidth;

  if ( LastPositionActive ) then
  begin
    if ( PositionLong ( LastPosition ) ) then
        SellAtLimit ( Bar+1, expEma22, LastPosition, 'Sell at ema' )
    else
      CoverAtLimit ( Bar+1, expEma22, LastPosition, 'Cover at ema' );
  end;
  if ( Not LastPositionActive ) then
  begin
    BuyAtLimit ( Bar+1, buyPrice, 'buy at lowerch' );
    ShortAtLimit ( Bar+1, shortPrice, 'short at upperch' );
  end;
  Print ( Inttostr(bar) );
end;



//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );



