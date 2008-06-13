/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Entry {

    String name_;
    String club_;
    int ranking_;
    int poule_;
    int piste_;
    int id_;
   
    public Entry(String nom, String club, int id, int rank, int pouleNum, int pisteNum){
        name_ = nom;
        club_ = club;
        ranking_ = rank;
        poule_ = pouleNum;
        piste_ = pisteNum;
        id_ = id;
        
    }
    
    public String getName() {
        return name_;
    }
    public String getClub() {
        return club_;
    }
    public int getId() {
        return id_;
    }
    public int getRanking() {
        return ranking_;
    }
    public int getPoule() {
        return poule_;
    }
    public int getPiste() {
        return piste_;
    }
}
