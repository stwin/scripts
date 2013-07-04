(*Description...
http://www.wealth-lab.com/cgi-bin/WealthLab.DLL/topic?id=20297&start=0

<h1>Postings: SimTradeFile script problem</h1>
<h2>Forum: ChartScripts</h2>

works with multiple positons
<hr>

<b>Description</b>

<br>This script is a working example of how you can import  an ASCII trade file for analysis in Wealth-Lab Developer.   It references the EnterAtPrice and ExitAtPrice functions found in Wealth-Lab's Code Library.
<br>
<br><b>Notes: </b>
<br>1. Only the trades that are within the chart's dates will be loaded.  Also, the trades must correspond to actual prices achieved.
<br>
<br>2.  The script supports only trades that obtain one position per symbol.  That is, they must occur in Buy then Sell, or Short  then Cover pairs.
<br>
<br>3.  You must run in Raw Profit mode for the Share size to take effect.  Otherwise, the Position Sizing control will control the number of shares for a position.  If desired, the number of shares should be placed in the last field for entry signals.
<br>
<br><hr><b>File Format:
<br>
<br><tt>SYMBOL,TradeDate,Type,ExecutionPrice,SignalName,[Shares]</tt></b>
<tt><br></tt><hr><tt>The data file is required to be chronological by symbol.  
<br>e.g.,
<br>AA,20031202,Buy,34.00,MySignal1,150

<br>AA,20031203,Sell,34.50,MySignal2
<br>AA,20031209,Short,35.50,MySignal3,300
<br>AA,20031211,Cover,34.0,MySignal4
<br>
<br>AEP,20031125,Buy,27.50,MySignal1,200
<br>AEP,20031128,Sell,27.80,MySignal2
<br>AEP,20031205,Short,28.40,MySignal3,1000
<br>AEP,20031211,Cover,28.20,MySignal4
<br>
<br></tt><hr><tt>Though not chronological, the following will also work because the trades are chronological by symbol.
<br>
<br>AEP,20031125,Buy,27.50,MySignal1,200
<br>AA,20031202,Buy,34.00,MySignal1,150
<br>AA,20031203,Sell,34.50,MySignal2
<br>AEP,20031128,Sell,27.80,MySignal2
<br>AA,20031209,Short,35.50,MySignal3,300
<br>AA,20031211,Cover,34.0,MySignal4

<br>AEP,20031205,Short,28.40,MySignal3,1000
<br>AEP,20031211,Cover,28.20,MySignal4
<br></tt>

*)
{$NO_AUTO_EXECUTE}
{$I 'EnterAtPrice'}
{$I 'ExitAtPrice'}
var Bar, TradeDate, hFile, p, Shares: integer;
var xPrice: float;
var Symbol, pType, MyFile, StrInput, SigName: string;
const Delim = ',';

{ Open your trades file }
MyFile := Input('Enter full file path' );
// MyFile := 'C:\TradesFile.txt';
if MyFile = '' then
  exit;

hFile := FileOpen( MyFile );

{ Load the trades for the Symbol }
while not FileEOF( hFile ) do
begin
  StrInput := FileRead( hFile );
  if StrInput = '' then // skip blank lines
    continue;

{ parse the string, assumes file format in Description view }
  Symbol := Trim( GetToken(StrInput, 0, Delim) );
  TradeDate := StrToInt( Trim( GetToken(StrInput, 1, Delim) ) );
  pType := UpperCase( Trim( GetToken(StrInput, 2, Delim) ) );
  xPrice := StrToFloat( Trim( GetToken(StrInput, 3, Delim) ) );
  SigName := Trim( GetToken(StrInput, 4, Delim) );
  Shares := 0;
  try
    Shares := StrToInt( GetToken(StrInput, 5, Delim) );
  except
  end;

  SetPrimarySeries( Symbol );
  Bar := DateToBar( TradeDate );

  if Bar = -1 then // Date not found in chart
    continue;

  case pType of
    'BUY':
      begin
        if Shares > 0 then
          SetShareSize( Shares );
        if not EnterAtPrice( Bar, xPrice, 'Long', SigName ) then
          Print('Buy failed on bar ' + IntToStr( Bar ) );
      end;

    'SHORT':
      begin
        if Shares > 0 then
          SetShareSize( Shares );
        if not EnterAtPrice( Bar, xPrice, 'Short', SigName ) then
          Print('Short failed on bar ' + IntToStr( Bar ) );
      end;

    'SELL', 'COVER':
      begin
        for p := 0 to PositionCount - 1 do
        begin
          if PositionActive( p ) and ( PositionSymbol( p ) = Symbol ) then
          begin
            if PositionLong( p ) then
            begin
              if not ExitAtPrice( Bar, p, xPrice, SigName ) then
                Print('Sell failed on bar ' + IntToStr( Bar ) );
            end
            else
              if not ExitAtPrice( Bar, p, xPrice, SigName ) then
                Print('Cover failed on bar ' + IntToStr( Bar ) );

            break;
          end;
        end;
      end;
  end; // end case
  PrintFlush; // Deleting this may result in faster loading for large files
end;
