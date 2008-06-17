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
 * 
 * Loads the fencers from the XML.
 */
public class FencersContentHandler  extends DefaultHandler {
    private CompetitionContentHandler parent_;
    private XMLReader parser_;
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    private ArrayList<Entry> fencers_ = new ArrayList<Entry>();
    private int current_id_ = -1;  
    private int current_piste_ = -1;
    private int current_poule_ = -1;
    private int current_initseed_ = -1;
    private String current_club_ = "";
    
    protected FencersContentHandler() {
    
    }
    
    protected ArrayList<Entry> getEntries() {
        return fencers_;
    }
    
    protected void processFencers(CompetitionContentHandler parent, XMLReader parser) {
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

        if (localName.equals("Fencer")) {
          // Got a result to process.  
          current_id_ = Integer.parseInt(attr.getValue("id"));
          current_piste_ = Integer.parseInt(attr.getValue("piste"));
          current_poule_ = Integer.parseInt(attr.getValue("poule"));
          String initseed = attr.getValue("initseed");
          if (initseed.isEmpty()) {
              current_initseed_ = 999;
          } else {
            current_initseed_ = Integer.parseInt(initseed);
          }
          current_club_ = attr.getValue("club");
        }
    }
    
    
    public class FencerComparator implements java.util.Comparator {
        public int compare(Object l, Object r) {
            Entry lhs = (Entry)l;
            Entry rhs = (Entry)r;
            
            // Sort by matchnumber            
            return lhs.getName().compareTo(rhs.getName());
        }
    }
    public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
        
        if ( localName.equals( "Fencer" ) ) {
            // Got to resolve the fencer name.
            
            fencers_.add(new Entry(contents_.toString(), current_club_, current_id_, current_initseed_, current_poule_, current_piste_));
            contents_.reset();
            current_id_ = -1;  
            current_piste_ = -1;
            current_poule_ = -1;
            current_initseed_ = -1;
            current_club_ = "";  
        }
        if ( localName.equals( "Fencers" ) ) {
            // Now sort our list
            java.util.Collections.sort(fencers_, new FencerComparator());
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
