/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import java.io.*;
import java.util.*;

/**
 *
 * @author Oliver
 * (c) 2008
 */
public class BoutsContentHandler extends DefaultHandler {
    private CompetitionContentHandler parent_;
    private XMLReader parser_;
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    private ArrayList<TableauPlaceHolder> tableauPlaceHolders_ = new ArrayList<TableauPlaceHolder>();
    private TableauPlaceHolder current_tableau_ = null;
    private int current_matchnum_ = -1;  
    private TableauPlaceHolder.RoundPlaceHolder current_round_ = null;
    private int current_piste_ = -1;
    private int current_scoreb_ = 0;
    private int current_scorea_ = 0;
    private int current_idb_ = -1;
    private int current_ida_ = -1;
    private int current_state_ = 0;
    private Bout.Winner current_winner = Bout.Winner.W_NONE;
    
    protected class TableauPlaceHolder {
        protected class RoundPlaceHolder {
            public ArrayList<Bout> bouts_ = new ArrayList<Bout>();
            public int round_ = -1;
            protected RoundPlaceHolder(int round) {
                round_ = round;
            }
        }
        // The rounds in this list are unordered.
        public ArrayList<RoundPlaceHolder> rounds_ = new ArrayList<RoundPlaceHolder>();
        public String name_;
        
        protected TableauPlaceHolder(String name) {
            name_ = name;
        }
        
        protected RoundPlaceHolder find_round(int round) {
            for (int i = 0;i < rounds_.size();++i) {
                if (round == rounds_.get(i).round_) {
                    return rounds_.get(i);
                }
            }

            return new RoundPlaceHolder(round);
            
        }
    }
    
    protected void resolveTableaux(ArrayList<Tableau> tabs) {
        // Go through our placeholders looking for the real tableaux and then add our rounds
        Tableau theTab = null;
        for (int i = 0; i < tableauPlaceHolders_.size(); ++i) {
            TableauPlaceHolder placeHold = tableauPlaceHolders_.get(i);
            for (int j = 0; j < tabs.size(); ++j) {
                Tableau thisTab = tabs.get(j);
                if (thisTab.getName().equals(placeHold.name_)) {
                    theTab = thisTab;
                    break;
                }
            }
            if (null != theTab) {
                // Now got and add the rounds
                for (int k = 0;k < placeHold.rounds_.size();++k) {
                    TableauPlaceHolder.RoundPlaceHolder round = placeHold.rounds_.get(k);
                    theTab.addRound(round.round_, round.bouts_);
                }
            }
        }
    }
    
    protected BoutsContentHandler() {
    
    }
        
    protected void processRounds(CompetitionContentHandler parent, XMLReader parser) {
      parent_ = parent;
      parser_ = parser;
      parser_.setContentHandler( this );
    }
    
    private TableauPlaceHolder find_tableau(String name) {
        for (int i = 0;i < tableauPlaceHolders_.size();++i) {
            if (name.equals(tableauPlaceHolders_.get(i).name_)) {
                return tableauPlaceHolders_.get(i);
            }
        }
        
        return new TableauPlaceHolder(name);
    }
    // Override methods of the DefaultHandler class
    // to gain notification of SAX Events.
    //
        // See org.xml.sax.ContentHandler for all available events.
    //
    public void startElement( String namespaceURI,
               String localName,
              String qName,
              Attributes attr ) throws SAXException {
        contents_.reset();

        if (localName.equals("Round")) {
          // Got a result to process.  
            current_tableau_ = find_tableau(attr.getValue("tableau")); 
            current_round_ = current_tableau_.find_round(Integer.parseInt(attr.getValue("round")));
        }
        if (localName.equals("Bout")) {
          // Got a result to process.  
            current_matchnum_ = Integer.parseInt(attr.getValue("matchnum"));  
            current_piste_ = Integer.parseInt(attr.getValue("piste"));
            current_scoreb_ = Integer.parseInt(attr.getValue("scoreb"));
            current_scorea_ = Integer.parseInt(attr.getValue("scorea"));
            current_idb_ = Integer.parseInt(attr.getValue("idb"));
            current_ida_ = Integer.parseInt(attr.getValue("ida"));
            current_state_ = Integer.parseInt(attr.getValue("match"));
        }
    }
    public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
        
        if ( localName.equals( "Bout" ) ) {
            // Got to resolve the fencer name.
            Entry fencerA = null;
            if (-1 != current_ida_) {
                fencerA = parent_.getCompetition().findEntryByID(current_ida_, parent_.getEntries());
            }
            String fencerA_name = "";
            String fencerA_club = "";
            if (null != fencerA) {
                fencerA_name = fencerA.getName();
                fencerA_club = fencerA.getClub();
            }
            Entry fencerB = null;
            if (-1 != current_idb_) {
                fencerB = parent_.getCompetition().findEntryByID(current_idb_, parent_.getEntries());
            }
            String fencerB_name = "";
            String fencerB_club = "";
            if (null != fencerB) {
                fencerB_name = fencerB.getName();
                fencerB_club = fencerB.getClub();
            }
            
            // Find whether the bout exists in the current competition to see whether it's state has changed.
            Bout existingBout = parent_.getCompetition().findBout(current_tableau_.name_, current_round_.round_, current_matchnum_);
            if (null == existingBout || current_state_ > existingBout.getState()) {
                current_round_.bouts_.add(new Bout(current_ida_, fencerA_name, fencerA_club, current_idb_, fencerB_name, fencerB_club,
                            parent_.getCompetition().getName(),parent_.getCompetition().getIndex(),current_tableau_.name_,
                            current_round_.round_, current_matchnum_,current_state_,current_piste_, current_winner,current_scorea_,current_scoreb_));
            } else {
                // Going to reuse the current one as either it is the same (so no new) or it has been updated from the piste
                current_round_.bouts_.add(existingBout);
            }
            contents_.reset();
            current_matchnum_ = -1;  
            current_piste_ = -1;
            current_scoreb_ = 0;
            current_scorea_ = 0;
            current_idb_ = -1;
            current_ida_ = -1;
            current_state_ = 0;
            current_winner = Bout.Winner.W_NONE;
        }
        if ( localName.equals( "Round" ) ) {
            
            current_round_ = null;
            current_tableau_ = null;
            
        }
        if ( localName.equals( "Rounds" ) ) {
            // end of our parsing so set things back
            parser_.setContentHandler( parent_ );
            
        }
    }
    public void characters( char[] ch, int start, int length )
                  throws SAXException {
      // accumulate the contents into a buffer.
      contents_.write( ch, start, length );
    }
}
