{$NO_AUTO_EXECUTE}

var ws, obj1, obj2, obj3: comvariant;

ws := CreateOleObject('WScript.Shell');
//ws.Popup ( 'TEST' );

//ws.Run ( 'wsFuncRef.hlp' );

{ OK, No, Cancel
var lib : ComVariant =CreateOLEObject('WScript.Shell');
var x : integer = lib.Popup( AsString(PriceClose( BarCount-1 ) ), 0,'My Message',32+3);
ShowMessage ( AsString(x) );

                  }
