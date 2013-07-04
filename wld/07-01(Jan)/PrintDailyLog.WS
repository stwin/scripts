{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( true );
//{$I 'mycommon'}

//______________________________________________________________________________
// Print Closed Positions
//
procedure PrintClosedPositions ();
begin
  var file: integer;
  var str, str2: string;

  var FileName: String = 'D:\WL\Manage\PositionsClosed.csv';
  file := FileOpen (FileName);

  Print( 'Closed Positions' );

  str := 'Symbol'
            + #9 + 'Type'
            + #9 + 'Size'
            + #9 + 'EntPr'
            + #9 + 'EntTot'
            + #9 + 'CurrPr'
            + #9 + 'CurrTot'
            + #9 + 'PL'
            + #9 + 'PL%'
            + #9 + 'Change'
            + #9 + 'Ch%'
            + #13 + #10;

  while not FileEOF (file) do
  begin
    var line, symbolStr, exitDateStr: String;

    line := FileRead (file);
    symbolStr := GetToken (line, 0, ',');
    exitDateStr    := GetToken( line, 3, ',' );
    if ( IntToStr(GetDate(BarCount-1)) = exitDateStr) then
    begin
      var positionSize, entryDate: integer;
      var entryPrice, entryTotal, exitPrice, exitTotal: float;
      var prevPrice, prevTotal: float;
      var tradeType: string;

      entryDate := StrToInt( GetToken( line, 1, ',' ) );
      entryPrice := StrToFloat( GetToken( line, 2, ',' ) );
      // exitDate := ...
      exitPrice := StrToFloat( GetToken( line, 4, ',' ) );
      tradeType := GetToken( line, 5, ',' );
      // splitInfo := ...
      positionSize := StrToInt( GetToken( line, 7, ',' ) );
      entryTotal := StrToFloat( GetToken( line, 8, ',' ) );
      exitTotal := StrToFloat( GetToken( line, 9, ',' ) );

      EnableSynch( true );
      var symClose: integer = GetExternalSeries( symbolStr, #Close );
      if( entryDate = GetDate( BarCount-1 ) ) then
      begin
        prevPrice := entryPrice;
        prevTotal := entryTotal;
      end
      else
      begin
        prevPrice := @symClose[BarCount-2];
        prevTotal := positionSize * prevPrice;
      end;

      var change, changePer, profit, profitPer: float;
      change := exitTotal - prevTotal;
      changePer := 100 * change / prevTotal;
      profit := exitTotal - entryTotal;
      profitPer := 100 * profit / entryTotal;

      str := str + symbolStr
            + #9 + tradeType
            + #9 + IntToStr( positionSize )
            + #9 + FormatFloat( '#.#0', entryPrice )
            + #9 + FormatFloat( '#,###.#0', entryTotal )
            + #9 + FormatFloat( '#.#0', exitPrice )
            + #9 + FormatFloat( '#,###.#0', exitTotal )
            + #9 + FormatFloat( '#,###.#0', profit )
            + #9 + FormatFloat( '#0', profitPer )
            + #9 + FormatFloat( '#.#0', change )
            + #9 + FormatFloat( '#0', changePer )
            + #13 + #10;
    end;
  end;
  Print( str );
  FileClose (file);
end;
//______________________________________________________________________________
// Print Open Positions
//
procedure PrintOpenPositions ();
begin
  var file: integer;
  var str, str2: string;

  var FileName: String = 'D:\WL\Manage\Positions.csv';

  file := FileOpen (FileName);

  Print( 'Current Positions' );

  str := 'Symbol'
            + #9 + 'Type'
            + #9 + 'Size'
            + #9 + 'EntPr'
            + #9 + 'EntTot'
            + #9 + 'CurrPr'
            + #9 + 'CurrTot'
            + #9 + 'PL'
            + #9 + 'PL%'
            + #9 + 'Change'
            + #9 + 'Ch%'
            + #9 + 'SL'
            + #9 + 'TR'
            + #13 + #10;
  str2 := 'Symbol'
            + #9 + 'PrevPr'
            + #9 + 'PrevTot'
            + #9 + 'Change'
            + #9 + 'Ch%'
            + #9 + 'Risk'
            + #13 + #10;


  while not FileEOF (file) do
  begin
    var line, symbolStr: String;

    line := FileRead (file);
    if( Copy( line, 0, 1 ) = '#' ) then
      continue;

    symbolStr := GetToken (line, 0, ',');

    var positionSize, entryDate, entryBar: integer;
    var entryPrice, entryTotal, targetPrice, stopPrice: float;
    var prevPrice, prevTotal, currentPrice, currentTotal: float;
    var tradeType: string;
    tradeType := GetToken( line, 1, ',' );
    positionSize := StrToInt( GetToken( line, 2, ',' ) );
    entryDate := StrToInt( GetToken( line, 3, ',' ) );
    entryPrice := StrToFloat( GetToken( line, 4, ',' ) );
    entryTotal := StrToFloat( GetToken( line, 5, ',' ) );
    stopPrice := StrToFloat( GetToken( line, 6, ',' ) );
    targetPrice := StrToFloat( GetToken( line, 7, ',' ) );

    EnableSynch( true );
    var symClose: integer = GetExternalSeries( symbolStr, #Close );
    currentPrice := @symClose[BarCount-1];
    currentTotal := positionSize * currentPrice;
    if( entryDate = GetDate( BarCount-1 ) ) then
    begin
      prevPrice := entryPrice;
      prevTotal := entryTotal;
      tradeType := tradeType + '-New';
    end
    else
    begin
      prevPrice := @symClose[BarCount-2];
      prevTotal := positionSize * prevPrice;
    end;

    var change, changePer, profit, profitPer, risk: float;
    change := currentTotal - prevTotal;
    changePer := 100 * change / prevTotal;
    profit := currentTotal - entryTotal;
    profitPer := 100 * profit / entryTotal;
    risk :=  currentTotal - positionSize * stopPrice;

    str := str + symbolStr
            + #9 + tradeType
            + #9 + IntToStr( positionSize )
            + #9 + FormatFloat( '#.#0', entryPrice )
            + #9 + FormatFloat( '#,###.#0', entryTotal )
            + #9 + FormatFloat( '#.#0', currentPrice )
            + #9 + FormatFloat( '#,###.#0', currentTotal )
            + #9 + FormatFloat( '#,###.#0', profit )
            + #9 + FormatFloat( '#0', profitPer )
            + #9 + FormatFloat( '#,###.#0', change )
            + #9 + FormatFloat( '#0', changePer )
            + #9 + FormatFloat( '#.#0', stopPrice )
            + #9 + FormatFloat( '#.#0', targetPrice )
            + #13 + #10;

    str2 := str2 + symbolStr
            + #9 + FormatFloat( '#.#0', prevPrice )
            + #9 + FormatFloat( '#,###.#0', prevTotal )
            + #9 + FormatFloat( '#,###.#0', change )
            + #9 + FormatFloat( '#0', changePer )
            + #9 + FormatFloat( '#,###.#0', risk )
            + #13 + #10;

  end;
  Print( str );
  Print( str2 );

  FileClose (file);

end;


//___________________ ___________________________________________________________
//______________________________________________________________________________
// Main Program

PrintClosedPositions();
PrintOpenPositions();

