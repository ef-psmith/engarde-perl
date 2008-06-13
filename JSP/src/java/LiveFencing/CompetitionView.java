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
    private String viewType;
    private boolean enabled;
    private String tableau_;
    private java.util.ArrayList<Seed> seeds_;
    private int displayround_;
    
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
    public void ClearCache() {
        // Just need to get rid of our cached seeds.
        seeds_ = null;
    }
    
    public Seed[] getSeeding() {
        // Assume a single round of poules
        synchronized( competition_) {
            competition_.check_for_file_changes();
            if (null == seeds_) {
                seeds_ = new java.util.ArrayList<Seed>();
                try {
                    java.sql.Connection conn = competition_.getTournament().getDBConn();
                    java.sql.Statement stmt = conn.createStatement();
                    java.sql.ResultSet resSet = stmt.executeQuery("SELECT seed, name,club,\"v-over-m\",ind,hs  FROM seeding, fencers WHERE fencers.key = seeding.fencerkey ORDER By seeding.seed");

                    while (resSet.next()) {
                        seeds_.add(new Seed(resSet.getInt(1), resSet.getString(2),resSet.getString(3), resSet.getString(4), resSet.getInt(5), resSet.getInt(6)));
                    }
                } catch (java.sql.SQLException e) {
                    String mess = e.getMessage();
                }
            }
        
            return seeds_.toArray(new Seed[0]);
        }
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
                if (tab.getLastCompleteRound() < 8) {
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
                int modulus = rounditer / numparts;
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
