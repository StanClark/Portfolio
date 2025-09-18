package uk.ac.ed.info;

import uk.ac.ed.inf.ilp.constant.SystemConstants;
import uk.ac.ed.inf.ilp.data.*;
import uk.ac.ed.info.LngLatHandler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.time.LocalDate;
import java.time.DayOfWeek;
import uk.ac.ed.inf.ilp.constant.OrderValidationCode;
import uk.ac.ed.inf.ilp.constant.OrderStatus;
import java.util.HashSet;
import java.util.List;
import java.util.logging.Handler;

public class ServerHandler extends Throwable {
    //private Order[] orders;
    //private Restaurant[] restaurants;
    //private NamedRegion[] noFlyZones;

    public ObjectMapper mapper;
    public String baseUrl;
    public String inputDate;

    public ServerHandler(String Url, String Date){
        mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());

        baseUrl = Url;
        inputDate = Date;

    }

    public ServerHandler(String Url, String Date, ObjectMapper m){
        mapper = m;
        mapper.registerModule(new JavaTimeModule());

        baseUrl = Url;
        inputDate = Date;
    }

    public Order[] getOrders(){
        try {
            return mapper.readValue(new URL(baseUrl + "/orders/" + inputDate), Order[].class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    public Restaurant[] getRestaurants(){
        try {
            return mapper.readValue(new URL(baseUrl + "/restaurants"), Restaurant[].class);

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    public NamedRegion[] getNoFlyZones() {
        try {
            return mapper.readValue(new URL(baseUrl + "/noFlyZones"), NamedRegion[].class);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

}
