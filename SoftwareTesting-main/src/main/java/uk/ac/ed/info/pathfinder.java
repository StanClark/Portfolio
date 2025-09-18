package uk.ac.ed.info;

import uk.ac.ed.inf.ilp.constant.SystemConstants;
import uk.ac.ed.inf.ilp.data.LngLat;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

public class pathfinder {
    private LngLatHandler handler;
    //private MinHeap minHeap;
    private PriorityQueue<Node> queue;
    private HashSet<LngLat> searched;

    public pathfinder(LngLatHandler h){
        handler = h;
        queue = new PriorityQueue<Node>(64, new NodeComparator());
        searched = new HashSet<LngLat>();
    }

    public List<Node> pathTo(LngLat start, LngLat end) throws IOException { //presumes start and end are in valid airspace
        Node startNode = new Node(end, start, BigDecimal.ZERO, 999,handler, null);

        List<Node> foundPath = new ArrayList<Node>();

         queue.add(startNode);
        int propCounter = 0;
        Node foundRoute = null;

        while(foundRoute == null){
            //Node growth = minHeap.remove();
            Node growth = queue.poll();

            if(handler.isCloseTo(growth.getPos(),end)){
                foundRoute = growth;
                break;
            }

            searched.add(growth.getPos());

            List<Node> newNodes = propagate(growth, end);
            //minHeap.insert(n);
            queue.addAll(newNodes);

            if(propCounter > 3000000){
                //throw new RuntimeException("search Time out");
                return null;
            }
            propCounter++;

        }

        foundPath.add(foundRoute);
        Node prevNode = foundRoute;
        while(prevNode.getPrevNode() != null){
            prevNode = prevNode.getPrevNode();

            foundPath.add(prevNode);
        }

        return foundPath.reversed();
    }

    private List<Node> propagate(Node from, LngLat goal){
        List<Node> newNodes = new ArrayList<Node>();
        for(int i = 0; i < 16; i++){
            double angle = i*22.5;
            LngLat pos = handler.nextPosition(from.getPos(), angle);
            if(!handler.isInNoFly(pos) && !searched.contains(pos)){
                newNodes.add(new Node(goal, pos, from.getDisTraveled(),angle, handler, from));

            }
        }

        return newNodes;
    }

    private static class NodeComparator implements Comparator<Node>{
        public int compare(Node n1, Node n2) {

            return n1.getScore().compareTo(n2.getScore());
        }
    }

    public void exportPoints(HashSet<LngLat> points) throws IOException {
        List<jsonPoint> jPoints = new ArrayList<jsonPoint>();

        for (LngLat p : points) {
            jPoints.add(new jsonPoint(p));
        }

        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.writeValue(new File("C:/Users/stanc/Documents/Desktop/ILACW1/searchedNodes.json"), jPoints);
    }



    private class jsonPoint{
        private String type = "Feature";
        private point geometry;

        private prop properties = new prop();

        public String getType(){return type;}
        public point getGeometry(){return geometry;}
        public prop getProperties(){return  properties;}

        public jsonPoint(LngLat p){
            geometry = new point(p);

        }



        private class prop{
            private String marker_color = "#FF0000";

            public String getMarker_color(){return marker_color;}
        }
        private class point{
            private String type = "Point";
            private double[] coordinates;

            public String getType(){return type;}
            public double[] getCoordinates(){return  coordinates;}
            public point(LngLat p){
                coordinates = new double[]{p.lng(),p.lat()};
            }


        }


    }
}
