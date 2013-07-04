{$NO_AUTO_EXECUTE}

var isCOM : boolean;

// If it is called from OLE, then don't do anything
var isCOMVal: variant  =  GetGlobal ('VMCIsCOM');
if (null <> isCOMVal) and (1 = isCOMVal) then
  exit;

var wlist: string = WatchlistName;
//var wlist: string = 'EOD';

// Execute scripts
var obj: COMVariant;
obj := CreateOleObject( 'WealthLab.WL3' );
obj.ExecuteScript( 'ElderChannelStore', wlist, GetSymbol );
obj.ExecuteScript( 'ElderChannelStoreW', wlist, GetSymbol );

// Get focus back
SetGlobal ('VMCIsCOM', 1);
obj.ExecuteScript( 'ViewMultiChartscript', WatchListName, GetSymbol );
SetGlobal ('VMCIsCOM', 0);


{

var isCOM : boolean;

var isCOMVal: variant  =  GetGlobal ('VMCIsCOM');
if (null = isCOMVal) or (0 = isCOMVal) then
begin
  isCOM := false;
end
else   // isCOMVal = 1
begin
  isCOM := true;
end;

if (not isCOM) then
begin
  var obj: COMVariant;
  obj := CreateOleObject( 'WealthLab.WL3' );
  obj.ExecuteScript( 'Elder', WatchListName, GetSymbol );
  obj.ExecuteScript( 'Elderw', WatchListName, GetSymbol );
  SetGlobal ('VMCIsCOM', 1);
  obj.ExecuteScript( 'ViewMultiChartscript', WatchListName, GetSymbol );
  SetGlobal ('VMCIsCOM', 0);
end;
}
