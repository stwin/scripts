
//$AddReference Interop.WealthLab.dll

using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Text;
using System.IO;

using WealthLab;

namespace MyScript
{
    class MyClass2
    {
        IWealthLabAddOn3 wl3 = null;
        double[] close = null;
        int BarCount;
		int iter = 0;

		public void Init ( IWealthLabAddOn3 wl3, int BarCount )
        {
            this.wl3 = wl3;
            this.BarCount = BarCount;
			close = new double[BarCount];
			for ( int bar = 0; bar < BarCount; bar++ )
				close[bar] = bar * 10;
		}
		public void SaveClosePrices ( int series )
        {
			for ( int count = 0; count < 1000; count++ )
			{
				wl3.PopulateSeries ( series, ref close[0] );
			}			
		}
		public void Verify ( )
		{
			MessageBox.Show ( String.Format ("BarCount={0}, Close[0]={1}, Close[Last]={2}, iter={3}",
				BarCount, close[0], close[BarCount-1], iter ) );
		}
		public void Test ( int a, int b )
        {
            string msg = String.Format ( "{0}, {1}", a, b );
            MessageBox.Show ( "Message=" + msg, "MyClass" );
		}
    }
}


