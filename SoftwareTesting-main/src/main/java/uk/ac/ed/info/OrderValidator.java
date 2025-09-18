package uk.ac.ed.info;
import uk.ac.ed.inf.ilp.constant.OrderValidationCode;
import uk.ac.ed.inf.ilp.data.Order;
import uk.ac.ed.inf.ilp.data.Restaurant;
import uk.ac.ed.inf.ilp.constant.SystemConstants;
import uk.ac.ed.inf.ilp.interfaces.OrderValidation;
import uk.ac.ed.inf.ilp.data.Pizza;

import java.time.LocalDate;
import java.time.DayOfWeek;
import java.util.Arrays;
import java.util.Objects;

public class OrderValidator implements OrderValidation{
    public Order validateOrder(Order orderToValidate, Restaurant[] definedRestaurants){

        if(orderToValidate == null) throw new IllegalArgumentException("order cannot be null");
        if(definedRestaurants == null) throw new IllegalArgumentException("defined Restaurants cannot be null");

        if(!cardNumValid(orderToValidate)){
            orderToValidate.setOrderValidationCode(OrderValidationCode.CARD_NUMBER_INVALID);
            return orderToValidate;
        }



        if(!cvvValid(orderToValidate)){
            orderToValidate.setOrderValidationCode(OrderValidationCode.CVV_INVALID);
            return orderToValidate;
        }

        if(!expDateValid(orderToValidate)){
            orderToValidate.setOrderValidationCode(OrderValidationCode.EXPIRY_DATE_INVALID);
            return orderToValidate;
        }



        if(orderToValidate.getPizzasInOrder().length > SystemConstants.MAX_PIZZAS_PER_ORDER){
            orderToValidate.setOrderValidationCode(OrderValidationCode.MAX_PIZZA_COUNT_EXCEEDED);
            return orderToValidate;
        } //checks for max pizzas


        for(Pizza p: orderToValidate.getPizzasInOrder()){
            if(!pizzaExists(definedRestaurants, p)){
                orderToValidate.setOrderValidationCode(OrderValidationCode.PIZZA_NOT_DEFINED);
                return orderToValidate;
            }
        } //checks if pizzas are available on any menus


        Restaurant orderedFrom = null;
        for (Pizza p: orderToValidate.getPizzasInOrder()) {
            if(orderedFrom == null){
                for(Restaurant r: definedRestaurants){
                    if(onMenu(r, p)){
                        orderedFrom = r;
                        break;
                    }
                }
            } else if (!onMenu(orderedFrom, p)) { // only correct if pizza exists on other menus
                orderToValidate.setOrderValidationCode(OrderValidationCode.PIZZA_FROM_MULTIPLE_RESTAURANTS);
                return orderToValidate;
            }

        } // checks pizza are from same restaurant and assigns orderedFrom


        if(!totalCorrect(orderToValidate)){
            orderToValidate.setOrderValidationCode(OrderValidationCode.TOTAL_INCORRECT);
            return orderToValidate;
        }



        if(orderedFrom == null){
            orderToValidate.setOrderValidationCode(OrderValidationCode.PIZZA_NOT_DEFINED);
            return orderToValidate;
        }
        if(!restaurantOpen(orderedFrom, orderToValidate)){
            orderToValidate.setOrderValidationCode(OrderValidationCode.RESTAURANT_CLOSED);
            return orderToValidate;
        }

        orderToValidate.setOrderValidationCode(OrderValidationCode.NO_ERROR);
        return orderToValidate;
    }

    public boolean onMenu(Restaurant r, Pizza p1){
        for(Pizza p2: r.menu()){
            if(Objects.equals(p1.name(), p2.name())){
                return true;
            }
        }

        return false;
    }

    private boolean pizzaExists(Restaurant[] rs, Pizza p){
        for(Restaurant r: rs){
            if(onMenu(r,p)) return true;
        }
        return false;
    }

    private boolean cardNumValid(Order order){
        String cardNo = order.getCreditCardInformation().getCreditCardNumber();

        return cardNo.matches("[0-9]+") && cardNo.length() == 16;
    }

    private boolean cvvValid(Order order){
        String cvv = order.getCreditCardInformation().getCvv();

        return cvv.matches("[0-9]+") && cvv.length() == 3;
    }

    private boolean expDateValid(Order order){
        String exp = order.getCreditCardInformation().getCreditCardExpiry();
        LocalDate now = LocalDate.now();

        if(exp.matches("[0-9,/]+") && exp.matches("../..")){
            int month = Integer.parseInt(exp.split("/")[0]);
            int year = Integer.parseInt(exp.split("/")[1]);

            if(year < (now.getYear() % 100)) return false;

            return year != (now.getYear() % 100) || month >= now.getMonthValue();
        }
        return false;
    }

    private boolean totalCorrect(Order order){
        int trueTotal = 0;
        int delCharge = 100;

        for(Pizza p: order.getPizzasInOrder()){
            trueTotal += p.priceInPence();
        }

        return order.getPriceTotalInPence() == (trueTotal + delCharge);
    }

    private boolean restaurantOpen(Restaurant r, Order o){

        LocalDate now = o.getOrderDate();
        return Arrays.stream(r.openingDays()).toList().contains(now.getDayOfWeek());
    }
}
