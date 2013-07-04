
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
#IncludeFile CSharpScripts\Include\Util.cs
#IncludeFile CSharpScripts\Include\Earning.cs 
#IncludeFile CSharpScripts\Include\FedResMeeting.cs
#IncludeFile CSharpScripts\Include\Macd.cs
#IncludeFile CSharpScripts\Include\Positions.cs
[/SCRIPT]*/

//#IncludeLibrary CSharpScripts\CoreLib\CoreLib.cs

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
        public void ScreenTwoDailyTest()
        {
            try
            {
                MessageBox.Show("ScreenTwoDaily is working. CurrDir = " + Environment.CurrentDirectory, "ScreenTwoDaily");
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message + "\r\n" + e.StackTrace);
            }

        }
        //____________________________________________________________________________________________
        //
        //--------------------------------------------------------------------------------------------
        public void ScreenTwoDailyInit(IWealthLabAddOn3 wl)
        {
            InternalLibInit(wl);
        }
        //____________________________________________________________________________________________
        //
        //--------------------------------------------------------------------------------------------
        public void ScreenTwoDaily_GetBasicSeries(int slowEmaSeries, int mainEmaSeries, int upperChannelSeries,
            int lowerChannelSeries, int channelWidthPercentSeries, ref string channelStr)
        {
            try
            {
                //
                // Calculate all series
                //
                Series slowEma = EMASeries(BarClose, 11);
                Series ema22 = EMASeries(BarClose, 22);
                Series mainEma = ema22; //SMASeries ( ema22, 5 );

                Series deviation, upperChannel, lowerChannel, channelWidthPercent;
                GetElderChDevSeries(mainEma, 22, 132, 90, out deviation,
                    out upperChannel, out lowerChannel, out channelWidthPercent);
                channelStr = String.Format("ChannelWidth ({0:G2}%):  {1:N2}",
                    channelWidthPercent[BarCount - 1],
                    (upperChannel[BarCount - 1] - lowerChannel[BarCount - 1]));

                //
                // Now populate all series
                //
                WL.PopulateSeries(slowEmaSeries, ref slowEma.Value[0]);
                WL.PopulateSeries(mainEmaSeries, ref mainEma.Value[0]);
                WL.PopulateSeries(upperChannelSeries, ref upperChannel.Value[0]);
                WL.PopulateSeries(lowerChannelSeries, ref lowerChannel.Value[0]);
                WL.PopulateSeries(channelWidthPercentSeries, ref channelWidthPercent.Value[0]);
            }
            catch (Exception e)
            {
                MessageBox.Show("Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
                    + e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetBasicSeries");
            }
        }
        //--------------------------------------------------------------------------------------------
        public void ScreenTwoDaily_GetStochSeries(int stochSlowSeries, int stochFastSeries)
        {
            try
            {
                Series stochSlow, stochFast;
                GetStochSeries(7, out stochSlow, out stochFast);

                WL.PopulateSeries(stochSlowSeries, ref stochSlow.Value[0]);
                WL.PopulateSeries(stochFastSeries, ref stochFast.Value[0]);
            }
            catch (Exception e)
            {
                MessageBox.Show("Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
                    + e.StackTrace, "Exception in MyScript.MyClass.ScreenTwoDaily_GetStochSeries");
            }
        }
    }
}


