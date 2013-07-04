/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#PrimaryClass Yahoo.RealData
[/SCRIPT]*/

using System;
using System.Text;
using System.Net;
using System.IO;
using System.Windows.Forms;
using System.Runtime.InteropServices;

using WealthLab;
using WLE;

namespace Yahoo
{
	//_________________________________________________________________________________________
	//-----------------------------------------------------------------------------------------
	public class RealData : IWealthLabRT3
	{
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		class BarData
		{
			public DateTime date;
			public double open;
			public double high;
			public double low;
			public double close;
			public int volume;

			public BarData ( )
			{
				open = high = low = close = 1.0;
				volume = 100;
				date = DateTime.Today;
			}
		};

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		static int requestNumber = 0;
		IWealthLabConnection3 connection3 = null;

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public RealData ( )
		{
			//MessageBox.Show ("Yahoo realData called" );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void TestTest ( )
		{
			MessageBox.Show ( "Yahoo Real Data is working" );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public string GetSecurityName ( string Symbol )
		{
			// Implement this method to return a security name for the specified 
			// Symbol.  If you don't have access to a security name, return a blank 
			// string.  This method is called after OpenRequest

			string SecurityName = readLink ( @"http://finance.yahoo.com/d/quotes.csv?s=" + Symbol + "&f=n" );
			if ( SecurityName.Length > 4 )
			{
				SecurityName = SecurityName.Substring ( 1, SecurityName.Length - 4 );
			}
			return SecurityName;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void CloseRequest ( )
		{
			// Implement this method to perform any necessary cleanup after a real-time
			// chart window is closed.  Note: CloseRequest is called prior to the 
			// first OpenRequest call.
		}

		//_________________________________________________________________________________________
		// The OpenRequest method is called when a new Symbol is selected for 
		// processing.  The Symbol parameter contains the Symbol being requested. 
		// The NumBars parameter contains the number of bars being requested.  You 
		// should not add more bars than requested.   The RequestType parameter 
		// contains the type of chart being requested (see below)   The BarInterval 
		// parameter contains the number of minutes, seconds or ticks per bar being 
		// requested (for those request types).  FilterMarketHours will contain true 
		// if the data should be filtered based on the supplied MarketOpen and 
		// MarketClose values.  Bars contains an instance of the IWealthLabBars3 
		// interface, save this to a local variable.  UpdateSink contains an instance 
		// of the IWealthLabRTUpdate3 interface, save this to a local variable.  You 
		// should populate the Bars interface with as many historical bars as available
		// (up to the NumBars limit), and then call IWealthLabRTUpdate3.Update when completed

		//-----------------------------------------------------------------------------------------
		public void OpenRequest ( string symbol, int numBars, BarIntervalEnum requestType,
					int barInterval, bool filterMarketHours, DateTime marketOpen,
					DateTime marketClose, IWealthLabBars3 bars3, IWealthLabRTUpdate3 rtUpdate3 )
		{
			//MessageBox.Show ( "Here " + requestNumber );
			requestNumber++;
			int barsDownloaded = 0;

			if ( BarIntervalEnum.biDaily == requestType 
				|| BarIntervalEnum.biWeekly == requestType
				|| BarIntervalEnum.biMonthly == requestType )  // daily, weekly, monthly
			{ 

				char requestTypeChar = 'd';
				switch ( requestType )
				{
					case BarIntervalEnum.biDaily: requestTypeChar = 'd'; break;
					case BarIntervalEnum.biWeekly: requestTypeChar = 'w'; break;
					case BarIntervalEnum.biMonthly: requestTypeChar = 'm'; break;
				}

				DateTime now = DateTime.Today;

				//"http://itable.finance.yahoo.com/table.csv?a=9&b=28&c=2005&d=5&e=28&f=2006&s=MSFT&y=0&g=d&ignore=.csv";


				string url = @"http://itable.finance.yahoo.com/table.csv?"
					+ "a=" + ( now.Month - 1 )
					+ "&b=" + now.Day
					+ "&c=" + ( now.Year - 3 )
					+ "&d=" + ( now.Month - 1 )
					+ "&e=" + now.Day
					+ "&f=" + now.Year
					+ "&s=" + symbol
					+ "&y=0&g=" + requestTypeChar + "&ignore=.csv";

				if ( connection3 != null )
				{
					connection3.Warning ( 0, "Downloading request (" + requestNumber + ")..." );
				}
				string data = readLink ( url );
				//CSharp.Print ( url );


				DateTime lastRetrievedDay = DateTime.Now;

				if ( data != null )
				{
					StringReader sr = new StringReader ( data );
					string firstLine = sr.ReadLine ( ); // Do nothing
					while ( true )
					{
						string nextLine = sr.ReadLine ( );
						if ( nextLine == "" )
						{
							break;
						}
						BarData barData = convertStrToBarRecord ( nextLine );
						barsDownloaded++;
						if ( bars3 != null )
						{
							bars3.Add ( barData.date, barData.open, barData.high, barData.low,
									barData.close, barData.volume );
						}
						else
						{
							Console.WriteLine ( String.Format ( "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n",
										   barData.date, barData.open, barData.high, barData.low,
										   barData.close, barData.volume ) );
						}
						lastRetrievedDay = barData.date;
						if ( sr.Peek ( ) < 0 )
						{
							break;
						}
					}
				}

				// If the latest bar was not retrieved from the historical data, retrieve it from quote
				// This happens before 9:00pm, because Yahoo updates historical data around 9:00pm.
				if ( lastRetrievedDay.Day == now.Day
					&& lastRetrievedDay.Month == now.Month
					&& lastRetrievedDay.Year == now.Year )
				{
					;
				}
				else if ( BarIntervalEnum.biDaily == requestType ) // Only for daily, later think about weekly or monthly
				{ 
					url = "http://finance.yahoo.com/d/quotes.csv?s=" + symbol + "&f=sl1d1t1c1ohgv&e=.csv";
					data = readLink ( url );
					if ( data != null )
					{
						//"MSFT",24.71,"7/31/2005","4:00pm",-0.13,24.85,24.9904,24.67,69786288
						BarData barData = convertQuoteToBarData ( data );
						if ( barData.date > lastRetrievedDay )
						{
							barsDownloaded++;
							if ( bars3 != null )
							{
								bars3.Add ( barData.date, barData.open, barData.high, barData.low,
										   barData.close, barData.volume );
							}
							else
							{
								Console.WriteLine ( String.Format ( "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n",
										   barData.date, barData.open, barData.high, barData.low,
										   barData.close, barData.volume ) );
							}
						}
					}
				}
				// Update
				if ( rtUpdate3 != null )
				{
					rtUpdate3.Update ( );
					connection3.Warning ( 0, "Request (" + requestNumber + ") completed - " + barsDownloaded + " bars downloaded." );
				}
				else
				{
					Console.WriteLine ( "Request (" + requestNumber + ") completed - " + barsDownloaded + " bars downloaded." );
				}
			}
			else
			{
				if ( connection3 != null )
				{
					connection3.Warning ( 0, "request (" + requestNumber + ") not supported." );
				}
				else
				{
					Console.WriteLine ( "Request (" + requestNumber + ") not supported." );
				}
			}
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public bool SupportsRequest ( BarIntervalEnum requestType )
		{
			// Return true if the Adapter supports the specified RequestType (see below)
			// biMinutes = 0
			// biDaily = 1
			// biTicks = 2
			// biSeconds = 3
			// biWeekly = 4
			// biMonthly = 5

			switch ( requestType )
			{
				case BarIntervalEnum.biDaily:
				case BarIntervalEnum.biWeekly:
				case BarIntervalEnum.biMonthly:
					return true;
				default:
					return false;
			}
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void AssignConnectionStatus ( IWealthLabConnection3 connection3 )
		{

			// Store the IWealthLabConnection3 interface instance passed in the Conn
			// variable to a local variable. You can use this instance to communicate 
			// changes in connection status to WLD

			connection3.Connect ( ); // Call this method when a connection to the real-time data source is established.
			this.connection3 = connection3;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public bool SupportsQuotes ( )
		{
			// Return true if the Adapter support the Quotes system (Quotes Manager tool)
			// VARIANT_FALSE or VARIANT_TRUE

			return false;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void AddSymbol ( string symbol, int item )
		{
			// Provides a Symbol that needs to be tracked for real-time quote 
			// updates, and a unique integer Item.  This Symbol/Item pair should be 
			// added to a local list for tracking.  The integer Item allows the Adapter 
			// to properly handle multiple requests for a Symbol from the same Quotes
			// Manager, and allows the Quotes Manager to update more quickly
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void RemoveSymbol ( string symbol, int item )
		{
			// Remove the specified Symbol/Item pair from the local list, quote 
			// updates for this Symbol are no longer required
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void ClearSymbols ( )
		{
			// Clear all symbols from the local Symbol list
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void ActivateQuotes ( IWealthLabQuoteUpdate3 quoteUpdate3 )
		{
			// The Update parameter contains an instance of the IWealthLabQuoteUpdate3 
			// interface, which should be stored to a local variable.  At this point 
			// you should activate the real-time quote updating mechanism.  Whenever a 
			// new quote is retrieved for a Symbol in the local symbols list you should 
			// call the UpdateQuote method of the IWealthLabQuoteUpdate3 instance saved 
			// earlier
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void DeactivateQuotes ( )
		{
			// Shut down the real-time quote updating mechanism.  
			// Do not clear the symbols list, as an ActivateQuotes call may follow 
		}
		//______________________________________________________________________
		//______________________________________________________________________
		//______________________________________________________________________
		//______________________________________________________________________
		//
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private static string readLink ( string url )
		{
			HttpWebRequest myRequest = (HttpWebRequest) WebRequest.Create ( url );
			myRequest.Method = "GET";
			WebResponse myResponse = myRequest.GetResponse ( );
			StreamReader sr = new StreamReader ( myResponse.GetResponseStream ( ), System.Text.Encoding.UTF8 );
			string result = sr.ReadToEnd ( );
			sr.Close ( );
			myResponse.Close ( );
			return result;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private BarData convertStrToBarRecord ( string line )
		{
			// Date,Open,High,Low,Close,Volume,Adj. Close*
			// 7-Jan-05,65.00,69.63,64.75,69.25,39775900,34.62

			string[] tokens = line.Split ( ",".ToCharArray ( ) );
			string dateStr = tokens[0];
			BarData barData = new BarData ( );
			barData.open = Double.Parse ( tokens[1] );
			barData.high = Double.Parse ( tokens[2] );
			barData.low = Double.Parse ( tokens[3] );
			barData.close = Double.Parse ( tokens[4] );
			try
			{
				barData.volume = Int32.Parse ( tokens[5] );
			}
			catch ( Exception )
			{
				barData.volume = Int32.MaxValue;
			}

			double adjustedClose = Double.Parse ( tokens[6] );

			if ( barData.close != 0 )
			{
				barData.open = barData.open * adjustedClose / barData.close;
				barData.high = barData.high * adjustedClose / barData.close;
				barData.low = barData.low * adjustedClose / barData.close;
				barData.close = barData.close * adjustedClose / barData.close;
			}

			barData.date = parseDate ( dateStr );

			return barData;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private BarData convertQuoteToBarData ( string line )
		{
			//"MSFT",24.71,"7/31/2005","4:00pm",-0.13,24.85,24.9904,24.67,69786288

			// Make sure it has 8 commas 

			string[] tokens = line.Split ( ",".ToCharArray ( ) );
			string symbolWithDQuotes = tokens[0];  // Symbol with double quotes
			double close = Double.Parse ( tokens[1] ); // close
			string dateStrWithDQuotes = tokens[2]; // date with double quotes
			string timeStrWithDQuotes = tokens[3]; // time with double quotes
			string priceChangeStr = tokens[4]; // change
			double open = Double.Parse ( tokens[5] ); // open
			double high = Double.Parse ( tokens[6] ); // high
			double low = Double.Parse ( tokens[7] ); // low
			int volume = Int32.Parse ( tokens[8] ); // volume

			BarData barData = new BarData ( );

			if ( 0.0 == open || 0.0 == high || 0.0 == low || 0.0 == close )
			{
				if ( close != 0.0 )
				{
					open = high = low = close;
				}
				else
				{
					MessageBox.Show ( "Parse error in convertQuoteToBarData\n" );
					return null;
				}
			}

			barData.open = open;
			barData.high = high;
			barData.low = low;
			barData.close = close;
			barData.volume = volume;

			// dateStr = 7/1/2005
			string dateStr = dateStrWithDQuotes.Substring ( 1, dateStrWithDQuotes.Length - 2 ); // remove double quotes from date
			barData.date = parseDate ( dateStr );

			return barData;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private int getMonthNumericFromStr ( string monthStr )
		{

			if ( monthStr.Length == 3 )
			{
				string[] monthName = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN",
		                              "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};
				monthStr = monthStr.ToUpper ( );
				for ( int i = 0; i < 12; i++ )
				{
					if ( monthStr == monthName[i] )
					{
						return i + 1;
					}
				}
			}
			else
			{
				try
				{
					int month = Int32.Parse ( monthStr );
					if ( month >= 1 && month <= 12 )
					{
						return month;
					}
				}
				catch ( Exception )
				{
				}
			}
			MessageBox.Show ( "Error could not get month name : " + monthStr + "" );
			return 1;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private DateTime parseDate ( string dateStr )
		{
			DateTime result = DateTime.Now; ;
			string[] tokens = dateStr.Split ( "-/".ToCharArray ( ) );

			//Supported formats: 1/30/2007, 2007-01-30, 01-JAN-07
			int day, month, year;
			day = month = year = 0;
			string part1, part2, part3;
			part1 = tokens[0]; part2 = tokens[1]; part3 = tokens[2];
			if ( part3.Length == 4 )
			{
				// 1/30/2007
				month = Int32.Parse ( part1 );
				day = Int32.Parse ( part2 );
				year = Int32.Parse ( part3 );
			}
			else if ( part1.Length == 4 )
			{
				// 2007-01-30
				year = Int32.Parse ( part1 );
				month = Int32.Parse ( part2 );
				day = Int32.Parse ( part3 );
			}
			else if ( part2.Length == 3 )
			{
				// 01-JAN-07
				day = Int32.Parse ( part1 );
				month = getMonthNumericFromStr ( part2 );
				year = Int32.Parse ( part3 );
				year = ( year < 50 ? ( 2000 + year ) : ( 1900 + year ) );
			}

			try
			{
				result = new DateTime ( year, month, day );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "dateStr=###" + dateStr + "###\nyear=" + year + ",month=" + month + ",day=" + day + "\n\n"
					+ e.Message + "\n\n" + e.StackTrace );
				result = DateTime.Now;
			}
			return result;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
	}
}

