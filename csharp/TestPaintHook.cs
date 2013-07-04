
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
using System.Drawing;
using System.Runtime.InteropServices;

using WealthLab;


namespace MyScript
{
	public partial class MyClass
	{
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void TestPaintHookTest ( )
		{
			try
			{
				Print ( "It is working" );
				MessageBox.Show ( "TestPaintHookTest is working. CurrDir = " + Environment.CurrentDirectory, "TestPaintHookTest" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
	}
	//____________________________________________________________________________________________
	//
	//--------------------------------------------------------------------------------------------
	public partial class TestPaintHook : IWealthLabPaintHook3
	{
		MyClass MyClass; 
		System.Windows.Forms.Timer myTimer = new System.Windows.Forms.Timer ( );
		int alarmCounter = 0;
		Graphics g = null;
		System.IntPtr hdc = IntPtr.Zero;
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public TestPaintHook ( MyClass MyClass )
		{
			this.MyClass = MyClass;
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void RegisterPaintHook ( IWealthLabAddOn3 wl )
		{
			wl.InstallPaintHook ( this );
			myTimer.Tick += new EventHandler ( TimerEventProcessor );
			MyClass.Print ( DateTime.Now + ":   Registered the PaintHook" );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		public void Paint ( int dc, int width, int height, int offset, int barSpacing,
			int top, int bottom, bool preBars, WealthLab.IWealthLabAddOn3 WL )
		{
			try
			{
				IntPtr hdc2 = (System.IntPtr) dc;
				hdc = CreateCompatibleDC ( (System.IntPtr) dc );
				g = Graphics.FromHdc ( (System.IntPtr) dc );
				//hdc = g.GetHdc ( );

				MyClass.Print ( "hdc = " + hdc + ",  hdc2 = " + hdc2 );

				if ( preBars == false )
				{
					SolidBrush brush = new SolidBrush ( Color.Red );
					g.FillRectangle ( brush, 1, 1, 50, 100 );
					MoveToEx ( hdc2, 100, 100, IntPtr.Zero );
					LineTo ( hdc2, 200, 200 );
					MoveToEx ( hdc, 200, 100, IntPtr.Zero );
					LineTo ( hdc, 300, 200 );
					myTimer.Interval = 2000;
					myTimer.Start ( );
				}

			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n\r\nStack:\r\n" + e.StackTrace, "TimerEventProcessor" );
				alarmCounter = 100;
			}
			MyClass.Print ( DateTime.Now + ":   Paint completed. PreBars = " + preBars );
		}
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		[DllImport ( "gdi32.dll" )]
		public static extern int BitBlt ( IntPtr hdcDst, int xDst, int yDst, int cx, int cy,
										 IntPtr hdcSrc, int xSrc, int ySrc, uint ulRop );

		[DllImport ( "gdi32.dll" )]
		public static extern IntPtr CreateCompatibleDC ( IntPtr hdc );

		[DllImport ( "gdi32.dll" )]
		public static extern  int MoveToEx(
  IntPtr hdc,          // handle to device context
  int X,            // x-coordinate of new current position
  int Y,            // y-coordinate of new current position
  IntPtr lpPoint   // old current position
);
        
		[DllImport ( "gdi32.dll" )]
		public static extern int LineTo (
	  IntPtr hdc,    // device context handle
	  int nXEnd,  // x-coordinate of ending point
	  int nYEnd   // y-coordinate of ending point
	);
		[DllImport ( "gdi32.dll" )]
		public static extern int RestoreDC (
  IntPtr hdc,       // handle to DC
  int nSavedDC   // restore state
);

				[DllImport ( "gdi32.dll" )]
		public static extern int SaveDC (
  IntPtr hdc   // handle to DC
);
		//____________________________________________________________________________________________
		//
		//--------------------------------------------------------------------------------------------
		private void TimerEventProcessor ( Object myObject,
													EventArgs myEventArgs )
		{

			myTimer.Stop ( );
			if ( g != null )
			{
				try
				{
					int x = 1 + alarmCounter * 10;
					int y = 1 + alarmCounter * 10;
					int width = 50 + alarmCounter * 10;
					int height = 100 + alarmCounter * 10;
					Bitmap bm = new Bitmap ( width, height );
					Graphics gbm = Graphics.FromImage ( bm );

					SolidBrush brush = new SolidBrush ( Color.Green );
					gbm.FillRectangle ( brush, 0, 0, width, height );

					IntPtr hdcbm = gbm.GetHdc ( );
					//hdc = g.GetHdc ( );

					BitBlt ( hdc, x, y, width, height, hdcbm, 0, 0, 0x00CC0020 );
					
				}
				catch ( Exception e )
				{
					MessageBox.Show ( e.Message + "\r\n\r\nStack:\r\n" + e.StackTrace, "TimerEventProcessor" );
					alarmCounter = 100;
				}
				MyClass.Print ( DateTime.Now + ":   Painting Now. alarmCounter = " + alarmCounter );
			}
			alarmCounter += 1;
			if ( alarmCounter > 3 )
			{
				MyClass.Print ( DateTime.Now + ":   Timer Stopped" );
			}
			else
			{
				myTimer.Start ( );
			}
			/*
			// Displays a message box asking whether to continue running the timer.
			if ( MessageBox.Show ( "Continue running?", "Count is: " + alarmCounter,
			   MessageBoxButtons.YesNo ) == DialogResult.Yes )
			{
				alarmCounter += 1;
				myTimer.Enabled = true;
			}*/
		}
	}
}



