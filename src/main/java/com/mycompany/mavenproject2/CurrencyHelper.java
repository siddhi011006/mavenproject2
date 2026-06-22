package com.mycompany.mavenproject2;

public class CurrencyHelper {
    public static double convert(double priceInInr, String country) {
        if (country == null) {
            return priceInInr;
        }
        switch (country.trim()) {
            case "United States":
            case "USA":
            case "US":
                return priceInInr * 0.012; // 1 INR = 0.012 USD
            case "United Kingdom":
            case "UK":
            case "GB":
                return priceInInr * 0.0093; // 1 INR = 0.0093 GBP
            case "Canada":
            case "CA":
                return priceInInr * 0.016; // 1 INR = 0.016 CAD
            case "Australia":
            case "AU":
                return priceInInr * 0.018; // 1 INR = 0.018 AUD
            case "UAE":
            case "AE":
                return priceInInr * 0.044; // 1 INR = 0.044 AED
            case "Germany":
            case "France":
            case "Europe":
            case "EU":
                return priceInInr * 0.011; // 1 INR = 0.011 EUR
            case "India":
            case "IN":
            default:
                return priceInInr; // Base currency is INR
        }
    }

    public static String getCurrencySymbol(String country) {
        if (country == null) {
            return "₹";
        }
        switch (country.trim()) {
            case "United States":
            case "USA":
            case "US":
                return "$";
            case "United Kingdom":
            case "UK":
            case "GB":
                return "£";
            case "Canada":
            case "CA":
                return "C$";
            case "Australia":
            case "AU":
                return "A$";
            case "UAE":
            case "AE":
                return "د.إ";
            case "Germany":
            case "France":
            case "Europe":
            case "EU":
                return "€";
            case "India":
            case "IN":
            default:
                return "₹";
        }
    }
    
    public static String formatPrice(double priceInInr, String country) {
        double converted = convert(priceInInr, country);
        String symbol = getCurrencySymbol(country);
        if ("د.إ".equals(symbol)) {
            return symbol + " " + String.format("%.2f", converted);
        }
        return symbol + String.format("%.2f", converted);
    }
}
