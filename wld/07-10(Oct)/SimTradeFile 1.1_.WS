(*Description...
SimTradeFile 1.1 
03/08/2003 

+Added missing symbol check 
+Shortened entry and exit error text to one line per error. 

******************************************************************************* 
SimTradeFile 1.0 
02/19/2003 

SimTradeFile is not a trading system. It is an analysis tool that's intended to help you visualize and analyze a series of real trades. SimTradeFile will only work on the retail version of WLD - not on the website. The reason for this is that it needs to be able to read a file containing trade executions. 

The way this chartscripts works is very simple. It reads a file that contains trade executions (one trade per line) and then forces the simulator to take the same trades. 

Once you run the script, you will have access to all of the familiar analysis tools. For example you can get a listing of the trades, look at the profit distribution, view the equity and drawdown curves, view and print a performance summary table, and examine returns by period. 

You will need a data file that contains your trade executions in the following format: 

Ptype,symb,shares,buyDate,buyPrice,sellDate,sellPrice 
Long,MCHP,300,9/16/2002,16.61,9/17/2002,17.75 
Long,LLTC,200,9/17/2002,20.39,9/18/2002,20.6 
Long,QLGC,150,9/18/2002,29.26,9/19/2002,29.84 
Short,QQQ,200,9/19/2002,21.71,9/12/2002,23.17 

The first line of the file is assumed to be a heading and is ignored. 

To get SimTradeFile to recognize your trade file - edit the initializations section of the chartscript to specify the filename. 

Except for the addition of the Ptype field (to specify Long or Short), the format is essentially the same as what you would see on schedule D of a US tax return. So the easiest way to create this file is to download it from your broker or create it from an acounting or tax program like quicken or turbo tax. If you don't have daytrades and want to make this part a little easier, you could modify the script to figure out Ptype, based on the order of the buy and sell dates. 

It's important that the trade data file (and symbol price data) is error free, or else the simulator may not take all of the trades. SimTradeFile has some basic error checking built in that will help you to find and fix errors. Entry and exit errors will be output to the debug window. 

For example if you have a trade that tries to enter above the high or below the low of bar, an entry error will be generated and the simulator will not take the trade. An exit error would occur if you tried to exit below the low or above the high. In this case, the simulator won't exit so you'll end up with an open position. To close the position, you will first need to fix the error in the trade file or correct the bad data in the datasource data file. 

Another caveat is that price history data for the symbols listed in your trade file must exist in a datasource somewhere. Otherwise, the simulator will ignore trades for symbols that it can't find. 

The datasource or watchlist that you point to when you run a simulation does not need to contain the symbols in your trade file. To shorten the time for the simulation - just point to a short watchlist. 

To prevent the simulator from changing the position size and/or entry and exit price, you will also need to choose the "ChartScript Value" on the position size tab and turn off slippage from the tools..options menu. 

You can also run the chartscript by opening it and pointing to a symbol. No matter which symbol you point to you will get the same list of trades that is specified in the trade file. 

*)
{
Chartscript Name: SimTradeFile 1.1
Author: Steve Jost
Date: 03/08/2003

Purpose: To read a file containing real trade data and
 then force the simulator to take the same trades.

The file should have the following format:

ptype,symb,shares,buyDate,buyPrice,sellDate,sellPrice
Long,MCHP,300,9/16/2002,16.61,9/17/2002,17.75
Long,LLTC,200,9/17/2002,20.39,9/18/2002,20.6
Long,QLGC,150,9/18/2002,29.26,9/19/2002,29.84
Short,QQQ,200,9/19/2002,21.71,9/12/2002,23.17

The first line of the file is ignored.

Make sure that the ChartScriptValue setting is checked on the
simulator position size tab and slippage is turned off from
the tools..options menu.

Check the debug window after executing the script for errors.
If you find entry or exit errors, either fix the data for that
symbol and bar or else correct the trade execution data such
such that the entry and exit price fall between the high and
low of the bar.

=========================Modifications==========================================
SimTrade 1.1, 3/08/03
  +Added error check for missing symbols. Errors print to debug window.
  +Entry and exit error messages shortened to one line per error.

SimTrade 1.0, 2/19/03
  +Original script

}

//========================= Functions ==========================================
// Glitch wrote ExitAtPrice function
function ExitAtPrice( Bar, p: integer; price: float;
  SignalName: string ): boolean;
begin
  if Bar >= BarCount then
    Result := SellAtLimit( Bar, price, p, SignalName )
  else if ( price > PriceHigh( Bar ) ) or ( price < PriceLow( Bar ) ) then
    Result := false
  else
  begin
    Result := true;
    if PositionLong( p ) then
    begin
      if PriceOpen( Bar ) <= price then
        SellAtLimit( Bar, price, p, SignalName )
      else
        SellAtStop( Bar, price, p, SignalName );
    end
    else
    begin
      if PriceOpen( Bar ) >= price then
        CoverAtLimit( Bar, price, p, SignalName )
      else
        CoverAtStop( Bar, price, p, SignalName );
    end;
  end;
end;

function EnterAtPrice( Bar: integer; price: float;
 Ptype, signalName: string ): boolean;
begin
  if Bar >= BarCount then
    Result := false
  else if ( price > PriceHigh( Bar ) ) or
   ( price < PriceLow( Bar ) ) then
    Result := false
  else
  begin
    Result := true;
    if Ptype = 'Long' then
    begin
      if PriceOpen( Bar ) >= price then
        BuyAtLimit( Bar, price, SignalName )
      else
        BuyAtStop( Bar, price, SignalName );
    end
    else
    begin
      if PriceOpen( Bar ) <= price then
        ShortAtLimit( Bar, price, SignalName )
      else
        ShortAtStop( Bar, price, SignalName );
    end;
  end;
end;

//========================= Variables ==========================================
VAR FIn: integer; // file handle
VAR Ptype, symb, f, s, stoken, entryDate, exitDate: string;
VAR entryPrice, exitPrice: float;
VAR shares, entryBar, exitBar: integer;

//========================= Initializations ====================================
f := 'C:\temp\test.csv';    // put your trade file name here
FIn := FileOpen( f );

//========================= Main Loop ==============================
s := FileRead( FIn );   // skip header row

while not FileEOF( FIn ) do
begin
  s := FileRead( FIn );
  try
    sToken := GetToken( s, 0, ',' );
    Ptype := sToken;
    sToken := GetToken( s, 1, ',' );
    Symb := sToken;
    sToken := GetToken( s, 2, ',' );
    Shares := Round(StrToFloat( sToken ));
    sToken := GetToken( s, 3, ',' );
    If Ptype = 'Long' then
     begin
       entryDate := sToken;
       entryBar := DateToBar( StrToDate( sToken ) );
     end
    else
     begin
       exitDate := sToken;
       exitBar :=  DateToBar( StrToDate( sToken ) );
     end;
    sToken := GetToken( s, 4, ',' );
    If Ptype = 'Long' then
       entryPrice := Int(round(100*StrToFloat( sToken )))/100
    else
       exitPrice :=  Int(round(100*StrToFloat( sToken )))/100;
    sToken := GetToken( s, 5, ',' );
    If Ptype = 'Long' then
     begin
       exitDate := sToken;
       exitBar := DateToBar( StrToDate( sToken ) );
     end
    else
     begin
       entryDate := sToken;
       entryBar :=  DateToBar( StrToDate( sToken ) );
     end;
    sToken := GetToken( s, 6, ',' );
    If Ptype = 'Long' then
       exitPrice := Int(round(100*StrToFloat( sToken )))/100
    else
       entryPrice :=  Int(round(100*StrToFloat( sToken )))/100;
    try
    setPrimarySeries( symb );
    except
    Print('symbol not found: ' + symb);
    continue;  // back to the beginning to read next trade
    end; //except
    SetShareSize( shares );
    if not enterAtPrice( entryBar, entryPrice, Ptype, '' ) then
      begin
        Print('entry error: ' + ptype + '  ' + symb +
         '  ' + IntToStr(Shares) + '  ' + EntryDate +
         '  ' + FloatToStr(EntryPrice));
      end;
    if not exitAtPrice( ExitBar, lastPosition, exitPrice, '') then
      begin
        Print('exit error: ' + ptype + '  ' + symb +
         '  ' + IntToStr(Shares) + '  ' + ExitDate +
         '  ' + FloatToStr(ExitPrice));
      end;
     restorePrimarySeries;
  except
  end; // except
end; // while NOT EOF
