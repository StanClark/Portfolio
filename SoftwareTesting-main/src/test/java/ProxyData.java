import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import uk.ac.ed.inf.ilp.constant.OrderStatus;
import uk.ac.ed.inf.ilp.constant.OrderValidationCode;
import uk.ac.ed.inf.ilp.data.*;
import uk.ac.ed.inf.ilp.constant.SystemConstants;
import uk.ac.ed.inf.ilp.interfaces.OrderValidation;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.io.File;
import java.util.List;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

public class ProxyData {
    public static Restaurant[] getRestaurants(){

        return new Restaurant[] {
                new Restaurant(
                        "Civerinos Slice", // name
                        new LngLat(-3.1912869215011597, 55.945535152517735), // Location
                        new DayOfWeek[] {DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY}, // opening days
                        new Pizza[] {new Pizza("Margarita", 1000)} // menu
                ),
                new Restaurant(
                        "The Pizza Post",
                        new LngLat(-3.186874, 55.944487), // Location near Appleton Tower
                        new DayOfWeek[] {DayOfWeek.WEDNESDAY, DayOfWeek.THURSDAY, DayOfWeek.FRIDAY},
                        new Pizza[] {
                                new Pizza("Pepperoni Feast", 1200),
                                new Pizza("Veggie Delight", 1100)
                        }
                ),
                new Restaurant(
                        "Slice of Heaven",
                        new LngLat(-3.186396, 55.944789), // Location near Appleton Tower
                        new DayOfWeek[] {DayOfWeek.WEDNESDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY},
                        new Pizza[] {
                                new Pizza("BBQ Chicken", 1400),
                                new Pizza("Four Cheese", 1300)
                        }
                ),
                new Restaurant(
                        "Napoli Express",
                        new LngLat(-3.184750, 55.944050), // Location near Appleton Tower
                        new DayOfWeek[] {DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.THURSDAY, DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY},
                        new Pizza[] {
                                new Pizza("Classic Margherita", 1000),
                                new Pizza("Diavola", 1500),
                                new Pizza("Capricciosa", 1600)
                        }
                ),
                new Restaurant(
                        "Pasta & Pizza Co.",
                        new LngLat(-3.187320, 55.943650), // Location near Appleton Tower
                        new DayOfWeek[] {DayOfWeek.THURSDAY, DayOfWeek.FRIDAY},
                        new Pizza[] {
                                new Pizza("Meat Feast", 1500),
                                new Pizza("Hawaiian", 1200)
                        }
                ),
                new Restaurant(
                        "Edinburgh Eats",
                        new LngLat(-3.185940, 55.945120), // Location near Appleton Tower
                        new DayOfWeek[] {DayOfWeek.MONDAY, DayOfWeek.WEDNESDAY, DayOfWeek.SATURDAY},
                        new Pizza[] {
                                new Pizza("Mediterranean Veggie", 1100),
                                new Pizza("Spicy Sausage", 1400)
                        }
                )
        };


    }

    public static Order[] getValidOrders(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] orderBadCardLength1(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("123412341234123",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] orderBadCardLength2(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("12341234123412345",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] orderBadChar(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234abcd12341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getCVVLong(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "1234"))
        };
    }

    public static Order[] getCVVShort(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "12"))
        };
    }

    public static Order[] getCVVBadChar(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "ab5"))
        };
    }

    public static Order[] getExpired1(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                LocalDate.now().minusYears(1).format(DateTimeFormatter.ofPattern("MM/yy")),
                                "123"))
        };
    }

    public static Order[] getExpired2(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                LocalDate.now().minusMonths(1).format(DateTimeFormatter.ofPattern("MM/yy")),
                                "123"))
        };
    }

    public static Order[] getExpBoundary(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                LocalDate.now().format(DateTimeFormatter.ofPattern("MM/yy")),
                                "123"))
        };
    }

    public static Order[] getMaxPizzaBoundary(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        5100,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500),new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getMaxPizzaOver(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        6100,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500),new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500),new Pizza("Classic Margherita",
                                1000)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getUndefinedPizza1(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        1600,
                        new Pizza[] {new Pizza("DaVinci", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getUndefinedPizza2(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000) ,new Pizza("DaVinci", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getMultiRest1(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getMultiRest2(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Mediterranean Veggie", 1100),
                                new Pizza("Spicy Sausage", 1400)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getMultiRest3(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2500,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000), new Pizza("Spicy Sausage", 1400)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getIncorrectTotalLow(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2500,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getIncorrectTotalHigh(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        4500,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getClosingTimeValid(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13).plusDays(2),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        1500,
                        new Pizza[] {new Pizza("BBQ Chicken", 1400)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getClosed1(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13).plusDays(2),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        2600,
                        new Pizza[] {new Pizza("Classic Margherita",
                                1000),new Pizza("Diavola", 1500)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static Order[] getClosed2(){
        return new Order[] {
                new Order("1",
                        LocalDate.of(2025, 1, 13),
                        OrderStatus.UNDEFINED,
                        OrderValidationCode.UNDEFINED,
                        1500,
                        new Pizza[] {new Pizza("BBQ Chicken", 1400)},
                        new CreditCardInformation("1234123412341234",
                                "08/29",
                                "123"))
        };
    }

    public static NamedRegion getIrregularRegion() {
        return new NamedRegion(
                "IrregularRegion", // Name of the region
                new LngLat[] {
                        new LngLat(-3.186023443613948, 55.944987257379125),
                        new LngLat(-3.186067112791136, 55.94446760121957),
                        new LngLat(-3.1844950224194406, 55.94446760121957),
                        new LngLat(-3.1837744809990056, 55.94542131776737),
                        new LngLat(-3.1851937292508126, 55.945378523297535),
                        new LngLat(-3.186023443613948, 55.94587371355783),
                        new LngLat(-3.1867876542115994, 55.945231799041125)
                }
        );
    }
    public static NamedRegion getSquareRegion() {
        return new NamedRegion(
                "SquareRegion", // Name of the region
                new LngLat[] {
                        new LngLat(-3.190409913289784, 55.94418314961936),
                        new LngLat(-3.190409913289784, 55.94296124829455),
                        new LngLat(-3.1867296627183634, 55.94296124829455),
                        new LngLat(-3.1867296627183634, 55.94418314961936)
                }
        );
    }

    public static NamedRegion getGeorgeSquareArea() {
        return new NamedRegion(
                "George Square Area",
                new LngLat[] {
                        new LngLat(-3.190578818321228, 55.94402412577528),
                        new LngLat(-3.1899887323379517, 55.94284650540911),
                        new LngLat(-3.187097311019897, 55.94328811724263),
                        new LngLat(-3.187682032585144, 55.944477740393744)
                }
        );
    }

    public static NamedRegion getDrElsieInglisQuadrangle() {
        return new NamedRegion(
                "Dr Elsie Inglis Quadrangle",
                new LngLat[] {
                        new LngLat(-3.1907182931900024, 55.94519570234043),
                        new LngLat(-3.1906163692474365, 55.94498241796357),
                        new LngLat(-3.1900262832641597, 55.94507554227258),
                        new LngLat(-3.190133571624756, 55.94529783810495)
                }
        );
    }

    public static NamedRegion getBristoSquareOpenArea() {
        return new NamedRegion(
                "Bristo Square Open Area",
                new LngLat[] {
                        new LngLat(-3.189543485641479, 55.94552313663306),
                        new LngLat(-3.189382553100586, 55.94553214854692),
                        new LngLat(-3.189259171485901, 55.94544803726933),
                        new LngLat(-3.1892001628875732, 55.94533688994374),
                        new LngLat(-3.189194798469543, 55.94519570234043),
                        new LngLat(-3.189135789871216, 55.94511759833873),
                        new LngLat(-3.188138008117676, 55.9452738061846),
                        new LngLat(-3.1885510683059692, 55.946105902745614),
                        new LngLat(-3.1895381212234497, 55.94555918427592)
                }
        );
    }

    public static NamedRegion getBayesCentralArea() {
        return new NamedRegion(
                "Bayes Central Area",
                new LngLat[] {
                        new LngLat(-3.1876927614212036, 55.94520696732767),
                        new LngLat(-3.187555968761444, 55.9449621408666),
                        new LngLat(-3.186981976032257, 55.94505676722831),
                        new LngLat(-3.1872327625751495, 55.94536993377657),
                        new LngLat(-3.1874459981918335, 55.9453361389472),
                        new LngLat(-3.1873735785484314, 55.94519344934259),
                        new LngLat(-3.1875935196876526, 55.94515665035927),
                        new LngLat(-3.187624365091324, 55.94521973430925)
                }
        );
    }

    public static NamedRegion[] getNoFly() {
        return new NamedRegion[] {
                getGeorgeSquareArea(),getDrElsieInglisQuadrangle(),getBristoSquareOpenArea(),getBayesCentralArea()
        };

    }

    public static Order[] trueOrders() throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());

        Order[] orders = objectMapper.readValue(
                new File("src/test/orders.json"),
                Order[].class
        );
        return orders;
    }

    public static Restaurant[] trueRestaurants() throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());

        return objectMapper.readValue(
                new File("src/test/restaurants.json"),
                Restaurant[].class
        );
    }

    public static NamedRegion[] trueNoFly() throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());

        return objectMapper.readValue(
                new File("src/test/noFlyZones.json"),
                NamedRegion[].class
        );
    }


}

