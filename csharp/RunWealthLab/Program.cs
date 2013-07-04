using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Threading;

namespace RunWealthLab
{
	static class Program
	{
		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main ( string[] args )
		{
			if ( args.Length != 3 )
			{
				MessageBox.Show ( 
					 "You need to provide three least one argument. This tool runs chartscripts in WealthLab.\r\n"
				   + "Usage:  RunWealthLab  <chartscript>  <watchlist>  <symbol>",
					"RunWealthLab Error", MessageBoxButtons.OK, MessageBoxIcon.Error );
				Environment.Exit ( 0 );
			}
			WealthLab.WL3 wl = new WealthLab.WL3 ( );
			//Thread.Sleep ( 1 );
			wl.ExecuteScript ( args[0], args[1], args[2] );
			
		}
	}
}