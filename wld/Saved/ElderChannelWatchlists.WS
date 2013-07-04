{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
ChangeScale( #Daily );
{$I 'myScreenCommon'}

///////////////////////////////////////////////////////////////////////////////
procedure GenerateElderChannelWatchList (newWatchList: String;
                          period, loopbackmonth, cutoffPercent: integer; isPercent: boolean);
begin
  var watchListNum: integer;

  if (Not IsDaily) then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  if( isPercent ) then
  begin
    WatchListClear (newWatchList + '-P');
    WatchListClear (newWatchList + '-P-20');
    WatchListClear (newWatchList + '-P-30');
    WatchListClear (newWatchList + '-P-50');
  end
  else
  begin
    WatchListClear (newWatchList + '-');
    WatchListClear (newWatchList + '-06-10');
    WatchListClear (newWatchList + '-10-15');
    WatchListClear (newWatchList + '-15-1000');
  end;

  for watchListNum := 0 to WatchListCount - 1 do
  //for watchListNum := 0 to 200 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;

    // skip if price < 4 or volume < 10000
    if ((PriceClose(Barcount-1) < 4) or (Volume(BarCount-1) < 10000)) then
      continue;

    // skip if above the fast ema
    //if( PriceLow(BarCount-1) > EMA(BarCount-1, #close, 11) ) then
    //  continue;

    var deviation, channelRange, channelRangePercent: float;

    deviation := getElderChannelDeviation (BarCount-1, period, loopbackmonth, cutoffPercent);
    channelRange := EMA(BarCount-1, #close, period) * 2 * deviation;
    channelRangePercent := 2 * deviation * 100;

    var localWatchList: String;

    //localWatchList := newWatchList;

    {
    if( channelRangePercent <= 0 ) then begin
    Print( GetSymbol
        + #9 + Formatfloat( '#.##', channelRangePercent )
        + #9 + Formatfloat( '#.##', SMA(BarCount-1, #Volume, 22) )
        + #9 + Formatfloat( '#.##', PriceClose(BarCount-1) )
        + #9 + FormatFloat( '#.##', channelRange )
        ); PrintFlush();                      end;
    }
    if (isPercent) then
    begin
      if (channelRangePercent >= 50) then
        localWatchList := newWatchList + '-P-50'
      else if (channelRangePercent >= 30) then
        localWatchList := newWatchList + '-P-30'
      else if (channelRangePercent >= 20) then
        localWatchList := newWatchList + '-P-20'
      else
        localWatchList := newWatchList + '-P-00';

      WatchListAddSymbol (localWatchList, '', GetSymbol);
    end
    else
    begin
      if ((channelRange >= 6) and (channelRange < 10)) then
        localWatchList := newWatchList + '-06-10'
      else if ((channelRange >= 10) and (channelRange < 15)) then
        localWatchList := newWatchList + '-10-15'
      else if ((channelRange >= 15) and (channelRange < 1000)) then
        localWatchList := newWatchList + '-15-1000'
      else
        localWatchList := newWatchList + '-00-06';
      WatchListAddSymbol (localWatchList, '', GetSymbol)
    end;

    //Print (GetSymbol + '   ' + FloatToStr(channelRange) + '  ' + FloatToStr(deviation));   PrintFlush;
  end;
end;
///////////////////////////////////////////////////////////////////////////////
procedure GenerateElderWatchLists (newWatchList: String;
                          period, loopbackmonth, cutoffPercent: integer; isPercent: boolean);
begin
  var BaseWatchList: string;
  var n1, n2: integer;
  n1:= GetTickCount;
  GenerateElderChannelWatchList (newWatchList, period, loopbackmonth, cutoffPercent, isPercent);
  n2:= GetTickCount;
  ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');
end;
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// For generating list
//GenerateElderWatchLists( WatchListName, 22, 6, 90, false ); // price range channel

GenerateElderWatchLists( WatchListName, 22, 6, 90, true );  // percent channel


