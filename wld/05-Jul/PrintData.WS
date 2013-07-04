{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program


var bar: integer;
var s: string;

Print( 'Symbol : ' + #9#9 + GetSymbol );
Print( 'Company Name : ' + #9 + GetSecurityName );
Print( '--------------------------------------------------------'
     + '--------------------------------------------------------' );
Print( 'Date ' + #9#9 + 'Open' + #9 + 'High' + #9
     + 'Low' + #9 + 'Close' + #9 + 'Volume' );
Print( '--------------------------------------------------------'
     + '--------------------------------------------------------' );

for bar := BarCount-1 downto 0 do
begin
  s := IntToStr( GetDate( bar ) )
    + #9 + FormatFloat( '0.00', PriceOpen( bar ) )
    + #9 + FormatFloat( '0.00', PriceHigh( bar ) )
    + #9 + FormatFloat( '0.00', PriceLow( bar ) )
    + #9 + FormatFloat( '0.00', PriceClose( bar ) )
    + #9 + FormatFloat( '#,##0', Volume( bar ) );
  Print( s );
end;

