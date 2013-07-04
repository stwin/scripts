{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );
ChangeScale( #Daily );
{$I 'mycommon' }


//______________________________________________________________________________
procedure GenLimitBuyData();
begin
  var text: String;
  var FileName: String = 'D:\WL\UploadWeb\Test.txt';
  var file : integer = FileCreate (FileName);
  var watchListNum: integer;
  for watchListNum := 0 to WatchListCount - 1 do
  begin
    PrintStatus ('Processing: ' + IntToStr(watchListNum) +
        '/' + IntToStr(WatchListCount-1) + ' ' +  WatchListSymbol (watchListNum));

    // Read the chart table for the symbol
    try
      SetPrimarySeries (WatchListSymbol (watchListNum) );
    except
      continue;
    end;
    var ema22 : integer = BetterEMASeries (#close, 22);
    var futureEMA: float = 2*@ema22[BarCount-1] - @ema22[BarCount-2];
    var deviation: float = getElderChannelDeviation(BarCount-1, 22, 6, 90);
    var chWidth: float = 2* deviation * @ema22[BarCount-1];
    var targetPrice: float = futureEMA + chWidth * 0.35;
    var stopLossPrice: float = futureEMA - chWidth * 0.35;

    var priceAlert: float = 1.01 * futureEMA;
    priceAlert := (Round(priceAlert*100))/100;

    text :=  GetSymbol + #9
          + FormatFloat( '0.00', futureEMA ) + #9
 //         + FormatFloat( '0.00', priceAlert ) + #9
          + FormatFloat( '0.00', stopLossPrice ) + #9
          + FormatFloat( '0.00', targetPrice ) + #9
          + FormatFloat( '0', 5000/futureEMA );
    Print( text ); PrintFlush();
    FileWrite( file, text );

  end;
  FileClose( file );
end;

//______________________________________________________________________________
procedure SaveImages();
begin
  var FileName: String = 'D:\WL\WLAdapter\viewerparam.txt';
  var file : integer = FileOpen (FileName);
  FileWrite( file, 'SaveChart=1' );
  FileClose( file );

  const SCRIPTNAME = 'ElderChannelStore';
  var obj1: COMVariant;
  var w: integer;

  obj1 := CreateOleObject( 'WealthLab.WL3' );
  for w := 0 to WatchListCount - 1 do
  begin
    var symbol: string = WatchListSymbol( w );
    obj1.ExecuteScript( SCRIPTNAME, WatchListName, symbol );
    RunProgram( 'cmd /C h:\Programs\ImageMagick\convert.exe D:\WL\Images\' +  symbol + '* '
              + ' D:\WL\UploadWeb\Img\' + symbol + '.gif', true );
  end;

  file := FileOpen (FileName);
  FileWrite( file, 'SaveChart=0' );
  FileClose( file );
end;
//______________________________________________________________________________
//______________________________________________________________________________
// Main Program
GenLimitBuyData;
SaveImages;



