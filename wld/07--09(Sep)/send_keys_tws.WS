{$NO_AUTO_EXECUTE}
//Blank Chartscript


var csScripting: ComVariant = CreateOleObject( 'WLExtra.Scripting' );
var compilerRes: integer = csScripting.CompileFile ( 'CsScripts\SendKeyTWS.cs.cs' );
if ( compilerRes = -1 ) then
  exit;
var instanceId: integer = csScripting.CreateInstance ( 'MyScript' );
csScripting.RunMethod1 ( instanceId, 'FindAndSetForegroundWindow', 'Untitled - Notepad' );
csScripting.RunMethod1 ( instanceId, 'SendKeys', 'Sample Text' );
csScripting.RunMethod1 ( instanceId, 'SendKeys', '{ENTER}' );



