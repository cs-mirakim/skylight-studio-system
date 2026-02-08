package com.skylightstudio.classmanagement.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // Get database config from environment variables (for production) or use defaults (for local)
    private static final String DB_URL = System.getenv("DATABASE_URL") != null
            ? System.getenv("DATABASE_URL")
            : "jdbc:postgresql://localhost:5432/skylightstudio";

    private static final String DB_USER = System.getenv("DB_USER") != null
            ? System.getenv("DB_USER")
            : "postgres";

    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD") != null
            ? System.getenv("DB_PASSWORD")
            : "postgres";

    static {
        try {
            // Load PostgreSQL driver
            Class.forName("org.postgresql.Driver");
            System.out.println("[DBConnection] PostgreSQL JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] ERROR: PostgreSQL driver not found");
            throw new RuntimeException("PostgreSQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("[DBConnection] Creating new connection...");
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("[DBConnection] Connection created successfully");
            System.out.println("[DBConnection] Database: " + conn.getMetaData().getDatabaseProductName());
            System.out.println("[DBConnection] URL: " + conn.getMetaData().getURL());
            return conn;
        } catch (SQLException e) {
            System.err.println("[DBConnection] Error creating connection: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                    System.out.println("[DBConnection] Connection closed");
                }
            } catch (SQLException e) {
                System.err.println("[DBConnection] Error closing connection: " + e.getMessage());
            }
        }
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[DBConnection] Test failed: " + e.getMessage());
            return false;
        }
    }
}
