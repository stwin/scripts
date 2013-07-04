
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
[/SCRIPT]*/

//____________________________________________________________________________________________
//____________________________________________________________________________________________
//_________________________   S T A N D A R D   T A   L I B R A R Y   ________________________
//____________________________________________________________________________________________
//
// This file implements all the standard APIs available in a good trading software
//

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Drawing;

using WealthLab;
using WLE;


namespace MyScript
{
    partial class MyClass
    {

        public IWealthLabAddOn3 WL = null;

        public int BarCount = 0;

        public DateTime[] BarDate = null;
        public Dictionary<DateTime, int> DateLookup = null;

        public Series BarOpen = null;
        public Series BarHigh = null;
        public Series BarLow = null;
        public Series BarClose = null;
        public Series BarVolume = null;


        // Primary Symbol copies

        public int PrimaryBarCount = 0;

        public DateTime[] PrimaryBarDate = null;
        public Dictionary<DateTime, int> PrimaryDateLookup = null;

        public Series PrimaryBarOpen = null;
        public Series PrimaryBarHigh = null;
        public Series PrimaryBarLow = null;
        public Series PrimaryBarClose = null;
        public Series PrimaryBarVolume = null;


        //_____________________________________________________________________________
        /// <summary>
        /// Method to test this libary.
        /// </summary>
        //-----------------------------------------------------------------------------
        public void StdLibTest()
        {
            try
            {
                MessageBox.Show("StdLib is working. CurrDir = " + Environment.CurrentDirectory, "StdLib");

            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message + "\r\n" + e.StackTrace);
            }

        }
        //____________________________________________________________________________________________
        // Initialization
        //--------------------------------------------------------------------------------------------
        public void StdLibInit(IWealthLabAddOn3 wl)
        {
            try
            {
                WL = wl;

                BarCount = WL.BarCount();

                BarDate = new DateTime[BarCount];
                BarOpen = new Series(BarCount);
                BarHigh = new Series(BarCount);
                BarLow = new Series(BarCount);
                BarClose = new Series(BarCount);
                BarVolume = new Series(BarCount);

                DateLookup = new Dictionary<DateTime, int>(BarCount);

                for (int i = 0; i < BarCount; i++)
                {
                    BarDate[i] = WL.Date(i);
                    BarOpen[i] = WL.PriceOpen(i);
                    BarHigh[i] = WL.PriceHigh(i);
                    BarLow[i] = WL.PriceLow(i);
                    BarClose[i] = WL.PriceClose(i);
                    BarVolume[i] = WL.Volume(i);
                    DateLookup.Add(BarDate[i], i);
                }

                // Saved primary series

                PrimaryBarCount = BarCount;

                PrimaryBarDate = BarDate;
                PrimaryDateLookup = DateLookup;

                PrimaryBarOpen = BarOpen;
                PrimaryBarHigh = BarHigh;
                PrimaryBarLow = BarLow;
                PrimaryBarClose = BarClose;
                PrimaryBarVolume = BarVolume;
            }
            catch (Exception e)
            {
                MessageBox.Show("Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
                    + e.StackTrace, "Exception in MyScript.MyClass.GetAllSeries");
            }
        }
        //_____________________________________________________________________________
        //_____________________________________________________________________________
        //
        // MISC METHODS
        //_____________________________________________________________________________
        //
        //_____________________________________________________________________________
        /// <summary>
        /// Prints in the debug window.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual void Print(string Format, params object[] args)
        {
            CSharp.Print(Format, args);
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Prints in the debug window.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual void PrintStatus(string Format, params object[] args)
        {
            CSharp.PrintStatus(Format, args);
        }
        //_____________________________________________________________________________
        /// <summary>
        /// SetSynchedPrimarySeries.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual bool SetPrimarySeries(bool ShouldSync)
        {
            if (ShouldSync)
            {
                int NewBarCount = WL.BarCount();
                if (BarCount != NewBarCount)
                {
                    MessageBox.Show("NewBarCount is not equal to BarCount. The series does not seem to be synched.",
                        "Error: SetSynchedPrimarySeries");
                    return false;
                }

                BarOpen = new Series(BarCount);
                BarHigh = new Series(BarCount);
                BarLow = new Series(BarCount);
                BarClose = new Series(BarCount);
                BarVolume = new Series(BarCount);

                for (int i = 0; i < BarCount; i++)
                {
                    BarOpen[i] = WL.PriceOpen(i);
                    BarHigh[i] = WL.PriceHigh(i);
                    BarLow[i] = WL.PriceLow(i);
                    BarClose[i] = WL.PriceClose(i);
                    BarVolume[i] = WL.Volume(i);
                }
            }
            else
            {
                BarCount = WL.BarCount();

                BarDate = new DateTime[BarCount];
                BarOpen = new Series(BarCount);
                BarHigh = new Series(BarCount);
                BarLow = new Series(BarCount);
                BarClose = new Series(BarCount);
                BarVolume = new Series(BarCount);

                DateLookup = new Dictionary<DateTime, int>(BarCount);

                for (int i = 0; i < BarCount; i++)
                {
                    BarDate[i] = WL.Date(i);
                    BarOpen[i] = WL.PriceOpen(i);
                    BarHigh[i] = WL.PriceHigh(i);
                    BarLow[i] = WL.PriceLow(i);
                    BarClose[i] = WL.PriceClose(i);
                    BarVolume[i] = WL.Volume(i);
                    DateLookup.Add(BarDate[i], i);
                }
            }

            return true;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// RestorePrimarySeries.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual bool RestorePrimarySeries()
        {
            BarCount = PrimaryBarCount;

            BarDate = PrimaryBarDate;
            DateLookup = PrimaryDateLookup;

            BarOpen = PrimaryBarOpen;
            BarHigh = PrimaryBarHigh;
            BarLow = PrimaryBarLow;
            BarClose = PrimaryBarClose;
            BarVolume = PrimaryBarVolume;

            return true;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// DateToBar
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual int DateToBar(DateTime dt)
        {
            int bar;
            if (!DateLookup.TryGetValue(dt, out bar))
            {
                bar = -1;
            }
            return bar;
        }
        //____________________________________________________________________________________________
        /// <summary>
        /// Gets the token from a string.
        /// </summary>
        //--------------------------------------------------------------------------------------------
        public string GetToken(string Str, int Index, string Separators)
        {
            string[] tokens = Str.Split(Separators.ToCharArray());
            if (Index < tokens.Length)
            {
                return tokens[Index];
            }
            return null;
        }
        //_____________________________________________________________________________
        //_____________________________________________________________________________
        //
        // METHODS TO MANIPULATE PRICE SERIES
        //_____________________________________________________________________________
        //
        //_____________________________________________________________________________
        /// <summary>
        /// Create a series.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series CreateSeries()
        {
            Series s = new Series(BarCount);

            // TODO - Do we actually need to initialize an array? Isn't it already initialized?
            for (int i = 0; i < s.Value.Length; i++)
            {
                s.Value[i] = 0;
            }
            return s;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Create a series.
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series CreateZeroSeries()
        {
            Series s = CreateSeries();
            return s;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Adds two series
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series AddSeries(Series s1, Series s2)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries[i] = s1.Value[i] + s2.Value[i];
            }
            return NewSeries;
        }

        //_____________________________________________________________________________
        /// <summary>
        /// Subtracts a value from a series
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series AddSeriesValue(Series s1, double Value)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = s1.Value[i] + Value;
            }
            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Multiply two series
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series MultiplySeries(Series s1, Series s2)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = s1.Value[i] * s2.Value[i];
            }
            return NewSeries;
        }

        //_____________________________________________________________________________
        /// <summary>
        /// Multiply a series and a value
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series MultiplySeriesValue(Series s1, double Value)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = s1.Value[i] * Value;
            }
            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Subtracts on series from other
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series SubtractSeries(Series s1, Series s2)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = s1.Value[i] - s2.Value[i];
            }
            return NewSeries;
        }

        //_____________________________________________________________________________
        /// <summary>
        /// Subtracts a value from a series
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series SubtractSeriesValue(Series s1, double Value)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = s1.Value[i] - Value;
            }
            return NewSeries;
        }

        //_____________________________________________________________________________
        /// <summary>
        /// Subtracts a series from a value
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series SubtractValueSeries(double Value, Series s1)
        {
            Series NewSeries = CreateSeries();
            for (int i = 0; i < BarCount; i++)
            {
                NewSeries.Value[i] = Value - s1.Value[i];
            }
            return NewSeries;
        }

        //_____________________________________________________________________________
        //_____________________________________________________________________________
        //
        // METHODS TO CALCULATE TECHNICAL INDICATORS
        //_____________________________________________________________________________
        //

        //_____________________________________________________________________________
        /// <summary>
        /// EMASeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public Series EMASeries(Series Series, int Period)
        {
            Series newSeries = CreateSeries();
            double c = 2.0 / (1.0 + Period);

            // Calculate now
            newSeries[0] = Series[0];
            for (int bar = 1; bar < BarCount; bar++)
            {
                newSeries[bar] = c * Series[bar] + (1 - c) * newSeries[bar - 1];
            }

            return newSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// SMASeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series SMASeries(Series s, int Period)
        {
            Series NewSeries = CreateSeries();

            // If BarCount is less than Period, then reset the Period to that 
            if (BarCount < Period)
            {
                Period = BarCount;
            }

            double total = 0.0;
            for (int i = 0; i < Period; i++)
            {
                total += s[i];
            }

            // Calculate now
            NewSeries[Period - 1] = total / Period;
            for (int i = Period; i < BarCount; i++)
            {
                total = total + s[i] - s[i - Period];
                NewSeries[i] = total / Period;
            }

            // Initialize the first few bars which have 0 value
            for (int i = 0; i < Period - 1; i++)
            {
                NewSeries[i] = NewSeries[Period - 1];
            }

            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// MACDSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series MACDSeries(Series s)
        {
            int Period1 = 12;
            int Period2 = 26;
            Series ema1 = EMASeries(s, Period1);
            Series ema2 = EMASeries(s, Period2);
            Series NewSeries = SubtractSeries(ema1, ema2);
            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// StochDSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series StochDSeries(int Period, int Smooth)
        {
            Series NewSeries = CreateSeries();

            if (Smooth > BarCount)
            {
                return NewSeries;
            }

            Series highestSeries = HighestSeries(BarHigh, Period);
            Series lowestSeries = LowestSeries(BarLow, Period);
            for (int i = Smooth - 1; i < BarCount; i++)
            {
                double strength = 0;
                double priceRange = 0;
                for (int j = 0; j < Smooth; j++)
                {
                    strength += BarClose[i - j] - lowestSeries[i - j];
                    priceRange += highestSeries[i - j] - lowestSeries[i - j];
                }
                if (priceRange != 0)
                {
                    NewSeries[i] = 100 * strength / priceRange;
                }
                else
                {
                    NewSeries[i] = 0;
                }
            }
            // Initialize initial values also
            for (int i = 0; i <= Smooth - 2; i++)
            {
                NewSeries[i] = NewSeries[Smooth - 1];
            }
            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// StochKSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series StochKSeries(int Period)
        {
            Series NewSeries = new Series(BarCount);
            Series highestSeries = HighestSeries(BarHigh, Period);
            Series lowestSeries = LowestSeries(BarLow, Period);
            for (int i = 0; i < BarCount; i++)
            {
                double strength = BarClose[i] - lowestSeries[i];
                double priceRange = highestSeries[i] - lowestSeries[i];
                if (priceRange != 0)
                {
                    NewSeries[i] = 100 * strength / priceRange;
                }
                else
                {
                    NewSeries[i] = 0;
                }
            }
            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// HighestSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series HighestSeries(Series s, int Period)
        {
            // If BarCount is less than Period, then reset the Period to that 
            if (BarCount < Period)
            {
                Period = BarCount;
            }

            Series NewSeries = CreateSeries();

            int highBar = 0;
            double highPrice = s[0];
            NewSeries[0] = s[0];
            for (int i = 1; i < Period; i++)
            {
                if (highPrice <= s[i])   // <= instead of < intentional
                {
                    highPrice = s[i];
                    highBar = i;
                }
                NewSeries[i] = highPrice;
            }

            // Calculate now
            for (int i = Period; i < BarCount; i++)
            {
                int oldBar = i - Period;
                if (oldBar == highBar) // The high bar is disappearing
                {
                    // We need to calculate all over again
                    highBar = oldBar + 1;
                    highPrice = s[oldBar + 1];
                    for (int bar = oldBar + 2; bar <= i; bar++)
                    {
                        if (highPrice <= s[bar])  // <= instead of < intentional
                        {
                            highPrice = s[bar];
                            highBar = bar;
                        }
                    }
                }
                else  // the high bar is in-between
                {
                    if (highPrice <= s[i]) // compare current high bar with the new bar
                    {
                        highPrice = s[i];
                        highBar = i;
                    }
                }
                NewSeries[i] = highPrice;
            }

            return NewSeries;
        }

        //_____________________________________________________________________________
        /// <summary>
        /// HighestBarSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series HighestBarSeries(Series s, int Period)
        {
            // If BarCount is less than Period, then reset the Period to that 
            if (BarCount < Period)
            {
                Period = BarCount;
            }

            Series NewSeries = CreateSeries();

            int highBar = 0;
            double highPrice = s[0];
            NewSeries[0] = 0;
            for (int i = 1; i < Period; i++)
            {
                if (highPrice <= s[i])   // <= instead of < intentional
                {
                    highPrice = s[i];
                    highBar = i;
                }
                NewSeries[i] = highBar;
            }

            // Calculate now
            for (int i = Period; i < BarCount; i++)
            {
                int oldBar = i - Period;
                if (oldBar == highBar) // The high bar is disappearing
                {
                    // We need to calculate all over again
                    highBar = oldBar + 1;
                    highPrice = s[oldBar + 1];
                    for (int bar = oldBar + 2; bar <= i; bar++)
                    {
                        if (highPrice <= s[bar])  // <= instead of < intentional
                        {
                            highPrice = s[bar];
                            highBar = bar;
                        }
                    }
                }
                else  // the high bar is in-between
                {
                    if (highPrice <= s[i]) // compare current high bar with the new bar
                    {
                        highPrice = s[i];
                        highBar = i;
                    }
                }
                NewSeries[i] = highBar;
            }

            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// LowestSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series LowestSeries(Series s, int Period)
        {
            // If BarCount is less than Period, then reset the Period to that 
            if (BarCount < Period)
            {
                Period = BarCount;
            }

            Series NewSeries = CreateSeries();

            int lowBar = 0;
            double lowPrice = s[0];
            NewSeries[0] = s[0];
            for (int i = 1; i < Period; i++)
            {
                if (lowPrice >= s[i])     // >= instead of > intentional
                {
                    lowPrice = s[i];
                    lowBar = i;
                }
                NewSeries[i] = lowPrice;
            }

            // Calculate now
            for (int i = Period; i < BarCount; i++)
            {
                int oldBar = i - Period;
                if (oldBar == lowBar) // The low bar is disappearing
                {
                    // We need to calculate all over again
                    lowBar = oldBar + 1;
                    lowPrice = s[oldBar + 1];
                    for (int bar = oldBar + 2; bar <= i; bar++)
                    {
                        if (lowPrice >= s[bar])     // >= instead of > intentional
                        {
                            lowPrice = s[bar];
                            lowBar = bar;
                        }
                    }
                }
                else  // the low bar is in-between
                {
                    if (lowPrice >= s[i]) // compare current low bar with the new bar
                    {
                        lowPrice = s[i];
                        lowBar = i;
                    }
                }
                NewSeries[i] = lowPrice;
            }

            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// LowestBarSeries
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual Series LowestBarSeries(Series s, int Period)
        {
            // If BarCount is less than Period, then reset the Period to that 
            if (BarCount < Period)
            {
                Period = BarCount;
            }

            Series NewSeries = CreateSeries();

            int lowBar = 0;
            double lowPrice = s[0];
            NewSeries[0] = 0;
            for (int i = 1; i < Period; i++)
            {
                if (lowPrice >= s[i])     // >= instead of > intentional
                {
                    lowPrice = s[i];
                    lowBar = i;
                }
                NewSeries[i] = lowBar;
            }

            // Calculate now
            for (int i = Period; i < BarCount; i++)
            {
                int oldBar = i - Period;
                if (oldBar == lowBar) // The low bar is disappearing
                {
                    // We need to calculate all over again
                    lowBar = oldBar + 1;
                    lowPrice = s[oldBar + 1];
                    for (int bar = oldBar + 2; bar <= i; bar++)
                    {
                        if (lowPrice >= s[bar])     // >= instead of > intentional
                        {
                            lowPrice = s[bar];
                            lowBar = bar;
                        }
                    }
                }
                else  // the low bar is in-between
                {
                    if (lowPrice >= s[i]) // compare current low bar with the new bar
                    {
                        lowPrice = s[i];
                        lowBar = i;
                    }
                }
                NewSeries[i] = lowBar;
            }

            return NewSeries;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Highest 
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual double Highest(int Bar, Series s, int Period)
        {
            int startBar = Bar - Period + 1;
            if (startBar < 0)
            {
                startBar = 0;
            }

            double highest = s[startBar];

            for (int i = startBar + 1; i <= Bar; i++)
            {
                if (s[i] >= highest)
                {
                    highest = s[i];
                }
            }

            return highest;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// HighestBar 
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual int HighestBar(int Bar, Series s, int Period)
        {
            int startBar = Bar - Period + 1;
            if (startBar < 0)
            {
                startBar = 0;
            }

            double highest = s[startBar];
            int highestBar = startBar;

            for (int i = startBar + 1; i <= Bar; i++)
            {
                if (s[i] >= highest)
                {
                    highest = s[i];
                    highestBar = i;
                }
            }

            return highestBar;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Lowest 
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual double Lowest(int Bar, Series s, int Period)
        {
            int startBar = Bar - Period + 1;
            if (startBar < 0)
            {
                startBar = 0;
            }

            double lowest = s[startBar];

            for (int i = startBar + 1; i <= Bar; i++)
            {
                if (s[i] <= lowest)
                {
                    lowest = s[i];
                }
            }

            return lowest;
        }
        //_____________________________________________________________________________
        /// <summary>
        /// Lowestbar 
        /// </summary>
        //-----------------------------------------------------------------------------
        public virtual int Lowestbar(int Bar, Series s, int Period)
        {
            int startBar = Bar - Period + 1;
            if (startBar < 0)
            {
                startBar = 0;
            }

            double lowest = s[startBar];
            int lowestBar = startBar;

            for (int i = startBar + 1; i <= Bar; i++)
            {
                if (s[i] <= lowest)
                {
                    lowest = s[i];
                    lowestBar = i;
                }
            }

            return lowestBar;
        }
        //____________________________________________________________________________________________
        //
        //--------------------------------------------------------------------------------------------
    }
    //____________________________________________________________________________________________
    //____________________________________________________________________________________________
    //_________________________      S E R I E S  -  C L A S S     _______________________________
    //____________________________________________________________________________________________
    //____________________________________________________________________________________________
    //
    // This class is not yet complete. I
    //
    public class Series
    {
        public string Name;
        public double[] Value;

        public int Style = -1;
        public int Color = -1;  // Color for all bars
        public int[] BarColor = null;		// Specify color for individual bars
        public int StartBar;
        public int EndBar;

        //_____________________________________________________________________________
        // Indexer
        //-----------------------------------------------------------------------------
        public double this[int index]
        {
            get { return Value[index]; }
            set { Value[index] = value; }
        }
        //_____________________________________________________________________________
        // Constructor
        //-----------------------------------------------------------------------------
        public Series(int Size)
        {
            this.Name = "";
            Value = new double[Size];
        }
        //_____________________________________________________________________________
        // Constructor
        //-----------------------------------------------------------------------------
        public Series(string Name, int Size)
        {
            this.Name = Name;
            Value = new double[Size];
        }
        //_____________________________________________________________________________
        // Constructor
        //-----------------------------------------------------------------------------
        public Series(string Name, double[] Value)
        {
            this.Name = Name;
            this.Value = Value;
        }

        //_____________________________________________________________________________
        // Set the color for one bar
        //-----------------------------------------------------------------------------
        public void updateBarColor(int bar, int color)
        {
            if (BarColor == null)
            {
                BarColor = new int[Value.Length];
                for (int i = 0; i < BarColor.Length - 1; i++)
                {
                    BarColor[i] = -1;
                }
            }
            BarColor[bar] = color;
        }
        //_____________________________________________________________________________
        // 
        //-----------------------------------------------------------------------------
    }
}

