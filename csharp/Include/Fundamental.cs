
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#AddReference Interop.TC2000Dev.dll
#IncludeFile CSharpScripts\Include\Telechart.cs
[/SCRIPT]*/




using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Diagnostics;


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
        public void FundamentalTest()
        {
            try
            {
                MessageBox.Show("Fundamental is working. CurrDir = " + Environment.CurrentDirectory, "Fundamental");
            }
            catch (Exception e)
            {
                MessageBox.Show(e.Message + "\r\n" + e.StackTrace);
            }

        }

        //____________________________________________________________________________________________
        // Returns a string which contains basic fundamental information
        //--------------------------------------------------------------------------------------------
        public string BasicFundamentalString(string Symbol)
        {
            long mcap = (long)(1000000.0 * tc_getCapitalization(Symbol));
            double price = BarClose[BarCount-1];
            long numShares = (long)(mcap / price);
            string retStr = String.Format("MCap:  {0}      OShares:  {1} ",
                                    LongToHumanReadable(mcap), LongToHumanReadable(numShares));
            return retStr;
            /*
            try
            {
                long MarketCap = 0L, Shares = 0L;
                string MarketCapStr = "", SharesStr = "";

                GetKeyStats(Symbol, ref MarketCap, ref Shares, ref MarketCapStr, ref SharesStr);

                string retStr = String.Format("MCap:  {0}      OShares:  {1}",
                    MarketCapStr, SharesStr);

                // Now try to get group info
                string Sector = "", SectorSymbol = "", Industry = "", IndustrySymbol = "";
                GetIndustryGroupInfo(Symbol, ref Sector, ref SectorSymbol,
                    ref Industry, ref IndustrySymbol);
                if (Regex.IsMatch(IndustrySymbol, @"MG\d{3}"))
                {
                    long GMarketCap = 0L, GShares = 0L;
                    string GMarketCapStr = "", GSharesStr = "";

                    if (GetKeyStats(IndustrySymbol, ref GMarketCap, ref GShares, ref GMarketCapStr,
                        ref GSharesStr) && GMarketCap != 0)
                    {
                        double MarketCapPer = (double)100 * MarketCap / GMarketCap;
                        retStr = String.Format("MCap:  {0} ({1:G2}% of {2})     OShares:  {3}",
                                    MarketCapStr, MarketCapPer, GMarketCapStr, SharesStr);

                    }
                }

                return retStr;
            }
            catch (Exception)
            {
            }
             */
        }
        //____________________________________________________________________________________________
        // Returns lines which contains basic fundamental information
        //--------------------------------------------------------------------------------------------
        //public int      GetFundamentalLines(string symbol, string[] fundamentalLines, ref int totalNum)
        public int GetFundamentalLines(string Symbol, ref Object COMArray)
        {
            //Print(COMArray.GetType().ToString() + " | " + COMArray.ToString());
            object[] fundamentalLines = (object[])COMArray;
            int totalNum = 0;
            fundamentalLines[totalNum++] = "";

            // Membership
            fundamentalLines[totalNum++] = MembershipString(Symbol);

            // Capitalization && num of shares
            long mcap = (long)(1000000.0 * tc_getCapitalization(Symbol));
            double price = BarClose[BarCount-1];
            long numShares = (long)(mcap / price);
            fundamentalLines[totalNum++] = String.Format("MCap:  {0}      OShares:  {1} ",
                                    LongToHumanReadable(mcap), LongToHumanReadable(numShares));
            
            // Earning data
            float epsPrctChange1stQtr, epsPrctChange2ndQtr, epsPrctChange3rdQtr, epsPrctChange4thQtr,
                epsPrctChangeLatestYear, epsLatestQtr, earningGrothRate5Yr;
            tc_getEarningData(Symbol, out epsPrctChange1stQtr, out epsPrctChange2ndQtr, out epsPrctChange3rdQtr,
                out epsPrctChange4thQtr, out epsPrctChangeLatestYear, out epsLatestQtr, out earningGrothRate5Yr);
            fundamentalLines[totalNum++] = String.Format("EPS Percent Change Latest Qtr     {0}% ", epsPrctChange1stQtr);
            fundamentalLines[totalNum++] = String.Format("EPS Percent Change 2nd Qtr Back   {0}% ", epsPrctChange2ndQtr);
            fundamentalLines[totalNum++] = String.Format("EPS Percent Change 3rd Qtr Back   {0}% ", epsPrctChange3rdQtr);
            fundamentalLines[totalNum++] = String.Format("EPS Percent Change 4th Qtr Back   {0}% ", epsPrctChange4thQtr);
            fundamentalLines[totalNum++] = String.Format("EPS Percent Change Latest Yr      {0}% ", epsPrctChangeLatestYear);
            fundamentalLines[totalNum++] = String.Format("EPS Latest Qtr                    {0} ", epsLatestQtr);
            fundamentalLines[totalNum++] = String.Format("Earnings Growth Rate 5-Yr         {0}% ", earningGrothRate5Yr);

            return totalNum;
        }
        //____________________________________________________________________________________________
        // Returns key stats
        //--------------------------------------------------------------------------------------------
        public bool GetKeyStats(string Symbol, ref long MarketCapM, ref long OutStandingSharesM,
            ref string MarketCapStr, ref string OutStandingSharesStr)
        {
            MarketCapM = OutStandingSharesM = 0;
            MarketCapStr = OutStandingSharesStr = "N/A";
            try
            {
                string FileName = RootDir + @"\Fundamentals\KeyStats\AllStats\" + Symbol + ".csv";
                if (!File.Exists(FileName))
                {
                    return false;
                }

                StreamReader sr = new StreamReader(FileName);

                //MarketCapitalization,7.4B
                //SharesOutstanding,137M

                MarketCapStr = GetToken(sr.ReadLine(), 1, ",");
                OutStandingSharesStr = GetToken(sr.ReadLine(), 1, ",");

                MarketCapM = HumanReadableToLong(MarketCapStr) / 1000000L;
                OutStandingSharesM = HumanReadableToLong(OutStandingSharesStr) / 1000000L;

                sr.Close();
                return true;
            }
            catch (Exception)
            {
            }
            return false;
        }
        //____________________________________________________________________________________________
        // Converts Human Readable to Long
        //--------------------------------------------------------------------------------------------
        public long HumanReadableToLong(string NumStr)
        {
            long RetNum = 0;
            Match m = Regex.Match(NumStr, @"(?<num>\d+\.?\d*)(?<suffix>[MB]?)");
            if (m.Success)
            {
                double num = Double.Parse(m.Groups["num"].ToString());
                string suffix = m.Groups["suffix"].ToString();
                switch (suffix)
                {
                    case "": RetNum = (long)Math.Round(num); Debugger.Break(); break;
                    case "B": RetNum = (long)Math.Round(num * 1000000000L); break;
                    case "M": RetNum = (long)Math.Round(num * 1000000L); break;
                    default:
                        MessageBox.Show("Problem occured");
                        Debugger.Break(); break;
                }
            }
            else
            {
                MessageBox.Show("Problem occured");
                Debugger.Break();
            }
            return RetNum;
        }
        //____________________________________________________________________________________________
        // Converts from Long To Human Readable
        //--------------------------------------------------------------------------------------------
        public string LongToHumanReadable(long Num)
        {
            string ret = "";
            long Millions = Num / 1000000L;
            if (Millions >= 1000L)
            {
                double Billions = (double)Millions / 1000.0;
                if (Billions >= 10)
                {
                    ret = String.Format("{0:f0}B", Billions);
                }
                else
                {
                    ret = String.Format("{0:f1}B", Billions);
                }
            }
            else
            {
                ret = String.Format("{0}M", Millions);
            }
            return ret;
        }
        //____________________________________________________________________________________________
        // Returns a string which contains basic membership information
        //--------------------------------------------------------------------------------------------
        public string MembershipString(string Symbol)
        {
            try
            {
                using (StreamReader sr = new StreamReader(RootDir + @"\Fundamentals\Membership\Members\" + Symbol + ".csv"))
                {
                    string line = sr.ReadLine();
                    sr.Close();

                    if (line != null && line.Trim() != "")
                    {
                        line = line.Substring(0, line.Length - 1);
                        line = "Membership: " + line;
                    }
                    else
                    {
                        line = "";
                    }

                    return line;
                }
            }
            catch (Exception)
            {
            }
            return "";
        }
        //____________________________________________________________________________________________
        // Returns Industry group information.
        //--------------------------------------------------------------------------------------------
        public void GetIndustryGroupInfo(string Symbol, ref string MainIndustry,
            ref string MainIndustrySymbol, ref string SubIndustry, ref string SubIndustrySymbol)
        {
            MainIndustry = "";
            MainIndustrySymbol = "";
            SubIndustry = "";
            SubIndustrySymbol = "";
            try
            {
                try
                {
                    using (StreamReader sr = new StreamReader(RootDir
                        + @"\Fundamentals\industryGroups\Telechart\" + Symbol + ".csv"))
                    {
                        MainIndustry = sr.ReadLine();
                        MainIndustrySymbol = sr.ReadLine();
                        SubIndustry = sr.ReadLine();
                        SubIndustrySymbol = sr.ReadLine();
                        sr.Close();
                    }
                }
                catch (Exception)
                {
                }

                // For indexes and for new symbols
                if (SubIndustry == "")
                {
                    // Set SP-500 as the default subindustry

                    MainIndustry = "Standard & Poors 500";
                    MainIndustrySymbol = "SP-500";
                    SubIndustry = "Standard & Poors 500";
                    SubIndustrySymbol = "SP-500";

                    if (Symbol == "SP-500")
                    {
                        MainIndustry = "Dow Jones Industrials";
                        MainIndustrySymbol = "DJ-30";
                        SubIndustry = "Dow Jones Industrials";
                        SubIndustrySymbol = "DJ-30";
                    }
                }

                // For possible industry group as symbols
                if (Symbol.Length == 5 && Regex.IsMatch(Symbol, @"MG\d\d\d"))
                {
                    int industryNum = Int32.Parse(Symbol.Substring(2, 3));
                    if (industryNum % 10 == 0)
                    {
                        // This is main industry group, plot SP-500
                        MainIndustry = "Standard & Poors 500";
                        MainIndustrySymbol = "SP-500";
                        SubIndustry = "Standard & Poors 500";
                        SubIndustrySymbol = "SP-500";
                    }
                    else
                    {
                        // This is sub-industry group, plot main industry group
                        SubIndustry = MainIndustry;
                        SubIndustrySymbol = MainIndustrySymbol;
                    }
                }
            }
            catch (Exception)
            {
            }
        }
        //____________________________________________________________________________________________
        // Returns Market Symbol
        //--------------------------------------------------------------------------------------------
        public void GetMarketSymbol(string Symbol, ref string MarketSymbol, ref string MarketName)
        {
            MarketSymbol = "SP-500";
            MarketName = "Standard & Poors 500";
            if (Symbol == "DJ-30" || Symbol == "SP-500")
            {
                MarketSymbol = "COMPQX";
                MarketName = "NASDAQ Composite";
            }
            else if (Symbol == "COMPQX")
            {
                MarketSymbol = "DJ-30";
                MarketName = "Dow Jones Industrial Average";
            }
        }

        //____________________________________________________________________________________________
        //
        //--------------------------------------------------------------------------------------------
    }
}

