{$NO_AUTO_EXECUTE}

const SCRIPTNAME = 'ElderChannelStore';
var obj: COMVariant;
var w: integer;

obj := CreateOleObject( 'WealthLab.WL3' );
for w := 0 to WatchListCount - 1 do
begin
  obj.ExecuteScript( SCRIPTNAME, WatchListName, WatchListSymbol( w ) );
  obj.ExecuteScript( 'ElderW', WatchListName, WatchListSymbol( w ) );
  Sleep(5000);
end;

