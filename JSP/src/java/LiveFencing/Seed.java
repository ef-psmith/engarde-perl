/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Seed {
    int seeding_;
    String name_;
    String club_;
    String v_over_m_;
    int ind_;
    int hs_;
   
    public Seed(int seed, String nom, String club, String v_m, int ind, int hs){
        seeding_ = seed;
        name_ = nom;
        club_ = club;
        v_over_m_ = v_m;
        ind_ = ind;
        hs_ = hs;
    }
    
    public int getSeed() {
        return seeding_;
    }
    public String getName() {
        return name_;
    }
    public String getClub() {
        return club_;
    }
    public String getVm() {
        return v_over_m_;
    }
    public int getInd() {
        return ind_;
    }
    public int getHs() {
        return hs_;
    }
}
