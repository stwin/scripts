{$NO_AUTO_EXECUTE}

var x,url: string;
var IE: ComVariant;
url :='https://trading.scottrade.com/quotesresearch/DetailedQuoteSummary.aspx?SYMBOL=' + GetSymbol;
IE := CreateOleObject('InternetExplorer.Application');
IE.Visible := true;
IE.Navigate(url);
while IE.ReadyState <> 4 do sleep( 2 );

x := IE.Document.documentElement.innerHTML;
Print( x );



