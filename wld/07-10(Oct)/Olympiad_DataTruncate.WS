{$NO_AUTO_EXECUTE}

var Bar, StartBar: integer;
StartBar := AsInteger(Max( 200, DateToBar ( 20070913 )));
Print ( 'StartBar = ' + AsString(StartBar) );

var dir : string = 'D:\WLE\Olympiad\IndexFutures\';
var file : integer = FileCreate( dir + GetSymbol + '.csv' );

for Bar := StartBar to Barcount-2 do
begin
  if ( (GetTime(Bar) < 700) or (GetTime(Bar) > 1630 ) ) then continue;
  var line: string = AsString( GetDate( Bar ) )
             + ',' + AsString( GetTime( Bar ) )
             + ',' + FormatFloat( '#.00', PriceOpen( Bar ) )
             + ',' + FormatFloat( '#.00', PriceHigh( Bar ) )
             + ',' + FormatFloat( '#.00', PriceLow( Bar ) )
             + ',' + FormatFloat( '#.00', PriceClose( Bar ) )
             + ',' + AsString( Volume( Bar ) );
  FileWrite( file, line );
end;
FileClose( file );

