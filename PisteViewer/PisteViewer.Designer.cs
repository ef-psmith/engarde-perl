/* (c) Copyright Oliver Smith 2008 */


namespace PisteView
{
    partial class PisteViewer
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
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.swapFencersButton = new System.Windows.Forms.Button();
            this.cancelBoutButton = new System.Windows.Forms.Button();
            this.startBoutButton = new System.Windows.Forms.Button();
            this.scoreRLabel = new System.Windows.Forms.Label();
            this.scoreLLabel = new System.Windows.Forms.Label();
            this.period_chooser = new System.Windows.Forms.ComboBox();
            this.period_timer = new System.Windows.Forms.Label();
            this.finishBoutButton = new System.Windows.Forms.Button();
            this.colourR = new System.Windows.Forms.PictureBox();
            this.whiteL = new System.Windows.Forms.PictureBox();
            this.colourL = new System.Windows.Forms.PictureBox();
            this.whiteR = new System.Windows.Forms.PictureBox();
            this.fencerRLabel = new System.Windows.Forms.Label();
            this.fencerLLabel = new System.Windows.Forms.Label();
            this.selectBoutButton = new System.Windows.Forms.Button();
            this.nextBoutsList = new System.Windows.Forms.ListBox();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.updateBoutsButton = new System.Windows.Forms.Button();
            this.next_bout_names = new System.Windows.Forms.Label();
            this.next_bout_label = new System.Windows.Forms.Label();
            this.settingsButton = new System.Windows.Forms.Button();
            this.pisteNumLabel = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.colourR)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteL)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.colourL)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteR)).BeginInit();
            this.groupBox2.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.swapFencersButton);
            this.groupBox1.Controls.Add(this.cancelBoutButton);
            this.groupBox1.Controls.Add(this.startBoutButton);
            this.groupBox1.Controls.Add(this.scoreRLabel);
            this.groupBox1.Controls.Add(this.scoreLLabel);
            this.groupBox1.Controls.Add(this.period_chooser);
            this.groupBox1.Controls.Add(this.period_timer);
            this.groupBox1.Controls.Add(this.finishBoutButton);
            this.groupBox1.Controls.Add(this.colourR);
            this.groupBox1.Controls.Add(this.whiteL);
            this.groupBox1.Controls.Add(this.colourL);
            this.groupBox1.Controls.Add(this.whiteR);
            this.groupBox1.Controls.Add(this.fencerRLabel);
            this.groupBox1.Controls.Add(this.fencerLLabel);
            this.groupBox1.Location = new System.Drawing.Point(30, 23);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(705, 164);
            this.groupBox1.TabIndex = 0;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Current Bout";
            // 
            // swapFencersButton
            // 
            this.swapFencersButton.Location = new System.Drawing.Point(356, 132);
            this.swapFencersButton.Name = "swapFencersButton";
            this.swapFencersButton.Size = new System.Drawing.Size(100, 25);
            this.swapFencersButton.TabIndex = 15;
            this.swapFencersButton.Text = "Swap Fencers";
            this.swapFencersButton.UseVisualStyleBackColor = true;
            this.swapFencersButton.Click += new System.EventHandler(this.swapFencersButton_Click);
            // 
            // cancelBoutButton
            // 
            this.cancelBoutButton.Location = new System.Drawing.Point(232, 131);
            this.cancelBoutButton.Name = "cancelBoutButton";
            this.cancelBoutButton.Size = new System.Drawing.Size(98, 26);
            this.cancelBoutButton.TabIndex = 14;
            this.cancelBoutButton.Text = "Unselect Bout";
            this.cancelBoutButton.UseVisualStyleBackColor = true;
            // 
            // startBoutButton
            // 
            this.startBoutButton.Location = new System.Drawing.Point(232, 93);
            this.startBoutButton.Name = "startBoutButton";
            this.startBoutButton.Size = new System.Drawing.Size(98, 27);
            this.startBoutButton.TabIndex = 13;
            this.startBoutButton.Text = "Start Bout";
            this.startBoutButton.UseVisualStyleBackColor = true;
            this.startBoutButton.Click += new System.EventHandler(this.startBoutButton_Click);
            // 
            // scoreRLabel
            // 
            this.scoreRLabel.AutoSize = true;
            this.scoreRLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.scoreRLabel.Location = new System.Drawing.Point(474, 93);
            this.scoreRLabel.Name = "scoreRLabel";
            this.scoreRLabel.Size = new System.Drawing.Size(36, 39);
            this.scoreRLabel.TabIndex = 12;
            this.scoreRLabel.Text = "0";
            // 
            // scoreLLabel
            // 
            this.scoreLLabel.AutoSize = true;
            this.scoreLLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.scoreLLabel.Location = new System.Drawing.Point(173, 93);
            this.scoreLLabel.Name = "scoreLLabel";
            this.scoreLLabel.Size = new System.Drawing.Size(36, 39);
            this.scoreLLabel.TabIndex = 11;
            this.scoreLLabel.Text = "0";
            // 
            // period_chooser
            // 
            this.period_chooser.FormattingEnabled = true;
            this.period_chooser.Location = new System.Drawing.Point(278, 65);
            this.period_chooser.Name = "period_chooser";
            this.period_chooser.Size = new System.Drawing.Size(148, 21);
            this.period_chooser.TabIndex = 10;
            // 
            // period_timer
            // 
            this.period_timer.AutoSize = true;
            this.period_timer.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.period_timer.Location = new System.Drawing.Point(313, 29);
            this.period_timer.Name = "period_timer";
            this.period_timer.Size = new System.Drawing.Size(66, 26);
            this.period_timer.TabIndex = 9;
            this.period_timer.Text = "00:00";
            this.period_timer.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            // 
            // finishBoutButton
            // 
            this.finishBoutButton.Enabled = false;
            this.finishBoutButton.Location = new System.Drawing.Point(356, 93);
            this.finishBoutButton.Name = "finishBoutButton";
            this.finishBoutButton.Size = new System.Drawing.Size(100, 27);
            this.finishBoutButton.TabIndex = 8;
            this.finishBoutButton.Text = "Bout Finished";
            this.finishBoutButton.UseVisualStyleBackColor = true;
            this.finishBoutButton.Click += new System.EventHandler(this.finishBoutButton_Click);
            // 
            // colourR
            // 
            this.colourR.Image = global::PisteView.Properties.Resources.green_off;
            this.colourR.Location = new System.Drawing.Point(645, 90);
            this.colourR.Name = "colourR";
            this.colourR.Size = new System.Drawing.Size(48, 48);
            this.colourR.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.colourR.TabIndex = 6;
            this.colourR.TabStop = false;
            // 
            // whiteL
            // 
            this.whiteL.Image = global::PisteView.Properties.Resources.white_off;
            this.whiteL.Location = new System.Drawing.Point(73, 90);
            this.whiteL.Name = "whiteL";
            this.whiteL.Size = new System.Drawing.Size(48, 48);
            this.whiteL.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.whiteL.TabIndex = 5;
            this.whiteL.TabStop = false;
            // 
            // colourL
            // 
            this.colourL.Image = global::PisteView.Properties.Resources.red_off;
            this.colourL.Location = new System.Drawing.Point(6, 90);
            this.colourL.Name = "colourL";
            this.colourL.Size = new System.Drawing.Size(48, 48);
            this.colourL.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.colourL.TabIndex = 4;
            this.colourL.TabStop = false;
            // 
            // whiteR
            // 
            this.whiteR.Image = global::PisteView.Properties.Resources.white_off;
            this.whiteR.Location = new System.Drawing.Point(572, 90);
            this.whiteR.Name = "whiteR";
            this.whiteR.Size = new System.Drawing.Size(48, 48);
            this.whiteR.SizeMode = System.Windows.Forms.PictureBoxSizeMode.AutoSize;
            this.whiteR.TabIndex = 3;
            this.whiteR.TabStop = false;
            // 
            // fencerRLabel
            // 
            this.fencerRLabel.AutoSize = true;
            this.fencerRLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.fencerRLabel.Location = new System.Drawing.Point(568, 35);
            this.fencerRLabel.Name = "fencerRLabel";
            this.fencerRLabel.Size = new System.Drawing.Size(74, 20);
            this.fencerRLabel.TabIndex = 1;
            this.fencerRLabel.Text = "Fencer B";
            // 
            // fencerLLabel
            // 
            this.fencerLLabel.AutoSize = true;
            this.fencerLLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.fencerLLabel.Location = new System.Drawing.Point(20, 35);
            this.fencerLLabel.Name = "fencerLLabel";
            this.fencerLLabel.Size = new System.Drawing.Size(74, 20);
            this.fencerLLabel.TabIndex = 0;
            this.fencerLLabel.Text = "Fencer A";
            // 
            // selectBoutButton
            // 
            this.selectBoutButton.Location = new System.Drawing.Point(558, 101);
            this.selectBoutButton.Name = "selectBoutButton";
            this.selectBoutButton.Size = new System.Drawing.Size(135, 32);
            this.selectBoutButton.TabIndex = 7;
            this.selectBoutButton.Text = "Select Bout";
            this.selectBoutButton.UseVisualStyleBackColor = true;
            this.selectBoutButton.Click += new System.EventHandler(this.selectBoutButton_Click);
            // 
            // nextBoutsList
            // 
            this.nextBoutsList.FormattingEnabled = true;
            this.nextBoutsList.Location = new System.Drawing.Point(8, 101);
            this.nextBoutsList.Name = "nextBoutsList";
            this.nextBoutsList.Size = new System.Drawing.Size(536, 147);
            this.nextBoutsList.TabIndex = 1;
            this.nextBoutsList.SelectedIndexChanged += new System.EventHandler(this.nextBoutsList_SelectedIndexChanged);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.updateBoutsButton);
            this.groupBox2.Controls.Add(this.next_bout_names);
            this.groupBox2.Controls.Add(this.next_bout_label);
            this.groupBox2.Controls.Add(this.nextBoutsList);
            this.groupBox2.Controls.Add(this.selectBoutButton);
            this.groupBox2.Location = new System.Drawing.Point(30, 219);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(704, 289);
            this.groupBox2.TabIndex = 2;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Assigned Bouts";
            // 
            // updateBoutsButton
            // 
            this.updateBoutsButton.Location = new System.Drawing.Point(558, 217);
            this.updateBoutsButton.Name = "updateBoutsButton";
            this.updateBoutsButton.Size = new System.Drawing.Size(134, 31);
            this.updateBoutsButton.TabIndex = 8;
            this.updateBoutsButton.Text = "Update Next Bouts";
            this.updateBoutsButton.UseVisualStyleBackColor = true;
            this.updateBoutsButton.Click += new System.EventHandler(this.updateBoutsButton_Click);
            // 
            // next_bout_names
            // 
            this.next_bout_names.AutoSize = true;
            this.next_bout_names.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.next_bout_names.Location = new System.Drawing.Point(123, 37);
            this.next_bout_names.Name = "next_bout_names";
            this.next_bout_names.Size = new System.Drawing.Size(164, 20);
            this.next_bout_names.TabIndex = 3;
            this.next_bout_names.Text = "a vs b in sword waving";
            // 
            // next_bout_label
            // 
            this.next_bout_label.AutoSize = true;
            this.next_bout_label.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.next_bout_label.Location = new System.Drawing.Point(31, 38);
            this.next_bout_label.Name = "next_bout_label";
            this.next_bout_label.Size = new System.Drawing.Size(93, 20);
            this.next_bout_label.TabIndex = 2;
            this.next_bout_label.Text = "Next Bout:";
            // 
            // settingsButton
            // 
            this.settingsButton.Location = new System.Drawing.Point(38, 565);
            this.settingsButton.Name = "settingsButton";
            this.settingsButton.Size = new System.Drawing.Size(139, 34);
            this.settingsButton.TabIndex = 3;
            this.settingsButton.Text = "Settings";
            this.settingsButton.UseVisualStyleBackColor = true;
            this.settingsButton.Click += new System.EventHandler(this.settingsButton_Click);
            // 
            // pisteNumLabel
            // 
            this.pisteNumLabel.AutoSize = true;
            this.pisteNumLabel.Font = new System.Drawing.Font("Microsoft Sans Serif", 16F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.pisteNumLabel.Location = new System.Drawing.Point(280, 566);
            this.pisteNumLabel.Name = "pisteNumLabel";
            this.pisteNumLabel.Size = new System.Drawing.Size(169, 26);
            this.pisteNumLabel.TabIndex = 4;
            this.pisteNumLabel.Text = "Piste Number: 1";
            // 
            // PisteViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(765, 640);
            this.Controls.Add(this.pisteNumLabel);
            this.Controls.Add(this.settingsButton);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.groupBox1);
            this.Name = "PisteViewer";
            this.Text = "Piste Controller";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.colourR)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteL)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.colourL)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.whiteR)).EndInit();
            this.groupBox2.ResumeLayout(false);
            this.groupBox2.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.Label fencerRLabel;
        private System.Windows.Forms.Label fencerLLabel;
        private System.Windows.Forms.PictureBox whiteR;
        private System.Windows.Forms.PictureBox whiteL;
        private System.Windows.Forms.PictureBox colourL;
        private System.Windows.Forms.PictureBox colourR;
        private System.Windows.Forms.ComboBox period_chooser;
        private System.Windows.Forms.Label period_timer;
        private System.Windows.Forms.Button finishBoutButton;
        private System.Windows.Forms.Button selectBoutButton;
        private System.Windows.Forms.ListBox nextBoutsList;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.Label next_bout_names;
        private System.Windows.Forms.Label next_bout_label;
        private System.Windows.Forms.Button settingsButton;
        private System.Windows.Forms.Label scoreLLabel;
        private System.Windows.Forms.Label scoreRLabel;
        private System.Windows.Forms.Label pisteNumLabel;
        private System.Windows.Forms.Button updateBoutsButton;
        private System.Windows.Forms.Button startBoutButton;
        private System.Windows.Forms.Button cancelBoutButton;
        private System.Windows.Forms.Button swapFencersButton;
    }
}

