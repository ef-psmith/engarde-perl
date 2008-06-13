/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class DisplaySeriesIterator {
    
    private DisplaySeries parent_;
    private String name_;
    private int index_;
    private CompetitionView view_;
    
    public DisplaySeriesIterator() {
        index_ = -1;
    }
    
    public static void setTournament(DisplaySeriesIterator iter, Tournament tourn, String series) {
        
        // If we already have a parent then do nothing
        if (null != iter.parent_) {
            return;
        }
        // Go through the display series on the tournament to find our parent
        DisplaySeries[] allSeries = tourn.getDisplaySeries();
        
        for (int i = 0; i < allSeries.length; ++i) {
            DisplaySeries thisSeries = allSeries[i];
            if (null != thisSeries && 0 == series.compareTo(thisSeries.getName())) {
                iter.parent_ = thisSeries;
                // If we already have a name then set it on the parent
                if (null != iter.name_ && !iter.name_.isEmpty()) {
                    iter.parent_.addSession(iter.name_);
                }
                break;
            }
        }
    }
    
    public void setSessionName(String sess) {
        
        // If no change of name then do nothing.
        if (null != name_ && 0 == name_.compareTo(sess)) {
            return;
        }
        // If we already have a name then remove it from the parent
        if (null != name_ && !name_.isEmpty()) {
            parent_.removeSession(name_);
        }
        name_ = sess;
        if (null != parent_) {
            parent_.addSession(name_);
        }
    }
    
    public CompetitionView getNextView() {
        int startIndex = index_;
        do {
            ++index_;
            if (index_ >= parent_.getViews().length) {
                if (-1 == startIndex) {
                    // We have just gone off the end of the array
                    // so if we started from -1 then we must have gone all
                    // the way around without finding anything.
                    return null;
                }
                index_ = 0;
            }
            view_ = parent_.getViews()[index_];
            if (index_ == startIndex) {
                // We have gone all the way around so time to stop.
                break;
            }
        } while (null == view_ || !view_.isEnabled());
        if (index_ == startIndex && (null == view_ || !view_.isEnabled())) {
            view_ = null;
        }
        return view_;
    }
    
    public CompetitionView getCurrentView() {
        return view_;
    }

}
