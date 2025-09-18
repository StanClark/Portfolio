import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.Test;

import org.junit.runner.RunWith;

import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnitRunner;


import uk.ac.ed.inf.ilp.data.*;

import uk.ac.ed.info.Main;
import uk.ac.ed.info.ServerHandler;

import java.io.IOException;
import java.net.URL;
import java.util.*;
import java.util.stream.Stream;

import static org.junit.Assert.fail;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;

@RunWith(MockitoJUnitRunner.class)
public class SystemTest {
    @Mock
    private ObjectMapper proxyMapper; // Mockito mock

    private ServerHandler serverHandler;

    @Test
    public void normalTest() throws IOException {

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenReturn(ProxyData.trueNoFly());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenReturn(ProxyData.trueRestaurants());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenReturn(ProxyData.trueOrders());


        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        Main.run(serverHandler);
    }

    @Test
    public void stressTest() throws IOException {
        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenReturn(ProxyData.trueNoFly());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Restaurant[].class)))
                .thenReturn(ProxyData.trueRestaurants());

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(Order[].class)))
                .thenReturn(Stream.generate(() -> {
                            try {
                                return ProxyData.trueOrders();
                            } catch (IOException e) {
                                throw new RuntimeException(e);
                            }
                        })
                        .limit(20)//200
                        .flatMap(Arrays::stream)
                        .toArray(Order[]::new));



        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        Main.run(serverHandler);
    }

    @Test
    public void errorTest() throws IOException {

        Mockito.when(proxyMapper.readValue(any(URL.class), eq(NamedRegion[].class)))
                .thenThrow(new IOException("server time out"));


        serverHandler = new ServerHandler("http://localhost:8080", "01/01/2000", proxyMapper);

        try{
            Main.run(serverHandler);
            fail("Should have thrown an exception");
        }catch (Exception ignored){

        }
    }


}
