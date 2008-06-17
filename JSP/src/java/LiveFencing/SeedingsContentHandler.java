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
public class SeedingsContentHandler extends DefaultHandler {
    
    private CompetitionContentHandler parent_;
    private XMLReader parser_;
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    private ArrayList<Seed> seeds_ = new ArrayList<Seed>();
    private int current_hs_ = 0;
    private int current_ind_ = 0;
    private String current_voverm_ = "";
    private int current_seed_ = -1;
    private int current_fencer_ = -1;
    
    protected SeedingsContentHandler() {
    
    }
    
    protected ArrayList<Seed> getSeeds() {
        return seeds_;
    }
    
    protected void processSeedings(CompetitionContentHandler parent, XMLReader parser) {
      parent_ = parent;
      parser_ = parser;
      parser_.setContentHandler( this );
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

        if (localName.equals("Seeding")) {
            // Got a Seeding to process.  
          
            current_hs_ = Integer.parseInt(attr.getValue("hs"));
            current_ind_ = Integer.parseInt(attr.getValue("ind"));
            current_voverm_ = attr.getValue("voverm");
            current_seed_ = Integer.parseInt(attr.getValue("seed"));
            current_fencer_ = Integer.parseInt(attr.getValue("fencer"));
        }
    }
    public class SeedComparator implements java.util.Comparator {
        public int compare(Object l, Object r) {
            Seed lhs = (Seed)l;
            Seed rhs = (Seed)r;
            
            // Sort by Seeding            
            if (lhs.getSeed() > rhs.getSeed()) {
                return 1;
            }
            if (lhs.getSeed() < rhs.getSeed()) {
                return -1;
            }
            return 0;
        }
    }
    public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
        
        if ( localName.equals( "Seeding" ) ) {
            // Got to resolve the fencer name.
            Entry fencer = parent_.getCompetition().findEntryByID(current_fencer_, parent_.getEntries());
            if (null != fencer) {
                seeds_.add(new Seed(current_seed_, fencer.getName(), fencer.getClub(), current_voverm_, current_ind_, current_hs_));
            }
            current_hs_ = 0;
            current_ind_ = 0;
            current_voverm_ = "";
            current_seed_ = -1;
            current_fencer_ = -1;
            contents_.reset();   
        }
        if ( localName.equals( "Seedings" ) ) {
            // Now sort our list
            java.util.Collections.sort(seeds_, new SeedComparator());
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
