{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'myScreenCommon'}


//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
function Registry(Version: string): TList;
begin
  const RegParam = ''
 + 'MainLeft, MainTop, MainWidth, MainHeight, MainState,'
 + 'CSExplorerLeft, CSExplorerTop, CSExplorerWidth, CSExplorerHeight, CSExplorerState,'
 + 'DebugLeft, DebugTop, DebugWidth, DebugHeight, DebugState,'
 + 'QuickRefLeft, QuickRefTop, QuickRefWidth, QuickRefHeight, QuickRefState,'
 + 'DataFormLeft, DataFormTop, DataFormWidth, DataFormHeight, DataFormState,'
 + 'StartFolder, ChartStyle, ChartStyleClassName, Log, Linear,'
 + 'UseIEProxy, ProxyServer, ProxyPort, UseProxy, ProxyUser,'
 + 'ProxyPassword, ViewStatusBar, ViewIconBar, StockMode, OutlookWidth,'
 + 'DefaultBarSpacing, LiveUpdates, KagiAmount, KagiPercentage, RenkoAmount,'
 + 'LineBreakAmount, ChartBarRange, UsePerfScript, UserID, CSSplitter,'
 + 'OptUseSim, MonteCarlo, MontePasses, MonteRuns, DSTreeWidth,'
 + 'IDServer, EODProvider, ExcludeLastBar, Commission, Slippage,'
 + 'EnableSlippage, LimitSlippage, PlayAlert, PlayRTS, Timeout,'
 + 'DSSize, PlayAlertCS, PlayLive, CSScan, OVScan,'
 + 'CSSim, OVSim, OVChart, OVRank, AutoBackup,'
 + 'EMailAlertOn, EMailChartScript, EMailAlert, MailHost, MailUser,'
 + 'ColorBackground, ColorUp, ColorDown, ColorVolume, ColorGrid,'
 + 'ColorMargin, CurrencyDecimals, IndicatorDecimals, CurrencySymbol, ScrollData,'
 + 'ScrollRate, ShowLists, SynchOn, Synch1, Synch2,'
 + 'Synch3, PerShare, CommScript, CommScriptName, AllowLowerCase,'
 + 'SoundHover, MailAuth, MailPassword, MailPort, DrawGridHorz,'
 + 'DrawGridVert, PlotLabels, MaxItems, LimitDay, RoundTick,'
 + 'GTC, BuyingPowerCheck, CashCheck, BaseFont, BaseFontSize,'
 + 'BkgColor, FontColorIdent, FontBoldIdent, FontItalicIdent, FontUnderlineIdent,'
 + 'FontColorKeyword, FontBoldKeyword, FontItalicKeyword, FontUnderlineKeyword, FontColorWealthScript,'
 + 'FontBoldWealthScript, FontItalicWealthScript, FontUnderlineWealthScript,FontColorComment, FontBoldComment,'
 + 'FontItalicComment, FontUnderlineComment, FontColorConst, FontBoldConst, FontItalicConst,'
 + 'FontUnderlineConst, FontColorSymbol, FontBoldSymbol, FontItalicSymbol, FontUnderlineSymbol,'
 + 'FontColorString, FontBoldString, FontItalicString, FontUnderlineString, FontColorNumbers,'
 + 'FontBoldNumbers, FontItalicNumbers, FontUnderlineNumbers, FontColorInclude, FontBoldInclude,'
 + 'FontItalicInclude, FontUnderlineInclude, AxisFont, AxisFontSize, AxisFontBold,'
 + 'AxisFontItalic, AxisFontUnderline, AxisFontColor, TradeFont, TradeFontSize,'
 + 'TradeFontBold, TradeFontItalic, TradeFontUnderline, TradeFontColor, TabWidth,'
 + 'FillCandle, DisableRollover, CashFalls, CashFallsVal, BPFalls,'
 + 'BPFallsVal, CancelActive, BarCompression, SameBarExit, ApplyCorrections,'
 + 'CompleteUpdate, UpdatedEMA, StDevPop, BadTickFilter, BadTick,'
 + 'Scheduled, ScheduleHour, UpdateMinute, RoundLots, RoundUp100,'
 + 'ApplyRates, CashRate, MarginRate, NoAutoExec, SimLeadBars,'
 + 'SimWeekly, SimMonthly, SimCapital, SimPosSize, SimPctEquity,'
 + 'SimStopRisk, SimFixed, SimShare, ShareSize, SimPct,'
 + 'SimStopBased, SimSimuScript, SimChartScript, SimDaily, SimUsePartial,'
 + 'SimUseMax, SimMaxPos, SimDayTrades, Liquidity, LiquidityAmount,'
 + 'SimAtClose, SimAtLimit, Leeway, DiscardSymbols, SimSimuScriptSelected,'
 + 'SimMargin, SimMarginFactor, SimRunNbr, ScanWeekly, ScanMonthly,'
 + 'ScanFolder, ScanChartScript, ScanMultiSymbol, ScanPage, RTSProvider,'
 + 'RTSFolder, RTSChartScript, RTSInterval, PerfScript, PerfScriptAuto,'
 + 'CommentaryLeft, CommentaryTop, CommentaryWidth, CommentaryHeight, CommentaryState,'
 + 'WizardFormLeft, WizardFormTop, WizardFormWidth, WizardFormHeight, WizardFormState,'
 + 'SimpleIndicator2Saved, SimpleIndicator2Style, SimpleIndicator2Color, BaseSaved, BaseStyle,'
 + 'BaseColor, BetaSaved, BetaStyle, BetaColor, Beta0,'
 + 'Beta1, Beta2, TrendLineSettings, ColorVolumeUp, ColorVolumeDown,'
 + 'DontShowHome, FuturesMode, DecreaseShares, UpdateFundamental, ADXSaved,'
 + 'ADXStyle, ADXColor, ADX0, ATRSaved, ATRStyle,'
 + 'ATRColor, ATR0, BBandUpperSaved, BBandUpperStyle, BBandUpperColor,'
 + 'BBandUpper0, BBandUpper1, BBandUpper2, AroonOscSaved, AroonOscStyle,'
 + 'AroonOscColor, AroonOsc1, AroonUpSaved, AroonUpStyle, AroonUpColor,'
 + 'AroonUp0, AroonUp1, AroonDownSaved, AroonDownStyle, AroonDownColor,'
 + 'AroonDown1, AroonDown0, ATR2Saved, ATR2Style, ATR2Color,'
 + 'ATR20, BBandBandWidthSaved, BBandBandWidthStyle, BBandBandWidthColor, BBandBandWidth0,'
 + 'BBandBandWidth1, BBandBandWidth2, AroonOsc0, MACDExSaved, MACDExStyle,'
 + 'MACDExColor, MACDEx0, MACDEx1, MACDEx2, MACDSaved,'
 + 'MACDStyle, MACDColor, MACD0, OrdersBroker, OrdersPort,'
 + 'OrderID, Route, AutoDeleteCancel, MACDTrigSaved, MACDTrigStyle,'
 + 'MACDTrigColor, MACDTrig0, MACDTrig1, MACDTrig2, MACDTrig3,'
 + 'MACDTrigCrossSaved, MACDTrigCrossStyle, MACDTrigCrossColor, MACDTrigCross0, MACDTrigCross1,'
 + 'MACDTrigCross2, MACDTrigCross3, ProxyExamined, Directory, SoundAlert,'
 + 'SoundRTS, SoundAlertCS, SoundLive, EvalStart, EvalStop,'
 + 'EvalStep, EvalLead, EvalCode, EvalFilter, EvalFilterMin,'
 + 'EvalFilterMax, EvalDays, EvalRows, EvalWeekly, EvalMonthly,'
 + 'AlertAutoSort, AlertSuspend, AlertFeed, AlertBidAsk, AlertOpen,'
 + 'AlertUp, AlertMkt, QMProvider, QMMktOrders, TargetPct,'
 + 'RemoveTriggered, SmartRemoval, AlertsTrigger7, PortfolioMgr, EqDS,'
 + 'RankFolder, RankFolderName, RankingsWeekly, RankingsMonthly, SimChartScriptValue,'
 + 'SimFolder, StreamingProvider, WLRankingsFolder, WLRankingsWeekly, WLRankingsMonthly,'
 + 'MultipleSTDSaved, MultipleSTDStyle, MultipleSTDColor, MultipleSTD0, MultipleSTD1,'
 + 'MultipleSTD2, SimWidth, DebugEvalLeft, DebugEvalTop, DebugEvalWidth,'
 + 'DebugEvalHeight, DebugEvalState';

  const ParamLen = 5*76+2;
  const KEY1 = 'HKEY_CURRENT_USER\Software\Wealth-Lab\Wealth-Lab Developer 3.0\';
  const KEY2 = 'HKEY_CURRENT_USER\Software\Fidelity Investments\Wealth-Lab Pro\';
  var RegIndex: integer;
  var Key, RegItem: string;
  var Shell: COMVariant = CreateOleObject('WScript.Shell');
  var Reg: TList = TList.Create( );

  if Version = 'WLD' then Key := KEY1 else Key := KEY2;
  for RegIndex := 0 to ParamLen-1 do
  begin
    try
      RegItem := Trim(GetToken(RegParam, RegIndex, ','));
      Reg.AddData(RegItem, Shell.RegRead(Key + RegItem));
    except;
    end;
  end;
  Reg.SortString;
  Result := Reg;
end;

//Ex:
var MyReg: Tlist = Registry('WLD'); //or 'WLP'
var j : integer;
var t: string = '<'+'table cellpadding="0" cellspacing="0" border="1">';
for j := 0 to MyReg.Count-1 do
  t := t + '<'+'tr><'+'td>'
         + MyReg.Item(j)+'<'+'/td><'+'td>'
         + MyReg.Data(j)+'<'+'/td><'+'/tr>';
t := t + '<'+'/table>';
AddCommentary(t);


