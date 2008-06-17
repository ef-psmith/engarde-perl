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
public class TableauxContentHandler   extends DefaultHandler {
    private CompetitionContentHandler parent_;
    private XMLReader parser_;
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    private ArrayList<Tableau> tableaux_ = new ArrayList<Tableau>();
    private int current_first_ = -1;  
    private int current_last_ = -1;
    private int current_lastfinished_ = -1;
    
    protected TableauxContentHandler() {
    
    }
    
    protected ArrayList<Tableau> getTableaux() {
        return tableaux_;
    }
    
    protected void processTableaux(CompetitionContentHandler parent, XMLReader parser) {
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

        if (localName.equals("Tableau")) {
          // Got a result to process.  
          current_first_ = Integer.parseInt(attr.getValue("first"));
          current_last_ = Integer.parseInt(attr.getValue("last"));
          current_lastfinished_ = Integer.parseInt(attr.getValue("lastfin"));
        }
    }
    public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
        
        if ( localName.equals( "Tableau" ) ) {
            // Got to resolve the fencer name.
            
            tableaux_.add(new Tableau(null, contents_.toString(),current_first_, current_last_, current_lastfinished_));
            contents_.reset();
            
              current_first_ = -1;
              current_last_ = -1;
              current_lastfinished_ = -1;
        }
        if ( localName.equals( "Tableaux" ) ) {
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
