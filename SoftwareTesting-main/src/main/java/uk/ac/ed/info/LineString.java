package uk.ac.ed.info;

import uk.ac.ed.inf.ilp.data.LngLat;
import com.fasterxml.jackson.annotation.JsonProperty;

public class LineString{
    private String type = "Feature";
    private Geometry geometry;

    private prop properties = new prop();

    public LineString(LngLat cord1, LngLat cord2){
        geometry = new Geometry(cord1, cord2);
    }

    public String getType(){return type;}

    public Geometry getGeometry() {return geometry;}

    public prop getProperties() {return properties;}

    private class Geometry{
        private String type = "LineString";
        private double[][] coordinates;


        public Geometry(LngLat cord1, LngLat cord2){
            coordinates = new double[][]{{cord1.lng(),cord1.lat()}, {cord2.lng(),cord2.lat()}};
        }

        public String getType(){return type;}

        public double[][] getCoordinates() {return coordinates;}
    }

    private class prop{
        private String stroke = "#FF0000";
        public String getStroke(){return stroke;}
    }
}
