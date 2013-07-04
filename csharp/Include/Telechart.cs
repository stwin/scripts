using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Diagnostics;

using TC2000Dev;

/*
GUID                                 Criteria Type Criteria
----------------------------------------------------------------------------------
D326988432934AE486E88D8E6F1D4ECE     Special Symbol
DC800C282559471EADF255CFF349C80D     Special Company Name
DF5847B9FE9E4682B8906AB9BFC5CD79     Special Note Dates
B7EB9365533A4A5294D9CB44655A1463     Special Discussion Dates
26BC5EA782E84AB0BF1EC2FC7A8F1000     Special # Users Viewing Chart
E215578183194AFDAD957FBB541D0C0A     Special News Dates
BEFBE1EB008A44CE977301D83AB0E41E     Special Latest Split Date
9D06F0E4D2F848B6B14BADA54FFDB6FF     Special Tracking Price
14F0E394F5F6483D847FC55EF34D4720     Special Tracking Days In List
552468A3328145C9A60CB1F2CC8676A2     Special Tracking Net Change
22BA38E7F4EC431E9D14940D953E16AD     Special Tracking Percent Change
BCE8A8996C7D43FB9FB35861DAE3CE0A     Special Tracking Annual Percent Change
957021B68B864DF987771A2F6ACACCD8     Special Industry Group
D4E173E841744308B0BB395EC1CBA6AE     Special Sub-Industry Group
497C1090759A4A85BF1068777B60863A     Formula 10 day moving average crossing 200 day
614e466d-e7e6-4784-aa1c-6094105362ec System  30 Day Price Trend vs. Market
f173ae26-c774-4026-8303-2448ec5ad62d System  5 Day Price Trend vs. Market
b7fbc12d-87b5-4d8d-b831-3d8ea59b715d System  Accumulated Depreciation and Depletion
11711c66-a24f-4081-9ed7-4b07536752be System  Asset Turnover
bc0e5ee7-e0a2-4ed8-b340-a0c52889878c System  Beta
CCD53073BD4B45FC8703EF6350B9ECBA     Formula BOP Net Change
966e1126-058c-458a-aa44-322adee2ce2c System  BOP Value Today
b8cf261b-4aeb-463b-a3a1-b06e878b93c8 System  Capitalization
165389f3-55a8-405a-b9fd-707d795132be System  Common Stock Equity
c7465e58-c8f7-4545-9223-5e5e03a9e74e System  Cost of Sales
e1dddbf0-812e-4602-923a-bf19991e015b System  Current Book Value Per Share
7de175de-3bea-4ec6-bffe-8c8fa963f129 System  Debt to Equity Ratio
9281d105-1d54-4da6-b3bb-520909430d6c System  Diluted EPS from Total Operations
0f824476-c175-4b50-bb9c-3fb239a435fa System  Dividend Growth Rate 5-Yr
403032c9-72a4-4e87-b150-30068af05f14 System  Dividend Yield
041e592f-dfa8-4d6d-802b-cd681074e185 System  Earnings ($Millions) 1-Yr
f1af8799-a533-4a88-9f32-c89d7356ba27 System  Earnings as Percent of Sales 1-Yr
610cb334-3037-45a8-bcb9-6c57b8a7a274 System  Earnings Growth Rate 5-Yr
a195b1a5-80c2-4581-bae9-baa0469f1d77 System  EPS Latest Qtr
47a5d1c1-8c15-4310-8772-b0d2c884e1c8 System  EPS Percent Change 2nd Qtr Back
ca67f4ea-241c-4050-a221-a4737ec4d9c0 System  EPS Percent Change 3rd Qtr Back
b90117a5-8544-4621-a2db-4bc1ceed0cca System  EPS Percent Change 4th Qtr Back
3828acd5-b8cc-4ee6-abf1-3be6e611e787 System  EPS Percent Change Latest Qtr
8ee8edf0-4056-4d37-95c5-3c9b3948c12b System  EPS Percent Change Latest Yr
4f4bea3f-8d8d-4ed6-a18b-f04b821b118e System  Exchange
a2904ad1-d2f3-488f-934f-4d683977095a System  Gappers
83aa2dc4-177e-4582-9ffa-79fbab02e542 System  Gross Fixed Assets (Plant, Property and Equipment)
f8d9a975-5a25-4d35-8083-e439e942229d System  Gross Margin
a5f673a8-9cff-4bb8-beb8-9e5b684380e7 System  Gross Operating Profit
1d792fa9-ca91-4f10-b98d-34e3dcd25f12 System  High Price Divided By Earnings Ratio
b496cacf-9a07-4183-9b27-183690055303 System  Latest Float
3aa08ec9-9381-4c6a-9b5c-303296df4e12 System  Latest Net Profit Margin
0d0e5c93-8a34-4773-a3d2-abcc45d8e0eb System  Latest Short Interest Ratio
60429b13-4c86-4c55-92a0-eac3a34d68f7 System  Latest Total Net Income
1bfea082-03f7-41a1-8797-a909ad0b934c System  Long Term Debt Divided By Total Capital
7ee77654-a996-4cbd-b459-8a2542ef7a24 System  Long Term Debt to Equity Ratio
a921660c-13ca-4a14-9c60-d0bfca1ad1cb System  Low Price Divided By Earnings Ratio
3d7b6ff5-6614-41ad-bff3-3fa414fe21ae System  MoneyStream - 1-Year Range
8a9fdfd2-6355-4d43-b86d-dde58fceb90c System  MoneyStream - 3 Month Range
40d6af0b-ef51-45d0-bc89-204d47f4ff6a System  MoneyStream - 3-Year Range
6bc4ab12-08a1-4acb-8207-36bf6a8999a5 System  MoneyStream Surge - 1 Week
ffab2613-fa7a-4d68-ad9a-f3afa88fc71d System  MoneyStream vs. Price - 1 Year Period
ae1d0c4d-5b26-4818-aa88-ccf07b4bc5ac System  MoneyStream vs. Price - 3 Month Period
7c71def8-1e00-4c74-b0af-91a364e77e16 System  MoneyStream vs. Price - 3 Year Period
7e492943-82d1-4456-8156-edadb6550e5b System  Net Fixed Assets
35bde339-8a62-48d8-b997-65ffada2b4f1 System  Net Profit Margin (Post Tax)
3178AC78E0784F94BC80C5323C0DD1F4     Formula New High
E375DC778E0B477CA378C61E4D2BC90B     Formula New Low
6cdf9602-848b-4ed4-85e2-244dc8e6d9a6 System  Number of Employees
93e2606b-5750-4681-8578-6f031a95f027 System  Operating Cash Flow 1-Yr
93c30c39-e8f8-4c10-8a29-2a668bab5660 System  Operating Income Before Depreciation (EBITDA)
e433fa4b-5a5f-4c13-81e5-2906f6c556a2 System  Optionable Stocks
71400c9a-03a3-4b6e-becf-f39829940062 System  P/E Ratio
d43c3d2d-e62d-4cb3-a4e8-a7cdfda9becc System  P/E Ratio vs. 5-Yr-Avg P/E
b460bfd8-df9d-4b6f-84c2-67de6aea730f System  Percent Change Revenue 1-Yr
beba78f2-136d-4c26-ab71-1ebae9c1b0d2 System  Percent Change Revenue Last Qtr
d2d278b8-8789-4854-804d-5278cb1d5fae System  Percent Shares Held by Insiders
8245666b-64a6-4a8b-8b4f-40a527297f88 System  Percent Shares Held by Institutions
58c02fdb-c1f3-4d17-ab4b-0e46b1c1d7d3 System  Pre Tax Income (EBT)
b2875136-7eab-463a-bfeb-31e2bd30c47b System  Price - 1 Year Range
5fea8de0-5231-453e-8f21-0f25d59fd283 System  Price - 3 Month Range
ae7b016d-f132-41dc-aff5-93e263680f08 System  Price - 3 Year Range
c7427d93-4044-414a-b7a6-12aa2a280926 System  Price as Percent of 30-Day High
67a2af61-db0f-4322-8552-e92b1d5d8361 System  Price as Percent of 30-Day Low
453fea10-5ae8-4885-acf5-9a8c7d073b04 System  Price as Percent of 52 Week High
4cd0d8a4-88a7-47e5-bf03-61b8a1287503 System  Price as Percent of 52 Week Low
a52e3850-5a0f-4957-b884-196fb72d6503 System  Price as Percent of 90-Day High
13612f42-0595-43ac-ba29-0739cdd77b44 System  Price as Percent of 90-Day Low
67510604-abea-4d80-9c23-0013e8c19139 System  Price Growth Rate 1-Year
014a605e-86a5-40f4-8834-958d41e995e7 System  Price Growth Rate 2-Year
4754e484-a84b-46af-9c5a-601ba84997ec System  Price Growth Rate 3-Year
22490217-c4d9-4619-8013-84a8a711203a System  Price Growth Rate 5-Year
35b47859-54b9-4472-b297-4eccd41271e1 System  Price Per Share
b5d7926e-6dcf-472f-8a36-c332b021a9aa System  Price Percent Change 1 Month
90372fac-dd26-467c-be30-a5a4587493f1 System  Price Percent Change 26-Week
27ba0e79-03b4-4429-ad33-5be80752a57d System  Price Percent Change 5-Day
50d9cc57-9d92-4ea6-9f78-a0fd86c78a0f System  Price Percent Change 5-Yr
da60701b-6552-4317-aef1-acb0f7f67590 System  Price Percent Change Today
c6c7b8f8-4fde-44bc-b7fa-3d5d0b9ed809 System  Price to Sales Ratio
7b331758-12b4-45c4-b519-e1030415e259 System  Price Volatility
940a75b3-ff7d-49d2-acf2-9169138adf69 System  Price vs. 200 Day Moving Average
998ed32c-61a6-4aeb-8cdd-1a5c3b23e8c6 System  Price vs. 40 Day Moving Average
2c083ff2-5160-432b-a8e4-9be20c00101c System  Relative Strength 1-Yr (vs SP-500)
652c31db-5b97-4347-b1cf-eca0a28fd459 System  Return on Assets (ROA)
94a20a6f-5170-431a-afad-477d35c059ca System  Return on Equity
927810eb-f021-4067-8c06-37af957085ea System  Revenue Growth Rate Last 4 Qtr
9476E26974ED4D0AB2920C9C896E22FB     Formula RSI Today
DE7838B8D6EB4475843BC3F14D1A4641     Formula RSI Yesterday
fa8c5753-530e-4e0a-8d8d-ad366700ea75 System  Sales ($Millions) 1-Yr
39ec1f22-8f94-4807-a705-fa90195889cf System  Sales Growth Rate 5-Yr
8defec45-7960-4029-8656-82cd82ad9945 System  Short Term Debt
C50F11B2D89B40CBAC8ED6445BE5962F     Formula Stochastic crossing down through 80
45059A2559FC4DD38A5746AEF55D8DF2     Formula Stochastic crossing up through 20
5d835553-ee30-49cd-81dd-5cd565eb2337 System  Stochastic Short Term
2C9CEC9612D841DA998AE3F425113097     Formula Today's range crossing 40 day moving avg
930dc639-c38d-46d4-88b7-6316194984b6 System  Total Assets
d899f9b5-f0de-412d-8fa5-9ed2bb468571 System  Total Current Assets
556c424d-3a83-4cc5-9b60-13e87f72287b System  Total Income Before Interest Expenses (EBIT)
ba4acf58-a6d8-46e7-b17f-43dc5bc8267a System  Total Volume Last 13 Weeks
E200D8D0810242FCB6D556376DBFE1C4     Formula Trending/Consolidation (25 day)
51FE9AD3527347689E26160F6EBD8070     Formula Up 5 days in a row
7f62143a-289c-45c8-9a20-2436e613f867 System  Volume (Dollars) 1-Day
eb4db998-15d3-4114-a6bc-2b2ba40ee1af System  Volume (Dollars) 5-Day
c58896c6-d7b3-4b39-9f33-e94ce4981321 System  Volume (Dollars) 90-Day
58fb8e42-94fd-4a28-b191-0cbc48778209 System  Volume 1-Day
2e9f127e-1a10-4b30-8b35-5d2b69269ca8 System  Volume 5-Day
bafd5800-6a7f-430a-8e39-1d745420db05 System  Volume 90-Day
bff0186b-f77d-4c20-b6c3-4fa20b5dc100 System  Volume Surge 5-Day
a688f74f-fee7-46dc-bdf2-7e2566e2f271 System  Volume Surge Today

 
Criteria                                           Value                Display Value        Rank
------------------------------------------------------------------------------------------------------------
Symbol
Company Name
Note Dates
Discussion Dates
# Users Viewing Chart
News Dates
Latest Split Date                                  3.767E+08            02/18/2003           25.76826
Tracking Price
Tracking Days In List
Tracking Net Change
Tracking Percent Change
Tracking Annual Percent Change
Industry Group                                     820                  COMPUTER SOFTWARE & SERVICES 87.82716
Sub-Industry Group                                 822                  APPLICATION SOFTWARE 86.81481
10 day moving average crossing 200 day             0                                         49.40878
30 Day Price Trend vs. Market                      0.17                 0.17                 70.16364
5 Day Price Trend vs. Market                       0.01                 0.01                 57.06494
Accumulated Depreciation and Depletion             10546                10546.00             97.92694
Asset Turnover                                     0.7                  0.70                 53.34046
Beta                                               0.97                 0.97                 43.14534
BOP Net Change                                     0                    0.00                 46.72935
BOP Value Today                                    4                    4.00                 56.58549
Capitalization                                     264141               264141.00            99.95568
Common Stock Equity                                6412100              6412100.00           99.31441
Cost of Sales                                      4.96E+09             4960000000.00        97.57596
Current Book Value Per Share                       7.65                 7.65                 49.25417
Debt to Equity Ratio                               0.21                 0.21                 48.93402
Diluted EPS from Total Operations                  0.78                 0.78                 87.97798
Dividend Growth Rate 5-Yr                          11.09                11.09                73.41297
Dividend Yield                                     2.5                  2.50                 74.46206
Earnings ($Millions) 1-Yr                          23468                23468.00             99.90278
Earnings as Percent of Sales 1-Yr                  32.57                32.57                95.11374
Earnings Growth Rate 5-Yr                          15.13                15.13                77.13964
EPS Latest Qtr                                     0.78                 0.78                 87.98898
EPS Percent Change 2nd Qtr Back                    9.7                  9.70                 53.91449
EPS Percent Change 3rd Qtr Back                    33.3                 33.30                67.57252
EPS Percent Change 4th Qtr Back                    35.6                 35.60                68.69785
EPS Percent Change Latest Qtr                      1.3                  1.30                 51.44848
EPS Percent Change Latest Yr                       17                   17.00                59.9841
Exchange                                           3                    Nasdaq               81.94697
Gappers                                            0                                         46.0657
Gross Fixed Assets (Plant, Property and Equipment) 18556                18556.00             96.75005
Gross Margin                                       15925                15925.00             99.56158
Gross Operating Profit                             15925                15925.00             99.77786
High Price Divided By Earnings Ratio               10.7                 10.70                11.73491
Latest Float                                       7561512              7561512.00           99.93311
Latest Net Profit Margin                           32.6                 32.60                95.21198
Latest Short Interest Ratio                        1                    1.00                 32.22222
Latest Total Net Income                            23150                23150.00             99.92139
Long Term Debt Divided By Total Capital            0.16                 0.16                 45.37415
Long Term Debt to Equity Ratio                     0.19                 0.19                 47.18813
Low Price Divided By Earnings Ratio                8.6                  8.60                 26.81924
MoneyStream - 1-Year Range                         98.24                98.24                89.64862
MoneyStream - 3 Month Range                        97.83                97.83                83.25389
MoneyStream - 3-Year Range                         57.56                57.56                47.98648
MoneyStream Surge - 1 Week                         6.33                 6.33                 86.54568
MoneyStream vs. Price - 1 Year Period              2.339996             2.34                 56.72986
MoneyStream vs. Price - 3 Month Period             2.779999             2.78                 53.65991
MoneyStream vs. Price - 3 Year Period              -40.23               -40.23               16.89707
Net Fixed Assets                                   8010                 8010.00              94.76101
Net Profit Margin (Post Tax)                       32.6                 32.60                95.62186
New High                                           0                                         48.02163
New Low                                            0                                         49.44492
Number of Employees
Operating Cash Flow 1-Yr                           25469                25469.00             99.63275
Operating Income Before Depreciation (EBITDA)      8672                 8672.00              99.70065
Optionable Stocks                                  1                    Optionable           50
P/E Ratio                                          11.4                 11.40                21.74199
P/E Ratio vs. 5-Yr-Avg P/E                         81                   81.00                29.84624
Percent Change Revenue 1-Yr                        8                    8.00                 48.65571
Percent Change Revenue Last Qtr                    4.7                  4.70                 44.94997
Percent Shares Held by Insiders                    10.17                10.17                82.9411
Percent Shares Held by Institutions                67.2                 67.20                64.15472
Pre Tax Income (EBT)                               8239                 8239.00              99.71997
Price - 1 Year Range                               95.90447             95.90                93.49953
Price - 3 Month Range                              95.05499             95.05                89.15453
Price - 3 Year Range                               97.79                97.79                93.64728
Price as Percent of 30-Day High                    98.89027             98.89                80.94231
Price as Percent of 30-Day Low                     111.5826             111.58               71.91666
Price as Percent of 52 Week High                   98.89027             98.89                92.23611
Price as Percent of 52 Week Low                    135.6448             135.64               57.40388
Price as Percent of 90-Day High                    98.89027             98.89                84.17196
Price as Percent of 90-Day Low                     132.0165             132.02               73.03204
Price Growth Rate 1-Year                           16.24                16.24                84.06898
Price Growth Rate 2-Year                           0.2                  0.20                 43.55199
Price Growth Rate 3-Year                           5.32                 5.32                 38.9044
Price Growth Rate 5-Year                           -1.67                -1.67                51.3047
Price Per Share                                    32.08                32.08                67.83987
Price Percent Change 1 Month                       7.326873             7.33                 82.6073
Price Percent Change 26-Week                       20.60151             20.60                82.45419
Price Percent Change 5-Day                         1.905979             1.91                 84.59628
Price Percent Change 5-Yr                          -11.6                -11.60               49.92701
Price Percent Change Today                         -0.6503533           -0.65                44.53145
Price to Sales Ratio                               3.67                 3.67                 80.81577
Price Volatility                                   23                   23.00                27.13992
Price vs. 200 Day Moving Average                   120.5589             120.56               90.8539
Price vs. 40 Day Moving Average                    107.2014             107.20               84.86386
Relative Strength 1-Yr (vs SP-500)                 115                  115.00               81.1631
Return on Assets (ROA)                             20.9                 20.90                96.82539
Return on Equity                                   36.6                 36.60                92.88279
Revenue Growth Rate Last 4 Qtr                     8                    8.00                 48.65571
RSI Today                                          52.43902             52.44                51.07831
RSI Yesterday                                      49.71098             49.71                45.03709
Sales ($Millions) 1-Yr                             72052                72052.00             99.11765
Sales Growth Rate 5-Yr                             7.26                 7.26                 61.13894
Short Term Debt                                    0                    0.00                 21.9134
Stochastic crossing down through 80                0                                         48.95398
Stochastic crossing up through 20                  0                                         48.90673
Stochastic Short Term                              89.623               89.62                94.42524
Today's range crossing 40 day moving avg           0                                         45.86951
Total Assets                                       112243               112243.00            97.94322
Total Current Assets                               72513                72513.00             99.82249
Total Income Before Interest Expenses (EBIT)       8334                 8334.00              99.75859
Total Volume Last 13 Weeks                         3.371548E+07         33715476.00          99.93079
Trending/Consolidation (25 day)                    18.89693             18.90                36.85672
Up 5 days in a row                                 0                                         49.12493
Volume (Dollars) 1-Day                             151784               151783.97            97.71512
Volume (Dollars) 5-Day                             168103.7             168103.67            97.71396
Volume (Dollars) 90-Day                            149980.3             149980.25            97.42576
Volume 1-Day                                       473142               473142.00            99.42082
Volume 5-Day                                       527533               527533.00            99.40779
Volume 90-Day                                      541017.4             541017.44            99.35806
Volume Surge 5-Day                                 89.75446             89.75                51.2942
Volume Surge Today                                 87.86776             87.87                52.76189
 */

namespace MyScript
{
    public partial class MyClass
    {
        static cTC2005 tc2005 = null;

        static Criteria criteriaCapitalization = null;
        static Criteria criteriaPrice = null;
        static Criteria criteriaIndustryGroup = null;
        static Criteria criteriaIndustrySubGroup = null;
        
        static Criteria criteriaEpsPrctChange1stQtr = null;
        static Criteria criteriaEpsPrctChange2ndQtr = null;
        static Criteria criteriaEpsPrctChange3rdQtr = null;
        static Criteria criteriaEpsPrctChange4thQtr = null;
        static Criteria criteriaEpsPrctChangeLatestYear = null;
        static Criteria criteriaEpsLatestQtr = null;
        static Criteria criteriaEarningGrothRate5Yr = null;
        
        static MyClass()
        {
            if (tc2005 == null)
            {
                //MessageBox.Show("Tc2005 initialized");
                tc2005 = new cTC2005();
                
                criteriaCapitalization          = tc2005.CriteriaFromGUID("b8cf261b-4aeb-463b-a3a1-b06e878b93c8");
                criteriaPrice                   = tc2005.CriteriaFromGUID("35b47859-54b9-4472-b297-4eccd41271e1");
                criteriaIndustryGroup           = tc2005.CriteriaFromGUID("957021B68B864DF987771A2F6ACACCD8");
                criteriaIndustrySubGroup        = tc2005.CriteriaFromGUID("D4E173E841744308B0BB395EC1CBA6AE");

                criteriaEpsPrctChange1stQtr     = tc2005.CriteriaFromGUID("3828acd5-b8cc-4ee6-abf1-3be6e611e787");
                criteriaEpsPrctChange2ndQtr     = tc2005.CriteriaFromGUID("47a5d1c1-8c15-4310-8772-b0d2c884e1c8");
                criteriaEpsPrctChange3rdQtr     = tc2005.CriteriaFromGUID("ca67f4ea-241c-4050-a221-a4737ec4d9c0");
                criteriaEpsPrctChange4thQtr     = tc2005.CriteriaFromGUID("b90117a5-8544-4621-a2db-4bc1ceed0cca");
                criteriaEpsPrctChangeLatestYear = tc2005.CriteriaFromGUID("8ee8edf0-4056-4d37-95c5-3c9b3948c12b");
                criteriaEpsLatestQtr            = tc2005.CriteriaFromGUID("a195b1a5-80c2-4581-bae9-baa0469f1d77");
                criteriaEarningGrothRate5Yr     = tc2005.CriteriaFromGUID("610cb334-3037-45a8-bcb9-6c57b8a7a274");

            }
        }
        //____________________________________________________________________________________________
        // Returns capitalization
        //--------------------------------------------------------------------------------------------
        public float tc_getCapitalization(string Symbol)
        {
            if (tc2005 != null && tc2005.TCEnabled)
            {
                Int32 wordenNum = tc2005.WordenNumFromSymbol(ref Symbol);
                if (criteriaCapitalization.get_HasValue(wordenNum))
                {
                    return criteriaCapitalization.get_Value(wordenNum);
                }
            }
            return 0.0F;
        }
        //____________________________________________________________________________________________
        // Returns industry/subindustry
        //--------------------------------------------------------------------------------------------
        public string tc_getIndustrySubIndustryString(string Symbol)
        {
            string output = "";
            if (tc2005 != null && tc2005.TCEnabled)
            {
                Int32 wordenNum = tc2005.WordenNumFromSymbol(ref Symbol);
                if (criteriaIndustryGroup.get_HasValue(wordenNum))
                {
                    output += criteriaIndustryGroup.get_DisplayValue(wordenNum) + " | ";
                }
                if (criteriaIndustrySubGroup.get_HasValue(wordenNum))
                {
                    output += criteriaIndustrySubGroup.get_DisplayValue(wordenNum);
                }

            }
            return output;
        }
        //____________________________________________________________________________________________
        // Returns earning
        //--------------------------------------------------------------------------------------------
        public void tc_getEarningData(
            string Symbol,
            out float epsPrctChange1stQtr,
            out float epsPrctChange2ndQtr,
            out float epsPrctChange3rdQtr,
            out float epsPrctChange4thQtr,
            out float epsPrctChangeLatestYear,
            out float epsLatestQtr,
            out float earningGrothRate5Yr
            )
        {
            epsPrctChange1stQtr = 0.0F;
            epsPrctChange2ndQtr = 0.0F;
            epsPrctChange3rdQtr = 0.0F;
            epsPrctChange4thQtr = 0.0F;
            epsPrctChangeLatestYear = 0.0F;
            epsLatestQtr = 0.0F;
            earningGrothRate5Yr = 0.0F;
            if (tc2005 != null && tc2005.TCEnabled)
            {
                Int32 wordenNum = tc2005.WordenNumFromSymbol(ref Symbol);
                if (criteriaEpsPrctChange1stQtr.get_HasValue(wordenNum))
                {
                    epsPrctChange1stQtr = criteriaEpsPrctChange1stQtr.get_Value(wordenNum);
                }
                if (criteriaEpsPrctChange2ndQtr.get_HasValue(wordenNum))
                {
                    epsPrctChange2ndQtr = criteriaEpsPrctChange2ndQtr.get_Value(wordenNum);
                }
                if (criteriaEpsPrctChange3rdQtr.get_HasValue(wordenNum))
                {
                    epsPrctChange3rdQtr = criteriaEpsPrctChange3rdQtr.get_Value(wordenNum);
                }
                if (criteriaEpsPrctChange4thQtr.get_HasValue(wordenNum))
                {
                    epsPrctChange4thQtr = criteriaEpsPrctChange4thQtr.get_Value(wordenNum);
                }
                if (criteriaEpsPrctChangeLatestYear.get_HasValue(wordenNum))
                {
                    epsPrctChangeLatestYear = criteriaEpsPrctChangeLatestYear.get_Value(wordenNum);
                }
                if (criteriaEpsLatestQtr.get_HasValue(wordenNum))
                {
                    epsLatestQtr = criteriaEpsLatestQtr.get_Value(wordenNum);
                }
                if (criteriaEarningGrothRate5Yr.get_HasValue(wordenNum))
                {
                    earningGrothRate5Yr = criteriaEarningGrothRate5Yr.get_Value(wordenNum);
                }
            }
        }
        //____________________________________________________________________________________________
        // Returns companyName
        //--------------------------------------------------------------------------------------------
        public string tc_getCompanyName(string Symbol)
        {
            if (tc2005 != null && tc2005.TCEnabled)
            {
                Int32 wordenNum = tc2005.WordenNumFromSymbol(ref Symbol);
                return tc2005.CompanyName(wordenNum);
            }
            return "";
        }
        //____________________________________________________________________________________________
        // Returns companyName
        //--------------------------------------------------------------------------------------------
        public bool tc_isStock(string Symbol)
        {
            if (tc2005 != null && tc2005.TCEnabled)
            {
                Int32 wordenNum = tc2005.WordenNumFromSymbol(ref Symbol);
                return (1 == tc2005.Category(wordenNum));
            }
            return false;
        }
    }
}
