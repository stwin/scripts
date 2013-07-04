{$NO_AUTO_EXECUTE}


var bar, s1, s2, s3, s4: integer;

s1 := SMASeries ( #High, 20 );
s2 := SMASeries ( #High, 20 );

for bar := 0 to BarCount-1 do
begin
  @s1[bar] := @#Close[bar];
  @s2[bar] := @#Volume[bar];
end;

s3 := SMASeries ( s1, 10 );
s4 := SMASeries ( s2, 10 );

Print ( AsString(@s3[BarCount-2]) + #9 + AsString(@s3[BarCount-1]) );
Print ( AsString(@s4[BarCount-2]) + #9 + AsString(@s4[BarCount-1]) );


