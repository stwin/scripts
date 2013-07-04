{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
//Fundamental Viewer

const s ='Symbol,Name,Ask,Average Daily Volume,Bid,Ask(Real Time),Bid(Real Time),'
       + 'Book Value,Change,Change(Real Time),After Hours Change( Real Time),'
       + 'Dividend/Share,Last Trade Date,Trade Date,Earnings/Share,Error Indication,'
       + 'EPS Estimate Current Year,EPS Estimate Next Year,EPS Estimate Next Quarter,'
       + 'Days Low,Days High,52-week Low,52-week High,'
       + 'Holdings Gain Percent,Annualized Gain,Holdings Gain,Holdings Gain Percent (RT),'
       + 'More Info,Order Book (Real-time),Market Capitalization,Market Cap (Real-time),'
       + 'EBITDA,Change From 52-week Low,Percent Change From 52-week Low,'
       + 'Last Trade Size,Change From 52-week High,Percent Change From 52-week High,'
       + 'Last Trade (With Time),Last Trade (Price Only),High Limit,Low Limit,'
       + 'Days Range,Days Range (Real-time),50-day Moving Average,200-day Moving Average,'
       + 'Change From 200-day Moving Average,Percent Change From 200-day Moving Average,'
       + 'Change From 50-day Moving Average,Percent Change From 50-day Moving Average,'
       + 'Open,Previous Close,Change in Percent,Price/Sales,Price/Book,Ex-Dividend Date,'
       + 'P/E Ratio,Dividend Pay Date,P/E Ratio (Real-time),PEG Ratio,'
       + 'Price/EPS Estimate Current Year, Price/EPS Estimate Next Year,'
       + 'Short Ratio,Last Trade Time,Ticker Trend,1 yr Target Price,Volume,'
       + 'Holdings Value,Holdings Value (Real-time),52-week Range,Days Value Change,'
       + 'Days Value Change (Real-time),Stock Exchange,Dividend Yield';


// Yahoo matching field parameter
const tt = 'snaa2bb2b3b4c1c6c8dd1d2ee1e7e8e9ghjkg1g3g4g5'
          +'ii5j1j3j4j5j6k3k4k5ll1l2l3mm2m3m4m5m6m7m8'
          +'opp2p5p6qrr1r2r5r6r7s7t1t7t8vv1v7ww1w4xy';

var IE, TextElements: ComVariant;
var x,url: string;

url :='http://finance.yahoo.com/d/quotes.csv?s='+GetSymbol+'&f='+tt;
IE := CreateOleObject('InternetExplorer.Application');
IE.Visible := false;
IE.Navigate(url);
while IE.ReadyState <> 4 do sleep( 2 );
TextElements := IE.Document.all;
x := TextElements.Item(0).InnerText;

function fund( item: integer): string;
begin
  Result := GetToken( x, item, ',' );
end;

const _ = '<';
var j: integer;

var t: string = _+'table cellpadding="2" cellspacing="0" align="center" border="1">'
+_+'tr>'+_+'th>Parameter'+_+'/th>'+_+'th>Value'+_+'/th>'+_+'/tr>';
while gettoken(s,j,',') <> '' do
begin
  try
    t := t + +_+'tr>'+_+'td>'+gettoken(s,j,',')+_+'/td>'+_+'td>'+fund( j )+_+'/td>'+_+'/tr>';
  except;
  end;
  inc( j );
end;
t := t +_+'/table>'+_+'br>';
t := t +_+'form>'+_+'table align="center" border="0">'+_+'th colspan=2>'
+_+'input type="button" value="Print" onclick="javascript:window.print()">'
+_+'/th>'+_+'/table>'+_+'/form>';
AddCommentary( t );
