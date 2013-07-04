{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

// Click on TC-AllItems watchlist
// This will create a watchlist of all TC industry groups  2/1/07


///////////////////////////////////////////////////////////////////////////////
procedure MakeIndustryGroupWatchList( newWatchList: String );
begin
  var watchListNum: integer;

  // Clear the new watch list if it exists
  WatchListClear( newWatchList );

  for watchListNum := 0 to WatchListCount - 1 do
  begin
    var sym: string = WatchListSymbol( watchListNum );
    if( (Length( sym ) = 5) and ( Copy( sym, 1, 2 ) = 'MG' ) ) then
    begin
    try
      var industryNum: integer = StrToInt( Copy( sym, 3, 3 ) );
      WatchListAddSymbol( newWatchList, '', sym );
      //Print( sym );  PrintFlush;
    except
      // It is of length 5 and starts with MG, but is not an industry group
    end;
  end;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// Main Program

MakeIndustryGroupWatchList( 'TC-Industries' );


