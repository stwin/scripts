
//______________________________________________________________________________
// Draws Label in bigger font on the price pane
//------------------------------------------------------------------------------
var myDrawLabelX: integer = 38;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 7, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;
//______________________________________________________________________________
// Color the Volume bars
//------------------------------------------------------------------------------
procedure VolumeColor ();
begin
  var Bar: integer;
  for Bar := 0 to BarCount - 1 do
    if PriceClose( Bar ) > PriceOpen( Bar ) then
      SetSeriesBarColor( Bar, #Volume, #Green )
    else
      SetSeriesBarColor( Bar, #Volume, #Red );
end;
//______________________________________________________________________________
// Plot Stochastic
//------------------------------------------------------------------------------
procedure PlotStochastic (period, line1, line2: integer);
begin
  var slowK, slowD, stochasticPane : integer;
  stochasticPane := CreatePane( 60, false, true );
  SetPaneMinMax ( stochasticPane, 0, 100 );
  slowK := StochDSeries (period, 3);
  slowD := SMASeries (slowK, 3);

  // First draw elder channel width series, if  that is available.
  var elderChWidthSeries: integer = FindNamedSeries( 'ElderChannelWidthPercent' );
  if( elderChWidthSeries <> -1 ) then
  begin
    PlotSeriesLabel( elderChWidthSeries, stochasticPane, #Teal, #Thin, 'ChannelWidth' );
  end;

  // Now the main series
  var lineColor: integer = 558;
  DrawHorzLine( 20, stochasticPane, lineColor, #Thin );
  DrawHorzLine( 80, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line1, stochasticPane, lineColor, #Thin );
  DrawHorzLine( line2, stochasticPane, lineColor, #Thin );
  PlotSeriesLabel( slowD, stochasticPane, #Blue, #Thin, 'Slow D(3)' );
  PlotSeriesLabel( slowK, stochasticPane, #red, #Thick, 'Slow K ('+IntToStr(period)+',3)' );
end;
//______________________________________________________________________________
// Plots Volume with custome size pane
//------------------------------------------------------------------------------
procedure PlotVolume( height: integer );
begin
  var volumePane: integer = CreatePane( height, false, true );
  var zeroSeries: integer = AddSeriesValue( #Volume, 0 );
  @zeroSeries[BarCount-1] := 0;
  SetDescription( zeroSeries, 'Volume' );
  PlotSeries( zeroSeries, volumePane, #Black, #Histogram );
  PlotSeriesLabel( #Volume, volumePane, #Black, #ThickHist,'Volume' );
end;
//______________________________________________________________________________
// Display Percent Changes for Last 5 Bars
//------------------------------------------------------------------------------
procedure DisplayPercentChangeForLast5Bars ();
begin
  var count: integer;
  var text: String;
  var firstTime: boolean;

  firstTime := true;
  text := 'Change(%): ';

  for count := BarCount-5 to BarCount-1 do
  begin
    var val: float;
    val := (PriceClose(count)-PriceClose(count-1))*100/PriceClose(count-1);
    //val := (PriceHigh(count)-PriceLow(count))*100/PriceLow(count);
    //val := (PriceClose(count)-PriceOpen(count))*100/PriceOpen(count);
    if (firstTime) then
    begin
      text :=  text + ' ' + FormatFloat('#0.00', val);
      firstTime := false;
    end
    else
      text :=  text + ',  ' + FormatFloat('#0.00', val);
  end;
  MyDrawLabel (text, #Black);
end;
//______________________________________________________________________________
// Returns the day of a bar as string
//------------------------------------------------------------------------------
function getDayStr( bar: integer ): String;
begin
  var str: String = 'Holiday';
  var dayAsInt: integer = DayOfWeek( bar );
  if( dayAsInt = #Monday ) then
    str := 'Monday'
  else if( dayAsInt = #Tuesday ) then
    str := 'Tuesday'
  else if( dayAsInt = #Wednesday ) then
    str := 'Wednesday'
  else if( dayAsInt = #Thursday ) then
    str := 'Thursday'
  else if( dayAsInt = #Friday ) then
    str := 'Friday';
  Result := str;
end;
//______________________________________________________________________________
// Displays Day on the price pane
//------------------------------------------------------------------------------
procedure DisplayDay;
begin
  DrawText( getDayStr( BarCount-1 ), 0, 80, 18, #Black, 8);
end;
