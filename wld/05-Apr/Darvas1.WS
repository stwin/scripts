(*Description...
This Script outlines the charting method described by Nicolas Darvas in his classic book, "How I Made 2,000,000 in the Stock Market."

Darvas forms "boxes" based on his studies of price actions.
I suggest that you read the entertaining and educational book, but here is the gist of the system:

1) If PriceHigh stops making new highs for 3 days, make the PriceHigh 3 days ago the BoxTop and go to Step 2.

2) If PriceHigh breaks BoxTop, go back to Step 1. Otherwise, If PriceLow stops making new lows for 3 days then Make the PriceLow the BoxBottom and go to Step 3.

3) Now that the BoxTop and BoxBottom are formed, we have a Darvas Box. The Darvas Box is broken when today's PriceHigh or PriceLow breaks BoxTop or BoxBottom.

I didn't form any trading plans for this charting technique. You could try buying or selling when the Darvas Box is broken. 

*)

var BOXTOP, BOXBOTTOM: float;
var BOXBOTTOMDEF, BOXTOPDEF, BOXDEF, RESET, FIRST: boolean;
var BOXTOPCOUNT, BOXBOTCOUNT, BOXDAYS, LASTBOXBAR, BAR: integer;
BoxTop := 0.0;
BoxBottom := 0.0;

BoxTopCount := 0;
BoxBotCount := 0;

BoxBottomDef := False;
BoxTopDef := False;

BoxDef := False;

Reset := False;

first := true;

BoxDays := 2;

LastBoxBar := 0;



{**************************}
for Bar := 5 to BarCount() - 1 do
begin

If First = True then
  Begin

  BoxTop := PriceHigh(Bar);

  First := false;
  BoxTopCount := 0;
  BoxBotCount := 0;
  BoxBottomDef := False;
  BoxTopDef := False;

  LastBoxBar := Bar;
  End;

If BoxDef = False then
 If PriceHigh(Bar) > BoxTop then
   Begin
   BoxTopCount := 0;
   BoxTop := PriceHigh(Bar);

   // {Resets BoxBotCount if New High is Made again}
   BoxBotCount := 0;

   End;

If BoxDef = False then
 If PriceHigh(Bar) <= BoxTop then
   Begin
   BoxTopCount := BoxTopCount + 1;
   End;

If BoxDef = False then
 If BoxTopCount = BoxDays then
  If PriceHigh(Bar) <= BoxTop then
   Begin
   BoxTopDef := True;
   End;

If BoxDef = False then
 If BoxTopDef = True then
  if BoxBottomDef = False then
    if BoxTopCount >= BoxDays+1 then

   Begin
     If BoxBotCount = 0 then
        Begin
        BoxBottom := PriceLow(Bar);
        End;

     If PriceLow(Bar) < BoxBottom then
        Begin
        BoxBotCount := 0;
        BoxBottom := PriceLow(Bar);
        End;

     If PriceLow(Bar) >= BoxBottom then
        Begin
        BoxBotCount := BoxBotCount + 1;
        End;

     If BoxBotCount = BoxDays+1 then
        Begin
        BoxBottomDef := True;
        End;

   End;

{test}

If BoxDef = False then
 If BoxTopDef = True then
       Begin
       If PriceHigh(Bar) > BoxTop then
          Begin
          First := True;
          End;
       End;

If BoxDef = False then
 If BoxBottomDef = True then
   If BoxTopDef = True then
     Begin
      BoxDef := True;

      BoxBottomDef := false;
      BoxTopDef := false;

     End;

{Darvas Box Defined}

If BoxDef = True then
   Begin

   DrawLine( Bar, BoxTop, LastBoxBar, BoxTop, 0, #Green, 2 );
   DrawLine( Bar, BoxBottom, LastBoxBar, BoxBottom, 0, #Red, 2 );



   If PriceHigh(Bar) > BoxTop then
      Begin
       BoxDef := False;

       DrawLine( LastBoxBar, BoxBottom, LastBoxBar, BoxTop, 0, #Green, 2 );
       DrawLine( Bar, BoxBottom, Bar, BoxTop, 0, #Green, 2 );


      first := true;
      BoxTop := PriceHigh(Bar);

      End;

   If PriceLow(Bar) < BoxBottom then
      Begin
      BoxDef := False;

       DrawLine( LastBoxBar, BoxBottom, LastBoxBar, BoxTop, 0, #Red, 2 );
       DrawLine( Bar, BoxBottom, Bar, BoxTop, 0, #Red, 2 );

      first := true;
      BoxTop := PriceHigh(Bar);

      End;
   End;

{second true}

If First = True then
  Begin

  BoxTop := PriceHigh(Bar);

  First := false;
  BoxTopCount := 1;
  BoxBotCount := 0;
  BoxBottomDef := False;
  BoxTopDef := False;

  LastBoxBar := Bar;

  End;

end;
