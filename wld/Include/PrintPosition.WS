
//______________________________________________________________________________
// Print Open Positions
//
procedure PrintOpenPosition ();
begin
  var file: integer;
  var FileName: String = myclass.GetRootDir() + '\Manage\Positions.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do
  begin
    var line, symbolStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');

    if (GetSymbol = symbolStr) then
    begin
      var positionSize, entryDate, entryBar: integer;
      var entryPrice, entryTotal, targetPrice, stopPrice: float;
      var currentPrice, currentTotal: float;
      var tradeType: string;
      tradeType := GetToken( line, 1, ',' );
      positionSize := StrToInt( GetToken( line, 2, ',' ) );
      entryDate := StrToInt( GetToken( line, 3, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 4, ',' ) );
      entryTotal := StrToFloat( GetToken( line, 5, ',' ) );
      stopPrice := StrToFloat( GetToken( line, 6, ',' ) );
      targetPrice := StrToFloat( GetToken( line, 7, ',' ) );

      currentPrice := PriceClose( BarCount-1 );
      currentTotal := positionSize * currentPrice;
      entryBar := DateToBar( entryDate );
      if( entryBar = -1 ) then
        exit;

      // Mark buy bar
      //SetBackgroundColor (entryBar, #BlueBkg);
      //AnnotateBar( 'B', entryBar, false, #Black, 7 );

      // Mark entryPrice, targetPrice and stopPrice
      var startBar: integer;
      if( entryBar < BarCount-2 ) then
        startBar := entryBar
      else
        startBar := BarCount-2;
      DrawLine( startBar, entryPrice, BarCount-1, entryPrice, 0, #Black, #thin );
      DrawLine( startBar, targetPrice, BarCount-1, targetPrice, 0, #Black, #thin );
      DrawLine( startBar, stopPrice, BarCount-1, stopPrice, 0, #Black, #thin );

      // Now some printing
      var entryStr, currStr, profitStr: String;

      entryStr := 'Entry   ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', entryPrice )
                        + ' = ' + FormatFloat( '#,###.#0', entryTotal );
      currStr := 'Current ' + IntToStr( positionSize )
                        + ' x ' + FormatFloat( '#.#0', currentPrice )
                        + ' = ' + FormatFloat( '#,###.#0', currentTotal );

      profitStr := 'Profits in ' + IntToStr( BarCount-entryBar ) + ' days = '
                          + FormatFloat( '#,###.#0', currentTotal-entryTotal );
      {
      MyDrawLabel( '', #Black );
      MyDrawLabel( entryStr, #Black );
      MyDrawLabel( currStr, #Black );
      if( currentTotal > entryTotal ) then
        MyDrawLabel( profitStr, #Green )
      else
        MyDrawLabel( profitStr, #Red );
       }
      // Now some detailed printing in the debug window
      Print( entryStr );
      Print( currStr );
      Print( profitStr );
      Print ('');
      var bar: integer;
      for bar := entryBar to BarCount-1 do
      begin
        Print( DateToStr( GetDate( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize )
                  + #9 + FormatFloat( '#,###.#0', PriceClose( bar ) * positionSize - entryTotal ) );
      end;
      break;
    end;
  end;
  FileClose (file);
end;
//______________________________________________________________________________
// Print Closed Positions
//
procedure PrintClosedPosition ();
begin
  var file: integer;
  var FileName: String;
  if( myclass.getBoolParam( 'hlTrades' ) ) then
    FileName := myclass.GetRootDir() + '\WLAdapter\params\hlTrades'
  else exit;
  //else if( isTrainingMode ) then
  //  FileName := rootDir + '\docs\Training-07\Rec_PositionsClosed.csv'
  //else
  //  FileName := rootDir + '\Manage\PositionsClosed.csv';

  file := FileOpen (FileName);

  while not FileEOF (file) do begin
    var line, symbolStr: String;

    line := FileRead (file);
    //#TradeNumber,EntryDate,PosType,Symbol,Shares,EntryPrice,EntryTotal,
    //ChannelWidthPercentage,ExitDate,ExitPrice,ExitTotal,SplitInfo,ClosePrices
    symbolStr := GetToken (line, 3, ',');
    if ( (GetSymbol = symbolStr)
     or ((GetSymbol = 'SP-500') and (myclass.getBoolParam( 'hlTrades' )) ) ) then
    begin
      var entryDateStr, entryPriceStr, exitDateStr, exitPriceStr, tradeType, splitInfoStr: string;
      entryDateStr   := GetToken( line, 1, ',' );
      tradeType     := GetToken( line, 2, ',' );
      entryPriceStr := GetToken( line, 5, ',' );
      exitDateStr    := GetToken( line, 8, ',' );
      exitPriceStr  := GetToken( line, 9, ',' );
      splitInfoStr  := GetToken( line, 11, ',' );

      var entryBar, exitBar, entryDate, exitDate: integer;
      var entryPrice, exitPrice: float;

      try
        entryDate := StrToInt( entryDateStr );
      except
        entryDate := StrToDate( entryDateStr );
      end;
      entryBar := DateToBar( entryDate );
      if( IsWeekly ) then
        entryBar := myclass.WeeklyBarFromDailyIntDate( entryDate );
      if( entryBar = -1 ) then // entryBar is in future i.e. you are studying history
        continue;
      entryPrice := StrToFloat( entryPriceStr );

      if( exitDateStr = '' ) then begin // Position not yet closed
        exitBar := 0;
        exitPrice := PriceClose( 0 );
      end else
      begin // For closed positions
        try
          exitDate := StrToInt( exitDateStr );
        except
          exitDate := StrToDate( exitDateStr );
        end;
        exitBar := DateToBar( exitDate );
        if( IsWeekly ) then
          exitBar := myclass.WeeklyBarFromDailyIntDate( exitDate );
        if( exitBar = -1 ) then   // Closed Position in future
          exitBar := 0;
        exitPrice := StrToFloat( exitPriceStr );
      end;

      if( splitInfoStr <> '1' ) then
      begin
        var split: float = StrToFloat( splitInfoStr );
        entryPrice := entryPrice / split;
        exitPrice  := exitPrice / split;
      end;

      var annotateColor: integer = 009;

      if( entryBar = exitBar ) then
      begin
        SetBackgroundColor (entryBar, 886);
      end
      else
      begin
        if( (tradeType = 'L') or (tradeType = 'B') ) then begin
          SetBackgroundColor (entryBar, 988);
          SetBackgroundColor( exitBar, 798 );
        end
        else
        begin
          SetBackgroundColor (entryBar, 798);
          SetBackgroundColor( exitBar, 988 );
        end;
      end;
      // Annotate Bars
      if( (tradeType = 'L') or (tradeType = 'B') ) then
      begin
        AnnotateBar( 'B', entryBar, false, annotateColor, 7 );
        AnnotateBar( 'S', exitBar, true, annotateColor, 7 );
      end
      else
      begin
        AnnotateBar( 'T', entryBar, true, annotateColor, 7 );
        AnnotateBar( 'C', exitBar, false, annotateColor, 7 );
      end;

      DrawLine( entryBar-1, entryPrice, entryBar+1, entryPrice, 0, #Blue, #thin );
      DrawLine( exitBar-1, exitPrice, exitBar+1, exitPrice, 0, #Blue, #thin );
    end;
  end;
  FileClose (file);
end;

//______________________________________________________________________________
// Print Positions
//
procedure PrintPosition ();
begin
  //PrintOpenPosition();
  PrintClosedPosition();
end;
//______________________________________________________________________________
//PrintPosition;

