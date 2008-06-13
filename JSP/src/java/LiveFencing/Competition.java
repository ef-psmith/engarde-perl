/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;
import java.io.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
/**
 *
 * @author Oliver
 */
public class Competition {
    
    private Tournament parent_;
    private String engardeFile_;
    private String name_;
    private String shortName_;
    private boolean unique_;
    private int index_;
    private long lastModifiedTime_;
    private String colour_;
    private java.util.ArrayList<Result> results_;
    private java.util.ArrayList<Entry> entries_;
    private java.util.ArrayList<CompetitionView> views_;
    private java.util.ArrayList<Tableau> tableaus_;
    
    public Competition(){
        unique_ = false;
    }
    
    public Tournament getTournament() {
        return parent_;
    }
    
    // comparator, equality is based on the engarde file.
     public boolean equals(Object o) {
        Competition rhs = (Competition)o;
        if (null != rhs) {
            return (0 == engardeFile_.compareTo(rhs.getEngardeFile()));
        }
        return false;
    }
     
     public int hashCode( ){
         return engardeFile_.hashCode();
     }
    
    // Set the parent tournament
    public static void setTournament(Competition comp, Tournament newParent){
        comp.parent_ = newParent;
        // Add ourselves.  Tell the world whether it was a new one
        boolean wasnew = newParent.addCompetition(comp);
        
        if (wasnew) {
            // Lock the competition.
            synchronized (comp) {
                comp.process_engarde_file();
            }
        }
    }
    
    public boolean isUnique(){
        return unique_;
    }
    
    /// The file which contains the Engarde Info
    public synchronized String getEngardeFile(){
        return engardeFile_;
    }
    public synchronized void setEngardeFile(String file){
        boolean same = false;
        if (null != engardeFile_ && 0 == engardeFile_.compareTo(file)) {
            same = true;
        }
        engardeFile_ = file;
        
        // If the file has changed then process it.
        if (!same) {
            process_engarde_file();
        }
    }
    
    public synchronized String getName(){
        check_for_file_changes();
        return name_;
    }
    public synchronized String getShortName(){
        check_for_file_changes();
        return shortName_;
    }

    public int getIndex() {
        return index_;
    }
    public void setIndex(int newIndex) {
        index_ = newIndex;
    }
    
    public String getColour() {
        return colour_;
    }
    public void setColour(String col) {
        colour_ = col;
    }
    
    protected Entry findEntryByID(int ID, java.util.ArrayList<Entry> fallbackList) {
        
        for (int i = 0;i < entries_.size(); ++i) {
            Entry thisEntry = entries_.get(i);
            if (thisEntry.getId() == ID) {
                return thisEntry;
            }
        }
        // So now try the fallback list
        for (int i = 0;i < fallbackList.size(); ++i) {
            Entry thisEntry = fallbackList.get(i);
            if (thisEntry.getId() == ID) {
                return thisEntry;
            }
        }
        return null;
    }
    
    public synchronized Entry[] getEntries() {
        check_for_file_changes();
        if (null == entries_) {
            entries_ = new java.util.ArrayList<Entry>();
            try {
                java.sql.Connection conn = parent_.getDBConn();
                java.sql.Statement stmt = conn.createStatement();
                java.sql.ResultSet resSet = stmt.executeQuery("SELECT * FROM fencers WHERE compkey = " + Integer.toString(index_) + " ORDER BY name");

                while (resSet.next()) {
                    entries_.add(new Entry(resSet.getString(1),resSet.getString(2), resSet.getInt(6), resSet.getInt(3), resSet.getInt(4), resSet.getInt(5)));
                }
            } catch (java.sql.SQLException e) {
                String mess = e.getMessage();
            }
            
        }
        
        return entries_.toArray(new Entry[0]);
    }
    public synchronized Result[] getResults() {
        check_for_file_changes();
        if (null == results_) {
            try {
                java.sql.Connection conn = parent_.getDBConn();
                java.sql.Statement stmt = conn.createStatement();
                java.sql.ResultSet resSet = stmt.executeQuery("SELECT position, name, club FROM results,fencers WHERE fencers.key = results.fencerkey AND results.compkey = " + Integer.toString(index_) + " ORDER BY \"position\"");

                results_ = new java.util.ArrayList<Result>();
                while (resSet.next()) {
                    results_.add(new Result(resSet.getInt(1),resSet.getString(2), resSet.getString(3)));
                }
            } catch (java.sql.SQLException e) {
                String mess = e.getMessage();
            } 
        }
        
        return results_.toArray(new Result[0]);
    }
    public synchronized Tableau[] getTableaus() {
        check_for_file_changes();
        if (null == tableaus_) {
            tableaus_ = new java.util.ArrayList<Tableau>();
            try {
                java.sql.Connection conn = parent_.getDBConn();
                java.sql.Statement stmt = conn.createStatement();
                java.sql.ResultSet resSet = stmt.executeQuery("SELECT tableauprefix, firstround, lastround, lastcompleteround FROM tableaus WHERE compkey = " + Integer.toString(index_));

                while (resSet.next()) {
                    String tableau = resSet.getString(1);
                    // Now create the matches.
                    java.util.ArrayList<java.util.ArrayList<Bout> > rounds = new java.util.ArrayList<java.util.ArrayList<Bout> >();
                    for (int i = resSet.getInt(2); i >= resSet.getInt(3); i = i/2 ) {
                        java.util.ArrayList<Bout> bouts = new java.util.ArrayList<Bout>();
                        java.sql.Statement matchStmt = conn.createStatement();
                        
                        String sql = "SELECT matches.fencera, a_fencers.name, a_fencers.club,";
                        sql += " matches.fencerb, b_fencers.name, b_fencers.club,";
                        sql += "competitions.name, matches.compkey, matches.tableau, matches.round, matches.match,";
                        sql += " matches.state, matches.piste, matches.winner, matches.scorea, matches.scoreb FROM matches ";
                        sql += "JOIN fencers a_fencers ON matches.fencera = a_fencers.key ";  
                        sql += "JOIN fencers b_fencers ON matches.fencerb = b_fencers.key "; 
                        sql += "JOIN competitions ON matches.compkey = competitions.key ";   
                        sql += "WHERE matches.tableau = '";
                        sql += tableau;
                        sql += "' AND matches.round = ";
                        sql += Integer.toString(i);
                        sql += " AND matches.compkey = ";
                        sql += Integer.toString(index_);
                        sql += " ORDER BY match"; 
                        java.sql.ResultSet matchResSet = matchStmt.executeQuery(sql);

                        while (matchResSet.next()) {
                            Bout.Winner winner = Bout.Winner.W_NONE;
                            int winnerID = matchResSet.getInt(14);
                            if (winnerID == matchResSet.getInt(1) )
                                winner = Bout.Winner.W_A;
                            else if (winnerID == matchResSet.getInt(4) )
                                winner = Bout.Winner.W_B;
                            
                            bouts.add(new Bout(matchResSet.getInt(1),matchResSet.getString(2), matchResSet.getString(3),
                                    matchResSet.getInt(4), matchResSet.getString(5), matchResSet.getString(6),
                                    matchResSet.getString(7), matchResSet.getInt(8), matchResSet.getString(9),
                                    matchResSet.getInt(10), matchResSet.getInt(11), matchResSet.getInt(12),matchResSet.getInt(13),
                                    winner, matchResSet.getInt(15), matchResSet.getInt(16)));
                        }
                        rounds.add(bouts);
                    }
                    tableaus_.add(new Tableau(rounds, tableau ,resSet.getInt(2), resSet.getInt(3), resSet.getInt(4)));
                }
            } catch (java.sql.SQLException e) {
                String mess = e.getMessage();
            } 
        }
        
        return tableaus_.toArray(new Tableau[0]);
    }
    
    protected Bout findBout(String tableau, int round, int match) {
        // First find the Tableau
        Tableau theTableau = null;
        for (int i = 0; i < tableaus_.size(); ++i) {
            Tableau thisTab = tableaus_.get(i);
            if (tableau.equals(thisTab.getName())) {
                theTableau = thisTab;
                break;
            }
        }
        if (null == theTableau) {
            // If we haven't found a tableau then stop now.
            return null;
        }
        return theTableau.findBout(round, match);
        
    }
    
    protected void check_for_file_changes() {
        // Going to check for the modified date of the file.  If it is newer than
        // when we processed it then we need to abandon our cached data and reprocess.
        if (null != parent_ && !engardeFile_.isEmpty()) {
            File file = new File(engardeFile_);
            long lastMod = file.lastModified();
            
            if (lastMod > lastModifiedTime_) {
                // The file is newer so clear all our current data.
                results_ = null;
                entries_ = null;
                tableaus_ = null;
                
                // Now go through the Display series and get rid of thier changed lists
                for (int i = 0; i < views_.size() ; ++i) {
                    views_.get(i).ClearCache();
                }
                // Now reprocess
                process_engarde_file();
            }
        }
    }
    
    private void process_engarde_file() {
        if (null != parent_ && !engardeFile_.isEmpty()) {
            
            File file = new File(engardeFile_);
            lastModifiedTime_ = file.lastModified();
            // We have a tournament and an engarde file.
            Runtime rt = Runtime.getRuntime();
            
            try {
                //String command = "C:\\perl\\bin\\perl \"C:\\Documents and Settings\\Oliver\\My Documents\\NetBeansProjects\\LiveFencing\\src\\perl\\writetodb.pl\" \"" + engardeFile_ + "\" " + Integer.toString(index_);
                String command = parent_.build_engarde_file_processing_cmd(engardeFile_, index_);
                Process proc = rt.exec(command);
                InputStream inputstream =
                proc.getInputStream();
                InputStreamReader inputstreamreader = new InputStreamReader(inputstream);
                BufferedReader bufferedreader = new BufferedReader(inputstreamreader);
    
                // read the ls output
                XMLReader xr = XMLReaderFactory.createXMLReader();
                // Set the ContentHandler...
                CompetitionContentHandler compReader = new CompetitionContentHandler(this,xr);
                xr.setContentHandler( compReader );
                // Parse the file...
                xr.parse( new InputSource(inputstreamreader) );
                
                String line;
                bufferedreader.reset();
                while ((line = bufferedreader.readLine()) 
                          != null) {
                    System.out.println(line);
                }
                int result = proc.waitFor();
                int test = result;
                
                // Now query the database for our names.
                java.sql.Connection conn = parent_.getDBConn();
                java.sql.Statement stmt = conn.createStatement();
                
                String sql = "SELECT name,shortname FROM competitions WHERE key=" + index_;
                java.sql.ResultSet resultSet = stmt.executeQuery(sql);
                
                while (resultSet.next()) {
                    name_ = resultSet.getString("name");
                    shortName_ = resultSet.getString("shortname");                
                }
            } catch (Exception ex) {
            
            }
        }
    
    }
    
}
