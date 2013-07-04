(*Description...
<h2>Date Study IV</h2>
<p><hr><font color=blue><b>Description:</b></font>
<br>This library consists of functions designed to aide in date manipulations. This version corrects an error in the SubTradingDaysInt  and AddTradingDaysInt functions.
<br><hr><font color=blue><b>Syntax:</b></font>

<br><tt>StrValue := <font color=blue>JulianToDateStr</font>( <b>JulianDate</b>: integer );</tt>
<br><tt>IntValue := <font color=blue>DateStrToJulian</font>( <b>DateStr</b>: string);</tt>
<br><tt>IntValue := <font color=blue>JulianToDateInt</font>( <b>JulianDate</b>: integer );</tt>

<br><tt>IntValue := <font color=blue>DateIntToJulian</font>( <b>DateInt</b>: integer );</tt>
<br><tt>IntValue := <font color=blue>AddCalenDaysInt</font>( <b>BegDate</b>, <b>Days</b>: integer );</tt>
<br><tt>IntValue := <font color=blue>SubCalenDaysInt</font>( <b>BegDate</b>, <b>Days</b>: integer );</tt>

<br><tt>StrValue := <font color=blue>AddCalenDaysStr</font>( <b>BegDate</b>: string, <b>Days</b>: integer );</tt>
<br><tt>StrValue := <font color=blue>SubCalenDaysStr</font>( <b>BegDate</b>: string, <b>Days</b>: integer );</tt>
<br><tt>IntValue := <font color=blue>AddTradingDays</font>( <b>Bar, Days</b>: integer );</tt>

<br><tt>IntValue := <font color=blue>SubTradingDays</font>( <b>Bar, Days</b>: integer );</tt>
<br><hr><font color=blue><b>A Few Examples:</b></font>
<br>Note: The date string (DateStr) format is the short date format  currently set in  your Windows Control Panel Regional Options. This example uses the English(US) format.  
<br>
<br> The date integer (DateInt) is always YYYYMMDD
<br>
<br><table border="1" cellpadding="2" cellspacing="0" style="border-collapse: collapse" bordercolor="#63659C" width="100%" bgcolor="#FFFFFF"><tr><td width="100%"><font color="#666666" face="Courier New"><tt><font color="#008000">{$I' Date Study IV'}</font>
<br>
<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( AddCalenDaysStr( <font color="#800080">'11/3/20063'</font>, 65 ) );

<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( <a href="cgi-bin/WealthLab.DLL/getdoc?id=86" style="color: #0000FF">IntToStr</a>( AddCalenDaysInt( 20031123, 65 ) ) );
<br>
<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( SubCalenDaysStr( <font color="#800080">'01/27/2004'</font>, 65 ) );
<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( <a href="cgi-bin/WealthLab.DLL/getdoc?id=86" style="color: #0000FF">IntToStr</a>( SubCalenDaysInt( 20040127, 65 ) ) );
<br>
<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( <a href="cgi-bin/WealthLab.DLL/getdoc?id=86" style="color: #0000FF">IntToStr</a>( AddTradingDays( <a href="cgi-bin/WealthLab.DLL/getdoc?id=33" style="color: #0000FF">BarCount</a>-100, 8 ) ) );

<br><a href="cgi-bin/WealthLab.DLL/getdoc?id=264" style="color: #0000FF">print</a>( <a href="cgi-bin/WealthLab.DLL/getdoc?id=86" style="color: #0000FF">IntToStr</a>( SubTradingDays( <a href="cgi-bin/WealthLab.DLL/getdoc?id=33" style="color: #0000FF">BarCount</a>-1, 10 ) ) );</tt>
<br></font></td></tr></table>
<br>
</p>

*)
function _jul( y, m, d: integer ): integer;
begin
  var a, s, j1, jd: float;

  jd := -1 * Int( 7 * ( Int( ( m + 9 ) / 12 ) + y ) / 4 );
  s := integer( ( ( m - 9 ) < 0 ) or 1 );
  a := Abs( m - 9 );
  j1 := Int( y + s * Int( a / 7 ) );
  j1 := -1 * Int( ( Int( j1 / 100 ) + 1 ) * 3 / 4 );
  jd := jd + Int( 275 * m / 9 ) + d + j1;
  jd := jd + 1721029 + 367 * y + 0.5;
  Result := Int( jd );
end;

function _rev( n: integer ): integer;
begin
  var t, w, x, y, z: float;

  x := n + 68569;
  y := Trunc( 4 * x / 146097 );
  x := x - Trunc( ( 146097 * y + 3 ) / 4 );
  z := Trunc( 4000 * ( x + 1 )/1461001 );
  x := x - Trunc( 1461 * z / 4 ) + 31;
  w := Trunc( 80 * x / 2447 );
  t := x - Trunc( 2447 * w / 80 );
  x := Trunc( w / 11 );
  w := w + 2 - 12 * x;
  z := 100 * ( y - 49 ) + z + x;
  Result := Int( z ) * 10000 + int( w )* 100 + int( t );
end;

function DateStrToJulian( DateStr: string ): integer;
begin
  //DateStr = Your International Date String
  var y, m, d: integer;

  d := StrToDate( DateStr );
  y := d div 10000;
  m := ( d mod 10000 ) div 100;
  d := ( d mod 10000 ) mod 100;
  Result := _jul( y, m, d );
end;

function JulianToDateStr( JulianDate: integer ): String;
begin
  Result := DateToStr( _rev( JulianDate ) );
end;

function DateIntToJulian( DateInt: integer ): integer;
begin
  //DateInt - YYYYMMDD
  var y, m, d: integer;

  y := DateInt div 10000;
  m := ( DateInt mod 10000 ) div 100;
  d := ( DateInt mod 10000 ) mod 100;
  Result := _jul( y, m, d );
end;

function JulianToDateInt( JulianDate: integer ): integer;
begin
  var n: integer;
  var y, m, d: integer;

  n := _rev( JulianDate );
  y := n div 10000;
  m :=( n mod 10000 ) div 100;
  d :=( n mod 10000 ) mod 100;
  Result := y*10000+m*100+d;
end;

function AddCalenDaysInt( BegDate, Days: integer ): integer;
begin
  Result := JulianToDateInt( DateIntToJulian( BegDate ) + Days );
end;

function SubCalenDaysInt( BegDate, Days: integer): integer;
begin
  Result := JulianToDateInt( DateIntToJulian( BegDate ) - Days );
end;

function AddCalenDaysStr( BegDate: string; Days: integer ): string;
begin
  Result := JulianToDateStr( DateStrToJulian( BegDate ) + Days );
end;

function SubCalenDaysStr( BegDate: string; Days: integer): string;
begin
  Result := JulianToDateStr( DateStrToJulian( BegDate ) - Days );
end;

function AddTradingDays( Bar, Days: integer ): integer;
begin
  repeat
    try
      Result := GetDate( Bar+Days );
    except
      Dec( Days );
    end;
  until (Result > 0);
end;

function SubTradingDays( Bar, Days: integer ): integer;
begin
  repeat
    try
      Result := GetDate( Bar-Days );
    except
      Inc( Days );
    end;
  until (Result > 0);
end;



