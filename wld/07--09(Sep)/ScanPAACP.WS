{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
{$I 'myScreenCommon'}


//______________________________________________________________________________
//
//------------------------------------------------------------------------------
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
//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function ScanPAACP( list: TList; newWatchList: String ): TList;
begin
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
      SetPrimarySeries (list.Item( num ) );
    except
      continue;
    end;
    
    if ( BarCount < 150 ) then
      continue;

    var mema: integer = EMASeries( #Close, 22 );
    var bar, score: integer;

    score := 0;
    for bar := BarCount-100 to BarCount-1 do
    begin
      if ( ( PriceHigh(bar) > @mema[bar] ) and ( PriceLow(bar) < @mema[bar] ) ) then
        score := score + 1;
    end;
    
    Print ( GetSymbol + #9 + IntToStr(score) ); PrintFlush;
  end;

  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;

//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function ScanForTails( list: TList; newWatchList: String ): TList;
begin
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
      SetPrimarySeries (list.Item( num ) );
    except
      continue;
    end;

    if ( BarCount < 140 ) then
      continue;

    var mema: integer = EMASeries( #Close, 22 );
    var bar: integer;
    var bodyTotal, tailTotal: float;

    bodyTotal := 0;
    tailTotal := 0;
    for bar := BarCount-100 to BarCount-1 do
    begin
      var O, H, L, C, body, tail, mid: float;
      O := PriceOpen( bar );
      H := PriceHigh( bar );
      L := PriceLow( bar );
      C := PriceClose( bar );
      body := Abs ( O - C );
      tail := ( H - L ) - body;
      mid := ( H + L ) / 2;
      bodyTotal := bodyTotal + body / mid;
      tailTotal := tailTotal + tail / mid;
      //Print ( FloatToStr(O) + #9 + FloatToStr(H) + #9 + FloatToStr(L) + #9 + FloatToStr(C) + #9
      //    + FloatToStr(body) + #9 +  FloatToStr(tail) + #9 + FloatToStr(mid) + #9
      //    + FloatToStr(bodyTotal) + #9 + FloatToStr(tailTotal) );
    end;

    Print ( GetSymbol + #9 + FloatToStr(tailTotal) + #9 + FloatToStr(bodyTotal)
        + #9 + FloatToStr(tailTotal/bodyTotal) + #9 + FloatToStr(tailTotal/(tailTotal+bodyTotal)) );
    //PrintFlush;
  end;


  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;

//______________________________________________________________________________
//
//------------------------------------------------------------------------------
function ScanForChannels( list: TList; newWatchList: String ): TList;
begin
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
      SetPrimarySeries (list.Item( num ) );
    except
      continue;
    end;

    if ( BarCount < 200 ) then
      continue;

    var dev: float;

    if ( isDaily ) then
      dev := getElderChannelDeviation( BarCount-1, 22, 6, 90 )
    else
      dev := getElderChannelDeviation( BarCount-1, 26, 12, 90 );


    Print ( GetSymbol + #9 + FloatToStr(dev*200) );
    //PrintFlush;
  end;


  RestorePrimarySeries();
  ClearIndicators();
  Result := newList;
end;

//______________________________________________________________________________
//
//------------------------------------------------------------------------------
var list : TList;

list := readWatchList();

//ScanPAACP ( list, 'B-PAACP' );
//ScanForTails ( list, 'B-PAACP_Tails' );
ScanForChannels ( list, 'B-CH' );


