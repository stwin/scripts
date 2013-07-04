/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Adapters\Emini1MinRealDataCommon.cs
#IncludeFile CSharpScripts\Adapters\Emini1MinRealDataCommon.Designer.cs
#PrimaryClass Emini1MinRT.Emini1MinRealData
[/SCRIPT]*/


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Net;

using WealthLab;
using WLE;

namespace Emini1MinRT
{
	public class Emini1MinRealData : IWealthLabRT3
	{

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		// Constants

		// Global
		static Emini1MinRealDataCommon Common = null;

		// 
		IWealthLabConnection3 connection3 = null;
		IWealthLabBars3 bars3 = null;
		IWealthLabRTUpdate3 rtUpdate3 = null;
		string Symbol = "";
		int BarIntervalMinutes = 1;

		List<BarData> Data = null;
		DateTime NextBarDateTime;
		double GhostBarOpen, GhostBarHigh, GhostBarLow, GhostBarClose;
		int GhostBarVolume;

		public Emini1MinRealData ( )
		{
			//MessageBox.Show ( "Emini1MinRealTimeAdapter Constructor called" );
			if ( Common == null )
			{
				Common = new Emini1MinRealDataCommon ( );
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void Update ()
		{
			BarData bd = Data[Common.CurrentBar];

			if ( BarIntervalMinutes == 1 )
			{
				bars3.Add ( bd.Date, bd.Open, bd.High, bd.Low, bd.Close, bd.Volume );
				rtUpdate3.Update ( );
			}
			else
			{
				if ( bd.Date >= NextBarDateTime )
				{
					bars3.Add ( NextBarDateTime.AddMinutes ( -BarIntervalMinutes ),
						GhostBarOpen, GhostBarHigh, GhostBarLow, GhostBarClose, GhostBarVolume );
					rtUpdate3.Update ( );
					GhostBarOpen = bd.Open;
					GhostBarHigh = bd.High;
					GhostBarLow = bd.Low;
					GhostBarClose = bd.Close;
					GhostBarVolume = bd.Volume;
					NextBarDateTime = bd.Date.AddMinutes (
						BarIntervalMinutes - ( bd.Date.Minute % BarIntervalMinutes ) );
					rtUpdate3.UpdateGhostBar ( GhostBarOpen, GhostBarHigh, GhostBarLow,
						GhostBarClose, GhostBarVolume );
				}
				else
				{
					GhostBarHigh = Math.Max ( GhostBarHigh, bd.High );
					GhostBarLow = Math.Min ( GhostBarLow, bd.Low );
					GhostBarClose = bd.Close;
					GhostBarVolume += bd.Volume;
					rtUpdate3.UpdateGhostBar ( GhostBarOpen, GhostBarHigh, GhostBarLow, 
						GhostBarClose, GhostBarVolume );
				}
			}

		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public override string ToString ( )
		{
			return String.Format ( "Emini1MinRealData[Symbol={0},BarIntervalMinutes={1}]",
				this.Symbol, this.BarIntervalMinutes );
		}
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public string GetSecurityName ( string Symbol )
		{
			// Implement this method to return a security name for the specified 
			// Symbol.  If you don't have access to a security name, return a blank 
			// string.  This method is called after OpenRequest

			return "";
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void CloseRequest ( )
		{
			// Implement this method to perform any necessary cleanup after a real-time
			// chart window is closed.  Note: CloseRequest is called prior to the 
			// first OpenRequest call.
			Common.DeRegisterForUpdate ( this );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void OpenRequest ( string Symbol, int numBars, BarIntervalEnum requestType,
					int barInterval, bool filterMarketHours, DateTime marketOpen,
					DateTime marketClose, IWealthLabBars3 bars3, IWealthLabRTUpdate3 rtUpdate3 )
		{
			// Special Symbols first
			if ( Symbol == "_SHOW_GUI" )
			{
				Common.Show ( );
				return;
			}
			if ( Symbol == "_DEBUG_INFO" )
			{
				Common.PrintDebugInfo ( );
				return;
			}

			this.bars3 = bars3;
			this.rtUpdate3 = rtUpdate3;
			this.Symbol = Symbol;
			this.BarIntervalMinutes = barInterval;

			Common.RegisterForUpdate ( this );

			Data = Common.AllData[Symbol];

			int StartIndex = Math.Max ( 0, Common.CurrentBar - BarIntervalMinutes * Common.TotalBars + 1 );

			// Intialize GhostBar
			BarData FirstBarData = Data[StartIndex];
			GhostBarOpen = FirstBarData.Open;
			GhostBarHigh = FirstBarData.High;
			GhostBarLow = FirstBarData.Low;
			GhostBarClose = FirstBarData.Close;
			GhostBarVolume = 0;
			NextBarDateTime = FirstBarData.Date.AddMinutes ( 
				BarIntervalMinutes - ( FirstBarData.Date.Minute % BarIntervalMinutes ) );

			for ( int index = StartIndex; index <= Common.CurrentBar; index++ )
			{
				//MessageBox.Show ( "Count = " + count );
				BarData bd = Data[index];
				if ( BarIntervalMinutes == 1 )
				{
					bars3.Add ( bd.Date, bd.Open, bd.High, bd.Low, bd.Close, bd.Volume );
				}
				else
				{
					if ( bd.Date >= NextBarDateTime )
					{
						bars3.Add ( NextBarDateTime.AddMinutes ( -BarIntervalMinutes ),
							GhostBarOpen, GhostBarHigh, GhostBarLow, GhostBarClose, GhostBarVolume );
						GhostBarOpen = bd.Open;
						GhostBarHigh = bd.High;
						GhostBarLow = bd.Low;
						GhostBarClose = bd.Close;
						GhostBarVolume = bd.Volume;
						NextBarDateTime = bd.Date.AddMinutes (
							BarIntervalMinutes - ( bd.Date.Minute % BarIntervalMinutes ) );

					}
					else
					{
						GhostBarHigh = Math.Max ( GhostBarHigh, bd.High );
						GhostBarLow = Math.Min ( GhostBarLow, bd.Low );
						GhostBarClose = bd.Close;
						GhostBarVolume += bd.Volume;
					}
				}
			}

			rtUpdate3.Update ( );

			if ( BarIntervalMinutes != 1 )
			{
				rtUpdate3.UpdateGhostBar ( GhostBarOpen, GhostBarHigh, GhostBarLow,
					GhostBarClose, GhostBarVolume );
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
				case BarIntervalEnum.biMinutes:
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
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
	}
}