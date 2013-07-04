/*[SCRIPT]
#AddReference Interop.WealthLab.dll
#AddReference Interop.TC2000Dev.dll
#AddReference WLE.dll
[/SCRIPT]*/

//#IncludeFile CSharpScripts\CoreLib\Telechart.cs

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Diagnostics;

//using TC2000Dev;

namespace CoreLib1
{
    public class CoreLibClass
    {
        public CoreLibClass()
        {
            MessageBox.Show("CoreLib1 initialized");
        }
    }
}

