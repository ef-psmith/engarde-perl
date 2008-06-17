/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class DisplaySeries {
    
    private java.util.ArrayList<String> sessions;
    private java.util.ArrayList<CompetitionView> views;
    private String name;
    private Tournament parent;
    
    public DisplaySeries() {
        sessions = new java.util.ArrayList<String>();
        views = new java.util.ArrayList<CompetitionView>();
    }
    
    public String[] getSessions() {
        String[] array = new String[sessions.size()];
        sessions.toArray(array);
        return array;
    }
    
    public CompetitionView[] getViews() {
        CompetitionView[] array = new CompetitionView[views.size()];
        views.toArray(array);
        return array;
    }
    
    public void setName(String nom){
        name = nom;
    }
    public String getName() {
        return name;
    }
    
    public static void setTournament(DisplaySeries disp, Tournament tourn){
        disp.parent = tourn;
        tourn.addDisplaySeries(disp);
        
        for (int i = 0; i < tourn.getCompetitions().length; ++i) {
            disp.addCompetition(tourn.getCompetitions()[i]);
        }
    }
    
    
    // Methods

    public void addSession(String sess){
        sessions.add(sess);
    }
    public void removeSession(String sess){
        sessions.remove(sess);
    }
    
    public void addCompetition(Competition comp){
        CompetitionView newCompView = new CompetitionView(comp);
            
        views.add(newCompView);
    }
    public void removeCompetition(Competition comp){
        for (int i = 0;i < views.size(); ++i) {
            CompetitionView view = views.get(i);
            if (null != view && view.getCompetition().equals(comp)) {
                views.remove(view);
                break;
            }
        }
    }
}
