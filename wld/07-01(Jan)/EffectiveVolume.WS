{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );

//______________________________________________________________________________
//
function addSeriesInterval( series, startBar, endBar: integer ): float;
begin
  var bar: integer;
  var sum: float = 0.0;
  for bar := startBar to endBar do
  begin
    sum := sum + @series[bar];
  end;
  Result := sum;
end;
//______________________________________________________________________________
//
procedure WriteSeries( fileName: string; s1, s2, s3: integer );
begin
  var bar, hFile: integer;
  var strOut: string;
  
  hFile := FileCreate( fileName );
  for bar := 0 to BarCount-1 do
  begin
    strOut := IntToStr( GetDate( bar ) )
            + ',' + FormatFloat( '0000', GetTime( bar ) )
            + ',' + '1'   // Dummy for close
            + ',' + FormatFloat( '0', @s1[bar] )
            + ',' + FormatFloat( '0', @s2[bar] )
            + ',' + FormatFloat( '0', @s3[bar] )
            ;
    FileWrite( hFile, strOut );
  end;

  FileClose( hFile );
end;

//______________________________________________________________________________
//
function calculateEV( evSeries, sevSeries, levSeries, startBar, endBar: integer ): float;
begin
  var tick: float = 0.01;
  var bar: integer;
  var sessionVolume: float;
  var lst: TList;

  @evSeries[startBar] := 0;
  sessionVolume := addSeriesInterval( #Volume, startBar, endBar );
  lst := TList.Create;

  for bar := startBar+1 to endBar do
  begin
    var trueHigh, trueLow, priceChange: float;
    var sign: integer;
    var ev: float;

    trueHigh := Max( PriceHigh(bar), PriceClose(bar-1) );
    trueLow  := Min( PriceLow (bar), PriceClose(bar-1) );
    priceChange := PriceClose(bar) - PriceClose(bar-1);

    if( priceChange > 0 ) then
      sign := 1
    else
      sign := -1;

    ev := (ABS(priceChange)+tick) / (trueHigh-trueLow+tick) * Volume(bar) * sign;

    // If priceChange direction is 0, then ev = 0
    if( priceChange = 0 ) then
      ev := 0;

    // If a one-minute bar has more than 10% of that day's volume, eliminate it
    if(  (@#Volume[bar] > (0.05 * sessionVolume)) and ( ABS(priceChange) < 2*tick ) ) then
    begin
      Print( 'Neglecting bar:  ' + IntToStr(GetDate(bar)) + #9 + IntToStr(GetTime(bar))
            + #9 + 'priceChange=' + FloatToStr(priceChange) + ' vol=' + FloatToStr(@#Volume[bar])
            + ' sessionVolume=' + FloatToStr(sessionVolume) );
      ev := 0;
    end;

    // Discard first 15 mintues and last 10 mintues
    if ((GetTime(Bar) <= 0930) and (GetTime(Bar) >= 1550)) then
    begin
      ev := 0;
    end;

    @evSeries[bar] := ev;
    //Print( IntToStr(GetDate(bar)) + #9 + IntToStr(GetTime(bar)) + #9 + FormatFloat( '0', ABS(ev) ) );
    //PrintFlush();

    if( ev <> 0 ) then
    begin
      lst.AddData( ABS(ev), FloatToStr(ev) + ':' + IntToStr(bar) );
    end;
  end;
  
  lst.SortNumeric();
  
  var i, separationBar: integer;
  
  separationBar := lst.Count * 70 / 100;
  
  //Print( 'SEV:' );
  for i := 0 to separationBar-1  do
  begin
    var ev: float;
    var data: string = lst.Data( i );
    ev := StrToFloat( GetToken( data, 0, ':' ) );
    bar := StrToInt( GetToken( data, 1, ':' ) );
    @sevSeries[bar] := ev;
    //Print( IntToStr(GetDate(bar)) + #9 + IntToStr(GetTime(bar)) + #9 + FormatFloat( '0', ev ) );
  end;
  
  //Print( 'LEV:' );
  for i := separationBar to lst.Count-1  do
  begin
    var ev: float;
    var data: string = lst.Data( i );
    ev := StrToFloat( GetToken( data, 0, ':' ) );
    bar := StrToInt( GetToken( data, 1, ':' ) );
    @levSeries[bar] := ev;
    //Print( IntToStr(GetDate(bar)) + #9 + IntToStr(GetTime(bar)) + #9 + FormatFloat( '0', ev ) );
  end;
  
  lst.Free();
  
  Print( 'Processed ' + IntToStr(startBar) + #9 + IntToStr(endBar) + #9
          + IntToStr(endBar-startBar+1) + #9 + IntToStr(GetDate(startBar)) + ' ' + IntToStr(GetTime(startBar))
          + ' to ' + IntToStr(GetDate(endBar)) + ' ' + IntToStr(GetTime(endBar)) );
end;

//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

var synchOptionChanged: boolean = false;
//synchOptionChanged := true;
if( Not synchOptionChanged ) then
begin
  ShowMessage( 'Check "Compressed bar available on first bar" for synchronization option. Exiting...' );
  exit;
end;

var evSeries: integer = CreateNamedSeries( 'EeffectiveVolume' );
var sevSeries: integer = CreateNamedSeries( 'SmallEeffectiveVolume' );
var levSeries: integer = CreateNamedSeries( 'LargeEeffectiveVolume' );

var vfSeries: integer = CreateNamedSeries( 'VolumeFlow' );
var svfSeries: integer = CreateNamedSeries( 'SmallVolumeFlow' );
var lvfSeries: integer = CreateNamedSeries( 'LargeVolumeFlow' );

var bar, startBar: integer;

startBar := 0;
for bar := 0 to BarCount-1 do
begin
  if( LastBar(bar) or (bar = BarCount-1) ) then
  begin
    calculateEV( evSeries, sevSeries, levSeries, startBar, bar );
    startBar := bar + 1;
  end;
end;


@vfSeries[0] := 0;
@svfSeries[0] := 0;
@lvfSeries[0] := 0;
for bar := 1 to BarCount-1 do
begin
  @vfSeries[bar] := @vfSeries[bar-1] + @evSeries[bar];
  @svfSeries[bar] := @svfSeries[bar-1] + @sevSeries[bar];
  @lvfSeries[bar] := @lvfSeries[bar-1] + @levSeries[bar];
end;

PlotSeriesLabel( vfSeries, CreatePane(60,false,true),009,#Thin,'Volume Flow' );
PlotSeriesLabel( svfSeries, CreatePane(60,false,true),009,#Thin,'Small Volume Flow' );
PlotSeriesLabel( lvfSeries, CreatePane(60,false,true),009,#Thin,'Large Volume Flow' );


// Write 1-min data to the file
WriteSeries( 'D:\WL\EffectiveVolume\1-min\' + GetSymbol + '-EV-1.csv', evSeries, sevSeries, levSeries );

var barCount1: integer = BarCount;

// Write 30-min data
SetScaleCompressed( 30 );
var ev30: integer = CreateSeries();
var sev30: integer = CreateSeries();
var lev30: integer = CreateSeries();
for bar := 0 to barCount1-1 do
begin
  var bar30: integer = GetIntraDayBar( bar, 30 );
  @ev30[bar30] := @ev30[bar30] + @evSeries[bar];
  @sev30[bar30] := @sev30[bar30] + @sevSeries[bar];
  @lev30[bar30] := @lev30[bar30] + @levSeries[bar];
end;
WriteSeries( 'D:\WL\EffectiveVolume\30-min\' + GetSymbol + '-EV-30.csv', ev30, sev30, lev30 );
RestorePrimarySeries();

// Write daily data
SetScaleDaily();
var evD: integer = CreateSeries();
var sevD: integer = CreateSeries();
var levD: integer = CreateSeries();
for bar := 0 to barCount1-1 do
begin
  var barD: integer = GetDailyBar( bar );
  @evD[barD] := @evD[barD] + @evSeries[bar];
  @sevD[barD] := @sevD[barD] + @sevSeries[bar];
  @levD[barD] := @levD[barD] + @levSeries[bar];
end;
WriteSeries( 'D:\WL\EffectiveVolume\daily\' + GetSymbol + '-EV-D.csv', evD, sevD, levD );
RestorePrimarySeries();


