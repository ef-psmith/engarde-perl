/* (c) Copyright Oliver Smith 2008 */


using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Net;
using System.Diagnostics;
using System.IO;
using System.Xml;

namespace PisteView
{
    public partial class PisteViewer : Form
    {
        #region Bouts
        private struct BoutEntry
        {
            public BoutEntry(XmlNode node)
            {
                fencerA_ = "";
                clubA_ = "";
                fencerA_ID_ = -1;
                fencerB_ = "";
                clubB_ = "";
                fencerB_ID_ = -1;


                competition_ = node.Attributes["comp"].Value;
                compKey_ = int.Parse(node.Attributes["compkey"].Value);
                ordinal_ = int.Parse(node.Attributes["order"].Value);
                tableau_ = node.Attributes["tableau"].Value;
                round_ = int.Parse(node.Attributes["round"].Value);
                match_ = int.Parse(node.Attributes["match"].Value);
                state_ = (BoutState)int.Parse(node.Attributes["state"].Value);
                //bout.colour_ = node.Attributes["colour"].Value;
                // Now sort out the fencers
                foreach (XmlNode fencerNode in node.ChildNodes)
                {
                    switch (fencerNode.Name)
                    {
                        case "fencer_a":
                            fencerA_ = fencerNode.InnerText;
                            clubA_ = fencerNode.Attributes["club"].Value;
                            fencerA_ID_ = int.Parse(fencerNode.Attributes["fencer_id"].Value);
                            break;
                        case "fencer_b":
                            fencerB_ = fencerNode.InnerText;
                            clubB_ = fencerNode.Attributes["club"].Value;
                            fencerB_ID_ = int.Parse(fencerNode.Attributes["fencer_id"].Value);
                            break;
                        default:
                            break;
                    }
                }
            }
            public string fencerA_;
            public string clubA_;
            public int fencerA_ID_;
            public string fencerB_;
            public string clubB_;
            public int fencerB_ID_;

            public string competition_;
            public int compKey_;
            //public string colour_;
            public int ordinal_;
            public string tableau_;
            public int round_;
            public int match_;
            public BoutState state_;
        };
        private class BoutComparer : IComparer<BoutEntry>
        {
            // Calls CaseInsensitiveComparer.Compare with the parameters reversed.
            int IComparer<BoutEntry>.Compare(BoutEntry lhs, BoutEntry rhs)
            {
                if (lhs.ordinal_ < rhs.ordinal_)
                    return -1;

                if (lhs.ordinal_ == rhs.ordinal_)
                    return 0;

                return 1;
            }
        };

        private enum BoutState
        {
            bs_notready = 0,
            bs_readytostart = 1,
            bs_inprogress = 2,
            bs_finishedatpiste = 3,
            bs_finishedinengarde = 4,
        }
        #endregion

        private int scoreA_;
        private int scoreB_;
        private BoutEntry bout_;
        private List<BoutEntry> boutList_;
        private bool fencerA_on_left_;

        private string serverName_;
        private string pisteNumber_;
        private string equipType_;
        private EquipmentConnector equipConnector_;
        private List<EquipmentConnector> allEquipConnectors_;
        private bool updateServer_;

        #region Properties
        public List<EquipmentConnector> allConnectors
        {
            get
            {
                return allEquipConnectors_;
            }
        }
        public string serverName
        {
            get
            {
                return serverName_;
            }
            set
            {
                if (0 == serverName_.CompareTo(value))
                {
                    // They are the same so nothing to do
                    return;
                }
                serverName_ = value;
                // Close the DB connection - TODO
            }
        }

        public string pisteNumber
        {
            get
            {
                return pisteNumber_;
            }
            set
            {
                if (0 == pisteNumber_.CompareTo(value))
                {
                    return;
                }
                pisteNumber_ = value;

                pisteNumLabel.Text = "Piste Number: " + pisteNumber_;

                // TODO - redo the query for next bout.
            }
        }

        public string equipType
        {
            get
            {
                return equipType_;
            }

            set
            {
                if (0 == equipType_.CompareTo(value))
                {
                    return;
                }
                // Changing equipment type
                equipType_ = value;
                
            }
        }

        public EquipmentConnector equipConnector
        {
            get
            {
                return equipConnector_;
            }
        }

        public bool updateServer
        {
            get
            {
                return updateServer_;
            }
            set
            {
                updateServer_ = value;
            }
        }
        #endregion

        public String create_match_url(String page)
        {
            string url = "http://" + serverName_ + "/LiveFencing/" + page;

            // Set values for the request back
            url += "?comp=";
            url += bout_.compKey_.ToString();
            url += "&tableau=";
            url += bout_.tableau_;
            url += "&round=";
            url += bout_.round_.ToString();
            url += "&match=";
            url += bout_.match_.ToString();

            return url;
        }
        public void setTime(int seconds_left)
        {
            int mins = seconds_left / 60;
            int secs = seconds_left % 60;

            period_timer.Text = mins.ToString() + ":" + ((secs < 10) ? "0" : "") + secs.ToString();
        }
        public void setScore(int scoreL, int scoreR)
        {
            if (fencerA_on_left_)
            {
                scoreA_ = scoreL;
                scoreB_ = scoreR;
            }
            else
            {
                scoreA_ = scoreR;
                scoreB_ = scoreL;
            }

            // Update the UI.
            this.scoreLLabel.Text = Convert.ToString(scoreA_);
            this.scoreRLabel.Text = Convert.ToString(scoreB_);

            if (updateServer_)
            {
                // Create the request obj
                string url = create_match_url("updatescore.jsp");

                // Set values for the request back
                url += "&scorea=";
                url += scoreA_.ToString();
                url += "&scoreb=";
                url += scoreB_.ToString();

                // TODO time remaining
                url += "&timeremaining=";
                url += "42";
                //strNewValue += bout_.timeRemaining_.ToString();

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
                catch (WebException e)
                {
                    Debug.Print(e.Message);
                }
            }
        }

        private void enable_buttons()
        {
            BoutState state = BoutState.bs_notready;
            state = bout_.state_;
            switch (state)
            {
                case BoutState.bs_readytostart:
                    // The start and cancel bout buttons are enabled as well as select bout
                    startBoutButton.Enabled = true;
                    cancelBoutButton.Enabled = true;
                    selectBoutButton.Enabled = true;
                    swapFencersButton.Enabled = true;
                    finishBoutButton.Enabled = false;
                    break;
                default:
                case BoutState.bs_notready:
                case BoutState.bs_finishedatpiste:
                case BoutState.bs_finishedinengarde:
                    // Nothing ongoing so we can't start finish or cancel bout
                    startBoutButton.Enabled = false;
                    cancelBoutButton.Enabled = false;
                    selectBoutButton.Enabled = true;
                    swapFencersButton.Enabled = false;
                    finishBoutButton.Enabled = false;
                    break;
                case BoutState.bs_inprogress:
                    startBoutButton.Enabled = false;
                    cancelBoutButton.Enabled = false;
                    selectBoutButton.Enabled = false;
                    swapFencersButton.Enabled = true;
                    finishBoutButton.Enabled = true;
                    break;
            }

        }
        private void change_bout_state(BoutState state)
        {
            string strResponse;
            if (updateServer_)
            {
                // Create the request obj
                string url = create_match_url("changeboutstate.jsp");

                // Set values for the request back
                url += "&oldstate=";
                url += ((int)bout_.state_).ToString();
                url += "&newstate=";
                url += ((int)state).ToString();

                // Create a request for the URL.         
                HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);

                try
                {
                    // Do the request to get the response
                    HttpWebResponse response = (HttpWebResponse)req.GetResponse();
                    StreamReader stIn = new StreamReader(response.GetResponseStream());
                    strResponse = stIn.ReadToEnd();
                    stIn.Close();
                    response.Close();
                    Debug.Print("Outcome of UpdateScore request" + strResponse);
                    if (strResponse.Contains("true"))
                    {
                        bout_.state_ = state;
                    }
                    enable_buttons();

                }
                catch (WebException e)
                {
                    Debug.Print(e.Message);
                }
            }
            else
            {

                bout_.state_ = state;
            }
        }

        public void showLights(bool onTargetLeft, bool offTargetLeft, bool onTargetRight, bool offTargetRight)
        {
            if (onTargetLeft)
            {
                colourL.Image = PisteView.Properties.Resources.red_on;
            }
            else
            {
                colourL.Image = PisteView.Properties.Resources.red_off;
            }

            if (offTargetLeft)
            {
                whiteL.Image = PisteView.Properties.Resources.white_on;
            }
            else
            {
                whiteL.Image = PisteView.Properties.Resources.white_off;
            }
            if (onTargetRight)
            {
                colourR.Image = PisteView.Properties.Resources.green_on;
            }
            else
            {
                colourR.Image = PisteView.Properties.Resources.green_off;
            }
            if (offTargetRight)
            {
                whiteR.Image = PisteView.Properties.Resources.white_on;
            }
            else
            {
                whiteR.Image = PisteView.Properties.Resources.white_off;
            }
        }

        private void update_next_bouts()
        {
            Stream dataStream = null;
            HttpWebResponse response = null;
            nextBoutsList.Items.Clear();
            try
            {
                string url = "http://" + serverName_ + "/LiveFencing/nextbouts.jsp?piste=" + pisteNumber_.ToString();
                // Create a request for the URL.         
                WebRequest request = WebRequest.Create(url);
                // If required by the server, set the credentials.
                request.Credentials = CredentialCache.DefaultCredentials;
                // Get the response.
                response = (HttpWebResponse)request.GetResponse();
                // Display the status.
                Debug.WriteLine(response.StatusDescription);

                XmlDocument xmldoc = new XmlDocument();
                // Get the stream containing content returned by the server.
                dataStream = response.GetResponseStream();
                xmldoc.Load(dataStream);
                XmlNode baseNode = xmldoc.FirstChild;

                // now verify that the node is bouts
                if (0 == baseNode.Name.CompareTo("bouts"))
                {
                    boutList_ = new List<BoutEntry>();
                    // Got the right thing
                    foreach (XmlNode node in baseNode.ChildNodes)
                    {
                        // Got a name
                        if (0 == node.Name.CompareTo("bout"))
                        {
                            BoutEntry bout = new BoutEntry(node);
                            // Now add the bout to a list of bouts.
                            boutList_.Add(bout);
                        }
                    }

                    // Now order the bouts according to the ordinal
                    boutList_.Sort(new BoutComparer());

                    foreach (BoutEntry bout in boutList_)
                    {
                        //Debug.Print("Ordinal " + bout.ordinal_.ToString() + "\n");
                        string boutString = bout.competition_ + ": " + bout.fencerA_ + " (" + bout.clubA_ + ") vs " + bout.fencerB_ + " (" + bout.clubB_ + ")";
                        nextBoutsList.Items.Add(boutString);
                    }
                    // Set the next bout.
                    if (0 < nextBoutsList.Items.Count)
                    {
                        next_bout_names.Text = nextBoutsList.Items[0].ToString();
                        nextBoutsList.SelectedIndex = 0;
                    }
                    else
                        next_bout_names.Text = "";
                }
            }
            catch (WebException ex)
            {
                Debug.Print(ex.Message);
            }
            finally
            {
                // Cleanup the streams and the response.
                if (null != dataStream)
                    dataStream.Close();
                if (null != response)
                    response.Close();

            }
        }
    }
}