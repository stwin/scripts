namespace Emini1MinRT
{	
	partial class Emini1MinRealDataCommon
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected  override void Dispose ( bool disposing )
		{
			if ( disposing && ( components != null ) )
			{
				components.Dispose ( );
			}
			base.Dispose ( disposing );
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent ( )
		{
			this.dateTimePicker1 = new System.Windows.Forms.DateTimePicker ( );
			this.buttonNextBar = new System.Windows.Forms.Button ( );
			this.buttonCacheData = new System.Windows.Forms.Button ( );
			this.label1 = new System.Windows.Forms.Label ( );
			this.textBoxCurrentBar = new System.Windows.Forms.TextBox ( );
			this.buttonDebugInfo = new System.Windows.Forms.Button ( );
			this.buttonSave = new System.Windows.Forms.Button ( );
			this.SuspendLayout ( );
			// 
			// dateTimePicker1
			// 
			this.dateTimePicker1.CustomFormat = "MM/dd/yyyy  HH:mm  ddd";
			this.dateTimePicker1.Format = System.Windows.Forms.DateTimePickerFormat.Custom;
			this.dateTimePicker1.Location = new System.Drawing.Point ( 28, 62 );
			this.dateTimePicker1.Name = "dateTimePicker1";
			this.dateTimePicker1.ShowUpDown = true;
			this.dateTimePicker1.Size = new System.Drawing.Size ( 234, 20 );
			this.dateTimePicker1.TabIndex = 7;
			this.dateTimePicker1.ValueChanged += new System.EventHandler ( this.dateTimePicker1_ValueChanged );
			// 
			// buttonNextBar
			// 
			this.buttonNextBar.BackColor = System.Drawing.SystemColors.Control;
			this.buttonNextBar.Location = new System.Drawing.Point ( 28, 110 );
			this.buttonNextBar.Name = "buttonNextBar";
			this.buttonNextBar.Size = new System.Drawing.Size ( 147, 47 );
			this.buttonNextBar.TabIndex = 8;
			this.buttonNextBar.Text = "&Next Bar";
			this.buttonNextBar.UseVisualStyleBackColor = false;
			this.buttonNextBar.Click += new System.EventHandler ( this.buttonNextBar_Click );
			this.buttonNextBar.KeyPress += new System.Windows.Forms.KeyPressEventHandler ( this.buttonNextBar_KeyPress );
			// 
			// buttonCacheData
			// 
			this.buttonCacheData.Location = new System.Drawing.Point ( 28, 12 );
			this.buttonCacheData.Name = "buttonCacheData";
			this.buttonCacheData.Size = new System.Drawing.Size ( 99, 23 );
			this.buttonCacheData.TabIndex = 11;
			this.buttonCacheData.Text = "&Cache Data";
			this.buttonCacheData.UseVisualStyleBackColor = true;
			this.buttonCacheData.Click += new System.EventHandler ( this.buttonCacheData_Click );
			// 
			// label1
			// 
			this.label1.AutoSize = true;
			this.label1.Location = new System.Drawing.Point ( 25, 197 );
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size ( 63, 13 );
			this.label1.TabIndex = 12;
			this.label1.Text = "Current Bar:";
			// 
			// textBoxCurrentBar
			// 
			this.textBoxCurrentBar.Location = new System.Drawing.Point ( 94, 194 );
			this.textBoxCurrentBar.Name = "textBoxCurrentBar";
			this.textBoxCurrentBar.Size = new System.Drawing.Size ( 168, 20 );
			this.textBoxCurrentBar.TabIndex = 13;
			// 
			// buttonDebugInfo
			// 
			this.buttonDebugInfo.Location = new System.Drawing.Point ( 145, 12 );
			this.buttonDebugInfo.Name = "buttonDebugInfo";
			this.buttonDebugInfo.Size = new System.Drawing.Size ( 117, 23 );
			this.buttonDebugInfo.TabIndex = 14;
			this.buttonDebugInfo.Text = "&Debug Info";
			this.buttonDebugInfo.UseVisualStyleBackColor = true;
			this.buttonDebugInfo.Click += new System.EventHandler ( this.buttonDebugInfo_Click );
			// 
			// buttonSave
			// 
			this.buttonSave.Location = new System.Drawing.Point ( 187, 110 );
			this.buttonSave.Name = "buttonSave";
			this.buttonSave.Size = new System.Drawing.Size ( 75, 47 );
			this.buttonSave.TabIndex = 15;
			this.buttonSave.Text = "Save ";
			this.buttonSave.UseVisualStyleBackColor = true;
			this.buttonSave.Click += new System.EventHandler ( this.buttonSave_Click );
			// 
			// Emini1MinRealDataCommon
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF ( 6F, 13F );
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size ( 297, 236 );
			this.Controls.Add ( this.buttonSave );
			this.Controls.Add ( this.buttonDebugInfo );
			this.Controls.Add ( this.textBoxCurrentBar );
			this.Controls.Add ( this.label1 );
			this.Controls.Add ( this.buttonCacheData );
			this.Controls.Add ( this.buttonNextBar );
			this.Controls.Add ( this.dateTimePicker1 );
			this.Name = "Emini1MinRealDataCommon";
			this.Text = "EMini1Min RealTime Data Adapter";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler ( this.EMiniForm_FormClosing );
			this.ResumeLayout ( false );
			this.PerformLayout ( );

		}

		#endregion

		private System.Windows.Forms.DateTimePicker dateTimePicker1;
		private System.Windows.Forms.Button buttonNextBar;
		private System.Windows.Forms.Button buttonCacheData;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.TextBox textBoxCurrentBar;
		private System.Windows.Forms.Button buttonDebugInfo;
		private System.Windows.Forms.Button buttonSave;
	}
}