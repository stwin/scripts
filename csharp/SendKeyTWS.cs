using System;                                                                
using System.Runtime.InteropServices;                                        
using System.Drawing;                                                        
using System.Windows.Forms;                                                  
                                                                             
public class MyScript1                                                        
{                                                                            
	// Get a handle to an application window.                                  
	[DllImport("USER32.DLL")]                                                  
	public static extern IntPtr FindWindow(string lpClassName,                 
	string lpWindowName);                                                      
                                                                             
	// Activate an application window.                                         
	[DllImport("USER32.DLL")]                                                  
	public static extern bool SetForegroundWindow(IntPtr hWnd);                
                                                                             
	IntPtr handle = IntPtr.Zero;                                               
                                                                             
	public void FindAndSetForegroundWindow( string title )                     
	{                                                                          
		// Get a handle to the window                                            
		handle = FindWindow(null, title);                                        
                                                                             
		// Verify that we have a valid handle.                                   
		if (handle == IntPtr.Zero)                                               
		{                                                                        
			MessageBox.Show("Could not find a valid handle for '" + title + "'", 
				"Error in FindAndSetForegroundWindow");                      
			return;                                                                
		}                                                                        
		SetForegroundWindow(handle);                                             
	}                                                                          
                                                                             
	public void SendKeys ( string keysSeq )                                    
	{                                                                          
		System.Windows.Forms.SendKeys.SendWait( keysSeq );	                     
	}                                                                          
}


