{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
//------------------------------------------------------------------------------


 var bar, w: integer;
var sym, t: string;
bar := barcount-1;

t := '<'+'table border=2 cellpadding=3 cellspacing=0 bordercolor=black>';
t := t + '<'+'tr>';
t := t + '<'+'th>NAME<'+'th>ROC-10<'+'th>ROC-20<'+'th>ROC-30<'+'/tr>';

for w := 0 to WatchListCount - 1 do
begin
  sym := WatchListSymbol( w );
  SetPrimarySeries( sym );
  t := t + '<'+'tr>';
  t := t + '<'+'td>'+ Getsecurityname + '<'+'/td>'
         + '<'+'td>'+ FormatFloat( '0.00', roc(bar, #close, 10 ) )
         + '<'+'td>'+ FormatFloat( '0.00', roc(bar, #close, 20 ) )
         + '<'+'td>'+ FormatFloat( '0.00', roc(bar, #close, 30 ) );
  t := t + '<' +'/tr>';
end;

t := t + '<' + '/table>';

AddCommentary( t );
