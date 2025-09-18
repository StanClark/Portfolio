import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import uk.ac.ed.inf.ilp.data.Order;


import uk.ac.ed.inf.ilp.constant.OrderValidationCode;
import uk.ac.ed.info.OrderValidator;


public class OrderValidatorTest {

    @Test
    public void testValidOrder(){

        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getValidOrders()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expect order to be valid");
    }

    @Test
    public void testOrderCardNumber(){ // counts as normal for all order eval tests

        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.orderBadCardLength1()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CARD_NUMBER_INVALID,
                o.getOrderValidationCode(),
                "expect card number to be invalid");

        o = validator.validateOrder(ProxyData.orderBadCardLength2()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CARD_NUMBER_INVALID,
                o.getOrderValidationCode(),
                "expect card number to be invalid");

        o = validator.validateOrder(ProxyData.orderBadChar()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CARD_NUMBER_INVALID,
                o.getOrderValidationCode(),
                "expect card number to be invalid");


    }

    @Test public void testOrderCVV(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getCVVShort()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CVV_INVALID,
                o.getOrderValidationCode(),
                "expect CVV to be invalid");

        o = validator.validateOrder(ProxyData.getCVVLong()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CVV_INVALID,
                o.getOrderValidationCode(),
                "expect CVV to be invalid");

        o = validator.validateOrder(ProxyData.getCVVBadChar()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.CVV_INVALID,
                o.getOrderValidationCode(),
                "expect CVV to be invalid");

    }

    @Test public void testExpDate(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getExpBoundary()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expect valid Exp Date");

        o = validator.validateOrder(ProxyData.getExpired1()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.EXPIRY_DATE_INVALID,
                o.getOrderValidationCode(),
                "expect invalid Exp Date");

        o = validator.validateOrder(ProxyData.getExpired2()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.EXPIRY_DATE_INVALID,
                o.getOrderValidationCode(),
                "expect invalid Exp Date");


    }

    @Test public void testMaxPizzaCount(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getMaxPizzaBoundary()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expect valid Number of Pizzas");

        o = validator.validateOrder(ProxyData.getMaxPizzaOver()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.MAX_PIZZA_COUNT_EXCEEDED,
                o.getOrderValidationCode(),
                "expect invalid Number of Pizzas");
    }

    @Test public void pizzaNotDefined(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getUndefinedPizza1()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.PIZZA_NOT_DEFINED,
                o.getOrderValidationCode(),
                "expected invalid pizza in order");

        o = validator.validateOrder(ProxyData.getUndefinedPizza2()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.PIZZA_NOT_DEFINED,
                o.getOrderValidationCode(),
                "expected invalid pizza in order");
    }
    @Test public void multiRest(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getMultiRest1()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expected valid pizzas in order");

        o = validator.validateOrder(ProxyData.getMultiRest2()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expected valid pizzas in order");

        o = validator.validateOrder(ProxyData.getMultiRest3()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.PIZZA_FROM_MULTIPLE_RESTAURANTS,
                o.getOrderValidationCode(),
                "expected invalid pizzas in order");
    }

    @Test public void totalIncorrect(){
        OrderValidator validator = new OrderValidator();
        Order o = validator.validateOrder(ProxyData.getIncorrectTotalLow()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.TOTAL_INCORRECT,
                o.getOrderValidationCode(),
                "expected invalid total");

        o = validator.validateOrder(ProxyData.getIncorrectTotalHigh()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.TOTAL_INCORRECT,
                o.getOrderValidationCode(),
                "expected invalid total");
    }

    @Test public void restaurantClosed(){
        OrderValidator validator = new OrderValidator();

        Order o = validator.validateOrder(ProxyData.getClosingTimeValid()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.NO_ERROR,
                o.getOrderValidationCode(),
                "expected valid Order Date");

        o = validator.validateOrder(ProxyData.getClosed1()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.RESTAURANT_CLOSED,
                o.getOrderValidationCode(),
                "expected invalid Order Date");

        o = validator.validateOrder(ProxyData.getClosed2()[0], ProxyData.getRestaurants());
        assertEquals(OrderValidationCode.RESTAURANT_CLOSED,
                o.getOrderValidationCode(),
                "expected invalid Order Date");
    }
}









