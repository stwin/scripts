//var tick1: integer = GetTickCount();
{$I 'myfedresmeet'}
//______________________________________________________________________________
//______________________________________________________________________________
// Plot NH and NL Series
//
procedure plotNHNLSeriesV2( paneSize, plotHisto: integer );
begin
  var NHSeries, NLSeries, NHNLSeries, paneNHNL_Line: integer;

  NHSeries := GetExternalSeries( 'NH-NL', #High );
  NLSeries := GetExternalSeries( 'NH-NL', #Low );
  SynchSeries( 'NH-NL' );
  SetDescription( NHSeries, 'NHSeries' );
  SetDescription( NLSeries, 'NLSereis' );

  paneNHNL_Line := CreatePane( paneSize, false, false);

  // First FedResMeet, then other indicators
  PlotSeriesLabel( getFedResMeetSeries(), paneNHNL_Line, #Blue, #Histogram, 'Fed. Res. Meet' );

  DrawHorzLine (0, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (300, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (600, paneNHNL_Line, 779, #Thin);
  DrawHorzLine (-300, paneNHNL_Line, 779, #Thin);
  PlotSeriesLabel( NHSeries,  paneNHNL_Line, #Green, #Thin, 'Number of 52-week High' );
  PlotSeriesLabel( NLSeries,  paneNHNL_Line, #Red, #Thin, 'Number of 52-week Low' );

  if( plotHisto = 1 ) then
  begin
    var paneNHNL_Hist: integer = CreatePane( paneSize, false, false );
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
//
procedure plotNHNLSeries();
begin
  plotNHNLSeriesV2( 60, 0 );
end;
//______________________________________________________________________________

//plotNHNLSeries;

//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );












// FOLLOWING TEXTS ARE FOR RECORD PURPOSE ONLY. THEY ARE OLD AND OUTDATED.

//______________________________________________________________________________
//__________________ O L D   I M P L E M E N T A T I O N _______________________
//______________________________________________________________________________
//var tick1: integer = GetTickCount();
// Generate NH and NL Series
//
var  NnewHigh_NewLow_fileName : string = 'D:\WL\NH-NL.txt';
procedure ReadNHNLSeries_direct();
begin
  var fileHandle: integer = FileOpen( NnewHigh_NewLow_fileName );
  var NHSeries: integer = CreateNamedSeries( 'NewHighSeries_direct' );
  var NLSeries: integer = CreateNamedSeries( 'NewLowSeries_direct' );

  while not FileEOF (fileHandle) do
  begin
    var line, dateStr, numHighStr, numLowStr: String;

    line := FileRead (fileHandle);
    dateStr := GetToken (line, 0, ',');
    numHighStr := GetToken (line, 1, ',');
    numLowStr := GetToken (line, 2, ',');

    try
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NHSeries, StrToFloat(numHighStr));
      SetSeriesValue (DateToBar(StrToDate(dateStr)), NLSeries, StrToFloat(numLowStr));
    except
    end;

  end;
  FileClose (fileHandle);
end;
//________________________
function NewHighSeries_direct(): integer;
begin
  var sName: string;
  var value: float;

  Result := FindNamedSeries( 'NewHighSeries_direct' );
  if Result >= 0 then
    exit;
  ReadNHNLSeries_direct();
  Result := FindNamedSeries( 'NewHighSeries_direct' );
end;
//________________________
function NewHigh_direct( bar, series, period1, period2: integer ): float;
begin
  Result := GetSeriesValue( bar, NewHighSeries_direct() );
end;
//________________________
function NewLowSeries_direct(): integer;
begin
  var sName: string;
  var value: float;

  Result := FindNamedSeries( 'NewLowSeries_direct' );
  if Result >= 0 then
    exit;
  ReadNHNLSeries_direct();
  Result := FindNamedSeries( 'NewLowSeries_direct' );
end;
//________________________
function NewLow_direct( bar, series, period1, period2: integer ): float;
begin
  Result := GetSeriesValue( bar, NewLowSeries_direct() );
end;

//____________________________
// Plot NH and NL Series
//
procedure plotNHNLSeriesV2_direct( paneSize, plotHisto: integer );
begin
  var NHSeries, NLSeries, NHNLSeries, NHNLpane1: integer;

  NHSeries := NewHighSeries_direct();
  NLSeries := NewLowSeries_direct();

  NHNLpane1 := CreatePane( paneSize, false, false);

  PlotSeriesLabel( NHSeries,  NHNLpane1, #Green, #Thin, 'Number of 52-week High' );
  PlotSeriesLabel( NLSeries,  NHNLpane1, #Red, #Thin, 'Number of 52-week Low' );

  if( plotHisto = 1 ) then
  begin
    var NHNLpane2: integer = CreatePane( paneSize, false, false );
    DrawHorzLine (0, NHNLpane2, #Olive, #Thin);
    NHNLSeries := SubtractSeries( NHSeries, NLSeries );
    PlotSeriesLabel( NHNLSeries, NHNLpane2, #Black, #Histogram, '52-week NHNL Index' );
  end;
end;
//____________________________
procedure plotNHNLSeries_direct();
begin
  plotNHNLSeriesV2_direct( 20, 0 );
end;
//____________________________
//plotNHNLSeries_direct;
//Print( 'Time = ' + IntToStr(GetTickCount() - tick1) + ' ms' );
//______________________________________________________________________________
//______________________________________________________________________________
//______________________________________________________________________________


