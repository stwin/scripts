
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
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
    partial class MyClass
    {
		//static int InternalLibCounter = 0;

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void InternalLibTest ( )
		{
			try
			{
				MessageBox.Show ( "InternalLib is working. CurrDir = " + Environment.CurrentDirectory, "InternalLib" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void InternalLibInit ( IWealthLabAddOn3 wl )
		{
			try
			{
				//Print ( "C# Scripting Working. InternalLibCounter = " + InternalLibCounter++ );
				StdLibInit ( wl );
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
		internal void GetElderChDevSeriesFast ( Series ValueSeries, int Period, int LoopBackBar, int CutOffPercent,
			out Series upperChannel, out Series lowerChannel )
		{
			int INITIAL_OFFSET = LoopBackBar + Period;

			if ( BarCount < INITIAL_OFFSET )
			{
				upperChannel = AddSeriesValue ( ValueSeries, 0 );
				lowerChannel = AddSeriesValue ( ValueSeries, 0 );
				return;
			}

			// Now calculate the deviation
			double deviation = GetElderChDevFromValueSeries ( BarCount-1, BarClose, ValueSeries, LoopBackBar, CutOffPercent );			

			// upper and lower series
			upperChannel = MultiplySeriesValue ( ValueSeries, ( 1 + deviation ) );
			lowerChannel = MultiplySeriesValue ( ValueSeries, ( 1 - deviation ) );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal void GetElderChDevSeries ( Series ValueSeries, int Period, int LookBackBar, int CutOffPercent,
			out Series deviation, out Series upperChannel, out Series lowerChannel, out Series channelWidthPercent )
		{
			if ( BarCount > 22 ) // Plot Channel for at least 22 bars
			{
				LookBackBar = Math.Min ( LookBackBar, BarCount );
			}
			else
			{
				deviation = CreateZeroSeries();
				upperChannel = AddSeriesValue ( ValueSeries, 0 );
				lowerChannel = AddSeriesValue ( ValueSeries, 0 );
				channelWidthPercent = CreateZeroSeries ( );
				return;
			}

			// Now calculate the new series
			deviation = CreateSeries ( );
			for ( int i = LookBackBar - 1; i < BarCount; i++ )
			{
				deviation[i] = GetElderChDevFromValueSeries ( i, BarClose, ValueSeries, LookBackBar, CutOffPercent );
			}

			// Initialize the first few bars which have 0 value
			for ( int i = 0; i <= LookBackBar - 2; i++ )
			{
				deviation[i] = deviation[LookBackBar - 1];
			}

			// upper and lower series
			upperChannel = MultiplySeries ( ValueSeries, AddSeriesValue ( deviation, 1 ) );
			lowerChannel = MultiplySeries ( ValueSeries, SubtractValueSeries ( 1, deviation ) );
			channelWidthPercent = MultiplySeriesValue ( deviation, 200 );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal double GetElderChDeviation_not_used ( int EndBar, Series MainSeries, 
			int Period, int LoopBackBar, int CutOffPercent )
		{
			if ( EndBar < ( LoopBackBar + 1 ) )
			{
				return 0;
			}
			Series ValueSeries = EMASeries ( MainSeries, Period );

			return GetElderChDevFromValueSeries ( EndBar, MainSeries, ValueSeries, LoopBackBar, CutOffPercent );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal double GetElderChDevFromValueSeries ( int EndBar, Series MainSeries,
			Series ValueSeries, int LoopBackBar, int CutOffPercent )
		{
			const int MAX_LOOP = 100;

			if ( EndBar < 9 )
			{
				return 0;
			}
			// First get an approximate value for deviation
			double totalRange = 0;
			for ( int bar = EndBar - 9; bar <= EndBar; bar++ ) // last 10 days
			{
				double range = Math.Abs ( MainSeries[bar] - ValueSeries[bar] );
				totalRange = totalRange + range;
				//if ( EndBar == BarCount - 1 ) Out.WriteLine ( "range=" + range + "\t totalRange" + totalRange );
			}
			double absDev = totalRange / 10; // Avg absolute deviation
			double deviation = absDev / ValueSeries[EndBar];  // deviation as a fraction of ValueSeries

			// Find High Low Range 
			double highLimit, lowLimit, highLowRange;
			highLimit = MainSeries[EndBar - LoopBackBar + 1];
			lowLimit = MainSeries[EndBar - LoopBackBar + 1];
			for ( int bar = EndBar - LoopBackBar + 2; bar <= EndBar; bar++ )
			{
				if ( MainSeries[bar] > highLimit )
				{
					highLimit = MainSeries[bar];
				}
				if ( MainSeries[bar] < lowLimit )
				{
					lowLimit = MainSeries[bar];
				}
			}
			highLowRange = highLimit - lowLimit;
			if ( highLowRange == 0 ) highLowRange = MainSeries[EndBar];

			// Fit on last couple of months by iteration, to get a good value of deviation
			int countLoop, percentIn;
			double totalIn = 0; // Weighted total in
			double total = 0;
			percentIn = 0;
			countLoop = 0;
			double factor = 0.01;
			int startBar = Math.Max ( 1, EndBar - LoopBackBar + 1 );
			while ( ( countLoop < MAX_LOOP ) )
			{
				countLoop = countLoop + 1;
				totalIn = 0; // Weighted total in
				total = 0; // Wedighted total
				for ( int bar = startBar; bar <= EndBar; bar++ )
				{
					int index = LoopBackBar - ( EndBar - bar );
					double slope;
					if ( ValueSeries[bar] > ValueSeries[bar - 1] ) // increasing
					{
						slope = ( ValueSeries[bar] - ValueSeries[bar - 1] ) / highLowRange;
					}
					else
					{
						slope = ( ValueSeries[bar - 1] - ValueSeries[bar] ) / highLowRange;
					}
					double weight = ( 1 - slope ) * (double) index / LoopBackBar;
					if ( ( MainSeries[bar] < ( ValueSeries[bar] * ( 1 + deviation ) ) ) &&
						 ( MainSeries[bar] > ( ValueSeries[bar] * ( 1 - deviation ) ) )
						)
                    {
						totalIn = totalIn + weight;
                    }
					total = total + weight;
				}
				percentIn = (int) ( 100 * totalIn / total );
				factor = ( CutOffPercent - percentIn ) / (double) CutOffPercent;
				if ( factor < 0.02 ) factor = 0.02;
				deviation = deviation * ( 1 + factor );
                //if ( EndBar == BarCount-1 )
                //    Debug.WriteLine ( String.Format ( "{0}: totalIn={1}, percentIn={2}, deviation={3}",
                //            countLoop, totalIn, percentIn, deviation ));
				if ( percentIn >= CutOffPercent )
					break;
			}
			//Debug.WriteLine ( String.Format ( "{0}:\t totalIn={1},\t percentIn={2},\t deviation={3}",
			//		countLoop, totalIn, percentIn, deviation ) );
			return deviation;
		}

		//____________________________________________________________________________________________
		// TODO : Get rid of this function
		//--------------------------------------------------------------------------------------------
		internal void GetMacdSeries ( out Series macd, out Series macdSignal, out Series macdHistogram )
		{
			macd = MACDSeries ( BarClose );
			macdSignal = EMASeries ( macd, 9 );

			Series trueMacdHistogram = SubtractSeries ( macd, macdSignal );
			macdHistogram = MultiplySeriesValue ( trueMacdHistogram, 3 ); // Magnify a bit
		}

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal void GetStochSeries ( int Period, out Series stochSlow, out Series stochFast )
		{
			stochFast = StochDSeries ( Period, 3 );
			stochSlow = SMASeries ( stochFast, 3 );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal void GetSyntheticGreenSeries ( out Series gOpen, out Series gHigh, out Series gLow,
			out Series gClose )
		{

			gOpen = CreateSeries ( );
			gHigh = CreateSeries ( );
			gLow = CreateSeries ( );
			gClose = CreateSeries ( );
			for ( int Bar = 0; Bar < BarCount; Bar++ )
			{
				if ( BarClose[Bar] > BarOpen[Bar] )
				{
					gOpen[Bar] = BarOpen[Bar];
					gHigh[Bar] = BarHigh[Bar];
					gLow[Bar] = BarLow[Bar];
					gClose[Bar] = BarClose[Bar];
				}
				else
				{
					gOpen[Bar] = BarOpen[Bar];
					gHigh[Bar] = BarOpen[Bar];
					gLow[Bar] = BarOpen[Bar];
					gClose[Bar] = BarOpen[Bar];
				}
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		internal void GetCustomMACDSeries ( Series ValueSeries, out Series macd, out Series macdSignal,
			out Series macdh, out Series macdhColor, ref double macdOffset, ref string impulseString )
		{
			macd = MACDSeries ( BarClose );
			macdSignal = EMASeries ( macd, 9 );

			Series trueMacdHistogram = SubtractSeries ( macd, macdSignal );
			macdh = MultiplySeriesValue ( trueMacdHistogram, 3 ); // Magnify a bit

			int lookBackBars = 104;
			if ( BarCount < lookBackBars )
			{
				lookBackBars = BarCount;
			}
			double x = Lowest ( BarCount - 1, BarLow, lookBackBars );
			double y = Highest ( BarCount - 1, BarHigh, lookBackBars );
			double a = Lowest ( BarCount - 1, macdh, lookBackBars );
			double b = Highest ( BarCount - 1, macdh, lookBackBars );

			macdOffset =  ( 7 * x + y ) / 8 ;
			double factor = ( y - x ) / ( 4 * ( b - a ) );

			// Scaling and Relocation
			macd = AddSeriesValue ( MultiplySeriesValue ( macd, factor ), macdOffset );
			macdSignal = AddSeriesValue ( MultiplySeriesValue ( macdSignal, factor ), macdOffset );
			macdh = AddSeriesValue ( MultiplySeriesValue ( macdh, factor ), macdOffset );

			// Faded Colors = 955, 559, 884, 373, 955 - Use these color to plot faded macdh

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
		}

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

