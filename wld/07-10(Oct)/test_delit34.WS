{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
//------------------------------------------------------------------------------

var startbar: integer = DateToBar(20071012 );

var bar: integer;
var msg: string = '';

for bar := startbar to Barcount-1 do
begin
  msg := msg + ( Formatfloat('#.##',PriceClose(bar)) + ';' );
   print ( asstring(getdate(bar)) );
end;

Print ( msg );

