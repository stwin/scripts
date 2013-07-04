
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs
#IncludeFile CSharpScripts\Include\FedResMeeting.cs
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
		public void ElderTest ( )
		{
			try
			{
				MessageBox.Show ( "PlayingAroundACorePosition is working. CurrDir = " + Environment.CurrentDirectory, "PlayingAroundACorePosition" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ElderInit ( IWealthLabAddOn3 wl )
        {
			InternalLibInit ( wl );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void Elder_GetAllSeries ( object SeriesHandles )
		{
			try
			{
				Elder_GetAllSeries_Internal ( SeriesHandles );
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
		public void Elder_GetAllSeries_Internal ( object SeriesHandlesObject )
		{
			//
			// Dirty works first
			//
			object[] SeriesHandlesObjArr = (object[]) SeriesHandlesObject;
			int arrSize = SeriesHandlesObjArr.Length;
			int[] SeriesHandles = new int[arrSize];
			for ( int i = 0; i < arrSize; i++ )
			{
				SeriesHandles[i] = (int) SeriesHandlesObjArr[i];
			}

			//
			// Get all the series handles
			//
			int mainEmaSeries = (int) SeriesHandles[0];
			int upperChannelSeries = (int) SeriesHandles[1];
			int lowerChannelSeries = (int)  SeriesHandles[2];
			int channelWidthPercentSeries = (int)  SeriesHandles[3];
			int macdSeries = (int)  SeriesHandles[4];
			int macdSignalSeries = (int)  SeriesHandles[5];
			int macdHistogramSeries = (int)  SeriesHandles[6];
			int stochSlowSeries = (int)  SeriesHandles[7];
			int stochFastSeries = (int)  SeriesHandles[8];

			//
			// Calculate all series
			//
			Series ema22 = EMASeries ( BarClose, 22 );
			Series mainEma = ema22 ; //SMASeries ( ema22, 5 );

			Series deviation, upperChannel, lowerChannel, channelWidthPercent;
			GetElderChDevSeries ( mainEma, 22, 132, 90, out deviation,
				out upperChannel, out lowerChannel, out channelWidthPercent  );

			Series macd, macdSignal, macdHistogram;
			GetMacdSeries ( out macd, out macdSignal, out macdHistogram );

			Series stochSlow, stochFast;
			GetStochSeries ( 7, out stochSlow, out stochFast );

			//
			// Now populate all series
			//
			WL.PopulateSeries ( mainEmaSeries, ref mainEma.Value[0] );
			WL.PopulateSeries ( upperChannelSeries, ref upperChannel.Value[0] );
			WL.PopulateSeries ( lowerChannelSeries, ref lowerChannel.Value[0] );
			WL.PopulateSeries ( channelWidthPercentSeries, ref channelWidthPercent.Value[0] );
			WL.PopulateSeries ( macdSeries, ref macd.Value[0] );
			WL.PopulateSeries ( macdSignalSeries, ref macdSignal.Value[0] );
			WL.PopulateSeries ( macdHistogramSeries, ref macdHistogram.Value[0] );
			WL.PopulateSeries ( stochSlowSeries, ref stochSlow.Value[0] );
			WL.PopulateSeries ( stochFastSeries, ref stochFast.Value[0] );
		}
	}
}


