{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
function GetNextEarningsDate(Symbol: string): string;
begin
  var IE: COMVariant = CreateOleObject('InternetExplorer.Application');
  var url: string = 'http://biz.yahoo.com/research/earncal/' + Symbol[1] + '/' + Symbol + '.html';
  Print( url );
  IE.Navigate( url );
  while (IE.ReadyState <> 4) do Sleep(1);
  Result := IE.Document.DocumentElement.InnerText;
  IE.Quit();

  if Copy(Result, 1, 12) = 'No Such Data' then
  begin
    Result := 'N/A';
    exit;
  end;

  var p: integer = Pos('US Earnings Calendar for ', Result);
  Result := Copy(Result, p + 25, 25);
  p := Pos(#13, Result);
  Result := Copy(Result, 1, p - 1);
end;

DrawLabel('Next Earnings Date: ' + GetNextEarningsDate(GetSymbol), 0);

