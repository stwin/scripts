{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------

// Key words
{
WScript.Shell       Windows Script Host ( WSH )
WScript.Network     Shell Programmer's Guide
Shell.Application
Shell.Windows
}

// Example: Registry manipulation
{
var shell: COMVariant = CreateOleObject('WScript.Shell');
const KEY1 = 'HKEY_CURRENT_USER\Software\Wealth-Lab\Wealth-Lab Developer 3.0\';
var str: string;
str := shell.RegRead(KEY1 + 'Directory');
Print( str );
//shell.RegWrite( 'HKCU\MyHome\Params\TempDir', 'C:\Temp' );
}

// Environment variables
{
var shell: COMVariant = CreateOleObject( 'WScript.Shell' );
var colSystemEnvVars: COMVariant = shell.Environment( 'System' );
var colUserEnvVars: COMVariant = shell.Environment( 'User' );
Print ('System PATH = ' + colSystemEnvVars.Item('PATH') );
Print ('User PATH = ' + colUserEnvVars.Item('PATH') );
Print( 'Full PATH = ' + shell.ExpandEnvironmentStrings( '%PATH%' ) );
Print( 'TEMP = ' + shell.ExpandEnvironmentStrings( '%TEMP%' ) );
colUserEnvVars.Item('WLTest') := 'Test';
Print( 'WLTest = ' + shell.ExpandEnvironmentStrings( '%WLTest%' ) );
// http://www.microsoft.com/technet/scriptcenter/guide/sas_wsh_kmmj.mspx?mfr=true    Microsoft Windows 2000 Scripting Guide - Environment Variables
}

// Run programs
{
var shell: COMVariant = CreateOleObject( 'WScript.Shell' );
shell.Run( 'notepad' );
}

// Send KeyStrokes
{
var shell: COMVariant = CreateOleObject( 'WScript.Shell' );
shell.Run( 'notepad' );
sleep( 100 );
shell.AppActivate( 'Notepad' );
}//shell.SendKeys( 'Hello.{ENTER}How are you?' );
{
}

// Special Folders
{
var shell: COMVariant = CreateOleObject( 'WScript.Shell' );
Print( 'My Documents = ' + shell.SpecialFolders( 'MyDocuments' ) );
Print( 'Desktop = ' + shell.SpecialFolders( 'Desktop' ) );
// AllUsersDesktop    * AllUsersStartMenu    * AllUsersPrograms    * AllUsersStartup
// Desktop    * Favorites    * Fonts    * MyDocuments    * NetHood    * PrintHood
// Programs    * Recent    * SendTo    * StartMenu    * Startup    * Templates
}





// Network property and drives
{
var net: COMVariant = CreateOleObject('WScript.Network');
//net.MapNetworkDrive "S:", "\\server\share"
Print( net.UserName + '@' + net.UserDomain  );
Print( net.ComputerName );

// Here are the properties of the Network Object of WScrip.
// Computer Name 	A string representation of the computer name.
// UserDomain 	A string representation of the user's domain.
// UserName 	A string representation of the user name.

// These are the methods of Network Object of WScript.
// AddPrinterConnection 	Maps a remote printer to a local resource name.
// EnumNetworkDrives 	Returns the current network drive mappings.
// EnumPrinterConnections 	Returns the current network drive mappings.
// MapNetworkDrive 	Maps a share point to a local resource name.
// RemoveNetworkDrive 	Removes the current resource connection.
// RemovePrinterConnection 	Removes a current resource connection.
// SetDefaultPrinter 	Sets the default printer.
}


// Example: Directory Browser
{
var shell, folder, folderItem: COMVariant; //
shell := CreateOleObject('Shell.Application');
var str: string;
folder := shell.BrowseForFolder(0, 'Select a Folder', 0, 'C:\Temp' );
folderItem := folder.Items().Item();
str := folderItem.Path();
Print( str );
}

// Example: File System Manipulation
{
var fso: COMVariant = CreateOleObject('Scripting.FileSystemObject');
var fileHandle: COMVariant = fso.CreateTextFile( 'C:\Temp\test.txt' );
fileHandle.WriteLine( 'This is a test.' );
fileHandle.Close();
// f = fso.OpenTextFile( outputfile, 2, true ); // Open the output file for writing, create if necessary
// http://msdn2.microsoft.com/en-us/library/bkx696eh.aspx
// http://msdn2.microsoft.com/en-us/library/z9ty6h50.aspx
// http://msdn2.microsoft.com/en-us/library/832c8c0x.aspx
// Other methods:
// BuildPath Method | CopyFile Method | CopyFolder Method | CreateFolder Method |
// CreateTextFile Method | DeleteFile Method | DeleteFolder Method |
// DriveExists Method | FileExists Method | FolderExists Method |
// GetAbsolutePathName Method | GetBaseName Method | GetDrive Method |
// GetDriveName Method | GetExtensionName Method | GetFile Method |
// GetFileVersion Method | GetFileName Method | GetFolder Method |
// GetParentFolderName Method | GetSpecialFolder Method | GetStandardStream Method |
// GetTempName Method | MoveFile Method | MoveFolder Method | OpenTextFile Method
}



