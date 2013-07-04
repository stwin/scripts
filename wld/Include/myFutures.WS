
//______________________________________________________________________________
// Display Quotes Plus 3 Futures Security Names
//------------------------------------------------------------------------------
procedure DisplayQP3FuturesName;
begin
  var symName: string = GetSymbol;
  var month, year: integer;
  if ( Length( symName ) = 8 ) then  // Is it renamed files?
  begin
    year := StrToInt( Copy( symName, 3, 4 ) );
    month := StrToInt( Copy( symName, 7, 2 ) );
  end
  else  // The default Quotes Plus 3 files
  begin
    year := StrToInt( Copy( symName, 5, 2 ) );
    month := StrToInt( Copy( symName, 3, 2 ) );
  end;

  var postFix: string;
  
  // Is it a continous contract ?
  if ( month = 16 ) then
  begin
    case year of
      0, 2000: postFix := 'Continuous Volume Rollover';
      1, 2001: postFix := 'Continuous Expiration Rollover';
      2, 2002: postFix := 'Continuous Volume Threshhold Rollover';
      else     postFix := 'Continuous Custom Rollover';
    end;
  end;
  
  // Is it cash ?
  if ( month = 15 ) then
    postfix := 'Cash';
    
  // Individual Contracts
  if ( month <= 12 ) then
  begin
    case month of
      1:  postFix := 'January';
      2:  postFix := 'February';
      3:  postFix := 'March';
      4:  postFix := 'April';
      5:  postFix := 'May';
      6:  postFix := 'June';
      7:  postFix := 'July';
      8:  postFix := 'August';
      9:  postFix := 'September';
      10: postFix := 'October';
      11: postFix := 'November';
      12: postFix := 'December';
    end;
    postFix := postFix + ', ' + IntToStr( year );
  end;

  var secCode: string = Copy( symName, 0, 2 );
  var secName: string = 'Not Known';
  case secCode of
    'EN': secName := 'E-Mini Nasdaq Composite';
    'ER': secName := 'E-Mini Russell 2000 Index';
    'M5': secName := 'E-Mini S&P 500 Stock Index';
    'RE': secName := 'E-Mini Russell 2000 Index';
    'EQ': secName := 'E-Mini Nasdaq Stock Index';
    'SM': secName := 'E-Mini S&P 400 Midcap Indexonic Sess';
    'NQ': secName := 'Nasdaq Stock Index';
    'NM': secName := 'Nasdaq Stock Index Combined Session';
    'N1': secName := 'Nasdaq Stock Index Globex Session';
    'R2': secName := 'Russell 2000 Index';
    'R4': secName := 'Russell 2000 Index Combined Session';
    'RG': secName := 'Russell 2000 Index Globex Session';
    'S3': secName := 'S&P 400 Midcap Index Day Session';
    'S4': secName := 'S&P 400 Midcap Index Combined Session';
    'S2': secName := 'S&P 400 Midcap Index Globex Session';
    'S5': secName := 'S&P 500 Stock Index';
    'SP': secName := 'S&P 500 Stock Index Combined Session';
    'S6': secName := 'S&P 500 Stock Index Globex Session';
  end;
  
  var description: string = secName + ' - ' + postFix;
  DrawText( description, 0, 130, 3, 005, 11 );
end;

//------------------------------------------------------------------------------

DisplayQP3FuturesName;

//------------------------------------------------------------------------------



