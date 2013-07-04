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


//----------------------------- Now Trading System 1-----------------------------------------
{
var StartBar: integer;
StartBar := AsInteger(Max( 200, DateToBar ( 20070913 )));
Print ( 'StartBar = ' + AsString(StartBar) );

for Bar := StartBar to Barcount-2 do
begin
  var expUC, expLC: float;
  expUC := 2 * @upperChannelSeries[Bar-1] - @upperChannelSeries[Bar-2];
  expLC := 2 * @lowerChannelSeries[Bar-1] - @lowerChannelSeries[Bar-1];
  
  if ( LastPositionActive ) then
  begin
    if ( GetTime(Bar) > 1605 )  then
    begin
      if ( PositionLong ( LastPosition ) ) then
        SellAtMarket ( Bar+1, #ALL, 'Sell at EOD' )
      else
        CoverAtMarket ( Bar+1, #ALL, 'Cover at EOD' )
    end
    else
    begin
      if ( PositionLong ( LastPosition ) ) then
        SellAtLimit ( Bar+1, expUC, #ALL, 'Sell at UC' )
      else
        CoverAtLimit ( Bar+1, expLC, #ALL, 'Cover at LC' );
    end;
  end;
  if ( Not LastPositionActive ) then
  begin
    if ( (GetTime(Bar) < 1000) or (GetTime(Bar) > 1545 ) ) then continue;
    BuyAtLimit ( Bar+1, expLC, 'buy at LC' );
    ShortAtLimit ( Bar+1, expUC, 'short at UC' );
  end;
end;
}

//----------------------------- Now Trading System 2-----------------------------------------

var StartBar: integer;
StartBar := AsInteger(Max( 200, DateToBar ( 20070913 )));
Print ( 'StartBar = ' + AsString(StartBar) );

for Bar := StartBar to Barcount-2 do
begin
  var expEMA, expUC, expLC: float;
  expEMA := 2 * @MainEmaSeries[Bar-1] - @MainEmaSeries[Bar-2];
  expUC := 2 * @upperChannelSeries[Bar-1] - @upperChannelSeries[Bar-2];
  expLC := 2 * @lowerChannelSeries[Bar-1] - @lowerChannelSeries[Bar-1];

  if ( LastPositionActive ) then
  begin
    if ( GetTime(Bar) > 1605 )  then
    begin
      if ( PositionLong ( LastPosition ) ) then
        SellAtMarket ( Bar+1, #ALL, 'Sell at EOD' )
      else
        CoverAtMarket ( Bar+1, #ALL, 'Cover at EOD' )
    end
    else
    begin
      if ( PositionLong ( LastPosition ) ) then
        SellAtLimit ( Bar+1, expEMA, #ALL, 'Sell at EMA' )
      else
        CoverAtLimit ( Bar+1, expEMA, #ALL, 'Cover at EMA' );
    end;
  end;
  if ( Not LastPositionActive ) then
  begin
    if ( (GetTime(Bar) < 1000) or (GetTime(Bar) > 1545 ) ) then continue;
    BuyAtLimit ( Bar+1, expLC, 'buy at LC' );
    ShortAtLimit ( Bar+1, expUC, 'short at UC' );
  end;
end;


//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );



