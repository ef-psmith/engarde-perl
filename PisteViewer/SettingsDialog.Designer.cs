/* (c) Copyright Oliver Smith 2008 */

namespace PisteView
{
    partial class SettingsDialog
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
            this.dbDSNText = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.pisteNumText = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.equipCombo = new System.Windows.Forms.ComboBox();
            this.okButton = new System.Windows.Forms.Button();
            this.cancelButton = new System.Windows.Forms.Button();
            this.advSettings = new System.Windows.Forms.Button();
            this.updateServerCheck = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(20, 19);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(117, 13);
            this.label1.TabIndex = 0;
            this.label1.Text = "Server Name (and port)";
            // 
            // dbDSNText
            // 
            this.dbDSNText.Location = new System.Drawing.Point(143, 16);
            this.dbDSNText.Name = "dbDSNText";
            this.dbDSNText.Size = new System.Drawing.Size(137, 20);
            this.dbDSNText.TabIndex = 1;
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(20, 58);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(70, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "Piste Number";
            // 
            // pisteNumText
            // 
            this.pisteNumText.Location = new System.Drawing.Point(143, 55);
            this.pisteNumText.Name = "pisteNumText";
            this.pisteNumText.Size = new System.Drawing.Size(137, 20);
            this.pisteNumText.TabIndex = 3;
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(20, 102);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(84, 13);
            this.label3.TabIndex = 4;
            this.label3.Text = "Equipment Type";
            // 
            // equipCombo
            // 
            this.equipCombo.AutoCompleteMode = System.Windows.Forms.AutoCompleteMode.Suggest;
            this.equipCombo.AutoCompleteSource = System.Windows.Forms.AutoCompleteSource.ListItems;
            this.equipCombo.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.equipCombo.FormattingEnabled = true;
            this.equipCombo.Location = new System.Drawing.Point(143, 99);
            this.equipCombo.Name = "equipCombo";
            this.equipCombo.Size = new System.Drawing.Size(137, 21);
            this.equipCombo.TabIndex = 5;
            this.equipCombo.SelectedIndexChanged += new System.EventHandler(this.equipCombo_SelectedIndexChanged);
            // 
            // okButton
            // 
            this.okButton.Location = new System.Drawing.Point(23, 187);
            this.okButton.Name = "okButton";
            this.okButton.Size = new System.Drawing.Size(94, 26);
            this.okButton.TabIndex = 6;
            this.okButton.Text = "&OK";
            this.okButton.UseVisualStyleBackColor = true;
            this.okButton.Click += new System.EventHandler(this.okButton_Click);
            // 
            // cancelButton
            // 
            this.cancelButton.Location = new System.Drawing.Point(161, 187);
            this.cancelButton.Name = "cancelButton";
            this.cancelButton.Size = new System.Drawing.Size(92, 26);
            this.cancelButton.TabIndex = 7;
            this.cancelButton.Text = "&Cancel";
            this.cancelButton.UseVisualStyleBackColor = true;
            this.cancelButton.Click += new System.EventHandler(this.cancelButton_Click);
            // 
            // advSettings
            // 
            this.advSettings.Location = new System.Drawing.Point(23, 139);
            this.advSettings.Name = "advSettings";
            this.advSettings.Size = new System.Drawing.Size(94, 27);
            this.advSettings.TabIndex = 8;
            this.advSettings.Text = "&Advanced";
            this.advSettings.UseVisualStyleBackColor = true;
            this.advSettings.Click += new System.EventHandler(this.advSettings_Click);
            // 
            // updateServerCheck
            // 
            this.updateServerCheck.AutoSize = true;
            this.updateServerCheck.Location = new System.Drawing.Point(147, 150);
            this.updateServerCheck.Name = "updateServerCheck";
            this.updateServerCheck.Size = new System.Drawing.Size(95, 17);
            this.updateServerCheck.TabIndex = 9;
            this.updateServerCheck.Text = "Update Server";
            this.updateServerCheck.UseVisualStyleBackColor = true;
            this.updateServerCheck.CheckedChanged += new System.EventHandler(this.updateServerCheck_CheckedChanged);
            // 
            // SettingsDialog
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(292, 233);
            this.Controls.Add(this.updateServerCheck);
            this.Controls.Add(this.advSettings);
            this.Controls.Add(this.cancelButton);
            this.Controls.Add(this.okButton);
            this.Controls.Add(this.equipCombo);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.pisteNumText);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.dbDSNText);
            this.Controls.Add(this.label1);
            this.Name = "SettingsDialog";
            this.Text = "SettingsDialog";
            this.Load += new System.EventHandler(this.SettingsDialog_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox dbDSNText;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.TextBox pisteNumText;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.ComboBox equipCombo;
        private System.Windows.Forms.Button okButton;
        private System.Windows.Forms.Button cancelButton;
        private System.Windows.Forms.Button advSettings;
        private System.Windows.Forms.CheckBox updateServerCheck;
    }
}