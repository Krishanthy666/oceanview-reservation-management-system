package com.oceanview.config;

import java.io.InputStream;
import java.util.Properties;

/**
 * ACADEMIC NOTE:
 * Loads configuration settings from a properties file.
 * This decouples configuration from code, adhering to the "Open/Closed Principle".
 */
public class AppConfig {
    private static Properties properties = new Properties();

    static {
        try (InputStream input = AppConfig.class.getClassLoader().getResourceAsStream("oceanview.properties")) {
            if (input == null) {
                System.err.println("FATAL: Unable to find oceanview.properties");
            }
            properties.load(input);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static String getDbUrl() { return properties.getProperty("db.url"); }
    public static String getDbUser() { return properties.getProperty("db.username"); }
    public static String getDbPass() { return properties.getProperty("db.password"); }
    public static double getTaxRate() { return Double.parseDouble(properties.getProperty("tax.rate")); }
    public static double getServiceCharge() { return Double.parseDouble(properties.getProperty("service.charge")); }
}

