{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );

// I could not make this script working. - 2/1/07

//______________________________________________________________________________
//
function CandleReversalWatchList(): boolean;
begin
  Result := true;
  
  // Second last should be red
  if( PriceClose(BarCount-2) > PriceOpen(BarCount-2) ) then
    exit;
  // Last bar should be green
  if( PriceClose(BarCount-1) < PriceOpen(BarCount-1) ) then
    exit;
  // Last bar close should be less than EMA11
  if( PriceClose(BarCount-1) > EMA(BarCount-1, #Close, 11) ) then
    exit;

  Result := true;
end;

//______________________________________________________________________________
//
// Main Program
var n1, n2: integer;

n1:= GetTickCount;

if Not IsDaily then
begin
  ShowMessage ('Runs only on Daily data');
  abort;
end;

if( true = CandleReversalWatchList() ) then
begin
  if( GetSymbol = WatchListSymbol( 0 ) ) then
    WatchListClear( 'C-CandelRevList' );
  WatchListAddSymbol( 'C-CandelRevList', '', GetSymbol);
end;

n2:= GetTickCount;
//ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

