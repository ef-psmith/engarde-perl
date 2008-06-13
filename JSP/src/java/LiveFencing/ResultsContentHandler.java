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
public class ResultsContentHandler extends DefaultHandler {
    
    private CompetitionContentHandler parent_;
    private XMLReader parser_;
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    private ArrayList<Result> results_ = new ArrayList<Result>();
    private int currentid_;
    
    protected ResultsContentHandler() {
    
    }
    
    protected ArrayList<Result> getResults() {
        return results_;
    }
    
    protected void processResults(CompetitionContentHandler parent, XMLReader parser) {
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

        if (localName.equals("Result")) {
          // Got a result to process.  
          currentid_ = Integer.parseInt(attr.getValue("fencer"));
        }
    }
    public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
        
        if ( localName.equals( "Result" ) ) {
            // Got to resolve the fencer name.
            Entry fencer = parent_.getCompetition().findEntryByID(currentid_, parent_.getEntries());
            int position = Integer.parseInt(contents_.toString());
            results_.add(new Result(position, fencer.getName(), fencer.getClub()));
            currentid_ = -1;
            contents_.reset();   
        }
        if ( localName.equals( "Results" ) ) {
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
