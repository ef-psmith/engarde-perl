/* (c) Copyright Oliver Smith 2008 */

namespace PisteView
{
    partial class confirmwinner
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
            this.winnerLRadio = new System.Windows.Forms.RadioButton();
            this.winnerRRadio = new System.Windows.Forms.RadioButton();
            this.fencerLLabel = new System.Windows.Forms.Label();
            this.fencerRLabel = new System.Windows.Forms.Label();
            this.scoreLLabel = new System.Windows.Forms.Label();
            this.scoreRLabel = new System.Windows.Forms.Label();
            this.confirmButton = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // winnerLRadio
            // 
            this.winnerLRadio.AutoSize = true;
            this.winnerLRadio.Location = new System.Drawing.Point(55, 97);
            this.winnerLRadio.Name = "winnerLRadio";
            this.winnerLRadio.Size = new System.Drawing.Size(14, 13);
            this.winnerLRadio.TabIndex = 0;
            this.winnerLRadio.TabStop = true;
            this.winnerLRadio.UseVisualStyleBackColor = true;
            this.winnerLRadio.CheckedChanged += new System.EventHandler(this.winnerLRadio_CheckedChanged);
            // 
            // winnerRRadio
            // 
            this.winnerRRadio.AutoSize = true;
            this.winnerRRadio.Location = new System.Drawing.Point(582, 97);
            this.winnerRRadio.Name = "winnerRRadio";
            this.winnerRRadio.Size = new System.Drawing.Size(14, 13);
            this.winnerRRadio.TabIndex = 1;
            this.winnerRRadio.TabStop = true;
            this.winnerRRadio.UseVisualStyleBackColor = true;
            this.winnerRRadio.CheckedChanged += new System.EventHandler(this.winnerRRadio_CheckedChanged);
            // 
            // fencerLLabel
            // 
            this.fencerLLabel.AutoSize = true;
            this.fencerLLabel.Location = new System.Drawing.Point(52, 20);
            this.fencerLLabel.Name = "fencerLLabel";
            this.fencerLLabel.Size = new System.Drawing.Size(61, 13);
            this.fencerLLabel.TabIndex = 2;
            this.fencerLLabel.Text = "Left Fencer";
            // 
            // fencerRLabel
            // 
            this.fencerRLabel.AutoSize = true;
            this.fencerRLabel.Location = new System.Drawing.Point(528, 20);
            this.fencerRLabel.Name = "fencerRLabel";
            this.fencerRLabel.Size = new System.Drawing.Size(68, 13);
            this.fencerRLabel.TabIndex = 3;
            this.fencerRLabel.Text = "Right Fencer";
            this.fencerRLabel.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // scoreLLabel
            // 
            this.scoreLLabel.AutoSize = true;
            this.scoreLLabel.Location = new System.Drawing.Point(52, 65);
            this.scoreLLabel.Name = "scoreLLabel";
            this.scoreLLabel.Size = new System.Drawing.Size(13, 13);
            this.scoreLLabel.TabIndex = 4;
            this.scoreLLabel.Text = "0";
            // 
            // scoreRLabel
            // 
            this.scoreRLabel.AutoSize = true;
            this.scoreRLabel.Location = new System.Drawing.Point(583, 65);
            this.scoreRLabel.Name = "scoreRLabel";
            this.scoreRLabel.Size = new System.Drawing.Size(13, 13);
            this.scoreRLabel.TabIndex = 5;
            this.scoreRLabel.Text = "0";
            this.scoreRLabel.TextAlign = System.Drawing.ContentAlignment.TopRight;
            // 
            // confirmButton
            // 
            this.confirmButton.Enabled = false;
            this.confirmButton.Location = new System.Drawing.Point(252, 130);
            this.confirmButton.Name = "confirmButton";
            this.confirmButton.Size = new System.Drawing.Size(131, 35);
            this.confirmButton.TabIndex = 6;
            this.confirmButton.Text = "&Confirm Winner";
            this.confirmButton.UseVisualStyleBackColor = true;
            this.confirmButton.Click += new System.EventHandler(this.confirmButton_Click);
            // 
            // confirmwinner
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(641, 187);
            this.Controls.Add(this.confirmButton);
            this.Controls.Add(this.scoreRLabel);
            this.Controls.Add(this.scoreLLabel);
            this.Controls.Add(this.fencerRLabel);
            this.Controls.Add(this.fencerLLabel);
            this.Controls.Add(this.winnerRRadio);
            this.Controls.Add(this.winnerLRadio);
            this.Name = "confirmwinner";
            this.Text = "Winner Confirmation";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.RadioButton winnerLRadio;
        private System.Windows.Forms.RadioButton winnerRRadio;
        private System.Windows.Forms.Label fencerLLabel;
        private System.Windows.Forms.Label fencerRLabel;
        private System.Windows.Forms.Label scoreLLabel;
        private System.Windows.Forms.Label scoreRLabel;
        private System.Windows.Forms.Button confirmButton;
    }
}