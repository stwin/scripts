var Bar: integer;
var scoreGoingDown, scoreGoingUp : integer;
var myMACDSeries, myMACDSignalSeries, MHist, MPane : integer;
var macdUp, macdRising : boolean;

myMACDSeries :=  MACDSeries( #Close );
myMACDSignalSeries :=  EMASeries( MACDSeries( #Close ), 9 );
MHist := SubtractSeries( myMACDSeries, myMACDSignalSeries);
MPane := CreatePane( 100, true, true );
PlotSeries( myMACDSeries, MPane, #Red, #Thick );
PlotSeries( myMACDSignalSeries, MPane, #Blue, #Thin );
PlotSeries( MHist, MPane, #Black, #Histogram );
DrawLabel( 'MACD and 9 period Signal Line', MPane );

for Bar := 20 to BarCount - 1 do
begin
  scoreGoingUp := 0;
  scoreGoingDown := 0;

  if (PriceLow (Bar) < PriceLow (Bar-1)) then
    scoreGoingDown := scoreGoingDown + 1;
  if (PriceLow (Bar) < PriceLow (Bar-2)) then
    scoreGoingDown := scoreGoingDown + 1;
  if (PriceHigh (Bar) < PriceHigh (Bar-1)) then
    scoreGoingDown := scoreGoingDown + 1;
  if (PriceHigh (Bar) < PriceHigh (Bar-2)) then
    scoreGoingDown := scoreGoingDown + 1;

  if (PriceLow (Bar) > PriceLow (Bar-1)) then
    scoreGoingUp := scoreGoingUp + 1;
  if (PriceLow (Bar) > PriceLow (Bar-2)) then
    scoreGoingUp := scoreGoingUp + 1;
  if (PriceHigh (Bar) > PriceHigh (Bar-1)) then
    scoreGoingUp := scoreGoingUp + 1;
  if (PriceHigh (Bar) > PriceHigh (Bar-2)) then
    scoreGoingUp := scoreGoingUp + 1;

   if (GetSeriesValue (Bar, myMACDSeries) > GetSeriesValue (Bar, myMACDSignalSeries)) then
      macdUp := true
   else
      macdUp := false;

   if (GetSeriesValue (Bar, MHist) > GetSeriesValue (Bar-1, MHist)) then
      macdRising := true
   else
      macdRising := false;
      
    //AnnotateBar ( IntToStr (scoreGoingUp),Bar, true, #Blue, 8);
    //AnnotateBar ( IntToStr (scoreGoingDown),Bar, false, #Blue, 8);
  Print ('scoreGoingUp = ' + IntToStr(scoreGoingUp) + '  scoreGoingDown = ' + IntToStr (scoreGoingDown));
  if (scoreGoingUp >= 3) And (ScoreGoingdown >= 3) then
  Abort;
  //AddCommentary ('scoreGoingUp = ' + IntToStr(scoreGoingUp) + '  scoreGoingDown = ' + IntToStr (scoreGoingDown));


  // Bullish
  if (scoreGoingUp >= 3) then
  begin
    setBarcolor (Bar, #Green);
    if LastPositionActive then
    begin
      if (PositionShort (LastPosition)) then
            CoverAtMarket (Bar+1, LastPosition, '');
    end;
    if (Not LastPositionActive) And macdUp And macdRising then
    begin
       BuyAtMarket (Bar+1, '');
    end;
  end;
  
  // Bearish
  if (scoreGoingDown >= 3) then
  begin
    setBarColor (Bar, #Red);
    if LastPositionActive then
    begin
      if (PositionLong (LastPosition)) then
            SellAtMarket (Bar+1, LastPosition, '');
    end;
    if (Not LastPositionActive) And (Not macdUp) And (Not macdRising) then
    begin
       ShortAtMarket (Bar+1, '');
    end;
  end;
end;
