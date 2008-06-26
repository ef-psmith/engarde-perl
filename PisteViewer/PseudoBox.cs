/* (c) Copyright Oliver Smith 2008 */

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace PisteView
{
    public partial class PseudoBox : Form
    {
        PisteViewer parent_;
        public PseudoBox(PisteViewer parent)
        {
            InitializeComponent();
            parent_ = parent;
        }

        private void sendButton_Click(object sender, EventArgs e)
        {
            parent_.showLights(colourLeftCheck.Checked, whiteLeftCheck.Checked, colourRightCheck.Checked, whiteRightCheck.Checked);
            parent_.setScore(Convert.ToInt32(scoreLeftText.Text), Convert.ToInt32(scoreRightText.Text));
            int time = 0;
            String timeStr = timeBox.Text;
            char[] charSeparators = new char[] { ':' };
            String[] numbers = timeStr.Split(charSeparators, StringSplitOptions.None);
            if (2 == numbers.Length)
            {
                time = 60 * Convert.ToInt32(numbers[0]) + Convert.ToInt32(numbers[1]);
            }
            parent_.setTime(time);
        }

    }
}
