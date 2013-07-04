{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

procedure PlotScatter( Series, Pane, Color: Integer );
begin
  var Bar: Integer;
  PlotSeries( #Open, pane, #Red, #Dots);
  for Bar := 0 to BarCount-1 do
    //DrawCircle( 4, Pane, Bar, GetSeriesValue(Bar, Series), Color, #Thick);
end;

var pane : integer = CreatePane(100,true,true);
PlotScatter( #Close, pane, #Red);

PlotSeries( #Open, pane, #Red, #Thin);



