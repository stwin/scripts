
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference Interop.TC2000Dev.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs
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
using System.Drawing;
using System.Globalization;

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
		public void ScreenOneWeeklyTest ( )
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
		public void ScreenOneWeeklyInit (String Symbol, IWealthLabAddOn3 wl )
		{
			InternalLibInit ( wl );
            wl.InstallPaintHook(new ScreenOneWeekly.PaintHook(this, Symbol));
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenOneWeekly_GetBasicSeries ( int slowEmaSeries, int mainEmaSeries, int upperChannelSeries,
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
				GetElderChDevSeries ( mainEma, 22, 66, 90, out deviation,
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
					+ e.StackTrace, "Exception in MyScript.MyClass.GetAllSeries" );
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ScreenOneWeekly_GetAllSeries2 ( int emaFastSeries, int emaSlowSeries,
			int upperSeries, int lowerSeries, int greenOpen, int greenHigh, int greenLow, int greenClose,
			int mmacd, int mmacdSignal, int mmacdh, int mmacdhColor, ref double macdOffset, ref string impulseStr)
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
	}

    //___________________________________________________________________________
    //___________________________________________________________________________
    public class ScreenOneWeekly
    {
        public class PaintHook : IWealthLabPaintHook3
        {
            enum Alignment { LEFT, CENTER, RIGHT };
            Brush whiteBrush = new SolidBrush(Color.White);
            Brush blackBrush = new SolidBrush(Color.Black);
            Pen blackPen = new Pen(Color.Black, 1);
            Font font = new System.Drawing.Font("Helvetica", 8, FontStyle.Regular);
            Font fontWlBold = new System.Drawing.Font("Helvetica", 9, FontStyle.Bold); // Need to find this correct font
            Font fontWlRegular = new System.Drawing.Font("Verdana", 9, FontStyle.Regular); // Need to find this correct font
            Font fontWlSmall = new System.Drawing.Font("Helvetica", 7, FontStyle.Regular);
            const int lineHeight = 14;
            const int boxX = 7;
            const int boxY = 40;
            const int totalLines = 5;
            const int boxHeight = totalLines * lineHeight;
            const int boxWidth = 120;

            MyClass myClass = null;

            // Fundamental Info 
            float epsPrctChange1stQtr, epsPrctChange2ndQtr, epsPrctChange3rdQtr, epsPrctChange4thQtr,
                    epsPrctChangeLatestYear, epsLatestQtr, earningGrothRate5Yr;
            string mcapStr, numSharesStr;
            string industrySubIndustryStr;
            string title;
            string memberShipStr;
            bool isStock;

            public PaintHook(MyClass myClass, string Symbol)
            {
                this.myClass = myClass;
                
                myClass.tc_getEarningData(Symbol, out epsPrctChange1stQtr, out epsPrctChange2ndQtr, out epsPrctChange3rdQtr,
                    out epsPrctChange4thQtr, out epsPrctChangeLatestYear, out epsLatestQtr, out earningGrothRate5Yr);
                
                // Capitalization && num of shares
                long mcap = (long)(1000000.0 * myClass.tc_getCapitalization(Symbol));
                double price = myClass.BarClose[myClass.BarCount - 1];
                long numShares = (long)(mcap / price);
                mcapStr = myClass.LongToHumanReadable(mcap);
                numSharesStr = myClass.LongToHumanReadable(numShares);

                industrySubIndustryStr = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(
                    myClass.tc_getIndustrySubIndustryString(Symbol).ToLower());
                title = Symbol + " (" + myClass.tc_getCompanyName(Symbol) + ") Weekly";

                memberShipStr = myClass.MembershipString(Symbol);

                isStock = myClass.tc_isStock(Symbol);
            }
            //___________________________________________________________________________
            public void Paint(int dc, int width, int height, int offset, int barSpacing,
                int top, int bottom, bool preBars, WealthLab.IWealthLabAddOn3 WL)
            {
                if (preBars)
                {
                    return;
                }
                // For indexes, we don't want to do anything
                if (!isStock)
                {
                    return;
                }

                Graphics g = Graphics.FromHdc((System.IntPtr)dc);

                int lineNumber = 0;
                int colBoxNum = 0;

                // Clear the rectangle for the two boxes and everything on the top-left corner
                g.FillRectangle(whiteBrush, 0, 0, boxX + boxWidth * 2, boxY + boxHeight);

                // industryp-subindustry
                SizeF sf = g.MeasureString(title, fontWlBold);
                SizeF sf2 = g.MeasureString(industrySubIndustryStr, fontWlBold);
                g.FillRectangle(whiteBrush, sf.Width + 30, 2, sf2.Width, sf2.Height);
                g.DrawString(industrySubIndustryStr, font, blackBrush, sf.Width + 30, 2);

                // Membership Info
                g.DrawString(memberShipStr, fontWlSmall, blackBrush, 80, 18);

                // Draw the boxes
                g.DrawRectangle(blackPen, boxX, boxY, boxWidth, boxHeight);
                g.DrawRectangle(blackPen, boxX + boxWidth, boxY, boxWidth, boxHeight);

                // First box 
                drawText(g, "LatestQtr", lineNumber, 0, Alignment.LEFT);
                drawText(g, "EPS % \u0394", lineNumber++, 0, Alignment.RIGHT);
                g.DrawLine(blackPen, boxX, boxY + lineHeight, boxX + boxWidth, boxY + lineHeight );

                drawText(g, "1st(Latest)", lineNumber, 0, Alignment.LEFT);
                drawText(g, epsPrctChange1stQtr + "%", lineNumber++, 0, Alignment.RIGHT);

                drawText(g, "2nd Lastest", lineNumber, 0, Alignment.LEFT);
                drawText(g, epsPrctChange2ndQtr + "%", lineNumber++, 0, Alignment.RIGHT);

                drawText(g, "3rd Latest", lineNumber, 0, Alignment.LEFT);
                drawText(g, epsPrctChange3rdQtr + "%", lineNumber++, 0, Alignment.RIGHT);

                drawText(g, "4th Latest", lineNumber, 0, Alignment.LEFT);
                drawText(g, epsPrctChange4thQtr + "%", lineNumber++, 0, Alignment.RIGHT);

                // Second box
                lineNumber = 0;
                colBoxNum = 1;
                drawText(g, "Mkt Cap", lineNumber, colBoxNum, Alignment.LEFT);
                drawText(g, mcapStr, lineNumber++, colBoxNum, Alignment.RIGHT);

                drawText(g, "Shares", lineNumber, colBoxNum, Alignment.LEFT);
                drawText(g, numSharesStr, lineNumber++, colBoxNum, Alignment.RIGHT);

                drawText(g, "EPS Lat.Qtr", lineNumber, colBoxNum, Alignment.LEFT);
                drawText(g, epsLatestQtr + "", lineNumber++, colBoxNum, Alignment.RIGHT);

                drawText(g, "EPS % \u0394 Yr", lineNumber, colBoxNum, Alignment.LEFT);
                drawText(g, epsPrctChangeLatestYear + "%", lineNumber++, colBoxNum, Alignment.RIGHT);

                drawText(g, "E.Growth 5yr", lineNumber, colBoxNum, Alignment.LEFT);
                drawText(g, earningGrothRate5Yr + "%", lineNumber++, colBoxNum, Alignment.RIGHT);

            }
            // aligned: -1 for left, 0 for center, 1 for right. 
            private void drawText(Graphics g, string text, int lineNumber, int colBoxNum, Alignment aligned)
            {
                int x = boxX + colBoxNum * boxWidth;
                int y = boxY + lineNumber * lineHeight;
                SizeF sf = g.MeasureString(text, font);
                switch (aligned)
                {
                    case Alignment.LEFT:
                        break;
                    case Alignment.CENTER:
                        x = (int)(x + boxWidth / 2 - sf.Width / 2);
                        break;
                    case Alignment.RIGHT:
                        x = (int)(x + boxWidth - sf.Width);
                        break;
                }
                g.DrawString(text, font, blackBrush, x, y);
            }
        }
    }
}


