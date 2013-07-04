{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////
function readWatchList(): TList;
begin
  var watchListNum: integer;
  var list : TList;

  list := TList.Create;
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    list.Add( WatchListSymbol (watchListNum) );
  end;
  Result := list;
end;
///////////////////////////////////////////////////////////////////////////////
function findCorrelation (list: TList; sp500Change, period: integer;
          corWatchList: String; corPercent: integer;
          nonCorWatchList: String; nonCorPercent: integer): TList;
begin
  var num: integer;
  var newList: TList = TList.Create;

  if Not IsDaily then
  begin
    ShowMessage ('Runs only on Daily data');
    abort;
  end;

  // Clear the new watch list if it exists
  WatchListClear (corWatchList);
  WatchListClear (nonCorWatchList);

  for num := 0 to list.Count-1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(num) +
        '/' + IntToStr(list.Count-1) + ' ' +  list.Item( num ));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (list.Item( num ) );
      var score, bar: integer;
      score := 0;
      for bar := BarCount-period to BarCount-1 do
      begin
        if( GetSeriesValue( bar, sp500Change ) > 0 )
             and ( PriceClose( bar ) > PriceOpen( bar ) )
             then
          score := score + 1;
      end;
      Print( GetSymbol + #9 + IntToStr( score )
              + #9 + FormatFloat( '#.##', PriceClose( BarCount-1 ) )
              + #9 + FloatToStr( Volume( BarCount-1 ))
              );
      var scorePer : float = 100 * score / period;
      if ( scorePer > corPercent ) then
      begin
        WatchListAddSymbol (corWatchList, '', GetSymbol);
        newList.Add( GetSymbol );
      end;
      if ( scorePer < nonCorPercent ) then
      begin
        WatchListAddSymbol (nonCorWatchList, '', GetSymbol);
      end;
    except
      continue;
    end;
  end;
  Result := newList;
end;

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program
var n1, n2: integer;
n1 := GetTickCount;

var list : TList;
var sp500Open, sp500Close, sp500Change: integer;

sp500Open := GetExternalSeries( 'SP-500', #Open );
sp500Close := GetExternalSeries( 'SP-500', #Close );
sp500Change := SubtractSeries( sp500Close, sp500Open );

list := readWatchList();

findCorrelation( list, sp500Change, 2*22, 'Prac-Correlated', 80, 'Prac-Correlated-Not', 20);

n2 := GetTickCount;
ShowMessage ('Loop took ' + IntToStr (n2 - n1) + ' ms or ' + IntToStr ((n2-n1)/1000) + ' sec to complete');

