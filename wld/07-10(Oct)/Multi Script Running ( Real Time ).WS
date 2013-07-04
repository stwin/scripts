{$NO_AUTO_EXECUTE}

{
  Before you run the above code, make sure you
  have only three chartscript windows - 2 of your
  actual scripts and one for the above script.
  Also make sure that the Symbol entry textbox
  has the focus in each of the actual script
  window.
}

const NumScripts = 2;

var ws: ComVariant = CreateOleObject('WScript.Shell');
var i: integer;
for i := 0 to NumScripts-1 do
begin
  ws.SendKeys ( '^{TAB}' );
  Sleep ( 1 );
  ws.SendKeys ( GetSymbol );
  ws.SendKeys ( '~' );
  Sleep ( 1 );
end;

// Get Back the focus
ws.SendKeys ( '^{TAB}' );

