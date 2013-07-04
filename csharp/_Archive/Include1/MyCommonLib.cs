
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CsScripts\StdLib.cs
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
		IWealthLabAddOn3 WL = null;

		int BarCount = 0;
		
		DateTime[] Date = null;
		Series Open = null;
		Series High = null;
		Series Low = null;
		Series Close = null;
		Series Volume = null;

		static int counter = 0;

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void MyCommonLibTest ( )
		{
			try
			{
				MessageBox.Show ( "MyCommonLib is working. CurrDir = " + Environment.CurrentDirectory, "MyCommonLib" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void MyCommonLibInit ( IWealthLabAddOn3 wl )
		{
			try
			{
				Print ( "C# Scripting Working. counter = " + counter++ );
				WL = wl;

				BarCount = WL.BarCount ( );

				Date = new DateTime[BarCount];
				Open = new Series ( BarCount );
				High = new Series ( BarCount );
				Low = new Series ( BarCount );
				Close = new Series ( BarCount );
				Volume = new Series ( BarCount );
				
				for ( int i = 0; i < BarCount; i++ )
				{
					Date[i] = WL.Date ( i );
					Open[i] = WL.PriceOpen ( i );
					High[i] = WL.PriceHigh ( i );
					Low[i] = WL.PriceLow ( i );
					Close[i] = WL.PriceClose ( i );
					Volume[i] = WL.Volume ( i );
				}
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
		public void GetElderChDevSeries ( Series ValueSeries, int Period, int LoopBackBar, int CutOffPercent,
			out Series upperChannel, out Series lowerChannel, out Series channelWidthPercent )
		{
			int INITIAL_OFFSET = LoopBackBar + Period;

			if ( BarCount < INITIAL_OFFSET )
			{
				upperChannel = AddSeriesValue ( ValueSeries, 0 );
				lowerChannel = AddSeriesValue ( ValueSeries, 0 );
				channelWidthPercent = MultiplySeriesValue ( ValueSeries, 0 );
				return;
			}

			// Now calculate the new series
			Series deviation = CreateSeries ( );
			for ( int i = INITIAL_OFFSET; i < BarCount; i++ )
			{
				deviation[i] = GetElderChDevFromValueSeries ( i, ValueSeries, LoopBackBar, CutOffPercent );
			}

			// Initialize the first few bars which have 0 value
			for ( int i = 0; i < INITIAL_OFFSET; i++ )
			{
				deviation[i] = deviation[INITIAL_OFFSET];
			}

			// upper and lower series
			upperChannel = MultiplySeries ( ValueSeries, AddSeriesValue ( deviation, 1 ) );
			lowerChannel = MultiplySeries ( ValueSeries, SubtractValueSeries ( 1, deviation ) );
			channelWidthPercent = MultiplySeriesValue ( deviation, 200 );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		double GetElderChDeviation ( int EndBar, int Period, int LoopBackBar, int CutOffPercent )
		{
			if ( EndBar < ( LoopBackBar + 1 ) )
			{
				return 0;
			}
			Series ValueSeries = EMASeries ( Close, Period );

			return GetElderChDevFromValueSeries ( EndBar, ValueSeries, LoopBackBar, CutOffPercent );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		double GetElderChDevFromValueSeries ( int EndBar, Series ValueSeries, int LoopBackBar, int CutOffPercent )
		{
			const int MAX_LOOP = 100;

			// First get an approximate value for deviation
			double totalRange = 0;
			for ( int bar = EndBar - 9; bar <= EndBar; bar++ ) // last 10 days
			{
				double range = Math.Abs ( Close[bar] - ValueSeries[bar] );
				totalRange = totalRange + range;
				//if ( EndBar == BarCount - 1 ) Out.WriteLine ( "range=" + range + "\t totalRange" + totalRange );
			}
			double absDev = totalRange / 10; // Avg absolute deviation
			double deviation = absDev / ValueSeries[EndBar];  // deviation as a fraction of ValueSeries

			// Find High Low Range 
			double highLimit, lowLimit, highLowRange;
			highLimit = Close[EndBar - LoopBackBar + 1];
			lowLimit = Close[EndBar - LoopBackBar + 1];
			for ( int bar = EndBar - LoopBackBar + 2; bar <= EndBar; bar++ )
			{
				if ( Close[bar] > highLimit )
				{
					highLimit = Close[bar];
				}
				if ( Close[bar] < lowLimit )
				{
					lowLimit = Close[bar];
				}
			}
			highLowRange = highLimit - lowLimit;
			if ( highLowRange == 0 ) highLowRange = Close[EndBar];

			// Fit on last couple of months by iteration, to get a good value of deviation
			int countLoop, percentIn;
			double totalIn = 0; // Weighted total in
			double total = 0;
			percentIn = 0;
			countLoop = 0;
			double factor = 0.01;
			while ( ( countLoop < MAX_LOOP ) )
			{
				countLoop = countLoop + 1;
				totalIn = 0; // Weighted total in
				total = 0; // Wedighted total
				for ( int bar = EndBar - LoopBackBar + 1; bar <= EndBar; bar++ )
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
					if ( ( Close[bar] < ( ValueSeries[bar] * ( 1 + deviation ) ) ) &&
						 ( Close[bar] > ( ValueSeries[bar] * ( 1 - deviation ) ) )
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
		//
		//--------------------------------------------------------------------------------------------
		public void GetMacdSeries ( out Series macd, out Series macdSignal, out Series macdHistogram )
		{
			macd = MACDSeries ( Close );
			macdSignal = EMASeries ( macd, 9 );

			Series trueMacdHistogram = SubtractSeries ( macd, macdSignal );
			macdHistogram = MultiplySeriesValue ( trueMacdHistogram, 3 ); // Magnify a bit
		}

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void GetStochSeries ( int Period, out Series stochSlow, out Series stochFast )
		{
			stochFast = StochDSeries ( Period, 3 );
			stochSlow = SMASeries ( stochFast, 3 );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

