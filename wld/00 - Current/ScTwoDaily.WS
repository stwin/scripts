{$NO_AUTO_EXECUTE}     ChangeScale(#Daily);
//============== Invoke CSharp Script and calculate all indiciators  ==============
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\ScreenTwoDaily.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.ScreenTwoDailyInit( IWealthLabAddOn3 );
//==============================================================================
var bar: integer; var myDrawLabelX: integer = 38;

//---------Plot in Primary Pane ---- EMA and Channel ---------------------------
var SlowEmaSeries: integer = CreateSeries;
var MainEmaSeries: integer = CreateSeries;
var UpperChannelSeries: integer = CreateSeries;
var LowerChannelSeries: integer = CreateSeries;
var ChannelWidthPercentSeries: integer = CreateSeries;  // Used in stochastic
var ChannelStr: string;
myclass.ScreenTwoDaily_GetBasicSeries( slowEmaSeries, mainEmaSeries, upperChannelSeries, lowerChannelSeries, channelWidthPercentSeries, channelStr );
SingleCalcMode(true); AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 ); SingleCalcMode(false);
DrawText( myclass.GetDayStr( BarCount-1 ), 0, 80, 18, #Black, 8); // Displays Day on the price pane
PlotSeries( slowEmaSeries, 0, 777, #Thin );
PlotSeries( mainEMASeries, 0, #Maroon, #Thin );
PlotSeries( upperChannelSeries, 0, #Teal, #thin );
PlotSeries( lowerChannelSeries, 0, #Teal, #thin );
DrawText( myclass.GetStrPercentChangeForLast5Bars(), 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
DrawText( channelStr, 0, 7, myDrawLabelX, 000, 10 ); myDrawLabelX := myDrawLabelX + 15;
DrawText( myclass.GetStrOHLC, 0, 7, myDrawLabelX, 036, 10 ); myDrawLabelX := myDrawLabelX + 15;

//------------------------- Earning Dates --------------------------------------
var EarningSeries: integer = CreateSeries;
var EarningStr: string;
var EarningStrColor: integer;
myclass.GetEarningSeriesDaily ( GetSymbol, EarningSeries, EarningStr, EarningStrColor );
for bar := 0 to BarCount-1 do
  if ( @EarningSeries[bar] > 0.5 )  then
    DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
DrawText( EarningStr, 0, 7, myDrawLabelX, EarningStrColor, 10 ); myDrawLabelX := myDrawLabelX + 15;

//----------------------------- Volume -----------------------------------------
//HideVolume();
for Bar:=0 to BarCount-1 do
  if PriceClose(Bar) > PriceOpen(Bar) then
    SetSeriesBarColor(Bar,#Volume,#Green)
  else
    SetSeriesBarColor(Bar,#Volume,#Red);

//---------------------------- Plot MACD ---------------------------------------
var mmacd : integer = CreateSeries;
var mmacdSignal : integer = CreateSeries;
var mmacdh : integer = CreateSeries;
var mmacdhColor : integer = CreateSeries;
var impulseStr: string;
var IsBullishDev, IsBearishDiv: boolean;
var BullBar1, BullBar2, BearBar1, BearBar2: integer;
myclass.GetMacdSeriesWithDiv ( mmacd, mmacdSignal, mmacdh, mmacdhColor, impulseStr, IsBullishDev, BullBar1, BullBar2, IsBearishDiv, BearBar1, BearBar2 );
var macdPane : integer = CreatePane( 40, false, true );
PlotSeriesLabel( mmacd, macdPane, #Red, #Thick, 'MACD' );
PlotSeriesLabel( MMacdSignal, macdPane, #Blue, #Thin, 'MACD Signal' );
DrawHorzLine( 0, macdPane, #Olive, #Thin );
for bar := 1 to BarCount-1 do SetSeriesBarColor( bar, mmacdh, AsInteger(@mmacdhColor[bar]) );
PlotSeries( mmacdh, macdPane, #Black, #Histogram);
DrawLabel( 'Impulse: ' + impulseStr, macdPane );
if ( IsBullishDev ) then begin
 DrawLine( BullBar1, PriceLow(BullBar1)*0.98, BullBar2, PriceLow(BullBar2)*0.98, 0, #Aqua, #Thick );
 DrawLine( BullBar1, @mmacdh[BullBar1]*0.98, BullBar2, @mmacdh[BullBar2]*0.98, MacdPane,  #Aqua, #Thick );
 DrawText( 'Bullish Divergence', 0, 7, myDrawLabelX, 009, 10 ); myDrawLabelX := myDrawLabelX + 15;
end;
if ( IsBearishDiv ) then begin
 DrawLine( BearBar1, PriceHigh(BearBar1)*1.02, BearBar2, PriceHigh(BearBar2)*1.02, 0, #Aqua, #Thick );
 DrawLine( BearBar1, @mmacdh[BearBar1]*1.02, BearBar2, @mmacdh[BearBar2]*1.02, MacdPane,  #Aqua, #Thick );
 DrawText( 'Bearish Divergence', 0, 7, myDrawLabelX, 009, 10 ); myDrawLabelX := myDrawLabelX + 15;
end;

//---------------------------- Plot NHNL----------------------------------------
{var NHSeries : integer = GetExternalSeries( 'NH-NL-Daily', #High );
var NLSeries : integer = GetExternalSeries( 'NH-NL-Daily', #Low );
var PaneNHNL : integer = CreatePane( 40, false, false);
SetPaneMinMax( PaneNHNL, 0, 800 );
var fedSeries: integer = CreateNamedSeries( 'FedResMeet' );
myclass.GetFedResMeetSeries ( fedSeries );
PlotSeriesLabel( fedSeries, PaneNHNL, #Blue, #Histogram, 'Fed. Res. Meet' );
DrawHorzLine (0, PaneNHNL, 779, #Thin); DrawHorzLine (300, PaneNHNL, 779, #Thin);
DrawHorzLine (600, PaneNHNL, 779, #Thin); DrawHorzLine (-300, PaneNHNL, 779, #Thin);
PlotSeriesLabel( NHSeries,  PaneNHNL, #Green, #Thin, 'Number of 52-week High' );
PlotSeriesLabel( NLSeries,  PaneNHNL, #Red, #Thin, 'Number of 52-week Low' );
}
//---------------------------- Plot Stochastic ---------------------------------
var StochSlowSeries : integer = CreateSeries;
var StochFastSeries : integer = CreateSeries;
myclass.ScreenTwoDaily_GetStochSeries ( stochSlowSeries, stochFastSeries );
var stochasticPane : integer = CreatePane( 60, false, true );
SetPaneMinMax ( stochasticPane, 0, 100 );
PlotSeriesLabel( channelWidthPercentSeries, stochasticPane, #Teal, #Thin, 'ChannelWidth' );
DrawHorzLine( 20, stochasticPane, 558, #Thin );
DrawHorzLine( 80, stochasticPane, 558, #Thin );
PlotSeriesLabel( stochFastSeries, stochasticPane, #Blue, #Thin, 'Stoch Fast Series' );
PlotSeriesLabel( stochSlowSeries, stochasticPane, #red, #Thick, 'Stoch Slow Series' );
//-------------------------- Print Position ------------------------------------
{var EntryBar, EntryColor, ExitBar, ExitColor: integer;
myclass.PrintClosedPosition ( GetSymbol, IsWeekly, EntryBar, EntryColor, ExitBar, ExitColor );
SetBackgroundColor( EntryBar, EntryColor );
SetBackgroundColor( ExitBar, ExitColor );
}

//______________________________________________________________________________
// Print Open Positions
//
procedure PrintOpenPosition ();
begin
  var file: integer;
  var FileName: String = myclass.GetRootDir() + '\Manage\Positions.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');

    if (GetSymbol = symbolStr) then
    begin
      var positionSize, entryDate, entryBar: integer;
      var entryPrice, entryTotal, targetPrice, stopPrice: float;
      var currentPrice, currentTotal: float;
      var tradeType: string;
      tradeType := GetToken( line, 1, ',' );
      positionSize := StrToInt( GetToken( line, 2, ',' ) );
      entryDate := StrToInt( GetToken( line, 3, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 4, ',' ) );
      entryTotal := StrToFloat( GetToken( line, 5, ',' ) );
      stopPrice := StrToFloat( GetToken( line, 6, ',' ) );
      targetPrice := StrToFloat( GetToken( line, 7, ',' ) );

      currentPrice := PriceClose( BarCount-1 );
      currentTotal := positionSize * currentPrice;
      entryBar := DateToBar( entryDate );
      if( entryBar = -1 ) then
        exit;

      // Mark buy bar
      //SetBackgroundColor (entryBar, #BlueBkg);
      //AnnotateBar( 'B', entryBar, false, #Black, 7 );

      // Mark entryPrice, targetPrice and stopPrice
      var startBar: integer;
      if( entryBar < BarCount-2 ) then
        startBar := entryBar
      else
        startBar := BarCount-2;
      DrawLine( startBar, entryPrice, BarCount-1, entryPrice, 0, #Black, #thin );
      DrawLine( startBar, targetPrice, BarCount-1, targetPrice, 0, #Black, #thin );
      DrawLine( startBar, stopPrice, BarCount-1, stopPrice, 0, #Black, #thin );
      SetBackgroundColor (entryBar, 899);

      // Now some printing
      var entryStr, currStr, profitStr: String;

      entryStr := 'Entry   ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', entryPrice )
                        + ' = ' + FormatFloat( '#,###.#0', entryTotal );
      currStr := 'Current ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', currentPrice )
                        + ' = ' + FormatFloat( '#,###.#0', currentTotal );

      profitStr := 'Profits in ' + IntToStr( BarCount-entryBar ) + ' days = '
                          + FormatFloat( '#,###.#0', currentTotal-entryTotal );

      DrawLabel( '', #Black );
      //DrawLabel( entryStr, #Black );
      //DrawLabel( currStr, #Black );
      DrawText( entryStr, 0, 7, myDrawLabelX, #Black, 10 ); myDrawLabelX := myDrawLabelX + 15;
      DrawText( currStr, 0, 7, myDrawLabelX, #Black, 10 ); myDrawLabelX := myDrawLabelX + 15;

      //if( currentTotal > entryTotal ) then
        //DrawLabel( profitStr, #Green );
      //else
        //DrawLabel( profitStr, #Red );

      // Now some detailed printing in the debug window
      Print( entryStr );
      Print( currStr );
      Print( profitStr );
      Print ('');
      var bar: integer;
      for bar := entryBar to BarCount-1 do
      begin
        Print( DateToStr( GetDate( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize - entryTotal ) );
      end;
    end;
  end;
  FileClose (file);
end;
//______________________________________________________________________________
// Print Closed Positions
//
//procedure PrintClosedPosition ();
//begin
  var file: integer;
  var FileName: String;
  FileName := 'C:\ST\WLE' + '\Manage\PositionsClosed.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do begin
    var line, symbolStr: String;

    line := FileRead (file);
    //#Symbol,EntryDate,EntryPrice,ExitDate,ExitPrice,PosType,SplitInfo,
    //Shares,EntryTotal,ExitTotal
    symbolStr := GetToken (line, 0, ',');
    if ( (GetSymbol = symbolStr) ) then
    begin
      var entryDateStr, entryPriceStr, exitDateStr, exitPriceStr, tradeType, splitInfoStr: string;
      entryDateStr   := Trim(GetToken( line, 1, ',' ));
      entryPriceStr := Trim(GetToken( line, 2, ',' ));
      exitDateStr    := Trim(GetToken( line, 3, ',' ));
      exitPriceStr  := Trim(GetToken( line, 4, ',' ));
      tradeType     := Trim(Trim(GetToken( line, 5, ',' )));
      splitInfoStr  := Trim(GetToken( line, 6, ',' ));
      var entryBar, exitBar, entryDate, exitDate: integer;
      var entryPrice, exitPrice: float;

      entryDate := StrToInt( entryDateStr );
      entryBar := DateToBar( entryDate );
      if( IsWeekly ) then
        entryBar := myclass.WeeklyBarFromDailyIntDate( entryDate );
      if( entryBar = -1 ) then // entryBar is in future i.e. you are studying history
        continue;
      entryPrice := StrToFloat( entryPriceStr );

      if( exitDateStr = '' ) then begin // Position not yet closed
        exitBar := 0;
        exitPrice := PriceClose( 0 );
      end else
      begin // For closed positions
        exitDate := StrToInt( exitDateStr );
        exitBar := DateToBar( exitDate );
        if( IsWeekly ) then
          exitBar := myclass.WeeklyBarFromDailyIntDate( exitDate );
        if( exitBar = -1 ) then   // Closed Position in future
          exitBar := 0;
        exitPrice := StrToFloat( exitPriceStr );
      end;

      if( splitInfoStr <> '1' ) then
      begin
        var split: float = StrToFloat( splitInfoStr );
        entryPrice := entryPrice / split;
        exitPrice  := exitPrice / split;
      end;

      var annotateColor: integer = 009;

      if( entryBar = exitBar ) then
      begin
        SetBackgroundColor (entryBar, 886);
      end
      else
      begin
        if( tradeType = 'L' ) then begin
          SetBackgroundColor (entryBar, 988);
          SetBackgroundColor( exitBar, 798 );
        end
        else
        begin
          SetBackgroundColor (entryBar, 798);
          SetBackgroundColor( exitBar, 988 );
        end;
      end;
      // Annotate Bars
      if( (tradeType = 'L') or (tradeType = 'B') ) then
      begin
        AnnotateBar( 'B', entryBar, false, annotateColor, 7 );
        AnnotateBar( 'S', exitBar, true, annotateColor, 7 );
      end
      else
      begin
        AnnotateBar( 'T', entryBar, true, annotateColor, 7 );
        AnnotateBar( 'C', exitBar, false, annotateColor, 7 );
      end;

      DrawLine( entryBar-1, entryPrice, entryBar+1, entryPrice, 0, #Blue, #thin );
      DrawLine( exitBar-1, exitPrice, exitBar+1, exitPrice, 0, #Blue, #thin );
    end;
  end;
  FileClose (file);
//end;

PrintOpenPosition();
//PrintClosedPosition();

//______________________________________________________________________________
// Save the chart
//
procedure SaveChartWithSize( width, height: integer; prefix: String );
begin
  var fileName: String;
  if (IsDaily) then
  begin
    fileName := IntToStr(GetDate(BarCount-1)) + '-' + GetSymbol + '-D';
  end
  else if (IsWeekly) then
  begin
    fileName := IntToStr(GetDate(BarCount-1)) + '-' + GetSymbol + '-W';
  end
  else begin
    fileName := IntToStr(GetDate(BarCount-1)) + '-' + GetSymbol + '--';
  end;

  SetColorScheme (050, 800, 222, 999, 887, 799);

  fileName := 'C:\ST\web\public\images\' + prefix + fileName + '.bmp';
  SaveChartImage( fileName, width, height, 'BMP' );
  {
  var str: String = myclass.GetDayStr( BarCount-1 );
  var dateInfo: string = DateToStr( getDate( BarCount-1 ) ) + '  ' + myclass.GetDayStr( BarCount-1 );

  var image: ComVariant;
  image := CreateOleObject( 'WLExtra.Image' );
  image.Open( fileName );
  image.DrawRectangle( 7, 19, 120, 37, 999, 0, 999 );
  image.DrawText( dateInfo, 7, 19, 0, 10 );
  image.Save( fileName, 'bmp' );
  image.Close();
  }
end;

//SaveChartWithSize(1270, 1014, '');


