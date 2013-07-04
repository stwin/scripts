
{$NO_AUTO_EXECUTE}
const SCRIPTNAME = 'ChartImageSaver';
var WatchList: string = WatchListName;
var obj: COMVariant;
var w: integer;
var sym: string;

obj := CreateOleObject( 'WealthLab.WL3' );
for w := 0 to WatchListCount - 1 do
begin
  sym := WatchListSymbol( w );
  obj.ExecuteScript( SCRIPTNAME, WatchList, sym );
end;
