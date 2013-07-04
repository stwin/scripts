using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using System.Drawing.Imaging;


namespace MyScript
{
	/// <summary>
	/// Summary description for Image.
	/// </summary>
	public class Image
	{
		Bitmap image = null;
		Graphics g = null;

		//___________________________________________________________________________
		public Image ( )
		{
		}
		//___________________________________________________________________________
		/// <summary>
		/// Opens an image from a file
		/// </summary>
		//___________________________________________________________________________
		public void Open ( string fileName )
		{
			try
			{
				Bitmap tempImage = new Bitmap ( fileName );
				image = new Bitmap ( tempImage );
				tempImage.Dispose ( );
				g = Graphics.FromImage ( image );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.StackTrace );
				image = null;
				g = null;
			}
		}
		//___________________________________________________________________________
		/// <summary>
		/// Creates an image of size (width, height)
		/// </summary>
		//___________________________________________________________________________
		public void Create ( int width, int height )
		{
			try
			{
				image = new Bitmap ( width, height );
				g = Graphics.FromImage ( image );
			}
			catch ( Exception e )
			{
				MessageBox.Show ( e.StackTrace );
				image = null;
				g = null;
			}
		}
		//___________________________________________________________________________
		/// <summary>
		/// Draws a rectangle on the currently opened image.
		/// x1, y1, x2, y2 are the co-ordinates
		/// color = color of the line in 999 format (an integer)
		/// style = style of the line. Valid values: 0, 1, and 2 for thin, thick, and dotted respectively
		/// fillColor = Color to fill the rectangle. Use -1 for no color.
		/// </summary>
		//___________________________________________________________________________
		public void DrawRectangle ( int x1, int y1, int x2, int y2, int color, int style, int fillColor )
		{
			if ( g == null )
			{
				return;
			}
			Pen pen = new Pen ( Int999ToColor ( color ) );

			// Implementation Notes: DrawRectangle and FillRectanlge behave differently (possibly a bug).
			// FillRectangle - the width and height of the box are exactly as specified.
			// DrawRectangle - the starting point is not included in width and height, so the width and height
			//				   of the drawn box will be more by 1 pixel.

			if ( fillColor != -1 )
			{
				Brush brush = new SolidBrush ( Int999ToColor ( fillColor ) );
				int widthForFill = x2 - x1 + 1;
				int heightForFill = y2 - y1 + 1;
				g.FillRectangle ( brush, x1, y1, widthForFill, heightForFill );
			}
			int widthForRect = x2 - x1;
			int heightForRect = y2 - y1;
			g.DrawRectangle ( pen, x1, y1, widthForRect, heightForRect );
		}
		//___________________________________________________________________________
		/// <summary>
		/// Draws a text at the specified location with specified size and color
		/// color - color in 999 format
		/// </summary>
		//___________________________________________________________________________
		public void DrawText ( string text, int x, int y, int color, int size )
		{
			if ( g == null )
			{
				return;
			}
			Brush brush = new SolidBrush ( Int999ToColor ( color ) );
			Font drawFont = new Font ( "Arial", size );
			StringFormat normalFormat = new StringFormat ( );
			g.DrawString ( text, drawFont, brush, x, y, normalFormat );
		}
		//___________________________________________________________________________
		/// <summary>
		/// Saves the file at the specified location
		/// The format paratmeter could be bmp, jpeg, gif, tiff, png, icon
		/// </summary>
		//___________________________________________________________________________
		public void Save ( string fileName, string format )
		{
			if ( image == null )
			{
				return;
			}
			format.ToUpper ( );
			ImageFormat imgFormat = ImageFormat.Bmp;
			switch ( format )
			{
				case "BMP": imgFormat = ImageFormat.Bmp; break;
				case "JPEG": imgFormat = ImageFormat.Jpeg; break;
				case "GIF": imgFormat = ImageFormat.Gif; break;
				case "TIFF": imgFormat = ImageFormat.Tiff; break;
				case "PNG": imgFormat = ImageFormat.Png; break;
				case "ICON": imgFormat = ImageFormat.Icon; break;
			}
			image.Save ( fileName, imgFormat );
		}
		//___________________________________________________________________________
		/// <summary>
		/// Frees the resources
		/// </summary>
		//___________________________________________________________________________
		public void Close ( )
		{
			if ( g == null )
			{
				return;
			}
			g.Dispose ( );
			image = null;
			g = null;
		}
		//___________________________________________________________________________
		//___________________________________________________________________________
		//__________________ H E L P E R   F U N C T I O N S ________________________
		//___________________________________________________________________________
		//___________________________________________________________________________
		public static Color Int999ToColor ( int color )
		{
			color = color % 1000;
			int red = color / 100;
			color = color % 100;
			int green = color / 10;
			int blue = color % 10;
			red = (int) ( red * 255 / 9 );
			green = (int) ( green * 255 / 9 );
			blue = (int) ( blue * 255 / 9 );
			return Color.FromArgb ( red, green, blue );
		}
		//___________________________________________________________________________
		//___________________________________________________________________________
		//___________________________________________________________________________
		//___________________________________________________________________________
	}
}
