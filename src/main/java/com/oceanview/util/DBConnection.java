package com.oceanview.util;

import com.oceanview.config.AppConfig;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * ACADEMIC NOTE:
 * Singleton Pattern implementation for Database Connection.
 * Ensures only one instance of the connection factory exists,
 * reducing overhead and managing connection logic centrally.
 */
public class DBConnection {

    private static DBConnection instance;

    private DBConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static synchronized DBConnection getInstance() {
        if (instance == null) {
            instance = new DBConnection();
        }
        return instance;
    }

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
            AppConfig.getDbUrl(),
            AppConfig.getDbUser(),
            AppConfig.getDbPass()
        );
    }
}

