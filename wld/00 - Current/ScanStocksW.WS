{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
ChangeScale( #Weekly );
{$I 'myCommon'}

///////////////////////////////////////////////////////////////////////////////
function readWatchList(): TList;
begin
  var watchListNum: integer;
  var list : TList;

  list := TList.Create;
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    list.Add( WatchListSymbol (watchListNum) );
  end;
  Result := list;
end;
///////////////////////////////////////////////////////////////////////////////
procedure printTList( list: TList);
begin
  var num: integer;
  for num := 0 to list.Count-1 do
  begin
    Print( list.Item( num ) );
  end;
end;
//______________________________________________________________________________
//
function PriceVolumeBarsRequirement (list: TList; newWatchList: String;
            minPrice: float; minVolume: integer; minBars: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount = 0 ) then
        continue;
    except
      continue;
    end;

    if( PriceClose( BarCount-1 ) < minPrice ) then
      continue;

    if( Volume( BarCount-1 ) < minVolume ) then
      continue;

    if( BarCount < minBars ) then
      continue;

    WatchListAddSymbol (newWatchList, '', GetSymbol);
    newList.Add( GetSymbol );
  end;
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function ATH (list: TList; newWatchList: String; backDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < backDays ) then
        continue;

      if( HighestBar( BarCount-1, #High, BarCount ) >= BarCount-1-backDays ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function VolumeDouble (list: TList; newWatchList: String; barsToTest, barsToGoBack: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var bar: integer;
      var avg: float;
      var flag: boolean;

      avg := (Volume(BarCount-barsToGoBack)+Volume(BarCount-barsToGoBack-1)+Volume(BarCount-barsToGoBack-2))/3;
      flag := true;
      for bar := BarCount-barsToTest to BarCount-1 do
      begin
        if( Volume( bar ) < 2*avg ) then
          flag := false;
      end;
      if ( flag ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function ConsecutiveGreenBars (list: TList; newWatchList: String; period: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var flag: boolean;
      var bar: integer;
      flag := true;
      for bar := BarCount-period to BarCount-1 do
      begin
        if( PriceClose( bar ) <= PriceClose( bar-1 ) ) then
          flag := false;
      end;
      if ( flag ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
function PriceRising( list: TList; newWatchList: String ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var rising: boolean;
      var bar: integer;
      rising := true;
      for bar := BarCount-52 to BarCount-1 do
      begin
        if( EMA( bar, #close, 26 ) < EMA( bar-1, #Close, 26 ) ) then
          rising := false;
      end;
      if ( rising ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
function PriceAtValue( list: TList; newWatchList: String ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( PriceClose( BarCount-1 ) < EMA( BarCount-1, #Close, 13 ) ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
function PriceOverExtended( list: TList; newWatchList: String ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var deviation, upperChannelPrice: float;
      deviation := getElderChannelDeviation( BarCount-1, 26, 12, 90 );
      upperChannelPrice := EMA(BarCount-1, #close, 26) * ( 1 + deviation );
      if( PriceClose( BarCount-1 ) > upperChannelPrice ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
//
function GenerateElderChannelReq( list: TList; newWatchList: String;
            period, loopbackmonth, cutoffPercent: integer ): TList;
begin

  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    try
      SetPrimarySeries (list.Item( num ) );
      var deviation, channelRange, channelRangePercent: float;
      deviation := getElderChannelDeviation( BarCount-1, period, loopbackmonth, cutoffPercent );
      channelRange := EMA(BarCount-1, #close, period) * 2 * deviation;
      channelRangePercent := 2 * deviation * 100;
      if( channelRangePercent > 30 ) then
      begin
          WatchListAddSymbol (newWatchList, '', GetSymbol);
          newList.Add( GetSymbol );
          Print( GetSymbol + #9 + FloatToStr( channelRangePercent ) );
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
procedure printSymbolInfo( list: TList );
begin
  var num: integer;

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var change, avg: float;
      avg := (Volume(BarCount-5)+Volume(BarCount-6)+Volume(BarCount-7))/3;
      change := 100*(Volume(BarCount-1)-avg)/avg;
      Print( GetSymbol
              + #9 + FormatFloat( '#', change )
              + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) )
              + #9 + FloatToStr( Volume( BarCount-1 ))
              );
    except
      continue;
    end;
  end;
end;
//______________________________________________________________________________
//______________________________________________________________________________
// Main Program
var n1, n2: integer;
n1 := GetTickCount;

var list : TList;

list := readWatchList();

//list := PriceVolumeBarsRequirement ( list, 'W1-MinRequirement', 10, 100000, 18*4);
  //PriceOverExtended( list, 'W1-Overextended' );
list := PriceRising( list, 'W2-Rising' );
PriceAtValue( list, 'W3-AtValue' );
//GenerateElderChannelReq ( list, 'W3-MinReqCh', 26, 12, 90 );

  //ATH( list, 'W3-ATH', 4 ); // 1 month

//VolumeDouble( list, 'W3-VolumeDouble', 2, 10 );
//ConsecutiveGreenBars (list, 'W3-3GreenW', 3);

  //printSymbolInfo( list );
  //printTList( list );

n2 := GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');


