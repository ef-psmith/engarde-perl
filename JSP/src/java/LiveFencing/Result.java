/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package LiveFencing;

/**
 *
 * @author Oliver
 */
public class Result {

    private int position_;
    private String name_;
    private String club_;
   
    public Result(int position, String nom, String club){
        position_ = position;
        name_ = nom;
        club_ = club;
    }
    
    public int getPosition() {
        return position_;
    }
    public String getName() {
        return name_;
    }
    public String getClub() {
        return club_;
    }
}
