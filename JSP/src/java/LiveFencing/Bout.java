/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Bout {
    public enum Winner {
        W_NONE,
        W_A,
        W_B
    }
    private int fencerA_ID_;
    private String fencerA_name_;
    private String fencerA_club_;
    private int fencerB_ID_;
    private String fencerB_name_;
    private String fencerB_club_;
    private String competition_;
    private int competition_key_;
    private String tableau_;
    private int round_;
    private int match_;
    private int state_;
    private Winner winner_;
    private int piste_;
    private int scoreA_;
    private int scoreB_;
    
    
    public Bout(int fencerA, String fencerAName, String fencerAClub, int fencerB, String fencerBName, String fencerBClub,
            String comp, int compKey, String tableau, int round, int match, int state, int piste, Winner winner, int scoreA, int scoreB) {
        fencerA_ID_ = fencerA;
        fencerA_name_ = fencerAName;
        fencerA_club_ = fencerAClub;
        fencerB_ID_ = fencerB;
        fencerB_name_ = fencerBName;
        fencerB_club_ = fencerBClub;
        competition_ = comp;
        competition_key_ = compKey;
        tableau_ = tableau;
        round_ = round;
        match_= match;
        state_ = state;
        winner_ = winner;
        piste_ = piste;
        scoreA_ = scoreA;
        scoreB_ = scoreB;
    }
    
    public int getFencerA_ID() {
        return fencerA_ID_;
    }
    public String getFencerA_Name() {
        return fencerA_name_;
    }
    public String getFencerA_Club() {
        return fencerA_club_;
    }
    public int getFencerB_ID() {
        return fencerB_ID_;
    }
    public String getFencerB_Name() {
        return fencerB_name_;
    }
    public String getFencerB_Club() {
        return fencerB_club_;
    }
   /* public String getCompetition() {
        return competition_;
    }*/
    public int getCompetitionKey() {
        return competition_key_;
    }
    public String getTableau() {
        return tableau_;
    }
    public int getRound() {
        return round_;
    }
    public int getMatch() {
        return match_;
    }
    public int getState() {
        return state_;
    }
    public Winner getWinner() {
        return winner_;
    }
    public void setWinner(Winner value) {
        winner_ = value;
    }
    public int getPiste() {
        return piste_;
    }
    public int getScoreA() {
        return scoreA_;
    }
    public void setScoreA(int scoreA) {
        scoreA_ = scoreA;
    }
    public int getScoreB() {
        return scoreB_;
    }
    public void setScoreB(int scoreB) {
        scoreB_ = scoreB;
    }
    
    public String getFencerAClasses() {
        String classes = "";
        switch (state_) {
            case 0:
            case 1:
            default:
                classes += "bout-pending";
                break;
            case 2:
                classes += "bout-started";
                break;
            case 3:
            case 4:
                if (Winner.W_A == winner_)
                    classes += "winner";
                else
                    classes += "loser";
        }
        return classes;
    }
    
    public String getFencerBClasses() {
        String classes = "";
        switch (state_) {
            case 0:
            case 1:
            default:
                classes += "bout-pending";
                break;
            case 2:
                classes += "bout-started";
                break;
            case 3:
            case 4:
                if (Winner.W_B == winner_)
                    classes += "winner";
                else
                    classes += "loser";
        }
        return classes;
    }

}
