/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Tournament {
    
   // Private members
    private String perl_exe_path_ = "C:\\Perl\\";
    private String perl_file_path_ = "C:\\Documents and Settings\\Oliver\\My Documents\\perl\\";
    private java.util.ArrayList<Competition> competitions_ = new java.util.ArrayList<Competition>();
    private java.util.ArrayList<DisplaySeries> displaySeries_ = new java.util.ArrayList<DisplaySeries>();
    java.sql.Connection conn_;
    
    protected String build_engarde_file_processing_cmd(String file, int index) {
        String cmd = perl_exe_path_ + "perl" + " " + perl_file_path_ + "writetoxml.pl " + file + " " + Integer.toString(index);
        return cmd;
    }
    
    public Tournament() {
        
        // Now set up the database access
        try {
            Class.forName("org.postgresql.Driver");
        } catch(java.lang.ClassNotFoundException e) {
            // We are pretty stuffed.
            e.getMessage();
        }
        try {
            conn_ = java.sql.DriverManager.getConnection("jdbc:postgresql:livefencing","postgres","root");
        } catch (java.sql.SQLException e) {
            // Assume that the DB doesn't exist
            try {
                java.sql.Connection defaultConn = java.sql.DriverManager.getConnection("jdbc:postgresql:postgres","postgres","root");
                java.sql.Statement defaultStmt = defaultConn.createStatement();
                defaultStmt.executeUpdate("CREATE DATABASE livefencing");
                conn_ = java.sql.DriverManager.getConnection("jdbc:postgresql:livefencing","postgres","root");
                
                java.sql.Statement stmt = conn_.createStatement();
                // Create the tables
                String sql = "CREATE TABLE \"competitions\"\n";
                sql += "(\n";
                sql += " name text, -- The name of the competition\n";
                sql += " shortname text, -- The shortened name of the competition (derived from the engarde file)\n";
                sql += " engardefile text, -- The filename (local to the web server) of the Engarde File for the competition.\n";
                sql += " key integer NOT NULL,\n";
                sql += "  CONSTRAINT competitionkey PRIMARY KEY (key)\n";
                sql += ")\n";
                sql += "WITH (OIDS=FALSE);\n";
                sql += "ALTER TABLE competitions OWNER TO postgres;\n";
                sql += "COMMENT ON COLUMN competitions.name IS 'The name of the competition';\n";
                sql += "COMMENT ON COLUMN competitions.shortname IS 'The shortened name of the competition (derived from the engarde file)';\n";
                sql += "COMMENT ON COLUMN competitions.engardefile IS 'The filename (local to the web server) of the Engarde File for the competition.';\n";
                
                stmt.executeUpdate(sql);
                
                sql = "CREATE TABLE \"fencers\"\n";
                sql += "(\n";
                sql += "  name text NOT NULL, -- Full name <LAST First> of the fencer\n";
                sql += "  club text, -- The fencer's club\n";
                sql += "  initrank integer NOT NULL, -- National ranking for determining poules\n";
                sql += "  poule integer NOT NULL, -- The Poule number of the next round\n";
                sql += "  piste integer, -- The Piste where the fencer will be fencing\n";
                sql += "  key integer NOT NULL, -- The FencerKey\n";
                sql += "  compkey integer NOT NULL, -- The key for the competition the fencer is in\n";
                sql += "  CONSTRAINT fencerkey PRIMARY KEY (key, compkey),\n";
                sql += "  CONSTRAINT competitionkey FOREIGN KEY (compkey)\n";
                sql += "      REFERENCES competitions (key) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION\n";
                sql += ")\n";
                sql += "WITH (OIDS=FALSE);\n";
                sql += "ALTER TABLE fencers OWNER TO postgres;\n";
                sql += "COMMENT ON COLUMN fencers.name IS 'Full name <LAST First> of the fencer';\n";
                sql += "COMMENT ON COLUMN fencers.club IS 'The fencer''s club';\n";
                sql += "COMMENT ON COLUMN fencers.initrank IS 'National ranking for determining poules';\n";
                sql += "COMMENT ON COLUMN fencers.poule IS 'The Poule number of the next round';\n";
                sql += "COMMENT ON COLUMN fencers.piste IS 'The Piste where the fencer will be fencing';\n";
                sql += "COMMENT ON COLUMN fencers.key IS 'The FencerKey';\n";
                sql += "COMMENT ON COLUMN fencers.compkey IS 'The key for the competition the fencer is in';\n";
                
                stmt.executeUpdate(sql);
                
                sql = "CREATE TABLE seeding\n";
                sql += "(\n";
                sql += "  seed integer NOT NULL, -- Seed after the poules\n";
                sql += "  \"v-over-m\" text NOT NULL, -- Victories/matches - primary indicator\n";
                sql += "  ind integer NOT NULL, -- hs-hr secondary indicator\n";
                sql += "  hs integer NOT NULL, -- hits scored - tertiary indicator\n";
                sql += "  round text NOT NULL, -- The round of poules\n";
                sql += "  fencerkey integer NOT NULL, -- Foreign key for fencer\n";
                sql += "  compkey integer NOT NULL, -- Foreign key for competition\n";
                sql += "  CONSTRAINT constseedingkey PRIMARY KEY (compkey, round, fencerkey),\n";
                sql += "  CONSTRAINT constcompkey FOREIGN KEY (compkey)\n";
                sql += "      REFERENCES competitions (key) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION,\n";
                sql += "  CONSTRAINT constfencerkey FOREIGN KEY (fencerkey, compkey)\n";
                sql += "      REFERENCES fencers (key, compkey) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION\n";
                sql += ")\n";
                sql += "WITH (OIDS=FALSE);\n";
                sql += "ALTER TABLE seeding OWNER TO postgres;\n";
                sql += "COMMENT ON TABLE seeding IS 'Seeding after the poules';\n";
                sql += "COMMENT ON COLUMN seeding.seed IS 'Seed after the poules';\n";
                sql += "COMMENT ON COLUMN seeding.\"v-over-m\" IS 'Victories/matches - primary indicator';\n";
                sql += "COMMENT ON COLUMN seeding.ind IS 'hs-hr secondary indicator';\n";
                sql += "COMMENT ON COLUMN seeding.hs IS 'hits scored - tertiary indicator';\n";
                sql += "COMMENT ON COLUMN seeding.round IS 'The round of poules';\n";
                sql += "COMMENT ON COLUMN seeding.fencerkey IS 'Foreign key for fencer';\n";
                sql += "COMMENT ON COLUMN seeding.compkey IS 'Foreign key for competition';\n";

                stmt.executeUpdate(sql);
                
                sql = "	CREATE TABLE tableaus\n";
                sql += "(\n";
                sql += "  lastcompleteround integer NOT NULL, -- The last round in which all the matches are complete\n";
                sql += "  firstround integer NOT NULL, -- The earliest round in the tableaux.\n";
                sql += "  lastround integer NOT NULL, -- The last round in the tableaux.\n";
                sql += "  tableauprefix text NOT NULL, -- The prefix for Engarde for this tableau\n";
                sql += "  compkey integer NOT NULL, -- The key for the competition\n";
                sql += "  CONSTRAINT tableaukey PRIMARY KEY (tableauprefix, compkey),\n";
                sql += "  CONSTRAINT compkey FOREIGN KEY (compkey)\n";
                sql += "      REFERENCES competitions (key) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION\n";
                sql += ")\n";
                sql += "WITH (OIDS=FALSE);\n";
                sql += "ALTER TABLE tableaus OWNER TO postgres;\n";
                sql += "COMMENT ON COLUMN tableaus.lastcompleteround IS 'The last round in which all the matches are complete';\n";
                sql += "COMMENT ON COLUMN tableaus.firstround IS 'The earliest round in the tableaux.';\n";
                sql += "COMMENT ON COLUMN tableaus.lastround IS 'The last round in the tableaux.';\n";
                sql += "COMMENT ON COLUMN tableaus.tableauprefix IS 'The prefix for Engarde for this tableau';\n";
                sql += "COMMENT ON COLUMN tableaus.compkey IS 'The key for the competition';\n";

                stmt.executeUpdate(sql);
                
                sql = "	CREATE TABLE matches\n";
                sql += "(\n";
                sql += "  fencera integer NOT NULL, -- The first fencer\n";
                sql += "  fencerb integer NOT NULL, -- The second fencer\n";
                sql += "  scorea integer NOT NULL DEFAULT 0, -- The number of hits fencera has scored\n";
                sql += "  scoreb integer NOT NULL DEFAULT 0, -- The number of hits fencer B has scored\n";
                sql += "  time integer, -- The number of seconds remaining.\n";
                sql += "  winner integer, -- The ID of the winner.\n";
                sql += "  piste integer, -- The piste number where the match is taking place\n";
                sql += "  compkey integer NOT NULL, -- The key for the competition\n";
                sql += "  round integer NOT NULL, -- The round, i.e.16 for last 16 etc\n";
                sql += "  match integer NOT NULL, -- The match number within this round of this tableau\n";
                sql += "  tableau text NOT NULL, -- The prefix for the tableau\n";
                sql += "  state integer NOT NULL, -- The state of the match - 0 Unable to start, 1 Ready to start, 2 Started at the piste, 3 Finished at piste, 4 Finished in Engarde";
                sql += "  CONSTRAINT matchkey PRIMARY KEY (match, compkey, round, tableau),\n";
                sql += "  CONSTRAINT compkey FOREIGN KEY (compkey)\n";
                sql += "      REFERENCES competitions (key) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION,\n";
                sql += "  CONSTRAINT constfencera FOREIGN KEY (fencera, compkey)\n";
                sql += "      REFERENCES fencers (key, compkey) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION,\n";
                sql += "  CONSTRAINT constfencerB FOREIGN KEY (fencerb, compkey)\n";
                sql += "      REFERENCES fencers (key, compkey) MATCH SIMPLE\n";
                sql += "      ON UPDATE NO ACTION ON DELETE NO ACTION\n";
                sql += ")\n";
                sql += "WITH (OIDS=FALSE);\n";
                sql += "ALTER TABLE matches OWNER TO postgres;\n";
                sql += "COMMENT ON COLUMN matches.fencera IS 'The first fencer';\n";
                sql += "COMMENT ON COLUMN matches.fencerb IS 'The second fencer';\n";
                sql += "COMMENT ON COLUMN matches.scorea IS 'The number of hits fencera has scored';\n";
                sql += "COMMENT ON COLUMN matches.scoreb IS 'The number of hits fencer B has scored';\n";
                sql += "COMMENT ON COLUMN matches.time IS 'The number of seconds remaining.  ';\n";
                sql += "COMMENT ON COLUMN matches.winner IS 'The ID of the winner.';\n";
                sql += "COMMENT ON COLUMN matches.piste IS 'The piste number where the match is taking place';\n";
                sql += "COMMENT ON COLUMN matches.compkey IS 'The key for the competition';\n";
                sql += "COMMENT ON COLUMN matches.round IS 'The round, i.e.16 for last 16 etc';\n";
                sql += "COMMENT ON COLUMN matches.match IS 'The match number within this round of this tableau';\n";
                sql += "COMMENT ON COLUMN matches.tableau IS 'The prefix for the tableau';\n";
                sql += "COMMENT ON COLUMN matches.state IS 'The state of the match - 0 Unable to start, 1 Ready to start, 2 Started at the piste, 3 Finished at piste, 4 Finished in Engarde';\n";

                stmt.executeUpdate(sql);
                
                sql = "CREATE TABLE results";
                sql += "(";
                sql += "   position integer NOT NULL, ";
                sql += "   fencerkey integer NOT NULL, ";
                sql += "   compkey integer NOT NULL, ";
                sql += "   CONSTRAINT resultkey PRIMARY KEY (position, fencerkey, compkey), ";
                sql += "   CONSTRAINT fencerkey FOREIGN KEY (fencerkey, compkey) REFERENCES fencers (key, compkey)    ON UPDATE NO ACTION ON DELETE NO ACTION, ";
                sql += "   CONSTRAINT compkey FOREIGN KEY (compkey) REFERENCES competitions (key)    ON UPDATE NO ACTION ON DELETE NO ACTION";
                sql += ") WITH (OIDS=FALSE)";
                sql += ";";
                sql += "COMMENT ON COLUMN results.position IS 'The final place.';";
                sql += "COMMENT ON COLUMN results.fencerkey IS 'The fencer';";
                sql += "COMMENT ON COLUMN results.compkey IS 'The competition index';";
                stmt.executeUpdate(sql);
            } catch (java.sql.SQLException e2) {
                System.out.println(e2.getErrorCode());
            }
        }
    }
    
    // Properties
    public Competition[] getCompetitions() {
        Competition[] array = new Competition[competitions_.size()];
        competitions_.toArray(array);
        return array;
    }
    
    public DisplaySeries[] getDisplaySeries(){
        DisplaySeries[] array = new DisplaySeries[displaySeries_.size()];
        displaySeries_.toArray(array);
        return array;
    }
    
    // Methods
    void addDisplaySeries(DisplaySeries dispSeries) {
        displaySeries_.add(dispSeries);
    }
    void removeDisplaySeries(DisplaySeries dispSeries) {
        displaySeries_.remove(dispSeries);
    }
    
    // Add a new competition, return true if it was added
    boolean addCompetition(Competition comp){
        // Go though the list and check that we haven't already got this file.
        if (-1 != competitions_.indexOf(comp)){
            return false;
        }
        competitions_.add(comp);
        
        // This only works becuse we can't remove competitions.
        comp.setIndex(competitions_.size());
        // Now we need to go through and add extra elements to the display lists
        for (int i = 0;i < displaySeries_.size();++i) {
            DisplaySeries disp = (DisplaySeries)displaySeries_.get(i);
            if (null != disp){
                disp.addCompetition(comp);
            }
        }
        return true;
    }

    java.sql.Connection getDBConn() {
      return conn_;
    }
    
    public static Bout[] bouts(Tournament tourn, int piste) {
        return tourn.bouts(piste);
    }
    // Gets the next set of bouts that are scheduled for the named piste
    public Bout[] bouts(int piste) {
        java.util.ArrayList<Bout> bouts = new java.util.ArrayList<Bout>();
        try {
       
            String sql = "SELECT matches.fencera, a_fencers.name, a_fencers.club, matches.fencerb, b_fencers.name, b_fencers.club, competitions.name, matches.compkey, matches.tableau, matches.round, matches.match, matches.state FROM matches ";
            sql += "JOIN fencers a_fencers ON matches.fencera = a_fencers.key ";  
            sql += "JOIN fencers b_fencers ON matches.fencerb = b_fencers.key "; 
            sql += "JOIN competitions ON matches.compkey = competitions.key ";   
            sql += "WHERE matches.piste = ";
            sql += Integer.toString(piste);
            sql += " AND matches.state = 1 ORDER BY round DESC, match"; 
            java.sql.Statement stmt = conn_.createStatement();
            java.sql.ResultSet resSet = stmt.executeQuery(sql);

            while (resSet.next()) {
                bouts.add(new Bout(resSet.getInt(1),resSet.getString(2), resSet.getString(3), resSet.getInt(4), resSet.getString(5), resSet.getString(6), resSet.getString(7), resSet.getInt(8), resSet.getString(9), resSet.getInt(10), resSet.getInt(11), resSet.getInt(12),piste, Bout.Winner.W_NONE, 0,0));
            }
        } catch (java.sql.SQLException e) {
            String mess = e.getMessage();
        }
        return bouts.toArray(new Bout[0]);
    }
    
    public static boolean updateScore(Tournament tourn, int competition, String tableau, int round, int match, int scoreA, int scoreB, int timeRemaining) {
       return tourn.updateScore(competition, tableau, round, match, scoreA, scoreB, timeRemaining) ;
    }
    public boolean updateScore(int competition, String tableau, int round, int match, int scoreA, int scoreB, int timeRemaining) {
        // Update the internal object
        Competition comp = null;
        for (int i = 0; i < competitions_.size(); ++i) {
            if ( competition == competitions_.get(i).getIndex()) {
                comp = competitions_.get(i);
                break;
            }
        }
        if (null != comp) {
            synchronized(comp) {
                
                Bout bout = comp.findBout(tableau, round, match);
                if (null != bout) {
                    bout.setScoreA(scoreA);
                    bout.setScoreB(scoreB);                                        
                }
            }
        }
        // Generate some SQL...
        String sql = "UPDATE matches SET (scorea, scoreb, time)=(";
        sql += Integer.toString(scoreA);
        sql += ",";
        sql += Integer.toString(scoreB);
        sql += ",";
        sql += Integer.toString(timeRemaining);
        sql += ") WHERE compkey=";
        sql += Integer.toString(competition);
        sql += " AND tableau='";
        sql += tableau;
        sql += "' AND round=";
        sql += Integer.toString(round);
        sql += " AND match=";
        sql += Integer.toString(match);
        
        boolean success = true;
        try {
            java.sql.Statement stmt = conn_.createStatement();
            stmt.executeUpdate(sql);
        } catch (java.sql.SQLException e) {
            String mess = e.getMessage();
            success = false;
        }
        return success;
    }
    public static boolean changeBoutState(Tournament tourn, int competition, String tableau, int round, int match, int oldstate, int newstate) {
       return tourn.changeBoutState(competition, tableau, round, match, oldstate, newstate) ;
    }
    public boolean changeBoutState(int competition, String tableau, int round, int match, int oldstate, int newstate) {
        // Generate some SQL...
        String sql = "UPDATE matches SET state=";
        sql += Integer.toString(newstate);
        sql += " WHERE compkey=";
        sql += Integer.toString(competition);
        sql += " AND tableau='";
        sql += tableau;
        sql += "' AND round=";
        sql += Integer.toString(round);
        sql += " AND match=";
        sql += Integer.toString(match);
        // We want to make sure that the current state is what we expect
        sql += " AND state=";
        sql += Integer.toString(oldstate);
        
        boolean success = true;
        try {
            java.sql.Statement stmt = conn_.createStatement();
            stmt.executeUpdate(sql);
        } catch (java.sql.SQLException e) {
            String mess = e.getMessage();
            success = false;
        }
        return success;
    }
    public static boolean setwinner(Tournament tourn, int competition, String tableau, int round, int match, int winner) {
       return tourn.setwinner(competition, tableau, round, match, winner) ;
    }
    public boolean setwinner(int competition, String tableau, int round, int match, int winner) {
        // Update the internal object
        Competition comp = null;
        for (int i = 0; i < competitions_.size(); ++i) {
            if ( competition == competitions_.get(i).getIndex()) {
                comp = competitions_.get(i);
                break;
            }
        }
        if (null != comp) {
            synchronized(comp) {
                Bout bout = comp.findBout(tableau, round, match);
                if (null != bout) {
                    if (winner == bout.getFencerA_ID())
                        bout.setWinner(Bout.Winner.W_A);   
                    else if (winner == bout.getFencerB_ID())
                        bout.setWinner(Bout.Winner.W_B);   
                    else
                        bout.setWinner(Bout.Winner.W_NONE);   
                }
            }
        }
        // Generate some SQL...
        String sql = "UPDATE matches SET winner=";
        sql += Integer.toString(winner);
        sql += " WHERE compkey=";
        sql += Integer.toString(competition);
        sql += " AND tableau='";
        sql += tableau;
        sql += "' AND round=";
        sql += Integer.toString(round);
        sql += " AND match=";
        sql += Integer.toString(match);
        
        boolean success = true;
        try {
            java.sql.Statement stmt = conn_.createStatement();
            stmt.executeUpdate(sql);
        } catch (java.sql.SQLException e) {
            String mess = e.getMessage();
            success = false;
        }
        return success;
    }
}
