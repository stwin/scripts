{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );
{$I 'mycommon'}

//______________________________________________________________________________

    DisplayPercentChangeForLast5Bars();
    PlotSeries( BetterEMASeries( #close, 11 ), 0, 777, #thin );
    PlotSeries( BetterEMASeries( #close, 22 ), 0, #Maroon, #thin );
    PlotElderChannelOnTheFly( 22, 6, 90 );
DisplayDay ();

//______________________________________________________________________________
//______________________________________________________________________________
// Main Program


var str: string = '';

if( IsDaily() ) then
  str := 'EV-D'
else if( IsIntraDay() ) then
begin
  var bi: integer = BarInterval();
  if( (bi = 1) or (bi = 30) ) then
    str := 'EV-' + IntToStr(bi)
  else
  begin
  ShowMessage( 'Only runs in 1-min, 30-min or Daily time frame' );
  exit;
  end;
end
else
begin
  ShowMessage( 'Only runs in 1-min, 30-min or Daily time frame' );
  exit;
end;

AllowSymbolSearch( 'IB-' + str );
SetPrimarySeries( GetSymbol + '-' + str );

var evSeries: integer = FindNamedSeries( 'EV' );
var sevSeries: integer = FindNamedSeries( 'SEV' );
var levSeries: integer = FindNamedSeries( 'LEV' );

RestorePrimarySeries();

var vfSeries: integer = CreateNamedSeries( 'VolumeFlow' );
var svfSeries: integer = CreateNamedSeries( 'SmallVolumeFlow' );
var lvfSeries: integer = CreateNamedSeries( 'LargeVolumeFlow' );

var bar, startBar: integer;

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

{
var strOut: string;
for bar := 0 to BarCount-1 do
begin
  strOut := IntToStr( GetDate( bar ) )
          + ',' + FormatFloat( '0000', GetTime( bar ) )
//          + ',' + FormatFloat( '0000', GetTime( bar ) )
//          + ',' + FormatFloat( '0', @evSeries[bar] )
//          + ',' + FormatFloat( '0', @sevSeries[bar] )
//          + ',' + FormatFloat( '0', @levSeries[bar] )
          + ',' + '1'
//          + ',' + FormatFloat( '0', @vfSeries[bar] )
//          + ',' + FormatFloat( '0', @svfSeries[bar] )
//          + ',' + FormatFloat( '0', @lvfSeries[bar] )
          ;
  Print( strOut );
end;

}

