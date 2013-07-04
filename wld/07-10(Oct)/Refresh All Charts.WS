{$NO_AUTO_EXECUTE}

{
  Refreshes all the charts in the main window.
}

const NumScripts = 8;

var ws: ComVariant = CreateOleObject('WScript.Shell');
var i: integer;
for i := 0 to NumScripts-1 do
begin
  ws.SendKeys ( '^{TAB}' );
  Sleep ( 1 );
  ws.SendKeys ( '{F5}' );
  Sleep ( 1000 );
end;

// Get Back the focus
ws.SendKeys ( '^{TAB}' );


