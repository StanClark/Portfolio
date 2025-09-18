import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.Before;
import org.junit.Test;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.RepeatedTest;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;


import uk.ac.ed.inf.ilp.constant.SystemConstants;
import uk.ac.ed.inf.ilp.data.LngLat;
import uk.ac.ed.inf.ilp.data.NamedRegion;
import uk.ac.ed.info.LngLatHandler;
import uk.ac.ed.info.Node;
import uk.ac.ed.info.pathfinder;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

@RunWith(MockitoJUnitRunner.class)
public class PathfinderTest {
    @Mock
    private ObjectMapper proxyMapper;

    //@InjectMocks
    private LngLatHandler handler;

    @Before
    public void setup() throws IOException {

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenReturn(ProxyData.getNoFly());

        handler = new LngLatHandler(proxyMapper);
    }

    @Test
    public void testInsideRegion() {
        insideRegion(new LngLat(-3.1886,	55.9437), ProxyData.getSquareRegion(), true);

        insideRegion(new LngLat(-3.1852,	55.9451), ProxyData.getIrregularRegion(), true);
    }

    @Test
    public void testOutsideRegion() {
        for(int i = -1; i < 2; i++) {
            for(int j = -1; j < 2; j++) {
                if(i == 0 && j == 0) continue;
                insideRegion(new LngLat(-3.1886 + i,	55.9437 + j), ProxyData.getSquareRegion(), false);

                insideRegion(new LngLat(-3.1852 + i,	55.9451 + j), ProxyData.getIrregularRegion(), false);
            }
        }
    }

    @Test
    public void testBoundary(){
        boundaries(ProxyData.getSquareRegion());

        boundaries(ProxyData.getBristoSquareOpenArea());
    }

    @Test
    public void testVertices(){
        vertices(ProxyData.getSquareRegion());

        vertices(ProxyData.getBristoSquareOpenArea());
    }

    @Test public void testOutParallel(){
        insideRegion(new LngLat(-3.191409913289784,	55.94296124829455), ProxyData.getSquareRegion(), false);
        insideRegion(new LngLat(-3.186023443613948,	55.944987257379125), ProxyData.getIrregularRegion(), false);
    }

    public void vertices(NamedRegion r){
        LngLat[] vs = r.vertices();

        for(LngLat v : vs){
            insideRegion(v, r, true);
        }
    }



    public void boundaries(NamedRegion r){
        LngLat[] vs = r.vertices();

        int vCount = vs.length;

        for(int i = 0; i < vCount; i++){
            LngLat v1 = vs[i];
            LngLat v2 = vs[(i+1)%vCount];

            LngLat midPoint = new LngLat((v1.lng() + v2.lng())/2, (v1.lat() + v2.lat())/2);

            insideRegion(midPoint, r, true);
        }
    }


    public void insideRegion(LngLat p,NamedRegion r, boolean result){

        assertEquals(handler.isInRegion(p, r), result);
    }

    @Test
    public void randomizedPathfinderTest() throws IOException {
        List<geojsonPoint> points = new ArrayList<>();
        List<String> failedPoints = new ArrayList<>();
        Random random = new Random();

        LngLat appleton = new LngLat(-3.1865, 55.9445);

        double minLng = -3.19251090330591;
        double maxLng = -3.182069891701039;
        double minLat = 55.94138488434978;
        double maxLat = 55.947305888964146;


        for (int i = 0; i < 200; i++) { // Run the test 200 times
            LngLat randPoint = new LngLat(999, 999);
            boolean valid = false;

            while (!valid) {
                double randomLng = minLng + (maxLng - minLng) * random.nextDouble();
                double randomLat = minLat + (maxLat - minLat) * random.nextDouble();

                randPoint = new LngLat(randomLng, randomLat);



                if (!handler.isInNoFly(randPoint)) valid = true;
            }


            pathfinder pFinder = new pathfinder(handler);

            long startTime = System.currentTimeMillis();



            List<Node> path = pFinder.pathTo(appleton, randPoint);

            long endTime = System.currentTimeMillis();

            // Calculate elapsed time in milliseconds
            long elapsedTime = endTime - startTime;


            if(path != null) {
                checkPath(path);

                String col = GradientGenerator.getColorForValue((int)elapsedTime,0,100);

                geojsonPoint p = new geojsonPoint(randPoint, col, (int)elapsedTime);
                points.add(p);

                double pathDist = (path.toArray().length - 1)* SystemConstants.DRONE_MOVE_DISTANCE;

                double straighLineDist = handler.distanceTo(appleton, randPoint);

                if (pathDist > straighLineDist * 2){
                    failedPoints.add("Failed to find effecient path for " + randPoint);
                }


                if (elapsedTime > 60000) {
                    failedPoints.add("Failed to find " + randPoint + " within 1 minute");
                }

            }
            else {
                geojsonPoint p = new geojsonPoint(randPoint, "#000000", 999);
                points.add(p);
                failedPoints.add("Failed to find " + randPoint);
            }




        }


        writeGeoJson(points);

        if (!failedPoints.isEmpty()) {
            Assertions.fail("Failed points: " + String.join(", ", failedPoints));
        }
    }

    private void checkPath(List<Node> path){
        for(Node n : path){
            LngLat p = n.getPos();

            assertFalse(handler.isInNoFly(p));
        }
    }

    private void writeGeoJson(List<geojsonPoint> points) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.writeValue(new File("distNodes.geojson"), points);

    }

    private class geojsonPoint{
        private String type = "Feature";
        private point geometry;



        private Prop properties;

        public String getType(){return type;}
        public point getGeometry(){return geometry;}
        public Prop getProperties(){return  properties;}

        public geojsonPoint(LngLat p, String color, int t){
            geometry = new geojsonPoint.point(p);
            properties = new Prop(color, t);

        }



        private class Prop {
            private String marker_color;
            private int timeToFind;

            // Constructor to initialize 'marker_color'
            public Prop(String color, int t) {
                this.marker_color = color;
                this.timeToFind = t;
            }

            // Getter method to return 'marker_color'
            public String getMarker_color() {
                return marker_color;
            }

            public int getTimeToFind(){return timeToFind;}
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








