//______________________________________________________________________________
// Save the chart
//
procedure SaveChartWithSize( width, height: integer );
begin
  var fileName: String;
  var Bar: integer;
  //PrintStatus( 'SaveChart: First you should zoom in, then print' );
  if (IsDaily) then
  begin
    fileName := GetSymbol + '-daily-' + IntToStr( GetMonth( BarCount-1 ) );
  end
  else if (IsWeekly) then
  begin
    fileName := GetSymbol + '-weekly';
  end
  else begin
    fileName := GetSymbol + '-unknownTimeFrame';
  end;

  SetColorScheme (050, 800, 222, 999, 887, 799);

  fileName :=  rootDir + '\Images\' + fileName + '.bmp';
  SaveChartImage( fileName, width, height, 'BMP' );

  var str: String = myclass.GetDayStr( BarCount-1 );
  var dateInfo: string = DateToStr( getDate( BarCount-1 ) ) + '  ' + myclass.GetDayStr( BarCount-1 );

  var image: ComVariant;
  image := CreateOleObject( 'WLExtra.Image' );
  image.Open( fileName );
  image.DrawRectangle( 7, 19, 120, 37, 999, 0, 999 );
  image.DrawText( dateInfo, 7, 19, 0, 10 );
  image.Save( fileName, 'bmp' );
  image.Close();
end;
//______________________________________________________________________________
// Save the chart
//
procedure SaveChart ();
begin
  SaveChartWithSize( 1024, 768 );
end;

