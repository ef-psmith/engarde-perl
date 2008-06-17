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
    private java.util.ArrayList<Seed> seeds_;
    
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
        
        if (null != entries_) {
            for (int i = 0;i < entries_.size(); ++i) {
                Entry thisEntry = entries_.get(i);
                if (thisEntry.getId() == ID) {
                    return thisEntry;
                }
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
    
    public java.util.ArrayList<Bout> getBoutsAtPiste(int piste, int state) {
        // Go through the tableaus looking for Bouts at that piste
        java.util.ArrayList<Bout> bouts = new java.util.ArrayList<Bout>();
        for (int i = 0; i < tableaus_.size(); ++i) {
            bouts.addAll(tableaus_.get(i).getBoutsAtPiste(piste, state));
        }
        return bouts;
    }
    
    public synchronized Entry[] getEntries() {
        check_for_file_changes();
        if (null == entries_) {
            return new Entry[0];
        }
        
        return entries_.toArray(new Entry[0]);
    }
    public synchronized Result[] getResults() {
        check_for_file_changes();
        if (null == results_) {
            return new Result[0];
        }
        
        return results_.toArray(new Result[0]);
    }
    public synchronized Tableau[] getTableaus() {
        check_for_file_changes();
        if (null == tableaus_) {
            return new Tableau[0];
        }
        
        return tableaus_.toArray(new Tableau[0]);
    }
    
    public Seed[] getSeeds(int pouleIndex) {
        // Going to ignore the poule index at the moment because we are assuming a single round
        check_for_file_changes();
        if (null == seeds_) {
            return new Seed[0];
        }
        
        return seeds_.toArray(new Seed[0]);
        
    }
    
    protected Bout findBout(String tableau, int round, int match) {
        // First find the Tableau
        Tableau theTableau = null;
        if (null != tableaus_) {
            for (int i = 0; i < tableaus_.size(); ++i) {
                Tableau thisTab = tableaus_.get(i);
                if (tableau.equals(thisTab.getName())) {
                    theTableau = thisTab;
                    break;
                }
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
                // We aren't going to clear the tableaus as these may have been updated from the piste
                //tableaus_ = null;
                seeds_ = null;
                
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
    
                // read the ls output
                XMLReader xr = XMLReaderFactory.createXMLReader();
                // Set the ContentHandler...
                CompetitionContentHandler compReader = new CompetitionContentHandler(this,xr);
                xr.setContentHandler( compReader );
                // Parse the file...
                xr.parse( new InputSource(inputstreamreader) );
                
                int result = proc.waitFor();
                
                // Now set the name and short name.
                name_ = compReader.getName();
                shortName_ = compReader.getShortName();
                
                // Then the collections
                results_ = compReader.getResults();
                entries_ = compReader.getEntries();
                tableaus_ = compReader.getTableaux();
                seeds_ = compReader.getSeeds();
                
            } catch (Exception ex) {
                String mess = ex.getMessage();
            
            }
        } 
    }
    
}
