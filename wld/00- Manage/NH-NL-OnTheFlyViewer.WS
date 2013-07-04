const TradingDIY = 254;
var w, NH, NL, Bar : integer;

var _52WeekHLSeries : integer;
var _52WeekNHSeries : integer = CreateSeries;
var _52WeekNLSeries : integer = CreateSeries;

for w := 0 to WatchlistCount-1 do
begin
    PrintStatus ('Symbol: ' + IntToStr(w) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (w));

    SetPrimarySeries (WatchListSymbol (w) );
    for Bar := TradingDIY+1 to BarCount-1 do
    begin
      if( PriceHigh(bar) > Highest( bar-1, #High, TradingDIY ) ) then
          @_52WeekNHSeries[Bar] := @_52WeekNHSeries[Bar]+1;
      if( PriceLow(bar) < Lowest( bar-1, #Low, TradingDIY ) ) then
          @_52WeekNLSeries[Bar] := @_52WeekNLSeries[Bar]+1;
    end;
end;
_52WeekHLSeries := SubtractSeries( _52WeekNHSeries, _52WeekNLSeries );

PlotSeriesLabel( _52WeekHLSeries, CreatePane( 100, -1, -1 ), 9, 0, '52-WK NHNL' );
PlotSeriesLabel( _52WeekNHSeries ,CreatePane( 100, -1, -1 ), 9, 0, '52-WK NH' );
PlotSeriesLabel( _52WeekNLSeries ,CreatePane( 100, -1, -1 ), 9, 0, '52-WK NL' );

