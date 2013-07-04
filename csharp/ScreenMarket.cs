
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#AddReference Interop.TC2000Dev.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs
#IncludeFile CSharpScripts\Include\FedResMeeting.cs
#IncludeFile CSharpScripts\Include\Fundamental.cs
#IncludeFile CSharpScripts\Include\Macd.cs
#IncludeFile CSharpScripts\Include\Positions.cs
#IncludeFile CSharpScripts\Include\Telechart.cs
[/SCRIPT]*/



using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;

using WealthLab;


namespace MyScript
{
	public partial class MyClass
	{
		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void ScreenMarketTest ( )
		{
			try
			{
				MessageBox.Show ( "ScreenMarketTest is working. CurrDir = " + Environment.CurrentDirectory, "ScreenMarketTest" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenMarketInit ( IWealthLabAddOn3 wl )
		{
			InternalLibInit ( wl );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenMarket_GetBasicSeries ( int slowEmaSeries, int mainEmaSeries, int upperChannelSeries,
			int lowerChannelSeries, ref string channelStr )
		{
			try
			{
				//
				// Calculate all series
				//
				Series slowEma = EMASeries ( BarClose, 11 );
				Series ema22 = EMASeries ( BarClose, 22 );
				Series mainEma = ema22; //SMASeries ( ema22, 5 );

				Series deviation, upperChannel, lowerChannel, channelWidthPercent;
				GetElderChDevSeries ( mainEma, 22, 132, 90, out deviation,
					out upperChannel, out lowerChannel, out channelWidthPercent );
				channelStr = String.Format ( "ChannelWidth ({0:G2}%):  {1:N2}",
					channelWidthPercent[BarCount - 1],
					( upperChannel[BarCount - 1] - lowerChannel[BarCount - 1] ) );

				//
				// Now populate all series
				//
				WL.PopulateSeries ( slowEmaSeries, ref slowEma.Value[0] );
				WL.PopulateSeries ( mainEmaSeries, ref mainEma.Value[0] );
				WL.PopulateSeries ( upperChannelSeries, ref upperChannel.Value[0] );
				WL.PopulateSeries ( lowerChannelSeries, ref lowerChannel.Value[0] );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetBasicSeries" );
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenMarket_GetAllSeries2 ( int emaFastSeries, int emaSlowSeries,
			int upperSeries, int lowerSeries, int greenOpen, int greenHigh, int greenLow, int greenClose,
			int mmacd, int mmacdSignal, int mmacdh, int mmacdhColor, ref double macdOffset, ref string impulseStr )
		{
			try
			{
				//
				// Calculate all series
				//
				Series fastEma = EMASeries ( BarClose, 11 );
				Series slowEma = EMASeries ( BarClose, 22 );

				Series upperChannel, lowerChannel;
				GetElderChDevSeriesFast ( slowEma, 22, 66, 90, out upperChannel, out lowerChannel );

				Series gOpen, gHigh, gLow, gClose;
				GetSyntheticGreenSeries ( out gOpen, out gHigh, out gLow, out gClose );

				Series macd, macdSignal, macdh, macdhColor;
				GetCustomMACDSeries ( slowEma, out macd, out macdSignal, out macdh, out macdhColor,
					ref macdOffset, ref impulseStr );

				//
				// Now populate all series
				//
				WL.PopulateSeries ( emaFastSeries, ref fastEma.Value[0] );
				WL.PopulateSeries ( emaSlowSeries, ref slowEma.Value[0] );
				WL.PopulateSeries ( upperSeries, ref upperChannel.Value[0] );
				WL.PopulateSeries ( lowerSeries, ref lowerChannel.Value[0] );
				WL.PopulateSeries ( greenOpen, ref gOpen.Value[0] );
				WL.PopulateSeries ( greenHigh, ref gHigh.Value[0] );
				WL.PopulateSeries ( greenLow, ref gLow.Value[0] );
				WL.PopulateSeries ( greenClose, ref gClose.Value[0] );
				WL.PopulateSeries ( mmacd, ref macd.Value[0] );
				WL.PopulateSeries ( mmacdSignal, ref macdSignal.Value[0] );
				WL.PopulateSeries ( mmacdh, ref macdh.Value[0] );
				WL.PopulateSeries ( mmacdhColor, ref macdhColor.Value[0] );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.GetAllSeries" );
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenMarket_GetStochSeries ( int stochSlowSeries, int stochFastSeries )
		{
			try
			{
				Series stochSlow, stochFast;
				GetStochSeries ( 7, out stochSlow, out stochFast );

				WL.PopulateSeries ( stochSlowSeries, ref stochSlow.Value[0] );
				WL.PopulateSeries ( stochFastSeries, ref stochFast.Value[0] );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetStochSeries" );
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenMarket_GetStockIndustryInfo ( ref string MainIndustry,
			ref string MainIndustrySymbol, ref string SubIndustry, ref string SubIndustrySymbol )
		{
			try
			{
				string StockSymbol = GetStringParam ( "Symbol" );

				if ( StockSymbol == null )
				{
					StockSymbol = "SP-500";
				}

				GetIndustryGroupInfo ( StockSymbol, ref MainIndustry, ref MainIndustrySymbol,
					ref SubIndustry, ref SubIndustrySymbol );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetStochSeries" );
			}
		}
	}
}


