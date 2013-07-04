using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;

using MyScript;
using WealthLab;
using MyScript.Adapters;

namespace WL_CSharp_Tester
{
    class Program
    {
        //-----------------------------------------------------------------------------------------------
        static void Main(string[] args)
        {
            Console.WriteLine("Working...");

            Console.WriteLine("Press enter to exit...");
            Console.ReadLine();
        }
        //-----------------------------------------------------------------------------------------------
        public static void test1()
        {
            WealthLabAddOn3 wl3 = new WealthLabAddOn3();
            MyClass myclass = new MyClass();
            string test = myclass.BasicFundamentalString("AAPL");

            myclass.InternalLibInit(wl3);


            Series s = myclass.StochDSeries(7, 3);
            double[] s0 = new double[wl3.BarCount()];
            wl3.Indicators.Add(s0);
            string str = myclass.GetDayStr(13);

            int bar = myclass.DateToBar(DateTime.Parse("3/4/2002"));
            Console.WriteLine("" + bar);
            bar = myclass.DateToBar(new DateTime(2002, 3, 1));
            Console.WriteLine("" + bar);
        }
        //-----------------------------------------------------------------------------------------------
        static void YahooRealDataTest()
        {
            Yahoo.RealData rd = new Yahoo.RealData();
            String sec = rd.GetSecurityName("MSFT");
            rd.OpenRequest("^NSEI", 50, BarIntervalEnum.biDaily, 0, false,
                        DateTime.Now, DateTime.Now, null, null);

            //Console.WriteLine (String.Format ("+{0:00}-\n", 255));

            Console.WriteLine("\nPress ENTER to exit...");
            Console.ReadLine();
        }
        //-----------------------------------------------------------------------------------------------
        public static void PlayingAroundACorePosition_Test()
        {
            /*
            WealthLabAddOn3 wl3 = new WealthLabAddOn3 ( );
            MyClass myclass = new MyClass ( );

            myclass.PlayingAroundACorePositionInit ( wl3 );
            double[] s0 = new double[wl3.BarCount ( )];
            double[] s1 = new double[wl3.BarCount ( )];
            double[] s2 = new double[wl3.BarCount ( )];
            double[] s3 = new double[wl3.BarCount ( )];
            double[] s4 = new double[wl3.BarCount ( )];
            double[] s5 = new double[wl3.BarCount ( )];
            double[] s6 = new double[wl3.BarCount ( )];
            double[] s7 = new double[wl3.BarCount ( )];
            double[] s8 = new double[wl3.BarCount ( )];
            wl3.Indicators.Add ( s0 );
            wl3.Indicators.Add ( s1 );
            wl3.Indicators.Add ( s2 );
            wl3.Indicators.Add ( s3 );
            wl3.Indicators.Add ( s4 );
            wl3.Indicators.Add ( s5 );
            wl3.Indicators.Add ( s6 );
            wl3.Indicators.Add ( s7 );
            wl3.Indicators.Add ( s8 );
            Object[] seriesObj = new Object[wl3.Indicators.Count];
            for ( int i = 0; i < wl3.Indicators.Count; i++ )
                seriesObj[i] = (Object) i;

            myclass.GetAllSeries ( seriesObj );
             */
        }
        //-----------------------------------------------------------------------------------------------
        public static void NHNLViewer_Test()
        {
            /*
            WealthLabAddOn3 wl3 = new WealthLabAddOn3 ( );
            MyClass myclass = new MyClass ( );
			
            myclass.NHNLViewerInit ( wl3 );
            myclass.MoreInfo ( 10, @"D:\WLE" );
			
            double[] s0 = new double[wl3.BarCount()];
            double[] s1 = new double[wl3.BarCount()];
            double[] s2 = new double[wl3.BarCount()];
            wl3.Indicators.Add ( s0 );
            wl3.Indicators.Add ( s1 );
            wl3.Indicators.Add ( s2 );
            Object[] seriesObj = new Object[wl3.Indicators.Count];
            for ( int i = 0; i < wl3.Indicators.Count; i++ )
                seriesObj[i] = (Object) i;

            myclass.GetAllSeries ( seriesObj );
            */
        }
        //-----------------------------------------------------------------------------------------------
        public static void test3()
        {
            WealthLab.WL3 wl = new WealthLab.WL3();
            Console.WriteLine("WL3 initializging");
            wl.ExecuteScript("PlayingAroundACorePosition", "A1-Blue Chips", "AA");
            wl.ExecuteScript("Elder", "", "AA");
        }

    }
}
