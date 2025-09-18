public class GradientGenerator {

    // Converts a number between a range to a hexadecimal color code
    public static String getColorForValue(int value, int minValue, int maxValue) {
        // Ensure the value stays within bounds
        if (value < minValue) value = minValue;
        if (value > maxValue) value = maxValue;

        // Normalize the value (0 to 1)
        double normalizedValue = (double) (value - minValue) / (maxValue - minValue);

        // Define the start and end colors (Blue and Orange)
        int startColor = 0x1f77b4;  // Blue
        int endColor = 0xff7f0e;    // Orange

        // Interpolate RGB values
        int r = interpolateColorComponent((startColor >> 16) & 0xff, (endColor >> 16) & 0xff, normalizedValue);
        int g = interpolateColorComponent((startColor >> 8) & 0xff, (endColor >> 8) & 0xff, normalizedValue);
        int b = interpolateColorComponent(startColor & 0xff, endColor & 0xff, normalizedValue);

        // Combine RGB values into a single hex value
        return String.format("#%02x%02x%02x", r, g, b);
    }
    private static int interpolateColorComponent(int start, int end, double factor) {
        return (int) (start + (end - start) * factor);
    }
}