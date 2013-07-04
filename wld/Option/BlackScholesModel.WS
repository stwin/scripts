{$NO_AUTO_EXECUTE}

//______________________________________________________________________________
// returns String representation of a month (1-12)
//
function getMonthStr( num: integer ): String;
begin
  if( num = 1 ) then
    Result := 'JAN'
  else if( num = 2 ) then
    Result := 'FEB'
  else if( num = 3 ) then
    Result := 'MAR'
  else if( num = 4 ) then
    Result := 'APR'
  else if( num = 5 ) then
    Result := 'MAY'
  else if( num = 6 ) then
    Result := 'JUN'
  else if( num = 7 ) then
    Result := 'JUL'
  else if( num = 8 ) then
    Result := 'AUG'
  else if( num = 9 ) then
    Result := 'SEP'
  else if( num = 10 ) then
    Result := 'OCT'
  else if( num = 11 ) then
    Result := 'NOV'
  else if( num = 12 ) then
    Result := 'DEC';
end;
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
//______________________________________________________________________________
// Main Program
//

if (Not IsDaily) then
begin
  ShowMessage ('Runs only on Daily data');
  abort;
end;

var riskFreeInterestRate : float = 0.045;

var stockVolatility : float;
stockVolatility := simpleVolatility();
Print( 'Volatility = ' + FormatFloat( '0.##', stockVolatility ) );

//Print( 'delta = ' + FloatToStr( getOptionPrice(0.10, 0.30, 45, 50, 60, 'Delta') ) );
//Print( 'callPrice = ' + FloatToStr( getOptionPrice(0.10, 0.30, 45, 50, 60, 'Call') ) );

var i, remaingDays, nextOptionMonth: integer;
// find nextOptionMonth and try to guess remainingDays
for i := 1 to 30 do
begin
  if( OptionExpiryDate( Barcount-i ) ) then
  begin
    remaingDays := Round( 30 - i * 7.0 / 5.0 );
    if( GetMonth( BarCount-1 ) = GetMonth( Barcount-i ) ) then
      nextOptionMonth := ( GetMonth(BarCount-1)-1 + 1 ) Mod 12 + 1
    else
      nextOptionMonth := GetMonth(BarCount-1)-1 Mod 12 + 1;
    break;
  end;
end;

remaingDays := 5;   // accurate remaingDays
Print( 'remaingDays = ' + IntToStr(remaingDays) );

var monCount: integer;
for monCount := 0 to 8 do
begin
  var daysLeft : integer = 31 * monCount + remaingDays;
  var stockPrice : float = @#Close[BarCount-1] + 0.000011;;
  var lowestStrike : float = ( Trunc((stockPrice+0.0000002) / 5.0) - 1 ) * 5;
  var count: integer;
  var line: String;
  
  if( monCount = 0 ) then
  begin
    var headerLine, line: String;
    headerLine := 'MNT';
    for count := 0 to 3 do
    begin
      var strikePrice: float;
      strikePrice := lowestStrike + count * 5;
      headerLine := headerLine + #9 + FormatFloat( '#.##', strikePrice );;
    end;
    Print( headerLine );
    Print( '---------------------------------------------------------------' );
  end;
  line := getMonthStr( nextOptionMonth );
  for count := 0 to 3 do
  begin
    var strikePrice, optionPrice : float;
    strikePrice := lowestStrike + count * 5;
    optionPrice := getOptionPrice( riskFreeInterestRate, stockVolatility,
              stockPrice, strikePrice, daysLeft, 'Put');
    line := line + #9 + FormatFloat( '0.##', optionPrice );
  end;
  Print( line );
  nextOptionMonth := nextOptionMonth Mod 12 + 1;
end;


