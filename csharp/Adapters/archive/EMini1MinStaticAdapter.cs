
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Adapters\EMini1MinStaticAdapter.Designer.cs
#PrimaryClass MyScript.Adapters.EMini1MinStaticAdapter
[/SCRIPT]*/


using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using System.Threading;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using System.Reflection;
using System.ComponentModel;

using WealthLab;
using WLE;

namespace MyScript.Adapters
{
	public partial class EMini1MinStaticAdapter : Form, IStaticDataAdapter
	{
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public class BarData
		{
			public DateTime Date;
			public double Open, High, Low, Close;
			public int Volume;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		// Constants
		string DataDir = @"D:\WLE\Futures\1minData";
		string PrimarySymbol = "ER2Z7";
		const int TotalBars = 400;
		string MainWatchListName = "A6-WLE-Static";
		//string[] ChartScripts = new string[] { "RealTimeBasic" };
		//string[] ChartSymbols = new string[] { "ER2Z7" };
		string[] ChartScripts = new string[] { "RealTimeBasic", "RealTimeBasic_1", "RealTimeBasic_2", 
			"RealTimeBasic_3", "RealTimeBasic_4" };
		string[] ChartSymbols = new string[] { "ER2Z7", "ESZ7", "NQZ7", "YMZ7", "EMDZ7" };

		// 
		WealthLab.WL3 WL = null;
		List<BarData> PrimaryData = null;
		Dictionary<DateTime, int> DateTimeToBar = null;
		Dictionary<string, List<BarData>> AllData = null;
		int CurrentBar = TotalBars - 1;

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public EMini1MinStaticAdapter ( )
		{
			InitializeComponent ( );
			this.Show ( );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public string CreateDataSource ( )
		{
			return "MyScript.Adapters";
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public string GetSecurityName ( string Symbol )
		{
			return "";
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void FillSymbols ( string DSString, IWealthLabStrings3 WLSymbols )
		{
			string[] files = Directory.GetFiles ( DataDir, "*.csv" );
			foreach ( string file in files )
			{
				string Symbol = Path.GetFileNameWithoutExtension ( file );
				WLSymbols.Add ( Symbol );
			}
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void LoadSymbol ( string DSString, string Symbol, IWealthLabBars3 Bars,
					DateTime StartDate, DateTime EndDate, int MaxBars )
		{
			if ( AllData == null )
			{
				CacheData ( );
			}
			List<BarData> Data = AllData[Symbol];

			int count = 0;
			for ( ; count < TotalBars; count++ )
			{
				int index = CurrentBar - TotalBars + count + 1;
				BarData bd = Data[index];
				Bars.Add ( bd.Date, bd.Open, bd.High, bd.Low, bd.Close, bd.Volume );
				int a = bd.Volume;
			}

			// If no bars was added, then add a dummy bar, otherwise WLD will go weired
			// This case should not happen, but just in case.
			if ( count == 0 )
			{
				MessageBox.Show ( "Count = 0 in LoadSymbol. Should not happen." );
				Bars.Add ( DateTime.Now, 1, 1, 1, 1, 1 );
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void DisplaySettings ( )
		{
			this.Show ( );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void ShutDown ( )
		{
			this.Hide ( );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void CacheData ( )
		{
			// Get Primary Data
			PrimaryData = LoadAsciiData ( DataDir + "\\" + PrimarySymbol + ".csv" );
			DateTimeToBar = new Dictionary<DateTime, int> ( PrimaryData.Count );
			for ( int index = 0; index < PrimaryData.Count; index++ )
			{
				BarData bd = PrimaryData[index];
				DateTimeToBar[bd.Date] = index;
			}

			// Get data for other symbols too
			string[] files = Directory.GetFiles ( DataDir, "*.csv" );
			Dictionary<string, List<BarData>> RawData = new Dictionary<string, List<BarData>> ( files.Length - 1 );
			foreach ( string file in files )
			{
				string Symbol = Path.GetFileNameWithoutExtension ( file );
				if ( Symbol == PrimarySymbol )
				{
					continue;
				}
				RawData[Symbol] = LoadAsciiData ( file );
			}

			// Synchronize Other Data with respect to the Primary Data
			AllData = new Dictionary<string, List<BarData>> ( files.Length );
			AllData[PrimarySymbol] = PrimaryData;
			foreach ( KeyValuePair<string, List<BarData>> val in RawData )
			{
				AllData[val.Key] = SynchronizeData ( DateTimeToBar, PrimaryData, val.Value );
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public List<BarData> LoadAsciiData ( string file )
		{
			List<BarData> Data = new List<BarData> ( );
			StreamReader sr = new StreamReader ( file );
			while ( !sr.EndOfStream )
			{
				string line = sr.ReadLine ( ).Trim ( );
				if ( line == "" ) continue;
				// 20070921,1120,821.20,822.00,821.20,821.80,784
				string[] tokens = line.Split ( ",".ToCharArray ( ) );
				BarData bd = new BarData ( );
				int date = Int32.Parse ( tokens[0] );
				int time = Int32.Parse ( tokens[1] );
				int year = date / 10000;
				int month = ( date / 100 ) % 100;
				int day = date % 100;
				int hour = time / 100;
				int minute = time % 100;
				bd.Date = new DateTime ( year, month, day, hour, minute, 0 );
				bd.Open = Double.Parse ( tokens[2] );
				bd.High = Double.Parse ( tokens[3] );
				bd.Low = Double.Parse ( tokens[4] );
				bd.Close = Double.Parse ( tokens[5] );
				bd.Volume = Int32.Parse ( tokens[6] );
				Data.Add ( bd );
			}
			sr.Close ( );
			return Data;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public List<BarData> SynchronizeData ( Dictionary<DateTime, int> DateTimeToBar,
						List<BarData> PrimaryData, List<BarData> SecondaryData )
		{
			List<BarData> NewData = new List<BarData> ( DateTimeToBar.Count );

			// Initialize NewData
			for ( int count = 0; count < DateTimeToBar.Count; count++ )
			{
				NewData.Add ( null );
			}

			// Now Fill NewData
			foreach ( BarData bd in SecondaryData )
			{
				int Bar;
				if ( DateTimeToBar.TryGetValue ( bd.Date, out Bar ) )
				{
					NewData[Bar] = bd;
				}
			}

			// Now handle those values which are still null

			if ( NewData[0] == null )
			{
				NewData[0] = new BarData ( );
				NewData[0].Date = PrimaryData[0].Date;
				// Make sure price values are non-zero, otherwise WLD will crash
				NewData[0].Open = NewData[0].High = NewData[0].Low = NewData[0].Close = 0.01;
				NewData[0].Volume = 0;
			}
			for ( int index = 1; index < NewData.Count; index++ )
			{
				if ( NewData[index] == null )
				{
					NewData[index] = new BarData ( );
					NewData[index].Date = PrimaryData[index].Date;
					NewData[index].Open = NewData[index - 1].Open;
					NewData[index].High = NewData[index - 1].High;
					NewData[index].Low = NewData[index - 1].Low;
					NewData[index].Close = NewData[index - 1].Close;
					NewData[index].Volume = NewData[index - 1].Volume;
				}
			}

			return NewData;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void ExecuteScript ( )
		{
			if ( WL == null )
			{
				WL = new WL3 ( );
			}

			for( int index = 0; index < ChartScripts.Length; index++ )
			{
				WL.ExecuteScript ( ChartScripts[index], MainWatchListName, ChartSymbols[index] );
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void SetCurrentBarText ( )
		{
			string txt = String.Format ( "{0} - {1}", CurrentBar,
				PrimaryData[CurrentBar].Date.ToString ( "MM/dd/yyyy HH:mm ddd" ) );
			textBoxCurrentBar.Text = txt;
		}
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonPrevBar_Click ( object sender, EventArgs e )
		{
			CurrentBar--;
			if ( CurrentBar < TotalBars - 1 )
			{
				CurrentBar = TotalBars - 1;
			}
			dateTimePicker1.Value = PrimaryData[CurrentBar].Date;
			ExecuteScript ( );
			SetCurrentBarText ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonExec_Click ( object sender, EventArgs e )
		{
			ExecuteScript ( );
			SetCurrentBarText ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonNextBar_Click ( object sender, EventArgs e )
		{
			CurrentBar++;
			if ( CurrentBar > PrimaryData.Count - 1 )
			{
				CurrentBar = PrimaryData.Count - 1;
			}
			dateTimePicker1.Value = PrimaryData[CurrentBar].Date;
			ExecuteScript ( );
			SetCurrentBarText ( );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonCacheData_Click ( object sender, EventArgs e )
		{
			CacheData ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void dateTimePicker1_ValueChanged ( object sender, EventArgs e )
		{
			int Bar;
			if ( DateTimeToBar.TryGetValue ( dateTimePicker1.Value, out Bar ) )
			{
				CurrentBar = Bar;
				if ( CurrentBar > PrimaryData.Count - 1 )
				{
					CurrentBar = PrimaryData.Count - 1;
				}
			}
			SetCurrentBarText ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void EMiniForm_FormClosing ( object sender, FormClosingEventArgs e )
		{
			ShutDown ( );
			e.Cancel = true;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
	}
}