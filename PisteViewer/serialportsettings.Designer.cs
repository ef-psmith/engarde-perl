/* (c) Copyright Oliver Smith 2008 */


namespace PisteView
{
    partial class serialportsettings
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.portNameCombo = new System.Windows.Forms.ComboBox();
            this.baudRateCombo = new System.Windows.Forms.ComboBox();
            this.parityCombo = new System.Windows.Forms.ComboBox();
            this.dataBitsCombo = new System.Windows.Forms.ComboBox();
            this.stopBitsCombo = new System.Windows.Forms.ComboBox();
            this.okButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(18, 32);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(57, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "Port Name";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(18, 68);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(32, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Baud";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(18, 105);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(33, 13);
            this.label3.TabIndex = 3;
            this.label3.Text = "Parity";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(18, 141);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(50, 13);
            this.label4.TabIndex = 4;
            this.label4.Text = "Data Bits";
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(18, 178);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(49, 13);
            this.label5.TabIndex = 5;
            this.label5.Text = "Stop Bits";
            // 
            // portNameCombo
            // 
            this.portNameCombo.FormattingEnabled = true;
            this.portNameCombo.Location = new System.Drawing.Point(105, 29);
            this.portNameCombo.Name = "portNameCombo";
            this.portNameCombo.Size = new System.Drawing.Size(138, 21);
            this.portNameCombo.TabIndex = 6;
            // 
            // baudRateCombo
            // 
            this.baudRateCombo.FormattingEnabled = true;
            this.baudRateCombo.Location = new System.Drawing.Point(105, 65);
            this.baudRateCombo.Name = "baudRateCombo";
            this.baudRateCombo.Size = new System.Drawing.Size(138, 21);
            this.baudRateCombo.TabIndex = 7;
            // 
            // parityCombo
            // 
            this.parityCombo.FormattingEnabled = true;
            this.parityCombo.Location = new System.Drawing.Point(105, 102);
            this.parityCombo.Name = "parityCombo";
            this.parityCombo.Size = new System.Drawing.Size(138, 21);
            this.parityCombo.TabIndex = 8;
            // 
            // dataBitsCombo
            // 
            this.dataBitsCombo.FormattingEnabled = true;
            this.dataBitsCombo.Location = new System.Drawing.Point(105, 138);
            this.dataBitsCombo.Name = "dataBitsCombo";
            this.dataBitsCombo.Size = new System.Drawing.Size(138, 21);
            this.dataBitsCombo.TabIndex = 9;
            // 
            // stopBitsCombo
            // 
            this.stopBitsCombo.FormattingEnabled = true;
            this.stopBitsCombo.Location = new System.Drawing.Point(105, 175);
            this.stopBitsCombo.Name = "stopBitsCombo";
            this.stopBitsCombo.Size = new System.Drawing.Size(138, 21);
            this.stopBitsCombo.TabIndex = 10;
            // 
            // okButton
            // 
            this.okButton.Location = new System.Drawing.Point(30, 214);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(86, 28);
            this.okButton.TabIndex = 11;
            this.okButton.Text = "&Ok";
            this.okButton.UseVisualStyleBackColor = true;
            // 
            // cancelButton
            // 
            this.cancelButton.Location = new System.Drawing.Point(159, 216);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(83, 25);
            this.cancelButton.TabIndex = 12;
            this.cancelButton.Text = "&Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            // 
            // serialportsettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(292, 254);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.stopBitsCombo);
            this.Controls.Add(this.dataBitsCombo);
            this.Controls.Add(this.parityCombo);
            this.Controls.Add(this.baudRateCombo);
            this.Controls.Add(this.portNameCombo);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Name = "serialportsettings";
            this.Text = "serialportsettings";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.ComboBox portNameCombo;
        private System.Windows.Forms.ComboBox baudRateCombo;
        private System.Windows.Forms.ComboBox parityCombo;
        private System.Windows.Forms.ComboBox dataBitsCombo;
        private System.Windows.Forms.ComboBox stopBitsCombo;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.Button cancelButton;
    }
}