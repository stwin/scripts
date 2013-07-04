{$NO_AUTO_EXECUTE}
//Blank Chartscript

// Launch debug window - Method 1
var obj: ComVariant = CreateOleObject( 'WScript.Shell' );

// Send the shortcut keys.
obj.SendKeys( '^%d' );

// Method 2 - from the View Menu
// obj.SendKeys( '%vd' );
