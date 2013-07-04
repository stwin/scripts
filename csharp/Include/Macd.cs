
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
[/SCRIPT]*/




using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;

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
		public void MacdTest ( )
		{
			try
			{
				MessageBox.Show ( "MacdTest is working. CurrDir = " + Environment.CurrentDirectory, "MacdTest" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void GetMacdSeriesWithDiv ( int mmacd, int mmacdSignal,	int mmacdh, int mmacdhColor,
			ref string impulseStr, ref bool IsBullishDev, ref int BullBar1, ref int BullBar2,
			ref bool IsBearishDev, ref int BearBar1, ref int BearBar2 )
		{
			try
			{
				//
				// Calculate all series
				//
				Series slowEma = EMASeries ( BarClose, 22 );

				Series macd, macdSignal, macdh, macdhColor;
				GetMACDSeries ( slowEma, out macd, out macdSignal, out macdh, out macdhColor, ref impulseStr,
					ref IsBullishDev, ref BullBar1, ref BullBar2, ref IsBearishDev, ref BearBar1, ref BearBar2 );

				//
				// Now populate all series
				//
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
		// Plots MACD Series including bearish and bullish divergences
		//--------------------------------------------------------------------------------------------
		public void GetMACDSeries ( Series ValueSeries, out Series macd, out Series macdSignal,
			out Series macdh, out Series macdhColor, ref string impulseString,
			ref bool IsBullishDev, ref int BullBar1, ref int BullBar2,
			ref bool IsBearishDev, ref int BearBar1, ref int BearBar2 )
		{
			macd = MACDSeries ( BarClose );
			macdSignal = EMASeries ( macd, 9 );

			Series trueMacdHistogram = SubtractSeries ( macd, macdSignal );
			macdh = MultiplySeriesValue ( trueMacdHistogram, 3 ); // Magnify a bit

			// Set the ipulse color of the histogram bars
			const int GREEN_IMPULSE = 070;
			const int RED_IMPULSE = 800;
			const int BLUE_IMPULSE = 009;
			macdhColor = CreateSeries ( );
			for ( int i = 1; i < BarCount; i++ )
			{
				if ( ( macdh[i] > macdh[i - 1] ) && ( ValueSeries[i] > ValueSeries[i - 1] ) )
				{
					macdhColor[i] = GREEN_IMPULSE;
				}
				else if ( ( macdh[i] < macdh[i - 1] ) && ( ValueSeries[i] < ValueSeries[i - 1] ) )
				{
					macdhColor[i] = RED_IMPULSE;
				}
				else
				{
					macdhColor[i] = BLUE_IMPULSE;
				}
			}

			// Now figure out the impulse of the last bar
			if ( macdhColor[BarCount - 1] == GREEN_IMPULSE )
			{
				impulseString = "Green";
			}
			else if ( macdhColor[BarCount - 1] == RED_IMPULSE )
			{
				impulseString = "Red";
			}
			else
			{
				impulseString = "Blue";
			}

			// Now MACD Divergences

			int bar;

			// Bullsih div
			double bottomLast = 0, bottom2ndLast = 0;
			int barBottomLast = 0, barBottom2ndLast = 0;

			bar = BarCount - 1;

			getBottom ( ref bar, ref bottomLast, ref barBottomLast, macdh );
			getBottom ( ref bar, ref bottom2ndLast, ref barBottom2ndLast, macdh );

			if ( ( bottomLast > bottom2ndLast )
				&& ( BarLow[barBottomLast] < BarLow[barBottom2ndLast] ) )
			{
				IsBullishDev = true;
				BullBar1 = barBottom2ndLast;
				BullBar2 = barBottomLast;
			}

			// Bearish div
			double peakLast = 0, peak2ndLast = 0;
			int barPeakLast = 0, barPeak2ndLast = 0;

			bar = BarCount - 1;

			getPeak ( ref bar, ref peakLast, ref barPeakLast, macdh );
			getPeak ( ref bar, ref peak2ndLast, ref barPeak2ndLast, macdh );

			if ( ( peakLast < peak2ndLast )
				&& ( BarHigh[barPeakLast] > BarHigh[barPeak2ndLast] ) )
			{
				IsBearishDev = true;
				BearBar1 = barPeak2ndLast;
				BearBar2 = barPeakLast;
			}
		}
		//____________________________________________________________________________________________
		// Used for detecting MACD Divergence
		//--------------------------------------------------------------------------------------------
		public void getBottom ( ref int bar, ref double bottomLast, ref int barBottomLast, Series macdh )
		{
			for ( ; bar > 0; bar-- )
			{
				if ( macdh[bar] < 0 )
				{
					break;
				}
			}

			// Now we are pointing to a negative entry
			bottomLast = macdh[bar];
			barBottomLast = bar;
			for ( bar = bar - 1; bar > 0; bar-- )
			{
				if ( macdh[bar] >= 0 )
				{
					break;
				}
				if ( macdh[bar] < bottomLast )
				{
					bottomLast = macdh[bar];
					barBottomLast = bar;
				}
			}
			if ( bar < 0 )
			{
				bar = 0;
			}
		}
		//____________________________________________________________________________________________
		// Used for detecting MACD Divergence
		//--------------------------------------------------------------------------------------------
		public void getPeak ( ref int bar, ref double peakLast, ref int barPeakLast, Series macdh )
		{
			for ( ; bar > 0; bar-- )
			{
				if ( macdh[bar] > 0 )
				{
					break;
				}
			}

			// Now we are pointing to a positive entry
			peakLast = macdh[bar];
			barPeakLast = bar;
			for ( bar = bar - 1; bar > 0; bar-- )
			{
				if ( macdh[bar] <= 0 )
				{
					break;
				}
				if ( macdh[bar] > peakLast )
				{
					peakLast = macdh[bar];
					barPeakLast = bar;
				}
			}
			if ( bar < 0 )
			{
				bar = 0;
			}
		}
		
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

