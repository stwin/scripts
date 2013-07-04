
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeFile CSharpScripts\Include\StdLib.cs
[/SCRIPT]*/

//______________________________________________________________________________
//              E A R N I N G S   L I B R A R Y
//______________________________________________________________________________


using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;

using WealthLab;

namespace MyScript
{
    partial class MyClass
    {
		// Global Variables
		private string DefaultEarningsDir = RootDir + @"\Fundamentals\Earnings\earningsBySymbol";
		private string AolEarningsDir = RootDir + @"\Fundamentals\Earnings\AolEarning\ascii";

		//____________________________________________________________________________________________
		/// <summary>
		/// Method to test this libary.
		/// </summary>
		//--------------------------------------------------------------------------------------------
		public void EarningTest ( )
		{
			try
			{
				MessageBox.Show ( "EarningTest is working. CurrDir = " + Environment.CurrentDirectory, "EarningTest" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		//____________________________________________________________________________________________
		// Populates EarningSeries for earning dates. The bars corresponding to earning dates are 
		// marked 1.
		//--------------------------------------------------------------------------------------------
		public void GetEarningSeriesWeekly ( string Symbol, int EarningSeries )
		{
			bool isWeekly = true;
			string EarningStr = ""; //dummy
			int EarningStrColor = 0; // dummy
			GetEarningDates ( Symbol, isWeekly, EarningSeries, ref EarningStr, ref EarningStrColor );
		}
		//____________________________________________________________________________________________
		// Populates EarningSeries for earning dates. The bars corresponding to earning dates are 
		// marked 1.
		//--------------------------------------------------------------------------------------------
		public void GetEarningSeriesDaily ( string Symbol, int EarningSeries, 
			ref string EarningStr, ref int EarningStrColor )
		{
			bool isWeekly = false;
			GetEarningDates ( Symbol, isWeekly, EarningSeries, ref EarningStr, ref EarningStrColor );
		}
		//____________________________________________________________________________________________
		// Populates EarningSeries for earning dates. The bars corresponding to earning dates are 
		// marked 1.
		//--------------------------------------------------------------------------------------------
		public void GetEarningDates ( string Symbol, bool isWeekly, int EarningSeries, 
			ref string EarningStr, ref int EarningStrColor )
		{
			try
			{
				List<DateTime> FutureEarnings = new List<DateTime> ( 5 );
				List<DateTime> PastEarnings = new List<DateTime> ( 50 );
				List<DateTime> Earnings = new List<DateTime> ( 50 );

				ReadEarningsFromFile ( DefaultEarningsDir + "\\" + Symbol + ".csv", Earnings );
				ReadEarningsFromFile ( AolEarningsDir + "\\" + Symbol + ".csv", Earnings );

				Earnings.Sort ( );

				foreach ( DateTime dt in Earnings )
				{
					if ( dt > BarDate[BarCount - 1] )
					{
						FutureEarnings.Add ( dt );
					}
					else
					{
						PastEarnings.Add ( dt );

						int bar = DateToBar ( dt );
						if ( isWeekly )
						{
							bar = WeeklyBarFromDailyDate ( dt );
						}
						if ( bar != -1 )
						{
							WL.SetSeriesValue ( bar, EarningSeries, 1 );

							//DrawImage( 'UpArrow', 0, bar, PriceLow(bar)*0.99, true);
							//DrawImage( 'test', 0, bar, PriceLow(bar)*0.99, true);
							//DrawImage( 'Circle4x4', 0, bar, PriceLow(bar)*0.99, true);
							//DrawCircle(4, 0, bar, PriceLow(bar), #Black, #Thin);
						}
					}
				}

				// Find NextEarning 
				int NextEarningDaysLeft = 0;
				EarningStr = "Next Earning: N/A";
				EarningStrColor = 0;
				if ( FutureEarnings.Count != 0 )
				{
					DateTime NextEarning = FutureEarnings[0];
					//Print ( NextEarning.ToLongDateString ( ) );
					NextEarningDaysLeft = WeekDaysBetweenDates ( BarDate[BarCount - 1], NextEarning );
					if ( NextEarningDaysLeft > 10 )
					{
						EarningStr = String.Format ( "Next Earning Date({0} weekdays): {1}",
							NextEarningDaysLeft, NextEarning.ToShortDateString() );
						EarningStrColor = 009; // blue
					}
					else
					{
						EarningStr = String.Format ( ">>>-------> Next Earning Date({0} weekdays): {1}",
							NextEarningDaysLeft, NextEarning.ToShortDateString() );
						EarningStrColor = 900; // red
					}
					//Print ( EarningStr + "   " +  EarningStrColor );
				}				
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace, "Earning" );
			}
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		private void ReadEarningsFromFile ( string FileName, List<DateTime> Earnings )
		{
			try
			{
				using ( StreamReader sr = new StreamReader ( FileName ) )
				{
					string line = sr.ReadLine ( );
					if ( line != null )
					{
						string[] tokens = line.Split ( ",".ToCharArray ( ) );
						foreach ( string token in tokens )
						{
							string dts = token.Trim ( );
							if ( dts == "" )
								continue;
							DateTime dt = IntDateToDateTime ( Int32.Parse ( dts ) );
							Earnings.Add ( dt );
						}
					}
				}
			}
			catch ( Exception )
			{
			}
		}
		/*

		//______________________________________________________________________________
		procedure displayEarnings();
		begin
		  __initEarningsLibrary();

		  //if( __earnings <> '' ) then
		  //  Print ( 'Earnings: ' + __earnings );

		  //if( __futureEarnings <> '' ) then
		  //  MyDrawLabel( 'Future Earning Dates: ' + __futureEarnings, #Blue );

		  //if( __lastEarning <> '' ) then
		  //  MyDrawLabel( 'Last Earning Date: ' + DateToStr(StrToInt(__lastEarning)), #Blue );

		  if( IsDaily() and ( __nextEarning <> '' ) ) then
		  begin
			var days: integer = myUtil.WeekDaysBetweenDates( GetDate(BarCount-1), StrToInt(__nextEarning) );
			if( days > 10 ) then
			  MyDrawLabel( 'Next Earning Date(' + IntToStr(days) + '): ' + DateToStr(StrToInt(__nextEarning)), #Blue )
			else
			  MyDrawLabel( '>>>-------> Next Earning Date(' + IntToStr(days) + '): ' + DateToStr(StrToInt(__nextEarning)), #Red );
		  end;
		end;
		//______________________________________________________________________________
		function lastEarning(): string;
		begin
		  __initEarningsLibrary();
		  Result := __lastEarning;
		end;

		//______________________________________________________________________________
		function nextEarning(): string;
		begin
		  __initEarningsLibrary();
		  Result := __nextEarning;
		end;

		//______________________________________________________________________________
		//readEarnings;
		//displayEarnings;
		 */
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
	}
}

