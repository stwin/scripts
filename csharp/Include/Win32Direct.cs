using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Drawing;
using System.Runtime.InteropServices;

namespace MyScript
{
	public class Win32Direct
	{
		public Win32Direct ( )
		{
			//
			// TODO: Add constructor logic here
			//
		}

		//___________________________________________________________________________
		// Set Environment Variable
		//---------------------------------------------------------------------------
		[DllImport ( "kernel32.dll", CharSet = CharSet.Auto, SetLastError = true )]
		[return: MarshalAs ( UnmanagedType.Bool )]
		public static extern bool SetEnvironmentVariable ( string lpName, string lpValue );
		public static bool SetEnvironmentVariableEx ( string environmentVariable, string variableValue )
		{
			return SetEnvironmentVariable ( environmentVariable, variableValue );
			/*
			try
			{
				// Get the write permission to set the environment variable.
				EnvironmentPermission environmentPermission = new EnvironmentPermission (EnvironmentPermissionAccess.Write, environmentVariable);
				environmentPermission.Demand(); 
				return SetEnvironmentVariable(environmentVariable, variableValue);
			}
			catch( SecurityException e)
			{
				return false;
			}
			return false;
			*/
		}
	}
}
