
DrawText( 'WealthLab Color Codes', 0, 300, 18, 900, 16 );
DrawText( 'This script shows different drawing colors (and their color-codes) available in Wealthlab', 0, 160, 40, 009, 10 );
//DrawText( 'WealthLab Color Codes', 0, 100, 18, 900, 16 );
//DrawText( 'This script shows different drawing colors and their color-codes available in Wealthlab', 0, 0, 40, 009, 10 );

// Hide everything possible
SetColorScheme( #White, #White, #White, #White, #White, #White );
HideVolume();

var bar, barIncrement, r, g, b: integer;
var priceLevel, topPriceLevel, levelIncrement: float;

// parameters - these can be tinkered
barIncrement := 5;
levelIncrement := 10000;
topPriceLevel := 100000;

// Quick error check - Do we have enough bars?
if( BarCount < 100 * barIncrement ) then
begin
  DrawText( '***Error! Not enough bars!!', 0, 300, 200, 900, 14 );
  DrawText( 'Need at least ' + IntToStr(100*barIncrement) + ' bars.', 0, 320, 230, 900, 14 );
  exit;
end;

SetPaneMinMax( 0, 0, topPriceLevel + levelIncrement );
bar := BarCount-1;
priceLevel := topPriceLevel;

for r := 0 to 9 do
begin
  for g := 0 to 9 do
  begin
    for b := 0 to 9 do
    begin
      var color: integer = r * 100 + g * 10 + b;
      var text: string = IntToStr(r) + IntToStr(g) + IntToStr(b);
      DrawRectangle( bar-barIncrement, priceLevel, bar, priceLevel - levelIncrement, 0, #White, #Thin, color, false );
      AnnotateChart( text, 0, bar - barIncrement+1, priceLevel - levelIncrement/2, #Black, 8 );
      priceLevel := priceLevel - levelIncrement;
    end;
    bar := bar - barIncrement;
    priceLevel := topPriceLevel;
  end;
end;


