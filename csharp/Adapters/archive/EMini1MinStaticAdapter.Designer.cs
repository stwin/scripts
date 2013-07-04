namespace MyScript.Adapters
{
	partial class EMini1MinStaticAdapter
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose ( bool disposing )
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
			this.buttonExec = new System.Windows.Forms.Button ( );
			this.buttonPrevBar = new System.Windows.Forms.Button ( );
			this.buttonCacheData = new System.Windows.Forms.Button ( );
			this.label1 = new System.Windows.Forms.Label ( );
			this.textBoxCurrentBar = new System.Windows.Forms.TextBox ( );
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
			this.buttonNextBar.Location = new System.Drawing.Point ( 187, 110 );
			this.buttonNextBar.Name = "buttonNextBar";
			this.buttonNextBar.Size = new System.Drawing.Size ( 75, 47 );
			this.buttonNextBar.TabIndex = 8;
			this.buttonNextBar.Text = "Next Bar";
			this.buttonNextBar.UseVisualStyleBackColor = true;
			this.buttonNextBar.Click += new System.EventHandler ( this.buttonNextBar_Click );
			// 
			// buttonExec
			// 
			this.buttonExec.Location = new System.Drawing.Point ( 105, 110 );
			this.buttonExec.Name = "buttonExec";
			this.buttonExec.Size = new System.Drawing.Size ( 76, 47 );
			this.buttonExec.TabIndex = 9;
			this.buttonExec.Text = "Execute";
			this.buttonExec.UseVisualStyleBackColor = true;
			this.buttonExec.Click += new System.EventHandler ( this.buttonExec_Click );
			// 
			// buttonPrevBar
			// 
			this.buttonPrevBar.Location = new System.Drawing.Point ( 28, 110 );
			this.buttonPrevBar.Name = "buttonPrevBar";
			this.buttonPrevBar.Size = new System.Drawing.Size ( 71, 47 );
			this.buttonPrevBar.TabIndex = 10;
			this.buttonPrevBar.Text = "Previous Bar";
			this.buttonPrevBar.UseVisualStyleBackColor = true;
			this.buttonPrevBar.Click += new System.EventHandler ( this.buttonPrevBar_Click );
			// 
			// buttonCacheData
			// 
			this.buttonCacheData.Location = new System.Drawing.Point ( 28, 12 );
			this.buttonCacheData.Name = "buttonCacheData";
			this.buttonCacheData.Size = new System.Drawing.Size ( 135, 23 );
			this.buttonCacheData.TabIndex = 11;
			this.buttonCacheData.Text = "Cache Data";
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
			// EMini1MinStaticAdapter
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF ( 6F, 13F );
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size ( 297, 236 );
			this.Controls.Add ( this.textBoxCurrentBar );
			this.Controls.Add ( this.label1 );
			this.Controls.Add ( this.buttonCacheData );
			this.Controls.Add ( this.buttonPrevBar );
			this.Controls.Add ( this.buttonExec );
			this.Controls.Add ( this.buttonNextBar );
			this.Controls.Add ( this.dateTimePicker1 );
			this.Name = "EMini1MinStaticAdapter";
			this.Text = "EMini1Min Static Data Adapter";
			this.FormClosing += new System.Windows.Forms.FormClosingEventHandler ( this.EMiniForm_FormClosing );
			this.ResumeLayout ( false );
			this.PerformLayout ( );

		}

		#endregion

		private System.Windows.Forms.DateTimePicker dateTimePicker1;
		private System.Windows.Forms.Button buttonNextBar;
		private System.Windows.Forms.Button buttonExec;
		private System.Windows.Forms.Button buttonPrevBar;
		private System.Windows.Forms.Button buttonCacheData;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.TextBox textBoxCurrentBar;
	}
}