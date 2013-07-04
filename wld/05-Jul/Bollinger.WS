{$NO_AUTO_EXECUTE}
UseUpdatedEma (true);

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program

PlotSeries (EMASeries(#close, 20), 0, #maroon, #Thin);

PlotSeries (BBandLowerSeries(#close, 20, 2), 0, #blue, #Thin);
PlotSeries (BBandUpperSeries(#close, 20, 2), 0, #blue, #Thin);

PlotSeries (BBandLowerSeries(#close, 20, 1.5), 0, #aqua, #Thin);
PlotSeries (BBandUpperSeries(#close, 20, 1.5), 0, #aqua, #Thin);



