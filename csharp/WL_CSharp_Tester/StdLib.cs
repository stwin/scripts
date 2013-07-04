
/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference WlDebug.dll
[/SCRIPT]*/


using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;

using WealthLab;
using WlDebug;

//using Console = WLExtra.Console;

namespace MyScript
{
    partial class MyClass
    {

		//--------------------------------------------------------------------------------------------
		public void StdLibTest( )
		{
			try
			{
				MessageBox.Show ( "StdLib is working.", "StdLib" );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.Message + "\r\n" + e.StackTrace );
			}

		}
	}
}

