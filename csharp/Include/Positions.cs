
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
[/SCRIPT]*/

//______________________________________________________________________________
//             Positions   L I B R A R Y
//______________________________________________________________________________


using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;

using WealthLab;

namespace MyScript
{
    partial class MyClass
    {
		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void PostionsTest ( )
		{
			try
			{
				MessageBox.Show ( "Postions is working. CurrDir = " + Environment.CurrentDirectory, "Postions" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		// Print Closed Positions
		//--------------------------------------------------------------------------------------------
		public void PrintClosedPosition ( string Symbol, bool IsWeekly, ref int Bar1, ref int Color1,
			ref int Bar2, ref int Color2 )
		{
			// Set some good default values
			Bar1 = Bar2 = 1;
			Color1 = Color2 = 999;

			// Now let's start

			string TradesListStr = "";

			string HlTrades = GetStringParam ( "hlTrades" );
            if (HlTrades != null)
            {
                TradesListStr = HlTrades;
            }
            else
            {
                string FileName = null;
                if (GetBoolParam("TrainingMode"))
                {
                    FileName = RootDir + @"\docs\Training-07\Rec_PositionsClosed.csv";
                }
                else
                {
                    FileName = RootDir + @"\Manage\PositionsClosed.csv";
                }
                StreamReader sr = null;
                try
                {
                    sr = new StreamReader(File.Open(FileName,
                                FileMode.Open, FileAccess.Read, FileShare.ReadWrite));
                    TradesListStr = sr.ReadToEnd();
                    sr.Close();
                }
                catch (Exception e)
                {
                    MessageBox.Show("Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
                        + e.StackTrace, "Exception in MyScript.MyClass.PrintClosedPosition");
                }                
            }
            MessageBox.Show(TradesListStr);
			try
			{
				StringReader sr = new StringReader ( TradesListStr );
				string line = null;
				while ( ( line = sr.ReadLine ( ) ) != null )
				{
                    Print(line);
                    if (line.Trim() == "" || line.StartsWith("#"))
                    {
                        continue;
                    }
					//#TradeNumber,EntryDate,PosType,Symbol,Shares,EntryPrice,EntryTotal,
					//ChannelWidthPercentage,ExitDate,ExitPrice,ExitTotal,SplitInfo,ClosePrices
					string[] tokens = line.Split ( ",".ToCharArray ( ) );
					string readSymbol = tokens[3];

					//Print ( "Info: readSymbol={0} Symbol={1} HlTrades={2}", readSymbol, Symbol, HlTrades );
					if ( ( readSymbol == Symbol ) ||  ( ( Symbol == "SP-500" ) && ( HlTrades != null ) ) )
					{
						string entryDateStr, numShareStr, entryPriceStr, exitDateStr, 
									exitPriceStr, tradeType, splitInfoStr;
						entryDateStr = tokens[1];
						tradeType = tokens[2];
						numShareStr = tokens[4];
						entryPriceStr = tokens[5];
						exitDateStr = tokens[8];
						exitPriceStr = tokens[9];
						splitInfoStr = tokens[11];

						// First process entry date and entry price
						DateTime EntryDate = DateTime.Parse ( entryDateStr );
						//Print ( "EntryDate = {0}", EntryDate.ToLongDateString ( ) );
						int EntryBar = -1;
						if ( IsWeekly )
						{
							EntryBar = WeeklyBarFromDailyDate ( EntryDate );
						}
						else
						{
							EntryBar = DateToBar ( EntryDate );
						}
						if ( EntryBar == -1 ) // Entry Bar out of range of the current chart
						{
							continue;
						}
						double EntryPrice = Double.Parse ( entryPriceStr );

						// Now process exit date and exit price
						int ExitBar = -1;
						double ExitPrice = 0.0;
						if ( exitDateStr == "" ) // Position not yet closed
						{
							ExitBar = -1;
						}
						else  // For closed positions
						{
							DateTime ExitDate = DateTime.Parse ( exitDateStr );
							//Print ( "ExitDate = {0}", ExitDate.ToLongDateString ( ) );
							if ( IsWeekly )
							{
								ExitBar = WeeklyBarFromDailyDate ( ExitDate );
							}
							else
							{
								ExitBar = DateToBar ( ExitDate );
							}
							if ( ExitBar == -1 )  // Closed Position in future
							{
								ExitBar = -1;
							}
							ExitPrice = Double.Parse ( exitPriceStr );
						}

						// Now check if there was any split in the stock
						if ( splitInfoStr != "1" )
						{
							double split = Double.Parse ( splitInfoStr );
							EntryPrice = EntryPrice / split;
							ExitPrice = ExitPrice / split;
						}

						// Now execute Buy/Sell Short/Cover signals
						int NumShares = Math.Abs ( Int32.Parse ( numShareStr ) );
						if ( tradeType == "L" || tradeType == "B" )
						{
							if ( EntryBar > 0 )
							{
								EnterAtPrice ( EntryBar, PositionTypeEnum.posLong, NumShares, EntryPrice, "Long Position" );
							}
							if ( ExitBar > 0 )
							{
								ExitAtPrice ( WL.LastPosition(), ExitBar, ExitPrice, "Exit Long" );
							}
							Color1 = 988;
							Color2 = 798;
						}
						else
						{
							if ( EntryBar > 0 )
							{
								EnterAtPrice ( EntryBar, PositionTypeEnum.posShort, NumShares, EntryPrice, "Short Position" );
							}
							if ( ExitBar > 0 )
							{
								ExitAtPrice ( WL.LastPosition ( ), ExitBar, ExitPrice, "Exit Short" );
							}
							Color1 = 798;
							Color2 = 988;
						}
						//Print ( "EntryBar = {0}, EntryPrice = {1}, ExitBar = {2}, ExitPrice = {3}", 
						//	EntryBar, EntryPrice, ExitBar, ExitPrice );

						// If its the same bar, use a different color
						if ( EntryBar == ExitBar )
						{
							Color1 = Color2 = 886;
						}

						Bar1 = Math.Max ( 1, EntryBar );
						Bar2 = Math.Max ( 1, ExitBar );
					}
				}
				sr.Close ( );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.PrintClosedPosition" );
			}
		}

		//____________________________________________________________________________________________
		// Enter at a specific price
		//--------------------------------------------------------------------------------------------
		public bool EnterAtPrice ( int Bar, PositionTypeEnum PosType, int NumShares, double Price, string Signal )
		{

			// There is a bug in WealthLab and orderLimit and orderStop of OrderTypeEnum should be 
			// reversed. This bug was fixed in Version 3 Build 20, so when you upgrade WealthLab,
			// chnage the following code. // TODO UPGRADE
			if ( PosType == PositionTypeEnum.posLong )
			{
				if ( BarOpen[Bar] >= Price )
				{
					WL.OpenPosition ( Bar, PosType, NumShares, Price, OrderTypeEnum.orderStop, Signal );
				}
				else
				{
					WL.OpenPosition ( Bar, PosType, NumShares, Price, OrderTypeEnum.orderLimit, Signal );
				}
			}
			else
			{
				if ( BarOpen[Bar] <= Price )
				{
					WL.OpenPosition ( Bar, PosType, NumShares, Price, OrderTypeEnum.orderStop, Signal );
				}
				else
				{
					WL.OpenPosition ( Bar, PosType, NumShares, Price, OrderTypeEnum.orderLimit, Signal );
				}
			}
			return true;
		}
		//____________________________________________________________________________________________
		// Exit at a specific price
		//--------------------------------------------------------------------------------------------
		public bool ExitAtPrice ( int Position, int Bar, double Price, string Signal )
		{
			// There is a bug in WealthLab and orderLimit and orderStop of OrderTypeEnum should be 
			// reversed. This bug was fixed in Version 3 Build 20, so when you upgrade WealthLab,
			// chnage the following code. // TODO UPGRADE
			if ( WL.PositionLong ( Position ) )
			{
				if ( BarOpen[Bar] <= Price )
				{
					WL.ClosePosition ( Position, Bar, Price, OrderTypeEnum.orderStop, Signal );
				}
				else
				{
					WL.ClosePosition ( Position, Bar, Price, OrderTypeEnum.orderLimit, Signal );
				}
			}
			else
			{
				if ( BarOpen[Bar] >= Price )
				{
					WL.ClosePosition ( Position, Bar, Price, OrderTypeEnum.orderStop, Signal );
				}
				else
				{
					WL.ClosePosition ( Position, Bar, Price, OrderTypeEnum.orderLimit, Signal );
				}
			}
			return true;
		}

/*

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
	if( tradeType = 'L' ) then begin
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
*/
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

