/* (c) Copyright Oliver Smith 2008 */


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.Diagnostics;
using System.IO;
using System.Xml;

namespace PisteView
{
    public partial class confirmwinner : Form
    {
        int l_id_;
        int l_score_;
        int r_id_;
        int r_score_;
        PisteViewer parent_;

        public confirmwinner(string fencerL_Name, int fencerL_ID, int fencerL_Score,
                                string fencerR_Name, int fencerR_ID, int fencerR_Score,
                                PisteViewer parent)
        {
            InitializeComponent();

            parent_ = parent;

            fencerLLabel.Text = fencerL_Name;
            l_score_ = fencerL_Score;
            scoreLLabel.Text = l_score_.ToString();
            l_id_ = fencerL_ID;

            fencerRLabel.Text = fencerR_Name;
            r_score_ = fencerR_Score;
            scoreRLabel.Text = r_score_.ToString();
            r_id_ = fencerR_ID;

            if (l_score_ > r_score_)
            {
                winnerLRadio.Checked = true;
            }
            else if (r_score_ > l_score_)
            {
                winnerRRadio.Checked = true;
            }
            enable_button();
        }
        private void enable_button()
        {
            if (winnerLRadio.Checked || winnerRRadio.Checked)
                confirmButton.Enabled = true;
            else
                confirmButton.Enabled = false;
        }

        private void confirmButton_Click(object sender, EventArgs e)
        {
            // Assume if L not checked then R is checked (if not button should not be enabled)
            int winnerID = winnerLRadio.Checked ? l_id_ : r_id_;

            string url = parent_.create_match_url("setwinner.jsp");
            url += "&winnerid=";
            url += winnerID.ToString();


            // Create a request for the URL.         
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);

            try
            {
                // Do the request to get the response
                HttpWebResponse response = (HttpWebResponse)req.GetResponse();
                StreamReader stIn = new StreamReader(response.GetResponseStream());
                string strResponse = stIn.ReadToEnd();
                stIn.Close();
                response.Close();
                Debug.Print("Outcome of UpdateScore request" + strResponse);
            }
            catch (WebException ex)
            {
                Debug.Print(ex.Message);
            }
            this.Close();

        }

        private void winnerLRadio_CheckedChanged(object sender, EventArgs e)
        {
            winnerRRadio.Checked = winnerLRadio.Checked ? false : true;
            enable_button();

        }

        private void winnerRRadio_CheckedChanged(object sender, EventArgs e)
        {
            winnerLRadio.Checked = winnerRRadio.Checked ? false : true;
            enable_button();

        }
    }
}
