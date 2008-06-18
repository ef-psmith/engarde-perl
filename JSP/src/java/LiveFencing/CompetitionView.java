/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class CompetitionView {
    
    private Competition competition_;
    private String viewType = "none";
    private boolean enabled = false;
    private String tableau_ = "none";
    private int displayround_ = 0;
    
    protected CompetitionView (Competition comp) {
        competition_ = comp;
        
        // For the moment don't allow the choice of which round to use as the base
        displayround_ = 0;
    }
    
    public Competition getCompetition() {
        return competition_;
    }
    
    public void setType(String type){
        viewType = type;
    
    }
    public String getType() {
        return viewType;
    }
    
    public void setEnabled(boolean enab) {
        enabled = enab;
    }
    
    public boolean isEnabled(){
        return enabled;
    }
    
    public void setTableau(String tab) {
        tableau_ = tab;
    }
    public String getTableau(){
        return tableau_;
    }
    
    public Seed[] getSeeding() {
        // Assume a single round of poules of index 0
        return competition_.getSeeds(0);
    }
    
    public TableauPart[] getTableauParts() {
        java.util.ArrayList<TableauPart> parts = new java.util.ArrayList<TableauPart>();
        // First work out which rounds we are displaying.
        Tableau[] tabs = competition_.getTableaus();
        Tableau tab = null;
        for (int i = 0; i < tabs.length; ++i) {
            if (0 == tableau_.compareTo(tabs[i].getName())) {
                tab = tabs[i];
                break;
            }
        }
        if (null != tab) {
            int round = displayround_;
            if (0 == displayround_) {
                // Need to calculate the round
                if (0 == tab.getLastCompleteRound()) {
                    // No rounds yet complete
                    round = tab.getFirstRound();
                } else if (tab.getLastCompleteRound() < 8) {
                    // We can't easily display the semis as we don't have the css at this point
                    round = 8;
                } else {
                    round = tab.getLastCompleteRound();
                }
            }
            // if we still haven't worked it out then use the first round in the tableau
            if (0 == round) {
                round = tab.getFirstRound();
            }
            
            // There are 8 fencers per segment of the tableau
            int numparts = round / 8;
            
            java.util.ArrayList<java.util.ArrayList<Bout> > bouts = tab.getBouts();
            int firstroundindex = 0;
            int tabround = tab.getFirstRound();
            // Find the index of our round.
            while (tabround > round) {
                ++firstroundindex;
                tabround /= 2;
            }
            java.util.ArrayList<java.util.ArrayList<java.util.ArrayList<Bout> > > boutlist = new java.util.ArrayList<java.util.ArrayList<java.util.ArrayList<Bout> > >(numparts);
            // Add the new arraylists
            for (int i = 0 ; i < numparts; ++i) {
                boutlist.add(new java.util.ArrayList<java.util.ArrayList<Bout> >());
            }
            int rounditer = round;
            int roundcounter = 0;
            // This is a odd way of only doing two rounds, but it does allow us to extend it later.
            while (rounditer >= round /2) {
                // The modulus relates to bouts not fencers so needs an extra factor of 2
                int modulus = rounditer / (2* numparts);
                for (int i = 0; i < bouts.get(firstroundindex).size();++i) {
                    int partindex = i / modulus;
                    int boutindex = i % modulus;
                    
                    if (0 == boutindex) {
                        // Need to add a new list to the list...
                        boutlist.get(partindex).add(new java.util.ArrayList<Bout>());
                    }
                    boutlist.get(partindex).get(roundcounter).add(bouts.get(firstroundindex).get(i));
                }
                ++firstroundindex;
                rounditer /= 2;
                ++roundcounter;
            }
            // Now create the tableauparts
            for (int i = 0 ; i < numparts; ++i) {
                parts.add(new TableauPart(boutlist.get(i).get(0),boutlist.get(i).get(1),round));
            }
        }
                
        return parts.toArray(new TableauPart[parts.size()]);
    }

}
