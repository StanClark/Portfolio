package uk.ac.ed.info;
import uk.ac.ed.inf.ilp.data.LngLat;
import uk.ac.ed.inf.ilp.constant.SystemConstants;

import java.math.BigDecimal;


public class Node {
    private final LngLat pos;

    private final Node prevNode;
    private final BigDecimal disTraveled;
    private final BigDecimal disToGoal;

    private final BigDecimal score;

    private final double angle; //angle the node was produced from

    public Node(LngLat goal, LngLat point, BigDecimal prevDistance, double a, LngLatHandler handler, Node prevN){
        this.pos = point;
        this.disToGoal =BigDecimal.valueOf(handler.distanceTo(pos, goal)).multiply(BigDecimal.valueOf(1.5));
        this.angle = a;
        this.disTraveled = prevDistance.add(BigDecimal.valueOf(SystemConstants.DRONE_MOVE_DISTANCE));
        this.prevNode = prevN;
        score = disTraveled.add(disToGoal);
    }

    public LngLat getPos() {return pos;}
    public BigDecimal getScore(){
        return score;
    }

    public double getAngle(){return angle;}

    public BigDecimal getDisTraveled(){return disTraveled;}

    public Node getPrevNode(){return prevNode;}
}
