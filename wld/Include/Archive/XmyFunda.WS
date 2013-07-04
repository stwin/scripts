//{$I 'mycommon'}
//______________________________________________________________________________
procedure DisplayMarketCap();
begin
  var fileHandle: integer;
  var preStr: string = '';
  fileHandle := FileOpen( 'D:\WL\Fundamentals\KeyStats\ststats\' + GetSymbol + '.csv' );

  if( FileEOF( fileHandle ) ) then
  begin
    fileHandle := FileOpen( 'D:\WL\Fundamentals\KeyStats\yahoostats\' + GetSymbol + '.csv' );
    preStr := 'Y!  ';
  end;

  var line, marketCapStr, sharesOutStr: string;

  //MarketCapitalization,7.4B
  //SharesOutstanding,137M

  line := FileRead (fileHandle);
  marketCapStr := GetToken( line, 1, ',' );

  line := FileRead (fileHandle);
  sharesOutStr := GetToken( line, 1, ',' );

  MyDrawLabel( preStr + 'MCap:  ' + marketCapStr + '     OShares:  ' + sharesOutStr, 000 );

  FileClose( fileHandle );
end;
//______________________________________________________________________________
//
procedure DisplayMembership();
begin
  var fileHandle: integer = FileOpen( 'D:\WL\Fundamentals\Membership\Members\' + GetSymbol + '.csv' );
  var line: string = FileRead( fileHandle );
  line := Copy( line, 0, Length( line ) - 1 );
  MyDrawLabel( 'Membership: ' + line, 000 );
  FileClose( fileHandle );
end;

//______________________________________________________________________________
//______________________________________________________________________________



