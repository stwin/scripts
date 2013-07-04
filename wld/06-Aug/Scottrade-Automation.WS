{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
// Main Program

var IE: ComVariant;

procedure setAlert( symbol: string; price: float );
begin
  var url: string;
  url := 'https://trading.scottrade.com/myaccount/ManageAlerts.aspx';
  IE.Navigate( url );
  while IE.ReadyState <> 4 do sleep( 2 );
  //x := IE.Document.documentElement.innerHTML;
  //Print( x );
end;

//______________________________________________________________________________
//______________________________________________________________________________


IE := CreateOleObject('InternetExplorer.Application');
IE.Visible := true;

setAlert( GetSymbol, PriceClose(Barcount-1)*0.99 );




