
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WLE.dll
#IncludeLibrary CSharpScripts\CoreLib\CoreLib.cs
#IncludeFile CSharpScripts\Test2.cs
[/SCRIPT]*/


using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Threading;

using WealthLab;

//#IncludeFile CSharpScripts\Include\StdLib.cs
//#IncludeFile CSharpScripts\Include\InternalLib.cs

using CoreLib;

namespace MyScript
{
	public class MyClass 
    {
        public MyClass()
        {
			MessageBox.Show("MyScript.MyClass created");
        }

		public void TestTest ( )
		{
			try
			{
                //Print ( "It is working" );
				//MessageBox.Show ( "Test is working. CurrDir = " + Environment.CurrentDirectory 
                //        + ".  Captializatoin(MSFT) = " + tc_getCapitalization("MSFT"), "Test" );
            CoreLibClass cc = null;//new CoreLibClass();
            if (cc == null )
                MessageBox.Show("cc is null");
            else 
                MessageBox.Show("cc is NOT null");
			}


			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
		public void TestTest2 ( IWealthLabAddOn3 wl )
		{
			try
			{
				//StdLibInit ( wl );
            }
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}		
	}
}


