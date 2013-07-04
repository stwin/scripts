{$NO_AUTO_EXECUTE}
// Basic HiLoLimit Trader (friendly)
// by DrKoch 2004-03-15

// include three modules from Code Library (www)
// or Indicator directory (WLD)
{$I 'BandTrader'}
{$I 'HiLoLimit'}
{$I 'WinLossBackground'}

//// Variables
var lookback_period, hilo_level, timeout: integer;
var minrange, profit_target: float;
var hilo_s, hs, ls, i: integer; // Series
var sym, params : string;

//list used to hold pre-optimized params for different ETFs
var lst: TList;

lst := TList.Create;

lst.AddData('DIA','4,19,7,16');
lst.AddData('DSV','4,12,8,17');
lst.AddData('ELG','4,13,8,16');
lst.AddData('ELV','4,14,11,20');
lst.AddData('EWA','4,18,12,20');
lst.AddData('EWC','4,19,8,16');
lst.AddData('EWD','4,13,9,20');
lst.AddData('EWG','4,12,11,20');
lst.AddData('EWH','4,13,7,14');
lst.AddData('EWI','4,18,12,20');
lst.AddData('EWK','4,12,12,18');
lst.AddData('EWL','4,12,10,14');
lst.AddData('EWO','4,12,10,20');
lst.AddData('EWP','4,21,10,18');
lst.AddData('EWQ','4,12,12,19');
lst.AddData('EWS','4,12,7,18');
lst.AddData('EWU','4,16,12,20');
lst.AddData('EWW','4,12,8,17');
lst.AddData('EWY','4,15,7,20');
lst.AddData('EZA','4,12,12,15');
lst.AddData('EZU','4,17,10,20');
lst.AddData('FFF','4,12,12,19');
lst.AddData('IGE','4,13,12,20');
lst.AddData('IGN','4,14,7,17');
lst.AddData('IGV','4,12,11,20');
lst.AddData('IJH','4,13,11,19');
lst.AddData('IJR','4,18,11,20');
lst.AddData('ILF','4,14,12,20');
lst.AddData('IOO','4,13,11,16');
lst.AddData('IVE','4,12,9,20');
lst.AddData('IVV','4,13,11,18');
lst.AddData('IVW','4,12,7,20');
lst.AddData('IWB','4,12,11,17');
lst.AddData('IWD','4,13,11,20');
lst.AddData('IWF','4,12,9,20');
lst.AddData('IWN','4,12,11,20');
lst.AddData('IWP','4,23,11,20');
lst.AddData('IWV','4,13,11,18');
lst.AddData('IWW','4,13,11,19');
lst.AddData('IXC','4,12,12,20');
lst.AddData('IXP','4,12,11,20');
lst.AddData('IYE','4,13,7,20');
lst.AddData('IYF','4,12,11,19');
lst.AddData('IYJ','4,14,11,20');
lst.AddData('IYM','4,12,12,19');
lst.AddData('IYR','4,20,10,18');
lst.AddData('ONEQ','4,13,9,18');
lst.AddData('RKH','4,13,10,20');
lst.AddData('RSP','4,22,8,20');
lst.AddData('SMH','4,22,7,17');
lst.AddData('SPY','4,13,12,20');
lst.AddData('TTE','4,19,11,18');
lst.AddData('TTH','4,12,12,20');
lst.AddData('UTH','4,19,12,18');
lst.AddData('VTI','4,13,11,20');
lst.AddData('XLB','4,12,12,19');
lst.AddData('XLE','4,12,8,20');
lst.AddData('XLF','4,12,11,19');
lst.AddData('XLI','4,13,9,20');
lst.AddData('BBH','5,15,6,19');
lst.AddData('BDH','5,12,6,20');
lst.AddData('EFA','5,19,11,17');
lst.AddData('EPP','5,16,12,14');
lst.AddData('EWM','5,16,6,15');
lst.AddData('EWN','5,13,11,17');
lst.AddData('FEU','5,12,12,20');
lst.AddData('FEZ','5,15,11,17');
lst.AddData('IEV','5,12,8,20');
lst.AddData('IJJ','5,12,9,20');
lst.AddData('IJK','5,14,12,20');
lst.AddData('IJS','5,18,8,20');
lst.AddData('IJT','5,17,8,19');
lst.AddData('IWR','5,12,9,20');
lst.AddData('IXJ','5,15,11,14');
lst.AddData('IYG','5,12,8,18');
lst.AddData('IYH','5,14,7,17');
lst.AddData('MDY','5,14,12,20');
lst.AddData('VXF','5,15,8,20');
lst.AddData('WMH','5,12,7,20');
lst.AddData('EWT','6,14,6,20');
lst.AddData('IDU','6,12,12,17');
lst.AddData('IWO','6,17,8,16');
lst.AddData('IWM','7,12,8,20');
lst.AddData('MTK','7,15,7,18');
lst.AddData('RTH','7,12,12,18');
lst.AddData('DSG','8,12,7,15');
lst.AddData('HHH','8,23,12,15');
lst.AddData('QQQQ','4,15,11,20');

//// Parameters

// unused here, useful for Intraday Data or low volume data
minrange := 0.0;


sym := GetSymbol();

i := lst.IndexOf(sym);

if i >= 0 then
begin
    params := lst.Data(i);

    lookback_period := StrToInt(GetToken(params, 0, ','));

    // calculate limit this level *below* Lowest
    hilo_level := -1 * StrToInt(GetToken(params, 1, ','));

    // unused here, useful for Intraday Data or low volume data
    minrange := 0.0;

    // Profit Target in percent
    profit_target := StrToInt(GetToken(params, 3, ',')) / 10.0; //1.7;

    // Timeout in Bars
    timeout := StrToInt(GetToken(params, 2, ','));
end
else
begin
    //we don't have params so use the defaults
    lookback_period := 4;

    // calculate limit this level *below* Lowest
    hilo_level := -19;

    // unused here, useful for Intraday Data or low volume data
    minrange := 0.0;

    // Profit Target in percent
    profit_target := 12 / 10.0;

    // Timeout in Bars
    timeout := 12;


end;

// Calculate Highest and Lowest (for Graphics only)
hs := HighestSeries( #High, lookback_period );
ls := LowestSeries( #low, lookback_period );

// Calculate HiLo level series (uses Highest/Lowest internally)
hilo_s := HiLoLimitSeries(lookback_period, hilo_level, minrange);

//// Graphics
HideVolume();

PlotSeries(EMASeries(#Volume, 30), 1, #Red, #Thin);

// Plot Highest and Lowest
PlotSeriesLabel(hs, 0, #Green, #Thin,
    'Highest(' + IntToStr(lookback_period) + ')');
PlotSeriesLabel(ls, 0, #Blue, #Thin,
    'Lowest(' + IntToStr(lookback_period) + ')');

// Plot Limit in red
PlotSeriesLabel(hilo_s, 0, 955, #Thin,'Limit := Lowest - (Hi - Lo) * ' + FloatToStr(hilo_level/100));

// Plot Limit used in Bandtrader (Limit price from yesterday)
PlotSeriesLabel(OffsetSeries( hilo_s, -1), 0, #Red, #Thick,
    'Limit Price');

DrawText('Lookback Period: ' + FloatToStr(lookback_period), 1, 4, 4, #Black, 8 );
DrawText( 'Hi/Lo Level ' + FloatToStr(hilo_level), 1, 4, 15, #Black, 8 );
DrawText( 'Timeout (days):' +FloatToStr(timeout), 1, 4, 26, #Black, 8 );
DrawText( 'Profit Target:' + FloatToStr(profit_target), 1, 4, 37, #Black, 8 );

//// Band Violation Trading System
// contains BuyAtLimit() commands
//BandTrader(hilo_s, profit_target, timeout);

var Bar: integer;
InstallTimeBasedExit(timeout);
InstallProfitTarget ( profit_target );
for Bar := 0 to BarCount() - 1 do begin
    var limitPrice: float;
    var P: integer; // Positions

    ApplyAutoStops( Bar );

    limitPrice := GetSeriesValue(Bar, hilo_s);
    if limitPrice = 0.0 then continue;

    if not LastPositionActive then
      BuyAtLimit(Bar + 1, limitPrice, 'HiLoLimit Buy');
end;


//// Visualize Results
// show profits as background color
WinLossBackground(0);
