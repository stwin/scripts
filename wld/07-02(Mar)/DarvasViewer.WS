{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
// The EMA series starts at 1st Bar.
//------------------------------------------------------------------------------
function BetterEMASeries( Series, period: integer ): integer;
begin
  var MA, bar: integer;
  var C: float;

  C := 2/(1+period);

  if( BarCount-1 < period ) then
    period := BarCount-1;
    
  MA := AddSeriesValue(EMASeries( Series, period ), 0);
  bar := 0;

  for bar := 0 to BarCount-1 do
  begin
    if( @Series[bar] <> 0) then
      break;
  end;

  @MA[bar] := @Series[bar];

  for bar := bar+1 to period do
  begin
    @MA[bar] := C * @Series[bar] + (1-C) * @MA[bar-1];
  end;
  Result := MA;
end;
//______________________________________________________________________________
// Color the Volume bars
//------------------------------------------------------------------------------
procedure VolumeColor ();
begin
  var Bar: integer;
  for Bar := 0 to BarCount - 1 do
    if PriceClose( Bar ) > PriceOpen( Bar ) then
      SetSeriesBarColor( Bar, #Volume, #Green )
    else
      SetSeriesBarColor( Bar, #Volume, #Red );
end;


//______________________________________________________________________________
// Main Program
//------------------------------------------------------------------------------
VolumeColor();
PlotSeries( BetterEMASeries( #close, 13), 0, 777, #thin );
PlotSeries( BetterEMASeries( #close, 26), 0, #Maroon, #thin );
//------------------------------------------------------------------------------



