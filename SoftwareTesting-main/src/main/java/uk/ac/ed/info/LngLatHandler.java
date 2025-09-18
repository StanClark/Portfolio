package uk.ac.ed.info;

import com.fasterxml.jackson.databind.ObjectMapper;
import uk.ac.ed.inf.ilp.data.LngLat;
import uk.ac.ed.inf.ilp.data.NamedRegion;
import uk.ac.ed.inf.ilp.data.Order;
import uk.ac.ed.inf.ilp.interfaces.LngLatHandling;
import uk.ac.ed.inf.ilp.constant.SystemConstants;


import java.awt.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.MathContext;
import java.net.URL;
import java.util.HashSet;

import com.fasterxml.jackson.databind.ObjectMapper;

import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

public class LngLatHandler implements LngLatHandling{
    NamedRegion[] noFlyZones;
    public LngLatHandler(ServerHandler serverHandler){
        noFlyZones = serverHandler.getNoFlyZones();
    }

    public LngLatHandler(ObjectMapper mapper){
        mapper.registerModule(new JavaTimeModule());

        try {
            noFlyZones = mapper.readValue(new URL("http://localhost:8080" + "/noFlyZones"), NamedRegion[].class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }


    @Override
    public double distanceTo(LngLat p, LngLat q){
        double latDis = p.lat() - q.lat();
        double lngDis = p.lng() - q.lng();



        return Math.sqrt(Math.pow(latDis, 2) + Math.pow(lngDis, 2));
    }

    @Override
    public boolean isCloseTo(LngLat startPosition, LngLat otherPosition) {
        return distanceTo(startPosition, otherPosition) <= SystemConstants.DRONE_IS_CLOSE_DISTANCE;
    }

    @Override
    public LngLat nextPosition(LngLat startPosition, double angle) {
        //check for negatives?
        if (angle == 999) return startPosition;

        if((angle % 22.5) != 0 ) throw new IllegalArgumentException("angle must be one of the 16 major compass directions");

        angle %= 360;

        if(angle == 0) return new LngLat(startPosition.lng()+ SystemConstants.DRONE_MOVE_DISTANCE, startPosition.lat());

        double xdis;
        double ydis;
        double theta;
        if(angle <= 90){
            theta = angle;

            xdis = Adj(theta, SystemConstants.DRONE_MOVE_DISTANCE);
            ydis = Opp(theta, SystemConstants.DRONE_MOVE_DISTANCE);
        } else if (angle <= 180) {
            theta = angle - 90;

            xdis = -Opp(theta, SystemConstants.DRONE_MOVE_DISTANCE);
            ydis = Adj(theta, SystemConstants.DRONE_MOVE_DISTANCE);
        } else if (angle <= 270) {
            theta = angle -180;

            xdis = -Adj(theta, SystemConstants.DRONE_MOVE_DISTANCE);
            ydis = -Opp(theta, SystemConstants.DRONE_MOVE_DISTANCE);
        } else if (angle <= 360) {
            theta = angle - 270;

            xdis = Adj(theta, SystemConstants.DRONE_MOVE_DISTANCE);
            ydis = -Opp(theta, SystemConstants.DRONE_MOVE_DISTANCE);
        }else throw new IllegalArgumentException("input angle must be below 360 unless hovering");

        return new LngLat(startPosition.lng() + xdis, startPosition.lat() + ydis);
    }

    @Override
    public boolean isInRegion(LngLat position, NamedRegion region) {
        HashSet<LngLat> interCount = new HashSet<>();
        interCount.add(null);
        int totalV = region.vertices().length;

        for(int i=0; i < totalV; i++){
            LngLat intersection = intersects(position, region.vertices()[i],region.vertices()[(i+1)%totalV]);
            // make number of intersections the sum of unique intersection points

            if(intersection != null && intersection.equals(new LngLat(999,999))) return true;
            interCount.add(intersection);
        }

        return ((interCount.size()-1) % 2) == 1;
    }

    public boolean isInNoFly(LngLat pos){

        for(NamedRegion r : noFlyZones) {
            if(isInRegion(pos,r)) return true;
        }
        return false;
    }



    //checks if a horizontal line cast from start to the right infinitely intersects line from vert1 to vert 2
    private LngLat intersects(LngLat start, LngLat Vert1, LngLat Vert2){ //returns 0 if false 1 if true and -1 if on line
        if(Vert1.lat() == Vert2.lat()){ // line is horizontal
            return null;
            //the horizontal cast line cannot intersect or start on another horizontal line for the sake of this function
        } else if (Vert1.lng() == Vert2.lng()) { // line is vertical
            if((Math.min(Vert1.lat(), Vert2.lat()) <= start.lat()) & (start.lat() <= Math.max(Vert1.lat(), Vert2.lat()))){
                if(start.lng() > Vert1.lng()) return null;
                else if (start.lng() < Vert1.lng()) return new LngLat(Vert1.lng(), start.lat());

                return new LngLat(999,999); //must be on line so return special value
            }
            return null;
        }

        double m = (Vert2.lat() - Vert1.lat())/(Vert2.lng() - Vert1.lng());
        double c = -m* Vert1.lng() + Vert1.lat();

        //if((Math.min(Vert1.lat(), Vert2.lat()) <= start.lat()) & (start.lat() <= Math.max(Vert1.lat(), Vert2.lat()))){
        if((Math.min(Vert1.lat(), Vert2.lat()) <= start.lat()) & (start.lat() <= Math.max(Vert1.lat(), Vert2.lat()))){
            double interX = (double) Math.round((start.lat() - c) / m * 1000000000) /1000000000; //requires rounding to cover rounding errors
            double startLngRounded = (double) Math.round(start.lng() * 1000000000) /1000000000;
            //if(interX < start.lng()){
            if(interX < startLngRounded){
                //intersection is to the left of point so not counted
                return null;
            } else if (interX > startLngRounded) {
                // intersection to right so it is counted
                return new LngLat(interX, start.lat());
            }
            //must be on line then so
            return start;
        }
        return null;

    }

    private double Adj(double theta, double hyp){

        if(theta == 90 || theta == 270){
            return 0;
        }

        return Math.cos(Math.toRadians(theta))*hyp;

    }

    private double Opp(double theta, double hyp){
        if(theta == 0 || theta == 180){
            return 0;
        }
        return Math.sin(Math.toRadians(theta))*hyp;
    }
}
