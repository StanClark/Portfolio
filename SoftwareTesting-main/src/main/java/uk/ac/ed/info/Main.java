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

public class Main {
    public static void main(String[] args) throws IOException {

        String inputDate = args[0];
        String baseUrl = args[1];


        ServerHandler serverHandler = new ServerHandler(baseUrl, inputDate);

        run(serverHandler);



    }

    public static void run(ServerHandler serverHandler) throws IOException {



        OrderValidator validator = new OrderValidator();
        LngLatHandler handler = new LngLatHandler(serverHandler);

        Order[] orders;
        Restaurant[] restaurants;

        orders = serverHandler.getOrders();

        restaurants = serverHandler.getRestaurants();

        List<Order> validOrders = new ArrayList<Order>();
        for(Order o: orders) {
            validator.validateOrder(o, restaurants);
            if(o.getOrderValidationCode() == OrderValidationCode.NO_ERROR){
                o.setOrderStatus(OrderStatus.VALID_BUT_NOT_DELIVERED);
                validOrders.add(o);
            }
            else {
                o.setOrderStatus(OrderStatus.INVALID);
            }
        }

        LngLat appleton = new LngLat(-3.1865, 55.9445);
        List<List<Node>> routes = new ArrayList<>();
        for (Order o: validOrders) {
            pathfinder pfinder = new pathfinder(handler);

            Restaurant orderedFrom = restaurants[0];
            for(Restaurant r: restaurants) {
                if(validator.onMenu(r, o.getPizzasInOrder()[0])){
                    orderedFrom = r;
                    break;
                }
            }

             routes.add(pfinder.pathTo(appleton, orderedFrom.location()));
        }

        /*
        List<LineString> gLine = new ArrayList<LineString>();
        for(int i = 1; i < route.size(); i++) {
            gLine.add(new LineString(route.get(i-1).getPos(), route.get(i).getPos()));
        }

        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.writeValue(new File("pathLine.json"), gLine);*/

    }




}
