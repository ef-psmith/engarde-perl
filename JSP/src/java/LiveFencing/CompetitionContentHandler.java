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
public class CompetitionContentHandler extends DefaultHandler {
    private Competition competition_;
    
    private ResultsContentHandler resultHandler_ = new ResultsContentHandler();
    private FencersContentHandler fencersHandler_ = new FencersContentHandler();
    private TableauxContentHandler tableauxHandler_ = new TableauxContentHandler();
    private BoutsContentHandler boutsHandler_ = new BoutsContentHandler();
    private SeedingsContentHandler seedingHandler_ = new SeedingsContentHandler();
    private XMLReader parser_;
    
    private String competition_shortname_ = "";
    private String competition_name_ = "";
    
    // Buffer for collecting data from
    // the "characters" SAX event.
    private CharArrayWriter contents_ = new CharArrayWriter();
    
    protected CompetitionContentHandler(Competition comp, XMLReader parser) {
        competition_ = comp;
        parser_ = parser;
    }
    
    protected String getName() {
        return competition_name_;
    }
    protected String getShortName() {
        return competition_shortname_;
    }
    
    protected Competition getCompetition() {
        return competition_;
    }
    
    protected ArrayList<Entry> getEntries() {
        return fencersHandler_.getEntries();
    }
    protected ArrayList<Tableau> getTableaux() {
        return tableauxHandler_.getTableaux();
    }
    protected ArrayList<Seed> getSeeds() {
        return seedingHandler_.getSeeds();
    }
    protected ArrayList<Result> getResults() {
        return resultHandler_.getResults();
    }
    
   public void startElement( String namespaceURI,
           String localName,
          String qName,
          Attributes attr ) throws SAXException {
      contents_.reset();
      if ( localName.equals( "Competition" ) ) {
            competition_name_ = attr.getValue("name");
            competition_shortname_ = attr.getValue("shortname");
      }
      if ( localName.equals( "Results" ) ) {
          
         resultHandler_.processResults( this, parser_ );
      }
      if ( localName.equals( "Tableaux" ) ) {
         tableauxHandler_.processTableaux(this, parser_);
      }
      if ( localName.equals( "Rounds" ) ) {
         boutsHandler_.processRounds(this, parser_);
      }
      if ( localName.equals( "Seedings" ) ) {
         seedingHandler_.processSeedings(this, parser_);
      }
      if ( localName.equals( "Fencers" ) ) {
         fencersHandler_.processFencers( this,parser_);
      }
   }
   public void endElement( String namespaceURI,
               String localName,
              String qName ) throws SAXException {
      // Don't need to do anything here
       if (localName.equals("Competition")) {
           // End of the competition so lets resolve the Bouts and the Tableaux
           boutsHandler_.resolveTableaux(tableauxHandler_.getTableaux());
       }
   }
   public void characters( char[] ch, int start, int length )
                  throws SAXException {
      // accumulate the contents into a buffer.
      contents_.write( ch, start, length );
   }

}
