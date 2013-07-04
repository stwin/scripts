{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

//______________________________________________________________________________
// Mod of integers and return as integer
//
function ModInt( dividend, divisor: integer ): integer;
begin
  Result := Trunc( dividend Mod divisor );
end;
//______________________________________________________________________________
// Calculates number of days ( including weekend and holidays days )
// between two dates
//
function DaysBetweenDates( startDate, endDate: integer ): integer;
begin
  var year1, month1, day1, year2, month2, day2: integer;
  year1 := Trunc(startDate / 10000);
  month1 :=  ModInt( startDate, 10000 ) / 100;
  day1 := ModInt( startDate, 100 );
  year2 := Trunc(endDate / 10000);
  month2 :=  ModInt( endDate, 10000 ) / 100;
  day2 := ModInt( endDate, 100 );
  var m: array[1..12] of integer;
  m[1] := 0;
  m[2] := 31;
  m[3] := 59;
  m[4] := 90;
  m[5] := 120;
  m[6] := 151;
  m[7] := 181;
  m[8] := 212;
  m[9] := 243;
  m[10] := 274;
  m[11] := 304;
  m[12] := 334;

  var totalDays1, totalDays2: integer;
  totalDays1 := Trunc(year1 * 365.25) + m[month1] + day1;
  if( ModInt(year1, 4) = 0 ) and (month1 <= 2) then
    totalDays1 := totalDays1 - 1;
  totalDays2 := Trunc(year2 * 365.25) + m[month2] + day2;
  if( ModInt(year2, 4) = 0 ) and (month2 <= 2) then
    totalDays2 := totalDays2 - 1;
  Result := totalDays2 - totalDays1;
end;
//______________________________________________________________________________
function WeeklyBarFromDailyDate2(Date: integer): integer;
begin
  var Bar: integer;
  var Left: integer = FirstActualBar;
  var Right: integer = BarCount;
  var D: integer = 0;
  if IsWeekly then D := DaysBetweenDates(18991231, Date) mod 7;
  if IsMonthly then D := Date mod 100;
  repeat
    Bar := (Left + Right) div 2;
    if DaysBetweenDates(GetDate(Bar), Date) <= D then Right := Bar else Left := Bar + 1;
  until Left >= Right;
  Result := Right;
end;
//______________________________________________________________________________
function WeeklyBarFromDailyDate( date: integer ): integer;
begin
  const maxDays = 5;
  var bar, count, maxLoopLimit: integer;
  count := 5;
  maxLoopLimit := 100;
  while count > 0 do
  begin
    Dec( maxLoopLimit );
    if( maxLoopLimit <= 0 ) then break;
    try
      bar := DateToBar( date );
      Dec( count );
    except
    end;
    if( bar <> -1 ) then
      break;
    Dec( date );
  end;
  Result := bar;
end;

//______________________________________________________________________________
//______________________________________________________________________________
// Main Program

var bar, date: integer;

date := 20070202;   //205

bar := WeeklyBarFromDailyDate( date );

Print( IntToStr(date) + ': bar = ' + IntToStr( bar )
    + '  || wdate = ' + IntToStr(GetDate(bar)) );




