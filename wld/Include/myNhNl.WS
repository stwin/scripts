//var tick1: integer = GetTickCount();
//______________________________________________________________________________
// Plot NH and NL Series
//------------------------------------------------------------------------------
procedure plotNHNLSeriesV2( paneSize, plotHisto: integer );
begin
  var NHSeries, NLSeries, NHNLSeries, paneNHNL_Line: integer;
  var Symbol : string;
  if ( IsDaily ) then
    Symbol := 'NH-NL-Daily'
  else if ( IsWeekly ) then
    Symbol := 'NH-NL-Weekly'
  else
    exit;
  NHSeries := GetExternalSeries( Symbol, #High );
  NLSeries := GetExternalSeries( Symbol, #Low );
  SynchSeries( Symbol );
  SetDescription( NHSeries, 'NHSeries' );
  SetDescription( NLSeries, 'NLSereis' );

  paneNHNL_Line := CreatePane( paneSize, false, false);
  SetPaneMinMax( paneNHNL_Line, 0, 800 );

  // First FedResMeet, then other indicators
  var fedSeries: integer = CreateNamedSeries( 'FedResMeet' );
  myclass.GetFedResMeetSeries ( fedSeries );
  PlotSeriesLabel( fedSeries, paneNHNL_Line, #Blue, #Histogram, 'Fed. Res. Meet' );

  DrawHorzLine (0, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (300, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (600, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (-300, paneNHNL_Line, 779, #Thin);
  PlotSeriesLabel( NHSeries,  paneNHNL_Line, #Green, #Thin, 'Number of 52-week High' );
  PlotSeriesLabel( NLSeries,  paneNHNL_Line, #Red, #Thin, 'Number of 52-week Low' );

  if( plotHisto = 1 ) then
  begin
    var paneNHNL_Hist: integer = CreatePane( paneSize, false, false );
    SetPaneMinMax( paneNHNL_Line, -300, 800 );
    NHNLSeries := SubtractSeries( NHSeries, NLSeries );

    DrawHorzLine (0, paneNHNL_Hist, #Olive, #Thin);
    DrawHorzLine (300, paneNHNL_Hist, 887, #Thin);
    DrawHorzLine (600, paneNHNL_Hist, 887, #Thin);
    DrawHorzLine (-300, paneNHNL_Hist, 887, #Thin);
    PlotSeriesLabel( NHNLSeries, paneNHNL_Hist, #Black, #Histogram, '52-week NHNL Index' );
  end;
end;
//______________________________________________________________________________
// Plot NH and NL Series
//------------------------------------------------------------------------------
procedure plotNHNLSeries();
begin
  plotNHNLSeriesV2( 60, 0 );
end;
//______________________________________________________________________________
//plotNHNLSeries;
//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );

