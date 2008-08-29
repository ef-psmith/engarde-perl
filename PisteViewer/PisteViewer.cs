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
    public partial class PisteViewer : Form
    {
        public PisteViewer()
        {
            InitializeComponent();

            serverName_ = "Localhost:8084";
            pisteNumber_ = "1";
            //equipType_ = "";
            updateServer_ = true;

            allEquipConnectors_ = new List<EquipmentConnector>(5);
            allEquipConnectors_.Add(new PseudoBoxConnector());
            allEquipConnectors_.Add(new SGConnector("Leon Paul", this));

            equipConnector_ = allEquipConnectors_[0];

            enable_buttons();
            update_next_bouts();
            fencerA_on_left_ = true;

        }

        private void allControls_KeyUp(object sender, System.Windows.Forms.KeyEventArgs e)
        {
            BoutState state = BoutState.bs_notready;
            state = bout_.state_;

            switch (e.KeyCode)
            {
                case Keys.NumPad8:
                    if (0 < nextBoutsList.SelectedIndex &&
                        (BoutState.bs_finishedatpiste == state 
                        || BoutState.bs_finishedinengarde == state 
                        || BoutState.bs_notready == state))
                    {
                        --nextBoutsList.SelectedIndex;
                    }
                    break;
                case Keys.NumPad2:
                    if (nextBoutsList.Items.Count - 1 > nextBoutsList.SelectedIndex &&
                        (BoutState.bs_finishedatpiste == state
                        || BoutState.bs_finishedinengarde == state
                        || BoutState.bs_notready == state))
                    {
                        ++nextBoutsList.SelectedIndex;
                    }
                    break;
                case Keys.Add:
                    break;
                case Keys.Subtract:
                    break;
                case Keys.Multiply:
                    break;
                case Keys.Divide:
                    break;
                default:
                    // Do nothing
                    break;
            }
        }

        private void settingsButton_Click(object sender, EventArgs e)
        {
            SettingsDialog settings = new SettingsDialog(this);
            settings.ShowDialog();
        }

        private void updateBoutsButton_Click(object sender, EventArgs e)
        {
            update_next_bouts();
        }

        private void nextBoutsList_SelectedIndexChanged(object sender, EventArgs e)
        {
            int index = -1 == nextBoutsList.SelectedIndex ? 0 : nextBoutsList.SelectedIndex;
            if (nextBoutsList.Items.Count > 0)
                next_bout_names.Text = nextBoutsList.Items[index].ToString();
            else
                next_bout_names.Text = "";
        }

        private void display_fencers_and_score()
        {
            period_timer.Text = "3:00";
            period_chooser.Text = "First Period";

            if (fencerA_on_left_)
            {
                fencerLLabel.Text = bout_.fencerA_;
                fencerRLabel.Text = bout_.fencerB_;
                scoreLLabel.Text = scoreA_.ToString();
                scoreRLabel.Text = scoreB_.ToString();
            }
            else
            {
                fencerLLabel.Text = bout_.fencerB_;
                fencerRLabel.Text = bout_.fencerA_;
                scoreLLabel.Text = scoreB_.ToString();
                scoreRLabel.Text = scoreA_.ToString();
            }
        }
        private void selectBoutButton_Click(object sender, EventArgs e)
        {
            bool replacing_bout = false;
            if (bout_.state_ == BoutState.bs_readytostart)
            {
                // The current bout selected is being replaced
                replacing_bout = true;
            }
            bout_ = boutList_[nextBoutsList.SelectedIndex];
            scoreA_ = 0;
            scoreB_ = 0;
            fencerA_on_left_ = true;
            display_fencers_and_score();

            // Now remove the bout from the list of next bouts
            boutList_.RemoveAt(nextBoutsList.SelectedIndex);
            nextBoutsList.Items.RemoveAt(nextBoutsList.SelectedIndex);

            if (nextBoutsList.Items.Count > 0)
            {
                nextBoutsList.SelectedIndex = 0;
                next_bout_names.Text = nextBoutsList.Items[nextBoutsList.SelectedIndex].ToString();
            }
            else
            {
                next_bout_names.Text = "";
            }

            // Now disable the select bout button until that bout is over
            enable_buttons();
        }
        private void startBoutButton_Click(object sender, EventArgs e)
        {
            // Let the server know the bout has started
            change_bout_state(BoutState.bs_inprogress);

            enable_buttons();
        }

        private void swapFencersButton_Click(object sender, EventArgs e)
        {
            // Mark the fencers as the other way around
            fencerA_on_left_ = fencerA_on_left_ ? false : true;
            // now we don't want to swap the scores because that will be done through the 
            // box or because it shouldn't be done as the fencers were at the wrong ends
            // So swap them over now.  We are not going to write this to the server as we want to wait
            // for the next score change.
            int tempScore = scoreA_;
            scoreA_ = scoreB_;
            scoreB_ = tempScore;

            display_fencers_and_score();
        }

        private void finishBoutButton_Click(object sender, EventArgs e)
        {
            // Confirm the winner
            string lfencer_name = fencerA_on_left_ ? bout_.fencerA_ :bout_.fencerB_ ;
            int lfencer_id = fencerA_on_left_ ? bout_.fencerA_ID_ :bout_.fencerB_ID_ ;
            int lfencer_score = fencerA_on_left_ ? scoreA_ : scoreB_ ;
            string rfencer_name = fencerA_on_left_ ? bout_.fencerB_ :bout_.fencerA_ ;
            int rfencer_id = fencerA_on_left_ ? bout_.fencerB_ID_ :bout_.fencerA_ID_ ;
            int rfencer_score = fencerA_on_left_ ? scoreB_ :scoreA_ ;
            confirmwinner conf = new confirmwinner(lfencer_name, lfencer_id, lfencer_score, rfencer_name, rfencer_id, rfencer_score, this);
            conf.ShowDialog();
            // Let the server know the bout has started
            change_bout_state(BoutState.bs_finishedatpiste);

            enable_buttons();

        }

    }
}
