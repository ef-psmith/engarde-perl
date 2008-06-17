/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Tournament {
    
   // Private members
    private String perl_exe_path_ = "C:\\Perl\\bin\\";
    private String perl_file_path_ = "C:\\Documents and Settings\\Oliver\\My Documents\\perl\\";
    private java.util.ArrayList<Competition> competitions_ = new java.util.ArrayList<Competition>();
    private java.util.ArrayList<DisplaySeries> displaySeries_ = new java.util.ArrayList<DisplaySeries>();
    private int nextCompIndex_ = 0;
    
    
    public Tournament() {
        
    }
    protected String build_engarde_file_processing_cmd(String file, int index) {
        String cmd = "\"" +perl_exe_path_ + "perl\"" + " \"" + perl_file_path_ + "writetoxml.pl\" \"" + file + "\" " + Integer.toString(index);
        return cmd;
    }
    
    public String getPerlExePath() {
        return perl_exe_path_;
    }
    public void setPerlExePath(String val) {
        perl_exe_path_ = val;
    }
    public String getPerlFilePath() {
        return perl_file_path_;
    }
    public void setPerlFilePath(String val) {
        perl_file_path_ = val;
    }
    
    // Properties
    public Competition[] getCompetitions() {
        Competition[] array = new Competition[competitions_.size()];
        competitions_.toArray(array);
        return array;
    }
    
    public DisplaySeries[] getDisplaySeries(){
        DisplaySeries[] array = new DisplaySeries[displaySeries_.size()];
        displaySeries_.toArray(array);
        return array;
    }
    
    // Methods
    void addDisplaySeries(DisplaySeries dispSeries) {
        displaySeries_.add(dispSeries);
    }
    void removeDisplaySeries(DisplaySeries dispSeries) {
        displaySeries_.remove(dispSeries);
    }
    
    // Add a new competition, return true if it was added
    boolean addCompetition(Competition comp){
        // Go though the list and check that we haven't already got this file.
        if (-1 != competitions_.indexOf(comp)){
            return false;
        }
        competitions_.add(comp);
        
        // Just set the next index, who cares if there are gaps.
        synchronized(this) {
            comp.setIndex(nextCompIndex_++);
        }
        // Now we need to go through and add extra elements to the display lists
        for (int i = 0;i < displaySeries_.size();++i) {
            DisplaySeries disp = (DisplaySeries)displaySeries_.get(i);
            if (null != disp){
                disp.addCompetition(comp);
            }
        }
        return true;
    }
    
    public static boolean removeCompetition(Tournament tourn, Competition comp) {
        return tourn.removeCompetition(comp);
    }
    
    boolean removeCompetition(Competition comp) {
        return competitions_.remove(comp);
    }
    
    public static Bout[] bouts(Tournament tourn, int piste) {
        return tourn.bouts(piste);
    }
    public class BoutListComparator implements java.util.Comparator {
        public int compare(Object l, Object r) {
            Bout lhs = (Bout)l;
            Bout rhs = (Bout)r;
            
            // Sort by start time, round and matchnumber (no match time yet)
            if (lhs.getRound() > rhs.getRound()) {
                return -1;
            }
            if (lhs.getRound() > rhs.getRound()) {
                return 1;
            }
            if (lhs.getMatch() > rhs.getMatch()) {
                return 1;
            }
            if (lhs.getMatch() > rhs.getMatch()) {
                return -1;
            }
                
            return 0;
        }
    }
    // Gets the next set of bouts that are scheduled for the named piste
    public Bout[] bouts(int piste) {
        java.util.ArrayList<Bout> bouts = new java.util.ArrayList<Bout>();
        for (int i = 0; i < competitions_.size(); ++i) {
            // Note that State 1 is ready.
            bouts.addAll(competitions_.get(i).getBoutsAtPiste(piste, 1));
        }
        
        // Now sort the bouts by start time, round (descending) and matchnumber
        java.util.Collections.sort(bouts, new BoutListComparator());
        return bouts.toArray(new Bout[0]);
    }
    
    public static boolean updateScore(Tournament tourn, int competition, String tableau, int round, int match, int scoreA, int scoreB, int timeRemaining) {
       return tourn.updateScore(competition, tableau, round, match, scoreA, scoreB, timeRemaining) ;
    }
    public boolean updateScore(int competition, String tableau, int round, int match, int scoreA, int scoreB, int timeRemaining) {
        // Update the internal object
        Competition comp = null;
        for (int i = 0; i < competitions_.size(); ++i) {
            if ( competition == competitions_.get(i).getIndex()) {
                comp = competitions_.get(i);
                break;
            }
        }
        boolean success = false;
        if (null != comp) {
            synchronized(comp) {
                
                Bout bout = comp.findBout(tableau, round, match);
                if (null != bout) {
                    bout.setScoreA(scoreA);
                    bout.setScoreB(scoreB);  
                    success = true;
                }
            }
        }
        return success;
    }
    public static boolean changeBoutState(Tournament tourn, int competition, String tableau, int round, int match, int oldstate, int newstate) {
       return tourn.changeBoutState(competition, tableau, round, match, oldstate, newstate) ;
    }
    public boolean changeBoutState(int competition, String tableau, int round, int match, int oldstate, int newstate) {
        // Update the internal object
        Competition comp = null;
        for (int i = 0; i < competitions_.size(); ++i) {
            if ( competition == competitions_.get(i).getIndex()) {
                comp = competitions_.get(i);
                break;
            }
        }
        boolean success = false;
        if (null != comp) {
            synchronized(comp) {
                Bout bout = comp.findBout(tableau, round, match);
                if (null != bout && oldstate == bout.getState()) {
                    bout.setState(newstate);
                    
                    success = true;   
                }
            }
        }
        return success;
    }
    public static boolean setwinner(Tournament tourn, int competition, String tableau, int round, int match, int winner) {
       return tourn.setwinner(competition, tableau, round, match, winner) ;
    }
    public boolean setwinner(int competition, String tableau, int round, int match, int winner) {
        // Update the internal object
        Competition comp = null;
        for (int i = 0; i < competitions_.size(); ++i) {
            if ( competition == competitions_.get(i).getIndex()) {
                comp = competitions_.get(i);
                break;
            }
        }
        boolean success = false;
        if (null != comp) {
            synchronized(comp) {
                Bout bout = comp.findBout(tableau, round, match);
                if (null != bout) {
                    if (winner == bout.getFencerA_ID())
                        bout.setWinner(Bout.Winner.W_A);   
                    else if (winner == bout.getFencerB_ID())
                        bout.setWinner(Bout.Winner.W_B);   
                    else
                        bout.setWinner(Bout.Winner.W_NONE);
                    
                    success = true;   
                }
            }
        }
        return success;
    }
}
