{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________


//______________________________________________________________________________
//______________________________________________________________________________
// Main Program
  PlotSeries( BBandLowerSeries( #Close, period, sd ), 0, #Teal+1, #Thin);
  PlotSeries( SMASeries (#close, period), 0, #Maroon, #thin);
  PlotSeries( BBandUpperSeries( #Close, period, sd ), 0, #Teal+1, #Thin);
     var bbuWidth: integer;
    bbuWidth := SubtractSeries( BBandUpperSeries( #Close, 22, 2.7 ), SMASeries( #Close, 22 ) );

