/* (c) Copyright Oliver Smith 2008 */


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;

namespace PisteView
{
    public partial class serialportsettings : Form
    {
        private SGConnector parent_;
        public serialportsettings(SGConnector parent)
        {
            InitializeComponent();

            parent_ = parent;

            parityCombo.Items.Clear(); parityCombo.Items.AddRange(Enum.GetNames(typeof(Parity)));
            stopBitsCombo.Items.Clear(); stopBitsCombo.Items.AddRange(Enum.GetNames(typeof(StopBits)));

            parityCombo.Text = parent_.parity.ToString();
            stopBitsCombo.Text = parent_.stopBits.ToString();
            dataBitsCombo.Text = parent_.dataBits.ToString();
            baudRateCombo.Text = parent_.baudRate.ToString();

            portNameCombo.Items.Clear();
            foreach (string s in SerialPort.GetPortNames())
                portNameCombo.Items.Add(s);


            if (portNameCombo.Items.Contains(parent_.portName)) portNameCombo.Text = parent_.portName;
            else if (portNameCombo.Items.Count > 0) portNameCombo.SelectedIndex = 0;
            else
            {
                MessageBox.Show(this, "There are no COM Ports detected on this computer.\nPlease install a COM Port and restart this app.", "No COM Ports Installed", MessageBoxButtons.OK, MessageBoxIcon.Error);
                this.Close();
            }
        }
    }
}
