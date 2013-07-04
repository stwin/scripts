//______________________________________________________________________________
// normalDistribution
//
function normDist( num : float ) : float;
begin
  var x, y, z: float;
  z := 0.3989423 * Power( 2.718281828, -1 * num * num / 2 );
  y := 1 / ( 1 + 0.2316419 * Abs( num ) );
  x := 1 - z *  ( 1.330274  * y*y*y*y*y
                - 1.821256  * y*y*y*y
                + 1.781478  * y*y*y
                - 0.356538  * y*y
                + 0.3193815 * y
                );
   if( num > 0 ) then
    Result := x
   else
    Result := 1-x;
end;

//______________________________________________________________________________
// Volatility
//
function simpleVolatility() : float;
begin
  var numDays : integer = 252;
  var avgPrice : float;
  var diffSeries, squaredSeries: integer;
  var sigmaSqr, sigma: float;

  avgPrice := SMA( BarCount-1, #Close, numDays );
  diffSeries := SubtractSeriesValue( #Close, avgPrice );
  squaredSeries := MultiplySeries( diffSeries, diffSeries );
  sigmaSqr := SMA( BarCount-1, squaredSeries, numDays );
  sigma :=  Sqrt( sigmaSqr );
  Result := sigma / avgPrice;
end;
//______________________________________________________________________________
// get option price using Black-Shcoles Model
//
function getOptionPrice( riskFreeInterestRate, stockVolatility, stockPrice,
       strikePrice : float; daysLeft: integer; whatOutput: String ): float;
begin
  var daysInYear : float = 365.0;
  var timeLeft : float;          // as a percentage of year
  timeLeft := daysLeft / daysInYear;

  var Nd1, Nd2, d1, d2, numerator, denominator : float;
  var e: float = 2.718281828;

  numerator := LN(stockPrice/strikePrice)
         + (riskFreeInterestRate + stockVolatility*stockVolatility/2) * timeLeft;
  denominator := stockVolatility * Sqrt( timeLeft );
  d1 := numerator / denominator;
  d2 := d1 - stockVolatility * Sqrt( timeLeft );
  Nd1 := normDist( d1 );
  Nd2 := normDist( d2 );

  if( whatOutput = 'Delta' ) then
    Result := Nd1
  else if( whatOutput = 'Call' ) then
    Result := stockPrice * Nd1 - strikePrice * Power( e, -1*riskFreeInterestRate*timeLeft ) * Nd2
  else if( whatOutput = 'Put' ) then
  begin
    Nd1 := normDist( -d1 );
    Nd2 := normDist( -d2 );
    Result := strikePrice * Power( e, -1*riskFreeInterestRate*timeLeft ) * Nd2 - stockPrice * Nd1;
  end
  else
    abort;
end;
//______________________________________________________________________________

// Options Study
{
var v : float =  simpleVolatility();
var price : float = 70;
var strike : float = 50;
var daysLeft : integer = 156;
var callPrice : float = getOptionPrice( 0.045, v, price, strike, daysLeft, 'Call');
var putPrice : float = getOptionPrice( 0.045, v, price, strike, daysLeft, 'Put');
MyDrawLabel(    '[' + + FormatFloat( '0.00', price )
              + ', ' + + FormatFloat( '0.00', strike )
              + ', ' + + IntToStr( daysLeft ) + '] '
              + 'Call:  ' + FormatFloat( '0.00', callPrice )
              + ', Put ' + FormatFloat( '0.00', putPrice ), 036 );
 }



