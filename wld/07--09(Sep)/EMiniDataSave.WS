(*Description...
<html><b>mytext</b>
<i>italic</i>

*)
{$NO_AUTO_EXECUTE}

var bar, fileHandle : integer;
var text : string;

//fileHandle := FileCreate ( 'D:\WLE\Futures\Data\' + GetSymbol + '.csv' );

for bar := 0 to BarCount-1 do
begin
  text :=     IntToStr(GetDate(bar)) + ',' +
              FormatFloat( '0000', GetTime(bar)) + ',' +
              FormatFloat( '0.00', PriceOpen(bar) ) + ',' +
              FormatFloat( '0.00', PriceHigh(bar) ) + ',' +
              FormatFloat( '0.00', PriceLow(bar) ) + ',' +
              FormatFloat( '0.00', PriceClose(bar) ) + ',' +
              FormatFloat( '0', Volume(bar) )
              ;
  //FileWrite ( fileHandle, text );
  Print ( text );
end;

//FileClose( fileHandle );





