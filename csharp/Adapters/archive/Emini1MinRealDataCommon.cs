

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.IO;
using System.Net;

using Microsoft.Win32;

using WealthLab;
using WLE;

namespace Emini1MinRT
{
	public partial class Emini1MinRealDataCommon : Form
	{
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		// Constants
		public string DataDir = @"D:\WLE\Futures\1minData";
		public string PrimarySymbol = "ER2Z7";
		public int TotalBars = 400;
		public static string WLRegistryHive = @"Software\WL";
		public static string EminiRegistryDir = @"Emini1MinRT";
		public static string EminiRegistryHive = WLRegistryHive + "\\" + EminiRegistryDir;

		// 
		public List<BarData> PrimaryData = null;
		public Dictionary<DateTime, int> DateTimeToBar = null;
		public Dictionary<string, List<BarData>> AllData = null;
		public int CurrentBar = 0;
		public List<Emini1MinRealData> Clients = new List<Emini1MinRealData> ( 10 );

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public Emini1MinRealDataCommon ( )
		{
			InitializeComponent ( );
			CacheData ( );

			try
			{
				RegistryKey key = Registry.CurrentUser.OpenSubKey ( EminiRegistryHive );
				CurrentBar = Int32.Parse ( (string) key.GetValue ( "CurrentBar" ) );
				key.Close ( );
			}
			catch ( Exception )
			{
				CurrentBar = TotalBars - 1;
			}

			CurrentBar = Math.Min ( CurrentBar, PrimaryData.Count );
			dateTimePicker1.Value = PrimaryData[CurrentBar].Date;
			this.Show ( );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void RegisterForUpdate ( Emini1MinRealData client )
		{
			Clients.Add ( client );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void DeRegisterForUpdate ( Emini1MinRealData client )
		{
			try
			{
				Clients.Remove ( client );
			}
			catch ( Exception )
			{
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void PrintDebugInfo ( )
		{
			String RetStr = String.Format ( "Number of Clients = {0}\r\n", Clients.Count );
			foreach ( Emini1MinRealData client in Clients )
			{
				RetStr += client.ToString ( ) + "\r\n";
			}
			WLE.CSharp.Print ( RetStr );
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
		public void SetCurrentBarText ( )
		{
			string txt = String.Format ( "{0} - {1}", CurrentBar,
				PrimaryData[CurrentBar].Date.ToString ( "MM/dd/yyyy HH:mm ddd" ) );
			textBoxCurrentBar.Text = txt;
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void UpdateClients ( )
		{
			foreach ( Emini1MinRealData client in Clients )
			{
				client.Update ( );
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void Save ( )
		{		
			try
			{
				RegistryKey key = Registry.CurrentUser.OpenSubKey ( EminiRegistryHive, true );
				key.SetValue ( "CurrentBar", CurrentBar.ToString()  );
				key.Close ( );
			}
			catch ( Exception )
			{
				
			}
		}

		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
		//_________________________________________________________________________________________
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
			UpdateClients ( );
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
				if ( CurrentBar < TotalBars - 1 )
				{
					CurrentBar = TotalBars - 1;
				}
			}
			SetCurrentBarText ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void EMiniForm_FormClosing ( object sender, FormClosingEventArgs e )
		{
			this.Hide ( );
			e.Cancel = true;
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonDebugInfo_Click ( object sender, EventArgs e )
		{
			this.PrintDebugInfo ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonSave_Click ( object sender, EventArgs e )
		{
			this.Save ( );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		private void buttonNextBar_KeyPress ( object sender, KeyPressEventArgs e )
		{
			if ( e.KeyChar == (char)Keys.Return )
			{
				buttonNextBar.PerformClick ( );
			}			
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
	}
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
}