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
    public partial class SettingsDialog : Form
    {
        private PisteViewer parent_;
        private EquipmentConnector currentConnector_;

        public SettingsDialog(PisteViewer view)
        {
            InitializeComponent();
            parent_ = view;
            updateServerCheck.Checked = true;
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            // Save the data to the parent
            parent_.serverName = dbDSNText.Text;
            parent_.pisteNumber = pisteNumText.Text;

            //parent_.equipConnector = (equipCombo.Text);

            Close();
        }

        private void cancelButton_Click(object sender, EventArgs e)
        {
            // Just close
            Close();
        }

        private void SettingsDialog_Load(object sender, EventArgs e)
        {
            pisteNumText.Text = parent_.pisteNumber;
            dbDSNText.Text = parent_.serverName;
            foreach (EquipmentConnector iter in parent_.allConnectors)
            {
                equipCombo.Items.Add(iter.name());
            }

            equipCombo.Text = parent_.equipConnector.name();
        }

        private void advSettings_Click(object sender, EventArgs e)
        {
            parent_.equipConnector.showSettings(parent_);
        }

        private void equipCombo_SelectedIndexChanged(object sender, EventArgs e)
        {
            ComboBox cmb = (ComboBox)sender;
            if (null != cmb)
            {
                foreach (EquipmentConnector iter in parent_.allConnectors)
                {
                    if (0 == cmb.Text.CompareTo(iter.name()))
                    {
                        currentConnector_ = iter;
                    }
                }
            }
        }

        private void updateServerCheck_CheckedChanged(object sender, EventArgs e)
        {
            parent_.updateServer = updateServerCheck.Checked;
        }

    }
}
