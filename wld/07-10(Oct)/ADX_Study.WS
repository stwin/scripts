{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
PlotSeries( EMASeries( #close, 11), 0, 777, #thin );
PlotSeries( EMASeries( #close, 22), 0, #Maroon, #thin );
//------------------------------------------------------------------------------


var ADXPane: integer = CreatePane( 60, false, true );
//SetPaneMinMax ( ADXPane, 0, 10 );
PlotSeriesLabel( DIMinusSeries( 14 ), ADXPane, 900, #Thin, 'DIMinus( 14 )' );
PlotSeriesLabel( DIPlusSeries( 14 ), ADXPane, 050, #Thin, 'DIPlus( 14 )' );
PlotSeriesLabel( ADXSeries( 14 ), ADXPane, 009, #Thick, 'ADX( 14 )' );


