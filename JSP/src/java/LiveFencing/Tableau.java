/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Tableau {

    private int lastcompleteround_;
    private int firstround_;
    private int lastround_;
    private String name_;
    
    private java.util.ArrayList<java.util.ArrayList<Bout> > matches_;
    
    
    public Tableau(java.util.ArrayList<java.util.ArrayList<Bout> > matches,
                        String name, int firstround, int lastround, int lastcompleteround) {
        name_ = name;
        firstround_ = firstround;
        lastround_= lastround;
        lastcompleteround_ = lastcompleteround;
        matches_ = matches;
        if (null == matches_) {
            // We had best create our own set of bouts
            matches_ = new java.util.ArrayList<java.util.ArrayList<Bout> >();
            // So work out how many rounds we need
            int currRound = firstround_;
            while (currRound >= lastround) {
                matches_.add(new java.util.ArrayList<Bout>());
                currRound /= 2;
            }
            
        }
    }
    protected Bout findBout(int round, int match) {
        if (round > firstround_ || round < lastround_) {
            // Out of bounds
            return null;
        }
        int index = index_from_round(round);
        if (index > matches_.get(index).size()) {
            return null;
        }
        return matches_.get(index).get(match-1);
    }
    
    protected java.util.ArrayList<Bout> getBoutsAtPiste(int piste, int state) {
        java.util.ArrayList<Bout> bouts = new java.util.ArrayList<Bout>();
        for (int i = 0; i < matches_.size(); ++i) {
            java.util.ArrayList<Bout> round = matches_.get(i);
            for (int j = 0; j < round.size(); ++j) {
                Bout bout = round.get(j);
                if (piste == bout.getPiste() && state == bout.getState()) {
                    bouts.add(bout);
                }
            }
        }
        return bouts;     
    }
    
    public String getName() {
        return name_;
    }
    public int getFirstRound() {
        return firstround_;
    }
    public int getLastRound() {
        return lastround_;
    }
    public int getLastCompleteRound() {
        return lastcompleteround_;
    }
    protected java.util.ArrayList<java.util.ArrayList<Bout> > getBouts() {
        return matches_;
    }
    private int index_from_round(int round) {
        // Work out the index of the round
        int currRound = firstround_;
        int index = 0;
        while (currRound > round) {
            ++index;
            currRound /= 2;
        }
        return index;
        
    }
    protected void addRound(int round, java.util.ArrayList<Bout> bouts) {
        if (round > firstround_ || round < lastround_) {
            // Out of bounds
            return;
        }
        int index = index_from_round(round);
        matches_.set(index, bouts);
    }
}
