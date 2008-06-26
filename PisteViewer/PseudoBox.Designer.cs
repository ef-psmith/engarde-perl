/* (c) Copyright Oliver Smith 2008 */


namespace PisteView
{
    partial class PseudoBox
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
            this.whiteLeftCheck = new System.Windows.Forms.CheckBox();
            this.colourLeftCheck = new System.Windows.Forms.CheckBox();
            this.colourRightCheck = new System.Windows.Forms.CheckBox();
            this.whiteRightCheck = new System.Windows.Forms.CheckBox();
            this.sendButton = new System.Windows.Forms.Button();
            this.scoreLeftText = new System.Windows.Forms.MaskedTextBox();
            this.scoreRightText = new System.Windows.Forms.MaskedTextBox();
            this.timeBox = new System.Windows.Forms.MaskedTextBox();
            this.SuspendLayout();
            // 
            // whiteLeftCheck
            // 
            this.whiteLeftCheck.AutoSize = true;
            this.whiteLeftCheck.Location = new System.Drawing.Point(63, 69);
            this.whiteLeftCheck.Name = "whiteLeftCheck";
            this.whiteLeftCheck.Size = new System.Drawing.Size(54, 17);
            this.whiteLeftCheck.TabIndex = 0;
            this.whiteLeftCheck.Text = "White";
            this.whiteLeftCheck.UseVisualStyleBackColor = true;
            // 
            // colourLeftCheck
            // 
            this.colourLeftCheck.AutoSize = true;
            this.colourLeftCheck.Location = new System.Drawing.Point(63, 33);
            this.colourLeftCheck.Name = "colourLeftCheck";
            this.colourLeftCheck.Size = new System.Drawing.Size(46, 17);
            this.colourLeftCheck.TabIndex = 1;
            this.colourLeftCheck.Text = "Red";
            this.colourLeftCheck.UseVisualStyleBackColor = true;
            // 
            // colourRightCheck
            // 
            this.colourRightCheck.AutoSize = true;
            this.colourRightCheck.Location = new System.Drawing.Point(454, 33);
            this.colourRightCheck.Name = "colourRightCheck";
            this.colourRightCheck.Size = new System.Drawing.Size(55, 17);
            this.colourRightCheck.TabIndex = 2;
            this.colourRightCheck.Text = "Green";
            this.colourRightCheck.UseVisualStyleBackColor = true;
            // 
            // whiteRightCheck
            // 
            this.whiteRightCheck.AutoSize = true;
            this.whiteRightCheck.Location = new System.Drawing.Point(454, 69);
            this.whiteRightCheck.Name = "whiteRightCheck";
            this.whiteRightCheck.Size = new System.Drawing.Size(54, 17);
            this.whiteRightCheck.TabIndex = 3;
            this.whiteRightCheck.Text = "White";
            this.whiteRightCheck.UseVisualStyleBackColor = true;
            // 
            // sendButton
            // 
            this.sendButton.Location = new System.Drawing.Point(217, 114);
            this.sendButton.Name = "sendButton";
            this.sendButton.Size = new System.Drawing.Size(120, 32);
            this.sendButton.TabIndex = 4;
            this.sendButton.Text = "Update";
            this.sendButton.UseVisualStyleBackColor = true;
            this.sendButton.Click += new System.EventHandler(this.sendButton_Click);
            // 
            // scoreLeftText
            // 
            this.scoreLeftText.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.scoreLeftText.Location = new System.Drawing.Point(140, 39);
            this.scoreLeftText.Mask = "00";
            this.scoreLeftText.Name = "scoreLeftText";
            this.scoreLeftText.Size = new System.Drawing.Size(57, 38);
            this.scoreLeftText.TabIndex = 5;
            this.scoreLeftText.Text = "0";
            this.scoreLeftText.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // scoreRightText
            // 
            this.scoreRightText.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.scoreRightText.Location = new System.Drawing.Point(368, 39);
            this.scoreRightText.Mask = "00";
            this.scoreRightText.Name = "scoreRightText";
            this.scoreRightText.Size = new System.Drawing.Size(56, 38);
            this.scoreRightText.TabIndex = 6;
            this.scoreRightText.Text = "0";
            this.scoreRightText.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // timeBox
            // 
            this.timeBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 20F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.timeBox.Location = new System.Drawing.Point(217, 39);
            this.timeBox.Mask = "00:00";
            this.timeBox.Name = "timeBox";
            this.timeBox.Size = new System.Drawing.Size(120, 38);
            this.timeBox.TabIndex = 7;
            this.timeBox.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // PseudoBox
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(551, 173);
            this.Controls.Add(this.timeBox);
            this.Controls.Add(this.scoreRightText);
            this.Controls.Add(this.scoreLeftText);
            this.Controls.Add(this.sendButton);
            this.Controls.Add(this.whiteRightCheck);
            this.Controls.Add(this.colourRightCheck);
            this.Controls.Add(this.colourLeftCheck);
            this.Controls.Add(this.whiteLeftCheck);
            this.Name = "PseudoBox";
            this.Text = "PseudoBox";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.CheckBox whiteLeftCheck;
        private System.Windows.Forms.CheckBox colourLeftCheck;
        private System.Windows.Forms.CheckBox colourRightCheck;
        private System.Windows.Forms.CheckBox whiteRightCheck;
        private System.Windows.Forms.Button sendButton;
        private System.Windows.Forms.MaskedTextBox scoreLeftText;
        private System.Windows.Forms.MaskedTextBox scoreRightText;
        private System.Windows.Forms.MaskedTextBox timeBox;
    }
}