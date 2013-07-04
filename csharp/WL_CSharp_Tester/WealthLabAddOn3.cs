using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

using WealthLab;

namespace WL_CSharp_Tester
{
	public class BarData 
	{
		public DateTime Date;
		public double Open, High, Low, Close, Volume;
	}

	public class WealthLabAddOn3: IWealthLabAddOn3
	{
		public List<BarData>  StockData = new List<BarData>(1000);
		public List<double[]> Indicators = new List<double[]> ( 10 );
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public WealthLabAddOn3 ()
		{
			ReadCsvFile ( "TESTSYM.CSV" );
			//StockData.RemoveRange ( 20, StockData.Count - 20 );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void ReadCsvFile ( string fileName )
		{
			// Format of TESTSYM.CSV: Date,Open,High,Low,Close,Volume
			//20070814,1943.00,1951.00,1910.00,1914.75,4557
			//20070815,1915.00,1923.00,1873.00,1878.50,5457
			//20070816,1879.25,1879.25,1813.00,1856.50,11196

			StreamReader sr = new StreamReader ( File.Open ( fileName, 
				FileMode.Open, FileAccess.Read, FileShare.ReadWrite ) );
			while ( true )
			{
				string line = sr.ReadLine ( );
				if ( line == null || line.Trim ( ) == "" )
					break;
				string[] tokens = line.Split ( ",".ToCharArray ( ) );
				BarData data = new BarData ( );
				int idate = Int32.Parse ( tokens[0] );
				data.Date = new DateTime ( idate / 10000, ( idate % 10000 ) / 100, idate % 100 );
				data.Open = Double.Parse ( tokens[1] );
				data.High = Double.Parse ( tokens[2] );
				data.Low = Double.Parse ( tokens[3] );
				data.Close = Double.Parse ( tokens[4] );
				data.Volume = Double.Parse ( tokens[5] );
				StockData.Add ( data );
			}
			sr.Close ( );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		//____________________________________________________________________________________________
		//____________________________________________________________________________________________
		
		
		//_________________________ INTERFACE METHODS        _________________________________________
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public bool ClosePosition ( int Position, int Bar, double Price, 
			OrderTypeEnum OrderType, string SignalName )
		{
			return true;
		}
		public bool OpenPosition ( int Bar, PositionTypeEnum PositionType, int Shares,
			double Price, OrderTypeEnum OrderType, string SignalName )
		{
			return true;
		}
		public int BarCount ( )
		{
			return StockData.Count;
		}
		public DateTime Date ( int Bar )
		{
			return StockData[Bar].Date;
		}
		public double GetSeriesValue ( int Bar, int Series )
		{
			return Indicators[Series][Bar];
		}
		public int LastPosition ( )
		{
			return -1;
		}
		public double PriceClose ( int Bar )
		{
			return StockData[Bar].Close;
		}
		public double PriceHigh ( int Bar )
		{
			return StockData[Bar].High;
		}
		public double PriceLow ( int Bar )
		{
			return StockData[Bar].Low;
		}
		public double PriceOpen ( int Bar )
		{
			return StockData[Bar].Open;
		}
		public int Volume ( int Bar ) 
		{
			return (int)StockData[Bar].Volume;
		}
		public void SetSeriesValue ( int Bar, int Series, double Value ) { Indicators[Series][Bar] = Value;  }
		public double GetPositionData ( int Position ) { return 5.1; }
		public bool PositionActive ( int Position ) { return false; }
		public int PositionCount ( ) { return 0; }
		public int PositionEntryBar ( int Position ) { return 5; }
		public double PositionEntryPrice ( int Position ) { return 5.1; }
		public int PositionExitBar ( int Position ) { return 5; }
		public double PositionExitPrice ( int Position ) { return 5.1; }
		public bool PositionLong ( int Position ) { return false; }
		public int PositionShares ( int Position ) { return 5; }
		public void AddScanColumn ( string Name, double Value ) { }
		public void SetPositionData ( int Position, double Value ) { }
		public void InstallPaintHook ( IWealthLabPaintHook3 Hook ) { }
		public int BarToX ( int Bar ) { return 5; }
		public int PriceToY ( double Price ) { return 5; }
		public void PopulateSeries ( int Series, ref double Values ) 
		{
 
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}
