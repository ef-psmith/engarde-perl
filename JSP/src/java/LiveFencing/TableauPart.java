/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class TableauPart {
    
    private int round_;
    
    private java.util.ArrayList<Bout> first_round_;
    private java.util.ArrayList<Bout> second_round_;
    
    protected TableauPart(java.util.ArrayList<Bout> firstRound, java.util.ArrayList<Bout> secondRound, int round) {
        // If we only have two sets of bouts then we are a finals view
       first_round_ = firstRound;
       second_round_ = secondRound;
        round_ = round;
    }
    public int getRound() {
        return round_;
    }
    
    public Bout[] getFirstRound() {
        return first_round_.toArray(new Bout[0]);
    }
    public Bout[] getSecondRound() {
        return second_round_.toArray(new Bout[0]);
    }

}
