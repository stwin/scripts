using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Windows.Forms;
using System.IO;
using System.Threading;

using WealthLab;

namespace MyScript
{
	public class PaintHook : IWealthLabPaintHook3
	{
		float[] openPrice = null;
		float[] highPrice = null;
		float[] lowPrice = null;
		float[] closePrice = null;
		Pen upBarPen = null;
		Pen downBarPen = null;
		Brush downBarBrush = null;

		//___________________________________________________________________________
		public PaintHook ( )
		{
		}
		//___________________________________________________________________________
		public void PlotFewBars ( IWealthLabAddOn3 WLA, int numBars, float factor, int upColor, int downColor,
								int o, int h, int l, int c )
		{
			WLA.InstallPaintHook ( this );
			upBarPen = new Pen ( Image.Int999ToColor ( upColor ) );
			downBarPen = new Pen ( Image.Int999ToColor ( downColor ) );
			downBarBrush = new SolidBrush ( Image.Int999ToColor ( downColor ) );

			openPrice = new float[numBars];
			highPrice = new float[numBars];
			lowPrice = new float[numBars];
			closePrice = new float[numBars];

			int totalBars = WLA.BarCount ( );
			for ( int i = 0; i < openPrice.Length; i++ )
			{
				int bar = totalBars - 1 - i;
				openPrice[i] = (float) WLA.GetSeriesValue ( bar, o ) * factor;
				highPrice[i] = (float) WLA.GetSeriesValue ( bar, h ) * factor;
				lowPrice[i] = (float) WLA.GetSeriesValue ( bar, l ) * factor;
				closePrice[i] = (float) WLA.GetSeriesValue ( bar, c ) * factor;
			}
		}
		//___________________________________________________________________________
		public void Paint ( int dc, int width, int height, int offset, int barSpacing,
			int top, int bottom, bool preBars, WealthLab.IWealthLabAddOn3 WL )
		{
			Graphics g = Graphics.FromHdc ( (System.IntPtr) dc );
			//StreamWriter sw = new StreamWriter( @"C:\Temp\log.txt", true );            
			//sw.WriteLine( "Starting." ); sw.Flush();

			//try{
			if ( preBars == false )
			{
				int totalBars = WL.BarCount ( );
				int thick = Math.Max ( 1, barSpacing / 2 - 1 );
				for ( int i = 0; i < openPrice.Length; i++ )
				{
					int openY = WL.PriceToY ( openPrice[i] );
					int highY = WL.PriceToY ( highPrice[i] );
					int lowY = WL.PriceToY ( lowPrice[i] );
					int closeY = WL.PriceToY ( closePrice[i] );
					int currentWLBar = totalBars - 1 - i;
					int midX = WL.BarToX ( currentWLBar );
					// Implementation Notes: DrawRectangle and FillRectanlge behave differently (possibly a bug).
					// FillRectangle - the width and height of the box are exactly as specified.
					// DrawRectangle - the starting point is not included in width and height, so the width and height
					//				   of the drawn box will be more by 1 pixel.
					if ( closePrice[i] > openPrice[i] )
					{ // Green bar, up bar
						g.DrawLine ( upBarPen, midX, highY, midX, closeY );
						g.DrawLine ( upBarPen, midX, openY, midX, lowY );
						g.DrawRectangle ( upBarPen, midX - thick, closeY, 2 * thick, openY - closeY );
						g.DrawLine ( upBarPen, midX - thick, openY, midX + thick, openY ); // For rectangle of 0 height
					}
					else
					{ // Red Bar, down bar
						g.DrawLine ( downBarPen, midX, highY, midX, openY );
						g.DrawLine ( downBarPen, midX, closeY, midX, lowY );
						g.FillRectangle ( downBarBrush, midX - thick, openY, 2 * thick + 1, closeY - openY + 1 );
					}
				}
			}
			//} catch( Exception e ) {
			//    sw.WriteLine( e.Message ); sw.Flush();
			//    sw.WriteLine( e.StackTrace ); sw.Flush();
			//}
			//sw.WriteLine( "Ending." ); sw.Flush();
			//sw.Close();
		}
		//___________________________________________________________________________
		//___________________________________________________________________________
	}
}
