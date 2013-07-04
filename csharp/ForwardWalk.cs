
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs
#IncludeFile CSharpScripts\Include\FedResMeeting.cs
#IncludeFile CSharpScripts\Include\Macd.cs
[/SCRIPT]*/



using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Drawing;

using WealthLab;


namespace MyScript
{
    public partial class MyClass
    {
		ForwardWalk ForwardWalk = null;
		public Series slowEma = null;
		public Series mainEma = null;

		public Series deviation = null, upperChannel = null, lowerChannel = null, channelWidthPercent = null;

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void ForwardWalkTest ( )
		{
			try
			{
				MessageBox.Show ( "ForwardWalk is working. CurrDir = " + Environment.CurrentDirectory, "ForwardWalk" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ForwardWalkInit ( IWealthLabAddOn3 wl )
        {
			InternalLibInit ( wl );
			ForwardWalk = new ForwardWalk ( this );
			wl.InstallPaintHook ( ForwardWalk );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ForwardWalk_GetBasicSeries ( int slowEmaSeries, int mainEmaSeries, int upperChannelSeries,
			int lowerChannelSeries, int channelWidthPercentSeries )
		{
			try
			{
				//
				// Calculate all series
				//
				slowEma = EMASeries ( BarClose, 11 );
				Series ema22 = EMASeries ( BarClose, 22 );
				mainEma = ema22; //SMASeries ( ema22, 5 );

				GetElderChDevSeries ( mainEma, 22, 132, 90, out deviation,
					out upperChannel, out lowerChannel, out channelWidthPercent );

				//
				// Now populate all series
				//
				WL.PopulateSeries ( slowEmaSeries, ref slowEma.Value[0] );
				WL.PopulateSeries ( mainEmaSeries, ref mainEma.Value[0] );
				WL.PopulateSeries ( upperChannelSeries, ref upperChannel.Value[0] );
				WL.PopulateSeries ( lowerChannelSeries, ref lowerChannel.Value[0] );
				WL.PopulateSeries ( channelWidthPercentSeries, ref channelWidthPercent.Value[0] );
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
		public void ForwardWalk_GetStochSeries ( int stochSlowSeries, int stochFastSeries )
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
	}

	//____________________________________________________________________________________________
	//
	//--------------------------------------------------------------------------------------------
	public class ForwardWalk : IWealthLabPaintHook3
	{
		MyClass MyClass;
		bool SkipTimeDisplay = false;

		// For drawings
		Font Font7 = new Font ( "Verdana", 7 );
		Font Font8 = new Font ( "Verdana", 8 );
		Font Font10 = new Font ( "Arial", 10 );
		SolidBrush BlackBrush = new SolidBrush ( Color.Black );
		SolidBrush TextBrush1 = new SolidBrush ( Color.FromArgb ( 50, 50, 150 ) );
		SolidBrush SemiTransparentWhiteBrush = new SolidBrush ( Color.FromArgb ( 180, Color.White ) );
		Pen CyanPen = new Pen ( Color.Cyan );
		float LabelY = 38;

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public ForwardWalk ( MyClass MyClass )
		{
			this.MyClass = MyClass;
			if ( MyClass.BarCount >= 20 )
			{
				TimeSpan ts = MyClass.BarDate[MyClass.BarCount - 1] - MyClass.BarDate[MyClass.BarCount - 20];
				if ( ts.Days > 19 )
				{
					SkipTimeDisplay = true;
				}
			}
		}
		//_____________________________________________________________________________
		/// <summary>
		/// Used Internally. Paints the chart.
		/// </summary>
		//-----------------------------------------------------------------------------
		public void Paint ( int DC, int Width, int Height, int Offset, int BarSpacing,
			int Top, int Bottom, bool PreBars, IWealthLabAddOn3 WLAddOn3 )
		{
			//MyClass.Print ( "Paint called PreBars = " + PreBars );
			//MyClass.Print ( "DC={6}, Width={0}, Height={1}, Offset={2}, BarSpacing={3}, Top={4}, Bottom={5}",
			//	Width, Height, Offset, BarSpacing, Top, Bottom, DC );
			
			Graphics g = Graphics.FromHdc ( (System.IntPtr) DC );
			LabelY = 38;
			if ( PreBars == false )
			{
				SizeF size;

				//Right Bar 
				int numBars = ( Width + BarSpacing -1 ) / BarSpacing;
				int rightBar = Offset + numBars - 1;
				if ( rightBar >= MyClass.BarCount )
				{
					rightBar = MyClass.BarCount-1;
				}
				int numVisibleBars = Width / BarSpacing - 1;
				if ( numVisibleBars < 1 )
				{
					numVisibleBars = 1;
				}

				// Left Bar 
				int leftBar = rightBar - numVisibleBars + 1;
				if ( leftBar < 0 )
				{
					leftBar = 0;
				}

				// Display Left Bar String and Right Bar String
				string leftBarString, rightBarString;

				if ( SkipTimeDisplay )
				{
					leftBarString = String.Format ( "{1}", leftBar,
						MyClass.BarDate[leftBar].ToString ( "M/d/yyyy  ddd" ) );
					rightBarString = String.Format ( "{1}", rightBar,
						MyClass.BarDate[rightBar].ToString ( "M/d/yyyy  ddd" ) );
				}
				else
				{
					leftBarString = String.Format ( "{1}", leftBar,
						MyClass.BarDate[leftBar].ToString ( "MM/dd/yy  HH:mm  ddd" ) );
					rightBarString = String.Format ( "{1}", rightBar,
						MyClass.BarDate[rightBar].ToString ( "MM/dd/yy  HH:mm  ddd" ) );
				}

				size = g.MeasureString ( leftBarString, Font7 );
				g.FillRectangle ( SemiTransparentWhiteBrush, 2, Bottom - size.Height, size.Width, size.Height );
				g.DrawString ( leftBarString, Font7, TextBrush1, 2, Bottom - size.Height );

				size = g.MeasureString ( rightBarString, Font7 );
				g.FillRectangle ( SemiTransparentWhiteBrush, Width-size.Width, Top, size.Width, size.Height );
				g.DrawString ( rightBarString, Font7, TextBrush1, Width - size.Width, Top );


				// Percent Change For Last 5Bars
				AddLabel ( g, Top, GetStrPercentChangeForLast5Bars ( rightBar ) );

				// Channel String		
				String channelStr = String.Format ( "ChannelWidth ({0:G2}%):  {1:N2}",
					MyClass.channelWidthPercent[rightBar],
					( MyClass.upperChannel[rightBar] - MyClass.lowerChannel[rightBar] ) );
				AddLabel ( g, Top, channelStr );

				// OHLC String
				String ohlcString = String.Format ( "(OHLC): {0}, {1}, {2}, {3}",
					Math.Round ( MyClass.BarOpen[rightBar], 2 ),
					Math.Round ( MyClass.BarHigh[rightBar], 2 ),
					Math.Round ( MyClass.BarLow[rightBar], 2 ),
					Math.Round ( MyClass.BarClose[rightBar], 2 ) );
				AddLabel ( g, Top, ohlcString );

				// Earning String
				/*
				var EarningSeries: integer = CreateSeries;
var EarningStr: string;
var EarningStrColor: integer;
myclass.GetEarningSeriesDaily ( GetSymbol, EarningSeries, EarningStr, EarningStrColor );
for bar := 0 to BarCount-1 do
  if ( @EarningSeries[bar] > 0.5 )  then
    DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
DrawText( EarningStr, 0, 7, myDrawLabelX, EarningStrColor, 10 ); myDrawLabelX := myDrawLabelX + 15;
*/
			}
			g.Dispose ( );
		}

		//___________________________________________________________________________
		// Display Percent Changes for Last 5 Bars
		//---------------------------------------------------------------------------
		public void AddLabel ( Graphics g, int Top, string str )
		{
			SizeF size;
			size = g.MeasureString ( str, Font10 );
			g.FillRectangle ( SemiTransparentWhiteBrush, 7, Top + LabelY, size.Width, size.Height );
			g.DrawString ( str, Font10, BlackBrush, 7, Top + LabelY );
			LabelY += size.Height;
		}
		//___________________________________________________________________________
		// Display Percent Changes for Last 5 Bars
		//---------------------------------------------------------------------------
		public string GetStrPercentChangeForLast5Bars ( int Bar )
		{
			string text;
			bool firstTime = true;

			text = "Change(%): ";

			int startBar = Math.Max ( 1, Bar - 5 );
			for ( int count = startBar; count < Bar; count++ )
			{
				double val = 100 * ( MyClass.BarClose[count] - MyClass.BarClose[count - 1] ) / MyClass.BarClose[count - 1];
				if ( firstTime )
				{
					text += String.Format ( " {0}", Math.Round ( val, 2 ) );
					firstTime = false;
				}
				else
				{
					text += String.Format ( ", {0}", Math.Round ( val, 2 ) );
				}
			}
			return text;

		}
		
	}
}


