{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);
EnableSynch( false );
ChangeScale( #Daily );

//==============================================================================
// Initialize CSharp Script
var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass: ComVariant = csScripting.LoadFile ( 'CSharpScripts\Everything.cs' );
if ( AsString(myclass) = '' ) then Abort;
myclass.EverythingInit( IWealthLabAddOn3 );
//==============================================================================

//______________________________________________________________________________
// Draws Label in bigger font on the price pane
//------------------------------------------------------------------------------
var myDrawLabelX: integer = 38;
procedure MyDrawLabel (str: String; color: integer);
begin
  DrawText (str, 0, 7, myDrawLabelX, color, 10);
  myDrawLabelX := myDrawLabelX + 15;
end;


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
  Print( 'Total count = ' + IntToStr( list.Count ) );
  for num := 0 to list.Count-1 do
  begin
    Print( list.Item( num ) );
  end;
end;
///////////////////////////////////////////////////////////////////////////////
function PriceVolumeBarsRequirement (list: TList; newWatchList: String;
            minPrice: float; minVolume: integer; minBars: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('PriceVolumeBarsRequirement: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );

      if( BarCount < minBars ) then
        continue;

      if( PriceClose( BarCount-1 ) < minPrice ) then
        continue;

      if( ( SMA( BarCount-1, #Volume, 22 ) < minVolume )
          or ( Volume( BarCount-1 ) < minVolume )
          ) then
        continue;

      WatchListAddSymbol (newWatchList, '', GetSymbol);
      newList.Add( GetSymbol );
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//______________________________________________________________________________
// Volume should be in topVolPer, price and bar should be at least as
// specified
//------------------------------------------------------------------------------
function PriceVolumeBarsRequirement2 (list: TList; newWatchList: String;
            minPrice, topVolPer: float; minBars: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;
  var volList: TList = TList.Create;
  var priceBarReqList: Tlist = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('PriceVolumeBarsRequirement: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );

      volList.AddData( SMA( BarCount-1, #Volume, 22 ), GetSymbol );
      if( (BarCount > minBars) and (PriceClose(BarCount-1) > minPrice) ) then
        priceBarReqList.Add( GetSymbol );
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();

  volList.sortNumeric();

  var start : integer = Trunc( volList.Count*(1-topVolPer) );
  Print( 'PriceVolumeBarsRequirement2: Least Volume = ' + FormatFloat('#', volList.Item(start)) );
  for num := start to volList.Count-1 do
  begin
    var symbol: string = volList.Data( num );
    if( priceBarReqList.IndexOf( symbol ) <> -1 ) then
    begin
      WatchListAddSymbol (newWatchList, '', symbol);
      newList.Add( symbol );
    end;
  end;
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function ATH (list: TList; newWatchList: String; startDays, endDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('ATH: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < startDays ) then
        continue;

      var hBar : integer = HighestBar( BarCount-1, #High, BarCount );
      if( ( hBar >= startDays ) and ( hBar <= endDays ) ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function ATHNew (list: TList; newWatchList: String; backDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('ATHNew: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < ( backDays + 1 ) ) then
        continue;

      if( HighestBar( BarCount-2, #High, BarCount-1 ) <= BarCount-2-backDays ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function Month3High (list: TList; newWatchList: String; backDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Month3High: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < backDays ) then
        continue;

      if( HighestBar( BarCount-1, #High, 3*22 ) > BarCount-backDays ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function Month3Low (list: TList; newWatchList: String; backDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Month3Low: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < backDays ) then
        continue;

      if( LowestBar( BarCount-1, #Low, 3*22 ) > BarCount-backDays ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//////////////////////////////////////////////////////////////////////////////
function WeakBulls (list: TList; newWatchList: String): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('WeakBulls: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries( list.Item( num ) );
      if( BarCount < 44 ) then
        continue;

      var endBar : integer = BarCount-1;
      var lowBar : integer = LowestBar( endBar-1, #Low, 5 );
      var shortTermUp : boolean = true;
      if( PriceClose(endBar) > PriceOpen(endBar) ) then
        shortTermUp := false;
      if( ( lowBar = endBar-1 ) or ( lowBar = endBar-2 ) ) then
        shortTermUp := false;
      var bar : integer;
      for bar := lowBar to endBar-2 do
      begin
        if( PriceClose( bar ) > PriceClose( bar+1 ) ) then
          shortTermUp := false;
      end;
      if( shortTermUp ) then
      begin
        var highBar : integer = HighestBar( lowBar-1, #High, 8 );
        var highBar2 : integer = HighestBar( endBar, #High, 22 );
        if( highBar = highBar2 ) then
        begin
          WatchListAddSymbol (newWatchList, '', GetSymbol);
          newList.Add( GetSymbol );
        end;
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//______________________________________________________________________________
//
function GenerateBullishReversal( list: TList; newWatchList: String ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('GenerateBullishReversal: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries( list.Item( num ) );

      if( BarCount < 254 ) then
        continue;

      // make sure 52-w High is in last 4 months, but not in last 11 days
      var topBar: integer = HighestBar( BarCount-1, #High, 254 );
      if( ( topBar < BarCount-1-88 ) or ( topBar > BarCount-1-11 ) ) then
        continue;

      // make sure EMA is rising right now and was falling a month back
      if( EMA( BarCount-1, #Close, 22 ) > EMA( BarCount-2, #Close, 22 ) )
        and ( EMA( BarCount-22, #Close, 22 ) < EMA( BarCount-23, #Close, 22 ) )
        then
      begin
        WatchListAddSymbol( newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;


///////////////////////////////////////////////////////////////////////////////
function BreakoutTraining (list: TList; newWatchList: String; numBDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('BreakoutTraining: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < numBDays ) then
        continue;

      var skipDays : integer = 22+1;
      var highestPriceBarB: integer = HighestBar (
                                BarCount-skipDays, #High, BarCount-skipDays);
      Print( IntToStr(BarCount-highestPriceBarB) );
      if( highestPriceBarB > (BarCount-numBDays) )
        and ( highestPriceBarB < (BarCount-2*skipDays) ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function MultiplyInGivenDays (list: TList; newWatchList: String; factor: float; numDays: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('MultiplyInGivenDays: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < numDays ) then
        continue;

      var highestPrice: float = Highest (BarCount-1, #Close, numDays);
      var highestPriceBar: integer = HighestBar (BarCount-1, #Close, numDays);
      var lowestPrice: float = Lowest (highestPriceBar-1, #Close, numDays);
      var lowestPriceBar: integer = LowestBar (highestPriceBar-1, #Close, numDays);
      if (highestPrice > (factor*lowestPrice)) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function VolumeIncrease( list: TList; newWatchList: String; period, goBack: integer; factor: float ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('VolumeIncrease: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      if( BarCount < goBack+period ) then
        continue;

      var avgVolCurr : float = SMA( BarCount-1, #Volume, period );
      var avgVolBack : float = SMA( BarCount-goBack, #Volume, period );
      if( avgVolCurr > ( factor * avgVolBack ) ) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function PercentChangeLastBar (list: TList; newWatchList: String; cutoffPercent: float): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('PercentChangeLastBar: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var percentChange: float;
      percentChange := 100 * ( PriceClose( BarCount-1 ) - PriceClose( BarCount-2 ) ) / PriceClose( BarCount-2 );
      if (percentChange >= cutoffPercent) then
      begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function ScanForHighLowRange (list: TList; newWatchList: String; period: integer; cutoffPercent: float): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('ScanForHighLowRange: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var score, bar: integer;
      var bodyLength, tailLength: float;
      score := 0;
      bodyLength := 0;
      tailLength := 0;
      for bar := BarCount-period to BarCount-1 do
      begin
        var percentChange: float;
        percentChange := 100 * ( PriceHigh( bar ) - PriceLow( bar ) ) / PriceLow( bar );
        if( percentChange >= cutoffPercent ) then
          score := score + 1;
        if( PriceClose( bar ) > PriceOpen( bar ) ) then //green
        begin
          bodyLength := bodyLength + (PriceClose( bar ) - PriceOpen( bar ));
          tailLength := tailLength + (PriceHigh( bar ) - PriceClose( bar ))
                                   + (PriceOpen( bar ) - PriceLow( bar ));
        end
        else
        begin
          bodyLength := bodyLength + (PriceOpen( bar ) - PriceClose( bar ));
          tailLength := tailLength + (PriceHigh( bar ) - PriceOpen( bar ))
                                   + (PriceClose( bar ) - PriceLow( bar ));
        end;
      end;
      if //( score > period/2 )
         //and
         ( tailLength > bodyLength )
      then
      begin
        Print( GetSymbol + #9 + IntToStr( score )
              + #9 + FormatFloat( '#.##', tailLength/bodyLength )
              + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) )
              + #9 + FloatToStr( Volume( BarCount-1 ))
              );
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
///////////////////////////////////////////////////////////////////////////////
function ScanForBarIntersection (list: TList; newWatchList: String; period: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('ScanForBarIntersection: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var bar: integer;
      var score: float;
      score := 0;
      for bar := BarCount-period to BarCount-1 do
      begin
        var minHigh, maxLow: float;
        var intersectionNormalized: float;
        minHigh := Min( PriceHigh( bar ), PriceHigh( bar-1 ) );
        maxLow := Max( PriceLow( bar ), PriceLow( bar-1 ) );
        intersectionNormalized := ( minHigh - maxLow ) / PriceClose( bar );
        score := score + intersectionNormalized;
      end;
      newList.AddData( score, GetSymbol );
    except
      continue;
    end;
  end;

  newList.sortNumeric();
  var finalList: TList = TList.Create;

  for num := list.Count-1 downto list.Count-50 do
  begin
    var symbol: String;
    var score: float;
    symbol := newList.Data( num );
    score := newList.Item( num );
    Print( symbol + #9 + FormatFloat( '#.####', score ) );
    WatchListAddSymbol (newWatchList, '', symbol);
    finalList.Add( symbol );
  end;
  RestorePrimarySeries();
  ClearIndicators();
  Result := finalList;
end;
///////////////////////////////////////////////////////////////////////////////
function ScanForGreenBars (list: TList; newWatchList: String; period: integer; minPercent: float): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('ScanForGreenBars: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var score, bar: integer;
      score := 0;
      for bar := BarCount-period to BarCount-1 do
      begin
        if( PriceClose( bar ) > PriceOpen( bar ) ) then
          score := score + 1;
      end;
      if ( score > minPercent * period / 100 ) then
      begin
        Print( GetSymbol + #9 + IntToStr( score )
              + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) )
              + #9 + FloatToStr( Volume( BarCount-1 ))
              );
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
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
    PrintStatus ('ConsecutiveGreenBars: ' + IntToStr(num) +
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
  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function GenerateElderChannelReq( list: TList; newWatchList: String;
            minPerCh: float; period, loopbackbar, cutoffPercent: integer ): TList;
begin

  if (Not IsDaily) then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('GenerateElderChannelReq: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) ); myclass.SetPrimarySeries ( false );
    except
      continue;
    end;

    var deviation: float = 0;

    myclass.Everything_GetChannelDeviation( BarCount-1, 22, 132, 90, deviation );

    var channelRange : float = EMA(BarCount-1, #close, period) * 2 * deviation;
    var channelRangePercent : float = 2 * deviation * 100;
    if( channelRangePercent > minPerCh ) then
    begin
        WatchListAddSymbol (newWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
    end;
  end;
  RestorePrimarySeries(); myclass.RestorePrimarySeries ( );
  ClearIndicators();
  Result := newList;
end;
//______________________________________________________________________________
// Finds the difference of two lists ( list1 - list2 )
//------------------------------------------------------------------------------
function DiffTList( list1, list2: TList; newWatchList: String ): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  // Clear the new watch list if it exists
  WatchListClear (newWatchList);

  for num := 0 to list1.Count-1 do
  begin
    PrintStatus ('DiffTList: ' + IntToStr(num) +
        '/' + IntToStr(list1.Count-1) + ' ' +  list1.Item( num ));
    if( list2.IndexOf( list1.Item(num) ) = -1 ) then
    begin
        WatchListAddSymbol (newWatchList, '', list1.Item( num ));
        newList.Add( GetSymbol );
    end;
  end;
  Result := newList;
end;
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
procedure printSymbolInfo( list: TList );
begin
  var num: integer;

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('printSymbolInfo: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );

      Print( GetSymbol
              + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) )
              + #9 + FormatFloat( '#', SMA( BarCount-1, #Volume, 22) )
              + #9 + FloatToStr( Volume( BarCount-1 ))
              );
    except
      continue;
    end;
  end;
  RestorePrimarySeries();
  ClearIndicators();
end;
//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------

var n1, n2: integer;
n1 := GetTickCount;
var prefix: string = 'D';
var list, list3mH : TList;

if( myclass.GetBoolParam('TrainingMode') ) then
  prefix := 'D'      // D = Demo
else
  prefix := 'C';     // C = Current

list := readWatchList();

list := PriceVolumeBarsRequirement ( list, prefix + '1-MinReq', 10, 100000, 22*6);
//list := PriceVolumeBarsRequirement2 ( list, prefix + '1-MinReq2', 10, 0.25, 22*6);

list := GenerateElderChannelReq ( list, prefix + '1-MinReqCh', 20, 22, 132, 90 );

//ScanForGreenBars( list, 'D2-GreenBars', 44, 70 );
//ScanForHighLowRange( list, 'D2-HighLowRange', 10, 5 );
//ScanForBarIntersection( list, 'D2-BarIntersection', 10 );
//PriceVolumeBarsRequirement ( list, 'D2-HighVol15M', 10, 15000000, 22*6);
//PriceVolumeBarsRequirement ( list, 'D2-HighVol10M', 6, 10000000, 22*6);
//PriceVolumeBarsRequirement ( list, 'D2-HighVol1M', 6, 1000000, 22*6);
//ConsecutiveGreenBars( list, 'D2-5Green', 5);

WeakBulls( list, prefix + '2-WeakBulls' );
GenerateBullishReversal( list, prefix + '2-BullishRev' );

///list3mH := Month3High( list, prefix + '2-3mHigh', 22 ); // in 1 month
Month3Low( list, prefix + '2-3mLow', 22 ); // in 1 month

///ATH( list, prefix + '2-ATH-4m-1m', BarCount-88, BarCount-23 ); // 4 month to 1 month back
list := ATH( list, prefix + '2-ATH', BarCount-22, BarCount-1 ); // 1 month back

///DiffTList( list3mH, list, prefix + '2-3mHighNATH' ); // 3mHigh - ATH

///ATHNew( list, prefix + '3-ATHNew', 22 ); // 1 month

//MultiplyInGivenDays( list, 'D3-Dou6M', 2.0, 22*6 );
//MultiplyInGivenDays( list, 'D3-1M1.5X', 1.5, 22 );
//MultiplyInGivenDays( list, 'D3-2M1.5X', 1.5, 22*2 );
//VolumeIncrease( list, 'D3-VD6M', 22, 22*6, 2.0 );
//VolumeIncrease( list, 'D3-V5D6M', 22, 22*6, 5.0 );
//ConsecutiveGreenBars( list, 'D3-5Green', 5);

//PercentChangeLastBar( list, 'D3-PerChangeLastBar10', 10 );
//BreakoutTraining( list, 'D3-BreakoutTraining', 22*6 );

//printSymbolInfo( list );
///printTList( list );

DrawText( 'MyDStockSelection Done!!!', 0, 10, 150, #Blue, 40 );

n2 := GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');




