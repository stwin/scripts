{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );

//______________________________________________________________________________
var bar, barCount5, date5, time5: integer;
var s1, s5: integer;

var strList: TList = TList.Create();

// generate series in 1-min
s1 := CreateNamedSeries( 'MyVolFlowSub_1min' );
for bar := 0 to BarCount-1 do
begin
  @s1[bar] := (PriceClose(bar) - PriceOpen(bar)) * Volume(bar);
end;

SetScaleCompressed( 5 );
// Create a 5-min series and save 5-min barCount, dates and times
s5 := CreateNamedSeries( 'MyVolumeFlow' );
for bar := 0 to BarCount-1 do
begin
  var s: string = IntToStr( GetDate( bar ) )
          + ',' + FormatFloat( '0000', GetTime( bar ) );
  strList.Add( s );
end;
barCount5 := BarCount;
RestorePrimarySeries();

// Fill the series in 5-min based on data in 1-min series
for bar := 0 to BarCount-1 do
begin
  var bar5: integer = GetIntraDayBar( bar, 5 );
  @s5[bar5] := @s5[bar5] + @s1[bar];
end;

// Write 5-min data to a file
var hFile: integer;
var strOut: string;
hFile := FileCreate( 'C:\Temp\Volume-5min\' + GetSymbol + '-EV.csv' );
for bar := 0 to barCount5-1 do
begin
  strOut := strList.Item( bar ) + ',' + FormatFloat( '0', @s5[bar] );
  FileWrite( hFile, strOut );
end;
FileClose( hFile );

{

var bar, barCount1: integer;
var s1, s5: integer;

// generate series in 1-min
s1 := CreateNamedSeries( 'MyVolFlowSub_1min' );
for bar := 0 to BarCount-1 do
begin
  @s1[bar] := (PriceClose(bar) - PriceOpen(bar)) * Volume(bar);
end;
barCount1 := BarCount;

SetScaleCompressed( 5 );
s5 := CreateNamedSeries( 'MyVolumeFlow' );

// Fill the series in 5-min based on data in 1-min series
for bar := 0 to barCount1-1 do
begin
  var bar5: integer = GetIntraDayBar( bar, 5 );
  @s5[bar5] := @s5[bar5] + @s1[bar];
end;

// Write 5-min data to a file
var hFile: integer;
var strOut: string;
hFile := FileCreate( 'C:\Temp\Volume-5min\' + GetSymbol + '-EV.csv' );
for bar := 0 to BarCount-1 do
begin
  strOut := IntToStr( GetDate( bar ) )
          + ',' + FormatFloat( '0000', GetTime( bar ) )
          + ',' + FormatFloat( '0', @s5[bar] )
          ;
  FileWrite( hFile, strOut );
end;
FileClose( hFile );

RestorePrimarySeries();
 }
