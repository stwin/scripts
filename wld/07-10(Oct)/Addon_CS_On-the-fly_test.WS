{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );


var csScripting: ComVariant = CreateOleObject( 'WLE.CSharp' );
var myclass : ComVariant = csScripting.LoadFile ( 'CSharpScripts\Test.cs' );
Print ( 'myclass = #' + AsString(myclass) + '$' );  PrintFlush;
if ( AsString(myclass) = '' ) then
  abort;

myclass.TestTest(  );

