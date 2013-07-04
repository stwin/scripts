
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#PrimaryClass MyScript.Adapters.EMini1MinStaticAdapter
[/SCRIPT]*/


using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;
using System.Reflection;
using System.ComponentModel;

using WealthLab;
using WLE;

namespace MyScript.Adapters
{
	//_________________________________________________________________________________________
	//-----------------------------------------------------------------------------------------
	public class EMini1MinStaticAdapter1 : IStaticDataAdapter
	{
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
			switch ( Symbol )
			{
				case "RANDOM_SEC": return "Random Seconds Data";
				case "RANDOM_MIN": return "Random Minutes Data";
				case "RANDOM_DAY": return "Random Daily Data";
			}
			return "";
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void FillSymbols ( string DSString, IWealthLabStrings3 WLSymbols )
		{
			WLSymbols.Add ( "RANDOM_SEC" );
			WLSymbols.Add ( "RANDOM_MIN" );
			WLSymbols.Add ( "RANDOM_DAY" );
		}

		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void LoadSymbol ( string DSString, string Symbol, IWealthLabBars3 Bars,
					DateTime StartDate, DateTime EndDate, int MaxBars )
		{
			double Open, High, Low, Close;
			int Volume;

			if ( MaxBars == 0 )
			{
				MaxBars = 1000;
			}

			DateTime CutOffDate = new DateTime ( 1901, 1, 1 );
			DateTime dt = new DateTime ( 2000, 1, 1 );
			if ( StartDate > CutOffDate )
			{
				dt = StartDate;
			}

			Random r = new Random ( );
			Close = 25 + r.Next ( 20 );
			for ( int count = 0; count < MaxBars; count++ )
			{
				Open = Close + ( Math.Round ( ( r.NextDouble ( ) - 0.5 ) / 30.0, 2 ) );
				double updown = r.NextDouble ( );
				if ( updown > 0.5 )
				{
					Close = Open + r.NextDouble ( );
					High = Close + r.NextDouble ( ) * r.NextDouble ( );
					Low = Open - r.NextDouble ( ) * r.NextDouble ( );
				}
				else
				{
					Close = Open - r.NextDouble ( );
					High = Open + r.NextDouble ( ) * r.NextDouble ( );
					Low = Close - r.NextDouble ( ) * r.NextDouble ( );
				}
				Volume = 100000 + r.Next ( 100000 );
				Bars.Add ( dt, Open, High, Low, Close, Volume );
				switch ( Symbol )
				{
					case "RANDOM_SEC": dt = dt.AddSeconds ( 1 ); break;
					case "RANDOM_MIN": dt = dt.AddMinutes ( 1 ); break;
					case "RANDOM_DAY": dt = dt.AddDays ( 1 ); break;
					default: dt = dt.AddDays ( 1 ); break;
				}
			}
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void DisplaySettings ( )
		{
			MessageBox.Show ( "DisplaySettings() called. Nothing to do.", this.GetType ( ).ToString ( ) );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
		public void ShutDown ( )
		{
			MessageBox.Show ( "ShutDown() called. Nothing to do.", this.GetType ( ).ToString ( ) );
		}
		//_________________________________________________________________________________________
		//-----------------------------------------------------------------------------------------
	}
}
