
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference Interop.TC2000Dev.dll 
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs
#IncludeFile CSharpScripts\Include\FedResMeeting.cs
#IncludeFile CSharpScripts\Include\Fundamental.cs
#IncludeFile CSharpScripts\Include\Macd.cs
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
		public void EverythingTest ( )
		{
			try
			{
				MessageBox.Show ( "EverythingTest is working. CurrDir = " + Environment.CurrentDirectory, "EverythingTest" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void EverythingInit ( IWealthLabAddOn3 wl )
        {
			InternalLibInit ( wl );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void Everything_GetChannelDeviationSeries ( int Period, int LookBackBars, int CutOffPercent, 
			int deviationSeries )
		{
			try
			{
				//
				// Calculate all series
				//
				Series mainEma = EMASeries ( BarClose, Period );

				Series deviation, upperChannel, lowerChannel, channelWidthPercent;
				GetElderChDevSeries ( mainEma, Period, LookBackBars, CutOffPercent, out deviation,
					out upperChannel, out lowerChannel, out channelWidthPercent );

				//
				// Now populate all series
				//
				WL.PopulateSeries ( deviationSeries, ref deviation.Value[0] );
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
		public void Everything_GetChannelDeviation ( int Bar, int Period, int LookBackBar, int CutOffPercent,
			ref double deviation )
		{
			try
			{
				if ( BarCount > 22 ) // Deviation for at least 22 bars
				{
					LookBackBar = Math.Min ( LookBackBar, BarCount );
				}
				else
				{
					deviation = 0;
					return;
				}

				Series mainEma = EMASeries ( BarClose, Period );

				deviation = GetElderChDevFromValueSeries ( Bar, BarClose, mainEma, LookBackBar, CutOffPercent );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetBasicSeries" );
			}
		}
	}
}


