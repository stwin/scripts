
{$I 'mycommon'}


var equitySeries: integer;
var virtualEquitySeries: integer;
var investSeries: integer;
var depositSeries: integer;
var equitySeriesColor: integer = 575;
var virtualEquitySeriesColor: integer = 054;

var s, i: integer;
s := CreateSeries;
SetDescription(s, 'test' );
for i := BarCount-10 to BarCount-1 do
begin
  SetSeriesValue(i, s, 0.50 * GetSeriesValue( i, #Close ) );
end;
PlotSeries( s, CreatePane(100,false,true), #Red, #ThickHist );
exit;

{$I 'myNHNL'}


