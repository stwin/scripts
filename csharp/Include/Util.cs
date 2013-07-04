
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
#IncludeFile CSharpScripts\Include\InternalLib.cs
[/SCRIPT]*/




using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;

using Microsoft.Win32;

using WealthLab;


namespace MyScript
{
    public partial class MyClass
    {
		public static string WLRegistryHive = @"Software\WL";
		public static string RootDir
		{
			get
			{
				if ( RootDir_Internal == null )
				{
					RegistryKey key = Registry.CurrentUser.OpenSubKey ( WLRegistryHive );
					RootDir_Internal = (string) key.GetValue ( "RootDir" );
					key.Close ( );
				} 
				return RootDir_Internal;
			}
		}
		private static string RootDir_Internal = null;

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void UtilTest ( )
		{
			try
			{
				MessageBox.Show ( "Util is working. CurrDir = " + Environment.CurrentDirectory, "Util" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void UtilInit ( )
		{
			try
			{
			}
			catch ( Exception e )
			{
				MessageBox.Show ( "Error:\r\ne.Message = " + e.Message + "\r\n\r\ne.StackTrace = \r\n"
					+ e.StackTrace, "Exception in MyScript.MyClass.GetAllSeries" );
			}
		}
		//___________________________________________________________________________
		// Boolean parameter passing to chartscripts in WealthLab
		//---------------------------------------------------------------------------
        public bool GetBoolParam(string paramName)
        {
            string WLParametersRegistryHive = WLRegistryHive + @"\Parameters";
            try
            {
                RegistryKey key = Registry.CurrentUser.OpenSubKey(WLParametersRegistryHive);
                string val = (string)key.GetValue(paramName);
                key.Close();
                if (val != null)
                {
                    return Convert.ToBoolean(val);
                }
            }
            catch (Exception)
            {
            }
            return false;
        }
		//___________________________________________________________________________
		// Boolean parameter passing to chartscripts in WealthLab
		//---------------------------------------------------------------------------
		public string GetStringParam ( string paramName )
		{
			string WLParametersRegistryHive = WLRegistryHive + @"\Parameters";
			try
			{
				RegistryKey key = Registry.CurrentUser.OpenSubKey ( WLParametersRegistryHive );
				string val = (string) key.GetValue ( paramName );
				key.Close ( );
				return val;
			}
			catch ( Exception )
			{
			}
			return null;
		}
		//___________________________________________________________________________
		// Splits a date (20070403) into year, month, day ( 2007, 04, 03 )
		//---------------------------------------------------------------------------
		public void SplitDate ( int date, ref int year, ref int month, ref int day )
		{
			year = date / 10000;
			month = ( date % 10000 ) / 100;
			day = date % 100;
		}

		//___________________________________________________________________________
		// Calculates number of days ( including weekend and holidays days )
		// between two dates ( 20060405, 20070704 )
		//---------------------------------------------------------------------------
		public int DaysBetweenDates ( int startDate, int endDate )
		{
			DateTime dt1 = IntDateToDateTime ( startDate );
			DateTime dt2 = IntDateToDateTime ( endDate );
			TimeSpan ts = dt2 - dt1;
			return ts.Days;
		}
		//___________________________________________________________________________
		// Calculates number of week days
		// between two dates ( 20060405, 20070704 )
		//---------------------------------------------------------------------------
		public int WeekDaysBetweenIntDates ( int startDateSimple, int endDateSimple )
		{
			DateTime beginDate = IntDateToDateTime ( startDateSimple );
			DateTime endDate = IntDateToDateTime ( endDateSimple );

			return WeekDaysBetweenDates ( beginDate, endDate );
		}
		//___________________________________________________________________________
		// Calculates number of week days
		// between two dates ( 20060405, 20070704 )
		//---------------------------------------------------------------------------
		public int WeekDaysBetweenDates ( DateTime beginDate, DateTime endDate )
		{
			TimeSpan span = endDate.Subtract ( beginDate );
			//int        wholeWeeks = (int)(((long)Math.Round(Math.Floor(span.TotalDays))) / 7);
			int wholeWeeks = (int) ( span.TotalDays / 7 );
			DateTime dateCount = beginDate.AddDays ( wholeWeeks * 7 );
			int endDays = 0;

			dateCount = dateCount.AddDays ( 1 );
			while ( dateCount.Date <= endDate.Date )
			{
				switch ( dateCount.DayOfWeek )
				{
					case DayOfWeek.Saturday:
					case DayOfWeek.Sunday:
						break;
					default:
						endDays++;
						break;
				}
				dateCount = dateCount.AddDays ( 1 );
			}
			int totalDays = wholeWeeks * 5 + endDays;
			return totalDays;
		}
		//___________________________________________________________________________
		// WeeklyBarFromDailyIntDate.
		// Get Weekly bar on a weekly chart from a daily date
		//---------------------------------------------------------------------------
		public int WeeklyBarFromDailyIntDate ( int IntDate )
		{
			DateTime dt = IntDateToDateTime ( IntDate );
			return WeeklyBarFromDailyDate ( dt );
		}
		//___________________________________________________________________________
		// WeeklyBarFromDailyDate.
		// Get Weekly bar on a weekly chart from a daily date
		//---------------------------------------------------------------------------
		public int WeeklyBarFromDailyDate ( DateTime dt )
		{
			int OffsetDays = 0;
			switch ( dt.DayOfWeek )
			{
				case DayOfWeek.Sunday: OffsetDays = -6; break;
				case DayOfWeek.Monday: OffsetDays = 0; break;
				case DayOfWeek.Tuesday: OffsetDays = -1; break;
				case DayOfWeek.Wednesday: OffsetDays = -2; break;
				case DayOfWeek.Thursday: OffsetDays = -3; break;
				case DayOfWeek.Friday: OffsetDays = -4; break;
				case DayOfWeek.Saturday: OffsetDays = -5; break;
			}
			DateTime WeeklyBarDate = dt.AddDays ( OffsetDays ); // This is monday

			// The Monday Date may not be a bar in some cases like when Monday is a holiday,
			// so look for a valid bar in next 5 days
			for ( int i = 0; i < 5; i++ )  
			{
				int bar = DateToBar ( WeeklyBarDate );
				if ( bar != -1 )
				{
					return bar;
				}
				WeeklyBarDate = WeeklyBarDate.AddDays ( 1 );
			}
			return -1;
		}
		//___________________________________________________________________________
		// Returns the day of a bar as string
		//---------------------------------------------------------------------------
		public string GetDayStr ( int Bar )
		{
			return BarDate[Bar].ToString ( "dddd" );
		}
		//___________________________________________________________________________
		// Display Percent Changes for Last 5 Bars
		//---------------------------------------------------------------------------
		public string GetStrPercentChangeForLast5Bars ()
		{
			string text;
			bool firstTime = true;

			text = "Change(%): ";

			int startBar = Math.Max ( 1, BarCount - 5 );
			for ( int count = startBar; count < BarCount; count++ )
			{
				double val = 100 * ( BarClose[count] - BarClose[count-1] ) / BarClose[count-1];
				if ( firstTime )
				{
					text += String.Format ( " {0:N2}", val );
					firstTime = false;
				}
				else
				{
					text += String.Format ( ", {0:N2}", val );
				}
			}
			return text;
		}
		//___________________________________________________________________________
		// Display Percent Changes for Last 5 Bars
		//---------------------------------------------------------------------------
		public string GetStrOHLC ( )
		{
			return String.Format ( "(OHLC): {0:N2}, {1:N2}, {2:N2}, {3:N2}",
				BarOpen[BarCount - 1], BarHigh[BarCount - 1], BarLow[BarCount - 1], BarClose[BarCount - 1] );
		}
		//___________________________________________________________________________
		// Gets the root directory (where all files, directory and other data are kept)
		//---------------------------------------------------------------------------
		public string GetRootDir ( )
		{			
			return RootDir;
		}
		//___________________________________________________________________________
		// Gets the environment variable
		//---------------------------------------------------------------------------
		public string GetEnvironmentVariable ( string variable )
		{
			return Environment.GetEnvironmentVariable ( variable );
		}
		//___________________________________________________________________________
		// Sets the environment variable
		//---------------------------------------------------------------------------
		public bool SetEnvironmentVariable ( string variable, string varValue )
		{
			//return Win32Direct.SetEnvironmentVariableEx ( variable, varValue );
			return false;
		}
		//___________________________________________________________________________
		// Expands environment variables in the string. 
		// For example
		//      "My system drive is %SystemDrive% and my system root is %SystemRoot%"
		// gets expanded to
		//      "My system drive is C: and my system root is C:\WINNT"
		//---------------------------------------------------------------------------
		public string ExpandEnvironmentVariables ( string line )
		{
			return Environment.ExpandEnvironmentVariables ( line );
		}
		//___________________________________________________________________________
		// Get Registry Key ( under CurrentUser i.e. HKCU )
		//---------------------------------------------------------------------------
		public string GetRegistryKey ( string key )
		{
			MessageBox.Show ( "Not implemented" );
			//RegistryKey key = Registry.CurrentUser.OpenSubKey( regKey );
			//return (string)key.GetValue( regValue );
			return "";
		}
		//___________________________________________________________________________
		// Get Registry Key at HKCU\Software\WL
		//---------------------------------------------------------------------------
		public string GetWlRegistryKey ( string regKey )
		{
			RegistryKey key = Registry.CurrentUser.OpenSubKey ( @"Software\WL" );
			return (string) key.GetValue ( regKey );
		}
		//___________________________________________________________________________
		// Set Registry Key
		//---------------------------------------------------------------------------
		public void SetRegistryKey ( string key, string regData )
		{
			MessageBox.Show ( "Not implemented" );
		}
		//___________________________________________________________________________


		//===========================================================================
		//============================= PRIVATE METHODS =============================
		//===========================================================================

		//___________________________________________________________________________
		// Converts int date format (20070312) to DateTime structure. 
		//---------------------------------------------------------------------------
		public DateTime IntDateToDateTime ( int IntDate )
		{
			DateTime dt = new DateTime ( IntDate / 10000, ( IntDate % 10000 ) / 100, IntDate % 100 );
			return dt;
		}
		//___________________________________________________________________________
		// Converts DateTime structure to int date format (20070312) . 
		//---------------------------------------------------------------------------
		public int DateTimeToIntDate ( DateTime dt )
		{
			int IntDate = dt.Year * 10000 + dt.Month * 100 + dt.Day;
			return IntDate;
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

