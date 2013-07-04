(*Description...
<b>test</b>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma (true);
EnableSynch( true );
ChangeScale( #Weekly );
{$I 'myScreenCommon'}
{$I 'myFunda'}
{$I 'myEarnings' }
{$I 'myIbdCheckup' }
{$I 'myElderChSaved' }

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
function getIndustrySubGroup(): string;
begin
  // Get industry group name
  var fileHandle: integer = FileOpen( rootDir + '\Fundamentals\industryGroups\Telechart\' + GetSymbol + '.csv' );
  var mainIndustry: string = FileRead (fileHandle);
  var mainIndustrySymbol: string = FileRead (fileHandle);
  var subIndustry: string = FileRead (fileHandle);
  var subIndustrySymbol: string = FileRead (fileHandle);
  FileClose( fileHandle );
  Result := subIndustry;
end;
//______________________________________________________________________________
procedure PlotIndustryGroup( paneHeight: integer );
begin
  try
  // Get industry group name
  var fileHandle: integer = FileOpen( rootDir + '\Fundamentals\industryGroups\Telechart\' + GetSymbol + '.csv' );
  var mainIndustry: string = FileRead (fileHandle);
  var mainIndustrySymbol: string = FileRead (fileHandle);
  var subIndustry: string = FileRead (fileHandle);
  var subIndustrySymbol: string = FileRead (fileHandle);
  FileClose( fileHandle );

  // For indexes and for new symbols
  if( subIndustry = '' ) then
  begin
    if( ( GetSymbol = 'DJ-30' ) or ( GetSymbol = 'COMPQX' ) ) then
    begin
      mainIndustry := 'Standard & Poors 500';
      mainIndustrySymbol := 'SP-500';
      subIndustry := 'Standard & Poors 500';
      subIndustrySymbol := 'SP-500';
    end;
    if( GetSymbol = 'SP-500' ) then
    begin
      mainIndustry := 'Dow Jones Industrials';
      mainIndustrySymbol := 'DJ-30';
      subIndustry := 'Dow Jones Industrials';
      subIndustrySymbol := 'DJ-30';
    end;
  end;

  // For possible industry group as symbols
  if( (Length( GetSymbol ) = 5) and ( Copy( GetSymbol, 1, 2 ) = 'MG' ) ) then
  begin
    // Note: symbol may not be an industry group
    try
      var industryNum: integer = StrToInt( Copy( GetSymbol, 3, 3 ) );
      if( ( industryNum mod 10 ) = 0 ) then
      begin
        // This is main industry group, plot SP-500
        mainIndustry := 'Standard & Poors 500';
        mainIndustrySymbol := 'SP-500';
        subIndustry := 'Standard & Poors 500';
        subIndustrySymbol := 'SP-500';
      end
      else
      begin
        // This is sub-industry group, plot main industry group
        subIndustry := mainIndustry;
        subIndustrySymbol := mainIndustrySymbol;
      end;
    except
      // It is of length 5 and starts with MG, but is not an industry group
    end;
  end;

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
  var market: string = 'SP-500';
  if( ( GetSymbol = 'DJ-30' ) or ( GetSymbol = 'SP-500' ) ) then
    market := 'COMPQX'
  else if( GetSymbol = 'COMPQX' ) then
    market := 'DJ-30';

  var marketPane: integer = CreatePane( paneHeight, false, true );
  DrawLabel( ' ', marketPane ); // blank label to create space
  DrawLabel( ' ', marketPane ); // blank label to create space
  //DrawLabel( ' ', marketPane ); // blank label to create space

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

VolumeColor();
HideVolume();
PlotVolume( 30 );

try
    //DisplaySomeBasicFundamentals();
    DisplayMarketCap();
    DisplayMembership();
    PlotSeries (EMASeries (#Close, 13), 0, 777, #Thin);
    PlotSeries (EMASeries (#Close, 26), 0, #Maroon, #Thin);

    PlotElderChannelFromSavedDev();
    //PlotElderChannelOnTheFly( 26, 12, 90 );
    PlotMACD2( 40, true );
    PrintClosedPosition();
    
    // Industry
    PlotIndustryGroup( 150 );
    DrawText( getIndustrySubGroup(), 0, 130, 20, 000, 10);

    // Market
    PlotMarket( 150 );
except
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );


try
  var date: integer = 20050829;
  var bar: integer = DateToBar( date );
  //SetBackgroundColor(	bar, 874 );
except
end;

// Earning Dates
displayEarnings();

// For saving image
if( myUtil.getBoolParam( 'SaveChart' ) ) then
  SaveChart ();

DisplayDay ();



//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );

