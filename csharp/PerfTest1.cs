
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
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
		double[] Close = null;
		int BarCount = 0;
		//--------------------------------------------------------------------------------------------
		public void Init ( IWealthLabAddOn3 wl )
        {
			WL = wl;
			BarCount = WL.BarCount ( );
			Close = new double[BarCount];
			for ( int i = 0; i < BarCount; i++ )
				Close[i] = WL.PriceClose ( i );
		}
		//--------------------------------------------------------------------------------------------
		double GetElderChDeviation ( int EndBar, int Period, int LoopBackBar, int CutOffPercent )
		{
			if ( EndBar < ( LoopBackBar + 1 ) )
			{
				return 0;
			}
			double[] ValueSeries = EMASeries ( Close, Period );

			// First get an approximate value for deviation
			double deviation, range, totalRange, absDev;
			totalRange = 0;
			for ( int bar = EndBar - 9; bar <= EndBar; bar++ ) // last 10 days
			{
				range = Math.Abs ( Close[bar] - ValueSeries[bar] );
				totalRange = totalRange + range;
			}
			absDev = totalRange / 10; // Avg absolute deviation
			deviation = absDev / ValueSeries[EndBar];  // deviation as a fraction of ValueSeries

			// fit on last couple of months by iteration, to get a good value of deviation
			int countLoop, percentIn, totalIn;
			percentIn = 0;
			countLoop = 0;
			while ( ( countLoop < 200 ) && ( percentIn < CutOffPercent ) )
			{
				countLoop = countLoop + 1;
				totalIn = 0;
				for ( int bar = EndBar - LoopBackBar + 1; bar <= EndBar; bar++ )
				{
					if ( ( Close[bar] < ( ValueSeries[bar] * ( 1 + deviation ) ) ) &&
						 ( Close[bar] > ( ValueSeries[bar] * ( 1 - deviation ) ) )
						)
						totalIn = totalIn + 1;
				}
				percentIn = 100 * totalIn / LoopBackBar;
				if ( percentIn < CutOffPercent )
					deviation = deviation * 1.1;
				//Print( 'countLoop=' + AsString(CountLoop) + #9 + IntToStr(percentIn)
				//      + '  ' + IntToStr (totalIn) + '  ' + '   ' + floatToStr(deviation));printflush();
			}
			return deviation;
		}

		//--------------------------------------------------------------------------------------------
		public void GetElderChDevSeries ( int outSeries, int Period, int LoopBackBar, int CutOffPercent )
		{
			double[] NewSeries = new double[BarCount];
			for ( int i = 200; i < BarCount; i++ )
			{
				NewSeries[i] = GetElderChDeviation ( i, Period, LoopBackBar, CutOffPercent );
			}
			WL.PopulateSeries ( outSeries, ref NewSeries[0] );
		}
		//--------------------------------------------------------------------------------------------
		public double[] EMASeries ( double[] Series, int Period )
		{
			double c = 2.0 / (1.0+Period);
			double[] newSeries = new double[BarCount];
			newSeries[0] = Series[0];
			for ( int bar = 1; bar < BarCount; bar++ )
			{
				newSeries[bar] = c * Series[bar] + ( 1 - c ) * newSeries[bar - 1];
			}
			return newSeries;
		}
		//--------------------------------------------------------------------------------------------
		public void PerfTest1Test ( )
		{
			try
			{
				MessageBox.Show ( "PerfTest1 is working.", "PerfTest1" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
	}
}


