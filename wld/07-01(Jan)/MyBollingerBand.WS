{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
function RootMeanSquareDeviationSeries(Series, Reference, Lookback: integer): integer;
begin
  var Name: string = 'RootMeanSquareDeviation(' + GetDescription(Series) + ','
                  + GetDescription(Reference) + ',' + IntToStr(Lookback) + ')';
  Result := FindNamedSeries(Name);
  if Result >= 0 then exit;
  Result := CreateNamedSeries(Name);
  var Bar: integer;
  for Bar := Lookback - 1 to BarCount - 1 do
  begin
    var BarInner: integer;
    var total: float = 0;
    for BarInner := Bar - Lookback + 1 to Bar do
      total := total + sqr( @Series[BarInner] - @Reference[Bar] );
    @Result[Bar] := sqrt( total / Lookback );
  end;
end;

///////////////////////////////////////////////////////////////////////////////
function RootMeanSquareDeviationSeries1(Series, Reference, Lookback: integer): integer;
begin
  var Name: string = 'RootMeanSquareDeviation1(' + GetDescription(Series) + ',' + GetDescription(Reference) + ',' + IntToStr(Lookback) + ')';
  Result := FindNamedSeries(Name);
  if Result >= 0 then exit;
  Result := CreateNamedSeries(Name);
  var AvgX: integer = SMASeries(Series, Lookback);
  var AvgXX: integer = SMASeries(MultiplySeries(Series, Series), Lookback);
  var Bar: integer;
  for Bar := Lookback - 1 to BarCount - 1 do
    @Result[Bar] := sqrt(abs(@AvgXX[Bar] - 2 * @AvgX[Bar] * @Reference[Bar] + sqr(@Reference[Bar])));
end;

///////////////////////////////////////////////////////////////////////////////
function MyBBandUpperSeries( series, maPeriod, lookbackPeriod: integer; stdDevVal: float ): integer;
begin
  var EMAs: integer = EMASeries(#Close, maPeriod);
  var RMSDs: integer = RootMeanSquareDeviationSeries(#Close, EMAs, lookbackPeriod);
  Result := AddSeries(EMAs, MultiplySeriesValue(RMSDs, stdDevVal));
end;

///////////////////////////////////////////////////////////////////////////////
function MyBBandLowerSeries( series, maPeriod, lookbackPeriod: integer; stdDevVal: float ): integer;
begin
  var EMAs: integer = EMASeries(#Close, maPeriod);
  var RMSDs: integer = RootMeanSquareDeviationSeries(#Close, EMAs, lookbackPeriod);
  Result := SubtractSeries(EMAs, MultiplySeriesValue(RMSDs, stdDevVal));
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

PlotSeries(EMASeries(#Close, 11), 0 , 005, #thin);
PlotSeries(MyBBandUpperSeries(#close, 11, 44, 1.5), 0 , 009, #thin);
PlotSeries(MyBBandLowerSeries(#close, 11, 44, 1.5), 0 , 009, #thin);


{
PlotSeries(SMASeries(#Close, 20), 0 , 500, #thin);
PlotSeries(BBandUpperSeries(#close,20,1.5), 0 , 900, #thin);
PlotSeries(BBandLowerSeries(#close,20,1.5), 0 , 900, #thin);
}

