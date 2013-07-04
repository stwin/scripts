function ElderSafeStopLongSeries( Period: Integer; LookBack: Integer; Coefficient: Float ): integer;
begin
  var Bar: integer;
  var sName: string;
  var Value: float;

  var x: integer;
  var iEMA, iDwnPen, iIsDwn, iDwnSum: integer;
  var fDwnSum, fDwnAvg, fDwnStop: float;

  sName := 'ElderSafeStopLong(' + IntToStr( Period ) + ',' + IntToStr( LookBack ) + ',' + FloatToStr( Coefficient ) + ')';
  Result := FindNamedSeries( sName );
  if Result >= 0 then
    Exit;
  Result := CreateNamedSeries( sName );

  iEMA := EMASeries(#Close,Period);

  iDwnPen := CreateSeries;
  iIsDwn := CreateSeries;

  for Bar := Period to BarCount() - 1 do
  begin

    //Calc Dwn Side Penetration ---
    if PriceLow(Bar) < PriceLow(Bar-1) then
    begin
         SetSeriesValue(Bar, iIsDwn, 1);
         SetSeriesValue(Bar, iDwnPen,(PriceLow(Bar) - PriceLow(Bar-1)));
    end
    else
    begin
         SetSeriesValue(Bar, iIsDwn, 0);
         SetSeriesValue(Bar, iDwnPen,0);
    end;

    //Reset our Sumations ---
    iDwnSum := 0;
    fDwnSum := 0;

    //Summarize the Penetraions in our LookBack Period ---
    for x := 1 to LookBack do
    begin
         iDwnSum := iDwnSum + Int(GetSeriesValue(Bar-x, iIsDwn));
         fDwnSum := fDwnSum + GetSeriesValue(Bar-x, iDwnPen);
    end;

    //Calc the Avg Penetration ---
    if iDwnSum > 0 then
       fDwnAvg := fDwnSum / iDwnSum
    else
       fDwnAvg := 0;

    fDwnStop := PriceLow(Bar) + (Coefficient * fDwnAvg);

    // Allow safezone value to lower when changing from downtrend to uptrend
    if (GetSeriesValue(Bar-1,iEMA) < GetSeriesValue(Bar-2,iEMA))
      and (GetSeriesValue(Bar,iEMA) >= GetSeriesValue(Bar-1,iEMA))
      then
       SetSeriesValue(Bar, Result, fDwnStop)
    else
    // If it is a downtrend, or a continuation of uptrend, don't lower safezone
    // value
       if fDwnStop < GetSeriesValue(Bar-1,Result) then
          SetSeriesValue(Bar, Result, GetSeriesValue(Bar-1,Result))
       else
          SetSeriesValue(Bar, Result, fDwnStop)
  end;
end;

function ElderSafeStopLong( Bar: integer; Period: Integer; LookBack: Integer; Coefficient: Float ): float;
begin
  Result := GetSeriesValue( Bar, ElderSafeStopLongSeries( Period, LookBack, Coefficient ) );
end;

PlotSeries (ElderSafeStopLongSeries (22, 20, 3), 0, #maroon, #thin);
PlotSeries (EMASeries (#close, 22), 0, #blue, #thin);
