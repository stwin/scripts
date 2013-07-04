{$NO_AUTO_EXECUTE}
UseUpdatedEma( true );
EnableSynch( false );

///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
// Main Program




//var Lib : ComVariant = CreateOleObject('InternetExplorer.Application');
//var Lib : ComVariant = CreateOleObject('WLExtra.Utility');
//var res : float = Lib.factorial( 5, IWealthLabAddOn3 );
//Print( FloatToStr( res ) );

var Lib : ComVariant;
Lib := CreateOleObject('WLExtra.IEDriverClass');
Lib.Navigate( 'https://trading.scottrade.com/myaccount/Balances.aspx' );

//Lib := CreateOleObject('WLExtra.Utility');



