import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.Test;

import org.junit.runner.RunWith;

import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;


import uk.ac.ed.inf.ilp.data.*;

import uk.ac.ed.info.ServerHandler;

import java.io.IOException;
import java.net.URL;
import java.util.*;

import static org.junit.Assert.fail;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

@RunWith(MockitoJUnitRunner.class) // Enable Mockito in JUnit 4
public class RestServerTest {

    @Mock
    private ObjectMapper proxyMapper; // Mockito mock


    private ServerHandler serverHandler;

    @Test
    public void testNormal() throws IOException {
        // Mock setup
        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenReturn(ProxyData.getNoFly());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenReturn(ProxyData.getRestaurants());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenReturn(ProxyData.getValidOrders());

        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        assertTrue(compareOrder(serverHandler.getOrders(), ProxyData.getValidOrders()));
        assertTrue(compareRegions(serverHandler.getNoFlyZones(), ProxyData.getNoFly()));
        assertTrue(compareRestaurant(serverHandler.getRestaurants(), ProxyData.getRestaurants()));
    }

    @Test
    public void testBoundary() throws IOException {
        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenReturn(new NamedRegion[]{});

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenReturn(new Restaurant[]{});

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenReturn(new Order[]{});

        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        assertEquals(0, serverHandler.getNoFlyZones().length, "no fly zones should be empty");
        assertEquals(0, serverHandler.getRestaurants().length, "restaurants should be empty");
        assertEquals(0, serverHandler.getOrders().length, "orders should be empty");
    }

    @Test
    public void testTimeOut() throws IOException {
        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenThrow(new IOException("Server timed out"));

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenThrow(new IOException("Server timed out"));

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenThrow(new IOException("Server timed out"));

        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        try {
            serverHandler.getNoFlyZones();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Server timed out", e.getMessage());
        }

        try {
            serverHandler.getRestaurants();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Server timed out", e.getMessage());
        }

        try {
            serverHandler.getOrders();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Server timed out", e.getMessage());
        }
    }

    @Test
    public void testBadFormatting() throws IOException {
        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenThrow(new IOException("Data has unexpected formatting"));

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenThrow(new IOException("Data has unexpected formatting"));

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenThrow(new IOException("Data has unexpected formatting"));

        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        try{
            serverHandler.getNoFlyZones();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Data has unexpected formatting", e.getMessage());
        }
        try{
            serverHandler.getRestaurants();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Data has unexpected formatting", e.getMessage());
        }
        try{
            serverHandler.getOrders();
            fail("Expected serverHandler exception to be thrown");
        } catch (RuntimeException e) {
            assertEquals("java.io.IOException: Data has unexpected formatting", e.getMessage());
        }
    }



    private Boolean compareOrder(Order[] os1, Order[] os2){
        if(os1.length != os2.length) return false;
        for(int i = 0; i < os1.length; i++){
            Order o1 =  os1[i];
            Order o2 =  os2[i];

            if (!Objects.equals(o1.getOrderNo(), o2.getOrderNo())) {
                System.out.println("Mismatched order numbers: " + o1.getOrderNo() + " " + o2.getOrderNo());
            }
            if (!o1.getOrderDate().toString().equals(o2.getOrderDate().toString())) {
                System.out.println("Mismatched order dates: " + o1.getOrderDate() + " " + o2.getOrderDate());
                return false;
            }
            if (o1.getOrderStatus() != o2.getOrderStatus()) {
                System.out.println("Mismatched order statuses: " + o1.getOrderStatus() + " " + o2.getOrderStatus());
                return false;
            }
            if (o1.getOrderValidationCode() != o2.getOrderValidationCode()) {
                System.out.println("Mismatched order validation codes: " + o1.getOrderValidationCode() + " " + o2.getOrderValidationCode());
                return false;
            }
            if (o1.getPriceTotalInPence() != o2.getPriceTotalInPence()) {
                System.out.println("Mismatched price totals: " + o1.getPriceTotalInPence() + " " + o2.getPriceTotalInPence());
                return false;
            }
// pizzas in order
            if (!Objects.equals(o1.getCreditCardInformation().getCreditCardNumber(), o2.getCreditCardInformation().getCreditCardNumber())) {
                System.out.println("Mismatched credit card numbers: " + o1.getCreditCardInformation().getCreditCardNumber() + " " + o2.getCreditCardInformation().getCreditCardNumber());
                return false;
            }
            if (!Objects.equals(o1.getCreditCardInformation().getCvv(), o2.getCreditCardInformation().getCvv())) {
                System.out.println("Mismatched CVVs: " + o1.getCreditCardInformation().getCvv() + " " + o2.getCreditCardInformation().getCvv());
                return false;
            }
            if (!Objects.equals(o1.getCreditCardInformation().getCreditCardExpiry(), o2.getCreditCardInformation().getCreditCardExpiry())) {
                System.out.println("Mismatched credit card expiries: " + o1.getCreditCardInformation().getCreditCardExpiry() + " " + o2.getCreditCardInformation().getCreditCardExpiry());
                return false;
            }

            if (!comparePizzas(o1.getPizzasInOrder(), o2.getPizzasInOrder())) {
                System.out.println("Mismatched pizzas in order.");
                return false;
            }

        }
        return true;
    }

    private boolean comparePizzas(Pizza[] ps1, Pizza[] ps2){
        if(ps1.length != ps2.length) return false;
        for(int i = 0; i < ps1.length; i++){
            Pizza p1 =  ps1[i];
            Pizza p2 =  ps2[i];

            if(!Objects.equals(p1.name(), p2.name())) return false;
            if(p1.priceInPence() != p2.priceInPence()) return false;
        }
        return true;
    }

    private Boolean compareRegions(NamedRegion[] rs1, NamedRegion[] rs2){
        if(rs1.length != rs2.length) return false;
        for(int i = 0; i < rs1.length; i++){
            NamedRegion r1 =  rs1[i];
            NamedRegion r2 =  rs2[i];

            if(r1.name() != r2.name()) {
                System.out.println("Mismatched region names: " + r1.name() + " " + r2.name());
                return false;
            }
            if(!Arrays.toString(r1.vertices()).equals(Arrays.toString(r2.vertices()))) {
                return false;
            }
        }

        return true;
    }

    private boolean compareRestaurant(Restaurant[] rs1, Restaurant[] rs2){
        if(rs1.length != rs2.length) return false;
        for(int i = 0; i < rs1.length; i++){
            Restaurant r1 =  rs1[i];
            Restaurant r2 =  rs2[i];

            if(!Objects.equals(r1.name(), r2.name())) {
                System.out.println("Mismatched restaurant names: " + r1.name() + " " + r2.name());
                return false;
            }

            if(!Objects.equals(r1.location().toString(), r2.location().toString())) {
                System.out.println("Mismatched restaurant locations: " + r1.location() + " " + r2.location());
                return false;
            }

            if(!Arrays.toString(r1.openingDays()).equals(Arrays.toString(r2.openingDays()))) {
                System.out.println("Mismatched restaurant opening days: " + Arrays.toString(r1.openingDays()) + " " + Arrays.toString(r2.openingDays()));
                return false;
            }

            if(!(comparePizzas(r1.menu(), r2.menu()))){
                System.out.println("Mismatched restaurant menus.");
                return false;
            }

        }

        return true;
    }
}