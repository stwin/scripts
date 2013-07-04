(*Description...
<b>test</b>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma (true);
EnableSynch( true );
ChangeScale( #Weekly );

//==============================================================================
// Invoke CSharp Script and calculate all indiciators
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\ScreenOneWeekly.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.ScreenOneWeeklyInit( IWealthLabAddOn3 );
//==============================================================================


{$I 'myScreenCommon'}
{$I 'PlotSymbolColoredCandle'}
{$I 'PlotElderChOnTheFly'}
{$I 'PlotMACD'}

//______________________________________________________________________________
procedure drawCustomMACD( pane: integer );
begin
  //TODO: just for testing: Draw MACD for industry group
  var mmacd: integer = MACDSeries( #Close );
  var mmacdSignal: integer = EMASeries( mmacd, 9 );
  var mmacdh: integer = SubtractSeries( mmacd, mmacdSignal );
  var mmacdh2: integer = MultiplySeriesValue( mmacdh, 3 );
  var emas: integer = EMASeries( #Close, 26 );

  var lookBackBars: integer = 104;
  if( BarCount < lookBackBars ) then
    lookBackBars := BarCount;
  var x: float = Lowest(BarCount-1, #Low, lookBackBars );
  var y: float = Highest(BarCount-1, #High, lookBackBars );
  var a: float = Lowest(BarCount-1, mmacdh2, lookBackBars );
  var b: float = Highest(BarCount-1, mmacdh2, lookBackBars );
  var offset: float = (7*x+y)/8;
  var factor: float = (y-x)/(4*(b-a));

  // Scaling and Relocation
  mmacd := AddSeriesValue( MultiplySeriesValue( mmacd, factor ), offset );
  mmacdSignal := AddSeriesValue( MultiplySeriesValue( mmacdSignal, factor ), offset );
  mmacdh2 := AddSeriesValue( MultiplySeriesValue( mmacdh2, factor ), offset );

  // Faded Colors = 955, 559, 884, 373, 955
  PlotSeries( mmacd, pane, 900, #Thick );
  PlotSeries( mmacdSignal, pane, 009, #Thin );
  DrawHorzLine( offset, pane, 550, #Thin );
  var i: integer;
  for i := 1 to BarCount-1 do
  begin
    if( (@mmacdh2[i] > @mmacdh2[i-1]) and (@emas[i] > @emas[i-1]) ) then
      DrawLine( i, @mmacdh2[i], i, offset, pane, 070, #Thin )
    else if( (@mmacdh2[i] < @mmacdh2[i-1]) and (@emas[i] < @emas[i-1]) ) then
      DrawLine( i, @mmacdh2[i], i, offset, pane, 800, #Thin )
    else
      DrawLine( i, @mmacdh2[i], i, offset, pane, 009, #Thin );
  end;
  var emaUp, macdhUp: boolean;
  var impulse: string;
  var emaSlow: integer = EMASeries( #Close, 26 );
  emaUP := @emaSlow[BarCount-1] > @emaSlow[BarCount-2];
  macdhUp := @mmacdh[BarCount-1] > @mmacdh[BarCount-2];
  if( emaUp and macdhUp ) then
    impulse := 'Green'
  else if( (not emaUp) and (not macdhUp) ) then
    impulse := 'Red'
  else
    impulse := 'Blue';
  DrawLabel( 'Impulse: ' + impulse, pane );
end;

//______________________________________________________________________________
  var mainIndustry, mainIndustrySymbol, subIndustry, subIndustrySymbol: string;
  myclass.GetIndustryGroupInfo ( GetSymbol, MainIndustry,
				 MainIndustrySymbol, SubIndustry, SubIndustrySymbol );

//______________________________________________________________________________
procedure PlotIndustryGroup( paneHeight: integer );
begin
  try

  // plot industry group
  var industryPane: integer = CreatePane( paneHeight, false, true );
  DrawLabel( ' ', industryPane ); // blank label to create space
  DrawLabel( ' ', industryPane ); // blank label to create space
  //DrawLabel( ' ', industryPane ); // blank label to create space

  SetPrimarySeries( subIndustrySymbol );
  drawCustomMACD( industryPane);

  PlotSymbolColoredCandle( industryPane, 050, 700 );

  // plot some info and indicators
  DrawText( subIndustrySymbol + ' || ' + mainIndustry + ' || ' + subIndustry , industryPane, 5, 5, #Black, 10 );
  //DrawText( mainIndustry, industryPane, 5, 20, #Black, 10 );
  PlotSeries( EMASeries( #Close, 13), industryPane, 777, #Thin );
  PlotSeries( EMASeries( #Close, 26), industryPane, #Maroon, #Thin );
  PlotElderChOnTheFly2( industryPane, 26, 132, 90 );

  RestorePrimarySeries();
  except
  end;
end;
//______________________________________________________________________________
procedure PlotMarket( paneHeight: integer );
begin
  var market: string = myclass.GetMarketSymbol ( GetSymbol );

  var marketPane: integer = CreatePane( paneHeight, false, true );
  DrawLabel( ' ', marketPane ); // blank label to create space
  DrawLabel( ' ', marketPane ); // blank label to create space

  SetPrimarySeries( market );
  drawCustomMACD( marketPane );

  PlotSymbolColoredCandle( marketPane, 050, 700 );

  // plot some info and indicators
  DrawText( market + ' (' + GetSecurityName + ') Weekly', marketPane, 5, 5, #Black, 10 );
  PlotSeries( EMASeries( #Close, 13), marketPane, 777, #Thin );
  PlotSeries( EMASeries( #Close, 26), marketPane, #Maroon, #Thin );
  PlotElderChOnTheFly2( marketPane, 26, 132, 90 );

  RestorePrimarySeries();
end;
//______________________________________________________________________________
//______________________________________________________________________________

// Create all series required
var mainEmaSeries: integer = CreateSeries;
var upperChannelSeries: integer = CreateSeries;
var lowerChannelSeries: integer = CreateSeries;
var channelWidthPercentSeries: integer = CreateNamedSeries ( 'ElderChannelWidthPercent' );
var mmacdSeries: integer = CreateSeries;
var macdSignalSeries: integer = CreateSeries;
var macdHistogramSeries: integer = CreateSeries;
var stochSlowSeries: integer = CreateSeries;
var stochFastSeries: integer = CreateSeries;

myclass.ScreenOneWeekly_GetAllSeries( mainEmaSeries, upperChannelSeries, lowerChannelSeries,
      channelWidthPercentSeries, mmacdSeries, macdSignalSeries, macdHistogramSeries,
      stochSlowSeries, stochFastSeries );


//__________________________________________
// Now plot all indicators

var bar: integer;

VolumeColor();
HideVolume();
PlotVolume( 30 );

try
    MyDrawLabel ( myclass.BasicFundamentalString( GetSymbol ), 000 );
    MyDrawLabel ( myclass.MembershipString( GetSymbol ), 000 );
    PlotSeries (EMASeries (#Close, 13), 0, 777, #Thin);
    PlotSeries (EMASeries (#Close, 26), 0, #Maroon, #Thin);

    PlotSeries (upperChannelSeries, 0, #Teal, #thin);
    PlotSeries (lowerChannelSeries, 0, #Teal, #thin);
    MyDrawLabel ('ChannelWidth ('
         + FormatFloat('#', ( @channelWidthPercentSeries[BarCount-1] ) )
         + '%): '
         + FormatFloat('#.##', @upperChannelSeries[BarCount-1]-@lowerChannelSeries[BarCount-1]),
         #Black);

    //PlotElderChannelOnTheFly( 26, 12, 90 );
    PlotMACD2( 40, true );
    //PrintClosedPosition();

    // Industry
    PlotIndustryGroup( 150 );
    DrawText( SubIndustry, 0, 130, 20, 000, 10);

    // Market
    PlotMarket( 150 );
except
end;


// Mark highest bar
SingleCalcMode(true);
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );
SingleCalcMode(false);


try
  var date: integer = 20050829;
  var bar: integer = DateToBar( date );
  //SetBackgroundColor(	bar, 874 );
except
end;

//------------------------- Earning Dates --------------------------------------
var EarningSeries: integer = CreateSeries;
var NextEarningDaysLeft, NextEarningIntDate: integer;
myclass.GetEarningDates ( GetSymbol, IsWeekly, EarningSeries, NextEarningDaysLeft, NextEarningIntDate );
for bar := 0 to BarCount-1 do
  if ( @EarningSeries[bar] > 0.5 )  then
    DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
if( IsDaily() and ( NextEarningIntDate <> 0 ) ) then
  if ( NextEarningDaysLeft > 10 ) then
    MyDrawLabel( 'Next Earning Date(' + IntToStr(NextEarningDaysLeft) + '): ' + DateToStr( NextEarningIntDate ), #Blue )
  else
    MyDrawLabel( '>>>-------> Next Earning Date(' + IntToStr(NextEarningDaysLeft) + '): ' + DateToStr( NextEarningIntDate ), #Red );

  
//------------------------- For saving image -----------------------------------
//if( myclass.GetBoolParam( 'SaveChart' ) ) then
//  SaveChart ();


//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );

