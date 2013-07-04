
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#AddReference WlData.dll
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
using WLData;


namespace MyScript
{
	enum TimeFrameEnum
	{
		Daily,
		Weekly,
		Monthly,
		Intraday
	}
    public partial class MyClass
    {
		TimeFrameEnum TimeFrame = TimeFrameEnum.Intraday;
		string RootDir = "";

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void NHNLViewerTest ( )
		{
			try
			{
				MessageBox.Show ( "NHNLViewer is working. CurrDir = "
					+ Environment.CurrentDirectory, "NHNLViewer" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void NHNLViewerInit ( IWealthLabAddOn3 wl )
        {
			InternalLibInit ( wl );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void GetAllSeries ( object SeriesHandles )
		{
			try
			{
				GetAllSeries_Internal ( SeriesHandles );
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
		public void GetAllSeries_Internal ( object SeriesHandlesObject )
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
			int NHSeries = (int) SeriesHandles[0];
			int NLSeries = (int) SeriesHandles[1];
			int NHNLSeries = (int)  SeriesHandles[2];

			//
			// Calculate all series
			//
			Series NH, NL;
			GetNHAndNLSeries ( out NH, out NL ); 

			Series NHNL = SubtractSeries ( NH, NL );

			//
			// Now populate all series
			//
			WL.PopulateSeries ( NHSeries, ref NH.Value[0] );
			WL.PopulateSeries ( NLSeries, ref NL.Value[0] );
			WL.PopulateSeries ( NHNLSeries, ref NHNL.Value[0] );
		}

		//____________________________________________________________________________________________
		// TimeFrame : 10 - Daily, 20 - Weekly, 30 - Monthly. 
		//--------------------------------------------------------------------------------------------
		public void MoreInfo ( int iTimeFrame, string RootDir )
		{
			switch ( iTimeFrame )
			{
				case 10: TimeFrame = TimeFrameEnum.Daily; break;
				case 20: TimeFrame = TimeFrameEnum.Weekly; break;
				case 30: TimeFrame = TimeFrameEnum.Monthly; break;
				default: TimeFrame = TimeFrameEnum.Intraday; break;
			}

			this.RootDir = RootDir;
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void GetNHAndNLSeries ( out Series NH, out Series NL )
		{
			NH = CreateSeries ( );
			NL = CreateSeries ( );

			string FileName = "";
			int LookbackBars = 0;

			switch ( TimeFrame )
			{
				case TimeFrameEnum.Daily:
					FileName = RootDir + @"\NH-NL-Daily.txt";
					LookbackBars = 252;
					break;

				case TimeFrameEnum.Weekly:
					FileName = RootDir + @"\NH-NL-Weekly.txt";
					LookbackBars = 52;
					break;

				case TimeFrameEnum.Monthly:
					FileName = RootDir + @"\NH-NL-Monthly.txt";
					LookbackBars = 12;
					break;

				default:
					return;
			}

			int LastUpdatedBar = ReadNHNLSeries ( FileName, NH, NL );
			if ( LastUpdatedBar != BarCount - 1 )
			{
				UpdateNHNLSeries ( LastUpdatedBar, LookbackBars, NH, NL );
				//WriteNHNLSeries ( fileName, lastUpdatedBar, NHSeries, NLSeries );
				//int date1 integer = GetYear(lastUpdatedBar+1) * 10000 + GetMonth(lastUpdatedBar+1) * 100 + GetDay(lastUpdatedBar+1);
				//var date2: integer = GetYear(BarCount-1) * 10000 + GetMonth(BarCount-1) * 100 + GetDay(BarCount-1);
				//PrintStatus( 'Updated: ' + DateToStr( date1 ) + ' to ' + DateToStr( date2 ) );
			}
		}

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public int ReadNHNLSeries ( string fileName, Series NHSeries, Series NLSeries)
		{
			StreamReader sr = new StreamReader ( fileName );
			string text = sr.ReadToEnd();
			sr.Close();

			string[] lines = text.Split ( "\n".ToCharArray() );
			List<WLData.EODBarData> RawBars = new List<WLData.EODBarData> ( lines.Length );
			foreach ( string textLine in lines )
			{
				string line = textLine.Trim ( );
				if ( line == "" )
					continue;
				string[] tokens = line.Split( ",".ToCharArray() );
				if ( tokens.Length < 3 )
					continue;
				WLData.EODBarData data = new EODBarData ( );
				data.Date = DateTime.Parse ( tokens[0] );
				data.High = Double.Parse ( tokens[1] );
				data.Low = Double.Parse ( tokens[2] );
				RawBars.Add ( data );
			}

			// Now we will synchronize the read data with the primary series
			int rawBarCount = 0;
			int rawBarMax = RawBars.Count;
			int LastValidBar = 0;
			NHSeries[0] = 0;
			NLSeries[0] = 0;
			for ( int bar = 0; bar < BarCount && rawBarCount < rawBarMax; bar++ )
			{
				int iDate = Date[bar].Year * 10000 + Date[bar].Month * 100 + Date[bar].Day;
				int iRawDate = RawBars[rawBarCount].Date.Year * 10000 
					+ RawBars[rawBarCount].Date.Month * 100 + RawBars[rawBarCount].Date.Day;
				if ( iDate == iRawDate )
				{
					NHSeries[bar] = RawBars[rawBarCount].High;
					NLSeries[bar] = RawBars[rawBarCount].Low;
					LastValidBar = bar;
					rawBarCount++;
				}
				else if ( iDate < iRawDate )
				{
					NHSeries[bar] = NHSeries[LastValidBar];
					NLSeries[bar] = NLSeries[LastValidBar];
				}
				else
				{
					while ( ( rawBarCount < rawBarMax ) && ( iDate > iRawDate ) )
					{
						rawBarCount++;
						iRawDate = RawBars[rawBarCount].Date.Year * 10000 
							+ RawBars[rawBarCount].Date.Month * 100 + RawBars[rawBarCount].Date.Day;
					}
					if ( rawBarCount < rawBarMax )
					{
						NHSeries[bar] = RawBars[rawBarCount].High;
						NLSeries[bar] = RawBars[rawBarCount].Low;
						LastValidBar = bar;
						rawBarCount++;
					}				
				}
			}
			// If rawBarMax is less than BarCount
			for ( int bar = LastValidBar+1; bar < BarCount; bar++ )
			{
				NHSeries[bar] = NHSeries[LastValidBar];
				NLSeries[bar] = NLSeries[LastValidBar];
			}

			return LastValidBar;
		}

		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------				
        public bool UpdateNHNLSeries(int LastUpdatedBar, int LookbackBars, Series NH, Series NL)
        {
            WealthLab.WL3 wl = new WL3();
            WLData.EOD eod = EOD.self;
            if (eod == null)
            {
                MessageBox.Show("WLDATA.EOD was NULL. Not doing anything", "Error UpdateNHNLSeries");
                return false;
            }

            int barsToUpdate = LookbackBars + (BarCount - LastUpdatedBar - 1) + 50;
            int watchListNum, startBar;

            startBar = LastUpdatedBar + 1;
            if (startBar < (tradingDays + 1))
                startBar = tradingDays + 1;

            string text = wl.WatchListSymbols("EOD");
            string[] tokens = text.Split("\n".ToCharArray());
            foreach (string token in tokens)
            {
                string symbol = token.Trim();
                if (symbol == "")
                    continue;
                List<EODBarData> bars = eod.LoadSymbol2("S", symbol, DateTime.MinValue, DateTime.MinValue, barsToUpdate);
                //TODO 




                /*

          for watchListNum := 0 to WatchListCount - 1 do
          begin
            PrintStatus ('Processing: ' + IntToStr(Trunc(100*IntToStr(watchListNum)/IntToStr(WatchListCount))) +
                '% (' + IntToStr(WatchListCount) + ') ' +  WatchListSymbol (watchListNum));

            try
              SetPrimarySeries (WatchListSymbol (watchListNum) );
            except
              continue;
            end;

            var bar: integer;
            for bar := startBar to BarCount-1 do
            begin
              if( PriceHigh(bar) > Highest( bar-1, #High, tradingDays ) ) then
                @NHSeries[ bar ] := @NHSeries[ bar ] + 1 ;
              if( PriceLow(bar) < Lowest( bar-1, #Low, tradingDays ) ) then
                @NLSeries[ bar ] := @NLSeries[ bar ] + 1;
            end;
          end;
        end;
                //____________________________________________________________________________________________
                //
                //--------------------------------------------------------------------------------------------

        ///////////////////////////////////////////////////////////////////////////////
        procedure WriteNHNLSeries( fileName: string; lastUpdatedBar, NHSeries, NLSeries: integer );
        begin
          var fileHandle, bar: integer;
          fileHandle := FileOpen (fileName);
          for bar := lastUpdatedBar+1 to BarCount-1 do
          begin
            var date: integer;
            date := GetYear(bar) * 10000 + GetMonth(bar) * 100 + GetDay(bar);
            FileWrite( fileHandle, DateToStr( date )
                        + ',' + IntToStr( Trunc( GetSeriesValue( bar, NHSeries) ) )
                        + ',' + IntToStr( Trunc( GetSeriesValue( bar, NLSeries) ) ) );
          end;
          FileClose( fileHandle );
        end;		//______________________________________________________________________________

                */
            }
        }

	}
}


