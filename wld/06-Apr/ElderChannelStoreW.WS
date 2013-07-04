(*Description...
<b>test</b>

*)
{$NO_AUTO_EXECUTE}
//var tick1: integer = GetTickCount();
UseUpdatedEma (true);
EnableSynch( true );
ChangeScale( #Weekly );
{$I 'myScreencommon'}
{$I 'myIbdCheckup'}
{$I 'myfunda'}
{$I 'myElderChSaved' }
//______________________________________________________________________________
procedure drawCustomMACDForIndustry( industryPane: integer );
begin
  //TODO: just for testing: Draw MACD for industry group
  var mmacd: integer = MACDSeries( #Close );
  var mmacdSignal: integer = EMASeries( mmacd, 9 );
  var mmacdh: integer = SubtractSeries( mmacd, mmacdSignal );
  var mmacdh2: integer = MultiplySeriesValue( mmacdh, 3 );

  {
  // Separate Pane
  var macdPane: integer = CreatePane( 40, false, true );
  PlotSeriesLabel( mmacd, macdPane, #Red, #Thick, 'MACD' );
  PlotSeriesLabel( mmacdSignal, macdPane, #Blue, #Thin, 'MACD Signal' );
  DrawHorzLine( 0, macdPane, #Olive, #Thin );
  PlotSeriesLabel( mmacdh2, macdPane, #Black, #Histogram, 'MACD Histogram');
  ColorSeriesRedGreen( mmacdh2 );
  }

  var lookBackBars: integer = 104;
  if( BarCount < lookBackBars ) then
    lookBackBars := BarCount;
  var x: float = Lowest(BarCount-1, #Low, lookBackBars );
  var y: float = Highest(BarCount-1, #High, lookBackBars );
  var a: float = Lowest(BarCount-1, mmacdh2, lookBackBars );
  var b: float = Highest(BarCount-1, mmacdh2, lookBackBars );
  var offset: float = (7*x+y)/8;
  var factor: float = (y-x)/(4*(b-a));
  mmacd := AddSeriesValue( MultiplySeriesValue( mmacd, factor ), offset );
  mmacdSignal := AddSeriesValue( MultiplySeriesValue( mmacdSignal, factor ), offset );
  mmacdh2 := AddSeriesValue( MultiplySeriesValue( mmacdh2, factor ), offset );

  //ColorSeriesRedGreen( mmacdh2 );
  PlotSeries( mmacd, industryPane, 955, #Thick );
  PlotSeries( mmacdSignal, industryPane, 559, #Thin );
  DrawHorzLine( offset, industryPane, 884, #Thin );
  var i: integer;
  for i := 1 to BarCount-1 do
  begin
    if( @mmacdh2[i] > @mmacdh2[i-1] ) then
    begin
      DrawLine( i, @mmacdh2[i], i, offset, industryPane, 373, #Thin );
    end
    else
    begin
      DrawLine( i, @mmacdh2[i], i, offset, industryPane, 955, #Thin );
    end;
  end;

end;
//______________________________________________________________________________
function getIndustrySubGroup(): string;
begin
  // Get industry group name
  var fileHandle: integer = FileOpen( 'D:\WL\Fundamentals\industryGroups\Telechart\' + GetSymbol + '.csv' );
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
  // Get industry group name
  var fileHandle: integer = FileOpen( 'D:\WL\Fundamentals\industryGroups\Telechart\' + GetSymbol + '.csv' );
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
      if( industryNum mod 10 = 0 ) then
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

  SetPrimarySeries( subIndustrySymbol );
  drawCustomMACDForIndustry( industryPane);
  RestorePrimarySeries();
  
  PlotSymbolColoredCandle( subIndustrySymbol, industryPane, 050, 700 );

  // plot some info and indicators
  SetPrimarySeries( subIndustrySymbol );
  DrawLabel( ' ', industryPane ); // blank label to create space
  //DrawLabel( ' ', industryPane ); // blank label to create space
  //DrawLabel( ' ', industryPane ); // blank label to create space
  DrawText( subIndustrySymbol + ' || ' + mainIndustry + ' || ' + subIndustry , industryPane, 5, 5, #Black, 10 );
  //DrawText( mainIndustry, industryPane, 5, 20, #Black, 10 );
  PlotSeries( EMASeries( #Close, 13), industryPane, 777, #Thin );
  PlotSeries( EMASeries( #Close, 26), industryPane, #Maroon, #Thin );
  PlotElderChannelOnTheFly2( industryPane, 26, 12, 90 );

  RestorePrimarySeries();
end;
//______________________________________________________________________________

VolumeColor();
HideVolume();
PlotVolume( 40 );

try
  if( IsDaily ) then
  begin
    PlotSeriesLabel( EMASeries( #Close, 13 ), 0, 333, #Thin, 'EMA 13' );
    PlotSeriesLabel( EMASeries( #Close, 26 ), 0, #Maroon, #Thin, 'EMA 26');
  end;
  
  if( IsWeekly ) then
  begin
    //MyDrawLabel( 'EMA: 13, 26', #Black );
    DisplaySomeBasicFundamentals();
    DisplayMarketCap();
    DisplayMembership();
    //PlotSeries (EMASeries (#close, 13), 0, 777, #thin);
    //PlotSeries (EMASeries (#close, 26), 0, #Maroon, #thin);
    PlotSeries (EMASeries (#Close, 13), 0, 777, #Thin);
    PlotSeries (EMASeries (#Close, 26), 0, #Maroon, #Thin);

    PlotElderChannelFromSavedDev();
    //PlotElderChannelOnTheFly( 26, 12, 90 );
    PlotMACD2( 50, true );
    //PlotPriceOscillator (26);
    PrintClosedPosition();
    
    // Industry
    PlotIndustryGroup( 150 );
    DrawText( getIndustrySubGroup(), 0, 130, 20, 000, 10);
  end;

except
end;


// Mark highest bar
AnnotateBar( 'H', HighestBar( BarCount-1, #High, BarCount ), true, 742, 10 );


try
  var date: integer = 20050131;
  var bar: integer = DateToBar( date );
  SetBackgroundColor(	bar, 874 );
except
end;

// For saving image
if( myUtil.getBoolParam( 'SaveChart' ) ) then
  SaveChart (); // **** FIRST YOU SHOULD ZOOM IN, THEN PRINT *****

DisplayDay ();



//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );


{
//var str : string = '19620528,19620529,19620529,19620531,19631126,19700527,19700609,19710816,19740711,19740712,19740806,19740904,19740919,19741007,19741009,19741010,19741014,19741029,19741118,19750127,19781101,19791010,19800327,19800422,19801105,19810107,19820817,19821011,19821025,19821103,19821210,19830124,19860911,19870427,19871016,19871019,19871020,19871021,19871022,19871026,19871027,19871029,19871103,19871130,19880108,19880414,19891013,19971027,19971028,19980827,19980831,19980901,19980908,19981008,19981015,20000316,20000404,20000414,20010103,20010312,20010405,20010418,20010917,20010919,20010921,20010924,20020715,20020719,20020722,20020724,20020729,20020806,20020814,20020903,20021001,20021011,20021015,20070227';
var str : string = '19871019,19871026,20000414,19880108,19971027,19620528,19980831,19891013,19871130,19871022,20000404,19871016,19871103,20010917,19860911,19981008,20020715,20010919,20010312,19821025,19800327,19880414,20020719,19980827,19620529,19830124,19810107,20020903,20070227,19741118,19740904,20020722,19791010,20010921';
var dstr: string;
var count: integer = 0;
while(true) do
begin
  dstr := GetToken( str, count, ',' );
  //Print( '+' + dstr + '=' ); PrintFlush;
  if( dstr = '' ) then
    break;
  var bar: integer = WeeklyBarFromDailyDate( StrToInt( dstr ) );
  SetBackgroundColor( bar, 977 );
  Inc( count );
end;

str := '20021001,20020814,19821011,19750127,19800422,19740806,20010405,19821103,20010924,19741029,19871027,19740919,19631126,19980901,19781101,19870427,19741014,19740712,19620531,20021015,19981015,20000316,20010418,20020806,19700609,20021011,19741007,19620529,19820817,20010103,19821210,19980908,19741009,19740711,19801105,19971028,19741010,20020729,19710816,19700527,19871029,20020724,19871020,19871021';
count := 0;
while(true) do
begin
  dstr := GetToken( str, count, ',' );
  //Print( '+' + dstr + '=' ); PrintFlush;
  if( dstr = '' ) then
    break;
  var bar: integer = WeeklyBarFromDailyDate( StrToInt( dstr ) );
  SetBackgroundColor( bar, 797 );
  Inc( count );
end;
}

