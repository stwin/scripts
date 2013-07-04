
var ser: integer = GetExternalSeries( 'GOOG', #High );
Print ( 'Old Name D1=' + GetDescription( ser ));
Print ( 'Get Series from old name S1=' + IntToStr(FindNamedSeries( 'High(GOOG)' )) );

// Set the sdescription manually and then retrieve it
SetDescription( ser, 'GoogHigh' );
Print ( 'New Name D1=' + GetDescription( ser ));
Print ( 'Get Series from new name S1=' + IntToStr(FindNamedSeries( 'GoogHigh' )) );
Print ( 'Get Series from old name S1=' + IntToStr(FindNamedSeries( 'High(GOOG)' )) );


