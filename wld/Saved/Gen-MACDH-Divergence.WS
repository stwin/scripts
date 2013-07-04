{$NO_AUTO_EXECUTE}
{$I 'MACDEx'}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////
procedure getBottom (var bar: integer; var bottomLast: float;
                     var barBottomLast: integer; macdh: integer);
begin
  for bar := bar downto 0 do
  begin
    if (@macdh[bar] < 0) then
      break;
  end;
  // Now we are pointing to a negative entry
  bottomLast := @macdh[bar];
  barBottomLast := bar;
  for bar := bar-1 downto 0 do
  begin
    if (@macdh[bar] >= 0) then
      break;
    if (@macdh[bar] < bottomLast) then
    begin
      bottomLast := @macdh[bar];
      barBottomLast := bar;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure getPeak (var bar: integer; var peakLast: float;
                     var barPeakLast: integer; macdh: integer);
begin
  for bar := bar downto 0 do
  begin
    if (@macdh[bar] > 0) then
      break;
  end;
  // Now we are pointing to a positive entry
  peakLast := @macdh[bar];
  barPeakLast := bar;
  for bar := bar-1 downto 0 do
  begin
    if (@macdh[bar] <= 0) then
      break;
    if (@macdh[bar] > peakLast) then
    begin
      peakLast := @macdh[bar];
      barPeakLast := bar;
    end;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure GenerateMACDHDivergenceWatchList (newWatchList: String);
begin
  var watchListNum: integer;
  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList + '-Bullish');
  WatchListClear (newWatchList + '-Bearish');

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 10 do
  begin

    PrintStatus ('Processing: ' + IntToStr(watchListNum+1)
          + '/' + IntToStr(WatchListCount)
          + ' ' +  WatchListSymbol (watchListNum));
    try
      EnableSynch( false );
      ClearIndicators();
      SetPrimarySeries (WatchListSymbol (watchListNum) );

    // Skip if Price < 4  or daily vol < 10000
    if (PriceCLose(BarCount-1) < 4) Or (Volume(BarCount-1) < 10000) then
      continue;

    var macdh : integer;
    var val1, val2, val3: integer;
    val1 := 12;
    val2 := 26;
    val3 := 9;
    macdh := SubtractSeries( MACDExSeries( #Close, val1, val2 ), EMASeries( MACDExSeries( #Close, val1, val2 ), val3 ) );

    var bar: integer;
    var bottomLast, bottom2ndLast: float;
    var barBottomLast, barBottom2ndLast: integer;
    
    bar := BarCount - 1;
    
    getBottom (bar, bottomLast, barBottomLast, macdh);
    getBottom (bar, bottom2ndLast, barBottom2ndLast, macdh);

    var peakLast, peak2ndLast: float;
    var barPeakLast, barPeak2ndLast: integer;

    bar := BarCount - 1;
    
    getPeak (bar, peakLast, barPeakLast, macdh);
    getPeak (bar, peak2ndLast, barPeak2ndLast, macdh);
    
    if (bottomLast > bottom2ndLast)
      and (PriceLow(barBottomLast) < PriceLow(barBottom2ndLast))
      and ((barBottomLast = BarCount-2)
            //or ((barBottomLast = BarCount-1)
               //  and (PriceClose(BarCount-1)>PriceOpen(BarCount-1))
            //   )
          )
      then
    begin
      WatchListAddSymbol (newWatchList + '-Bullish', '', GetSymbol);
    end;
    if (peakLast < peak2ndLast)
      and (PriceHigh(barPeakLast) > PriceHigh(barPeak2ndLast))
      and ((barPeakLast = BarCount-2)
            //or ((barPeakLast = BarCount-1)
               //   and (PriceClose(BarCount-1)<PriceOpen(BarCount-1))
            //   )
          )
      then
    begin
      WatchListAddSymbol (newWatchList + '-Bearish', '', GetSymbol);
    end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

GenerateMACDHDivergenceWatchList ( 'B-MACDH' );

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

