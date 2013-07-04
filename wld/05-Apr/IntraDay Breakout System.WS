(*Description...
THIS SYSTEM IS MADE FOR INTRA DAY DATA AND THEREFOR CAN ONLY BE USED WITH THE DESKTOP VERSION!!!

This system is a half hour breakout system. It buys, if the closing price of any bar intervall is above the highest high or below the lowest low of the first half hour time span. You can experiment with various filters. I have traded it very successfully on the DAX futures some time ago with some more filters. I have written a few lines of description what the following code is doing inbetween the code.

It also has a few nice excamples of how to code:

1. Take only one position per day
2. Trade only stocks that closing price is above 5


Have fun.

vk

*)
var OD, HIGH30, LOW30: float;
var N, NUM, BAR, COUNTER: integer;
var entrytime,exittime: Integer;



entrytime:= CreateSeries();
exittime:= CreateSeries();


{this is a function that is available on the desktop}


n := BarInterval;

if n = 0 then
begin
  ShowMessage( 'Works on intraday data only!' );
  Abort;
end;

function MarketPosition: integer;
begin
  if not LastPositionActive then
    Result := 0
  else if PositionLong( LastPosition ) then
    Result := 1
  else
    Result := -1;
end;

{setting the time interval (here 30 minutes) that i want to use}

num := ( 30 / n ) - 1;


for Bar := 20 to BarCount - 1 do
begin

{color the first 30 minutes in green}

  if BarNum( Bar ) <= num then
    SetBarColor( Bar, #Green );

{the breginning of the day}

  if BarNum( Bar ) = 0 then
    begin

{get the open of the day}

    OD := PriceOpen ( Bar );

{set a variable called "counter" to zero on every beginning of the day}

    Counter := 0;
    end;

  if BarNum( Bar ) = num then
  begin

{get the highest high and the lowest low after 30 minutes}

    High30 := Highest( Bar, #High, num + 1 );
    Low30 := Lowest( Bar, #Low, num + 1 );
  end;
  if LastBar( Bar ) then

{exit on the last bar of the day}
   begin
    SellAtClose( Bar, LastPosition, 'Last Bar' );
    Setseriesvalue(bar,exittime,gethour(bar));
    end
  else if BarNum( Bar ) > num then
  begin

{check wether the closing price of the previous day was greater then 5
( we dont want to trade penny stocks ). If it is smaller then five the
script will coninue the upper loop until the closing price is above 5.}

    if PriceClose( Bar ) < 5 then
      Continue;

{only if the Close is above five the next line will be executed}

    if PriceClose( Bar ) > High30 then
    begin
{if the closing price is greater then the first 30 minute high the bars will
be colored blue}

      SetBarColor( Bar, #Blue );

{checking that we are not long already}

      if MarketPosition <> 1 then
      begin

{if we are short then we want to cover}

        CoverAtMarket( Bar + 1, LastPosition, '' );
        Setseriesvalue(bar,exittime,gethour(bar));

{checking that we had no position on that day already, because we only want
to take one position per day}

          if Counter = 0 then
          begin
             BuyAtMarket( Bar + 1, '' );
              Setseriesvalue(bar,entrytime,gethour(bar));
{since we are getting into a position for the first time we put the counter
to one}

             Counter := 1;
          end;
       end;
    end

{see wether the close is below the first 30 minute low}

    else if PriceClose( Bar ) < Low30 then
    begin

{if it is the bars are now cloured red}

      SetBarColor( Bar, #Red );

{make sure we arent already short}

      if MarketPosition <> -1 then
      begin

{if we are long we exit the position}

        SellAtMarket( Bar + 1, LastPosition, '' );
        Setseriesvalue(bar,exittime,gethour(bar));

{make also sure we did not have any position during the day, because we only
want to take one position per day}

        if Counter = 0 then
          begin

{now we can go short}

            ShortAtMarket( Bar + 1, '' );
            Setseriesvalue(bar,entrytime,gethour(bar));
{and set the counter to one}

            Counter := 1;
          end;
      end;
    end;
  end;
end;

analyzeseries(entrytime,'entrytime');
analyzeseries(exittime,'exittime');
