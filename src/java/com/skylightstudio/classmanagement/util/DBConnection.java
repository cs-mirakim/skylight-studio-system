package com.skylightstudio.classmanagement.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.net.URI;

public class DBConnection {

    static {
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("[DBConnection] PostgreSQL JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] ERROR: PostgreSQL driver not found");
            throw new RuntimeException("PostgreSQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        System.out.println("[DBConnection] Creating new connection...");

        String dbUrl;
        String dbUser;
        String dbPassword;

        // Get DATABASE_URL from environment
        String databaseUrl = System.getenv("DATABASE_URL");

        if (databaseUrl != null && !databaseUrl.isEmpty()) {
            // Parse Fly.io DATABASE_URL format: postgres://user:password@host:port/database
            try {
                // Replace postgres:// with postgresql:// for JDBC compatibility
                if (databaseUrl.startsWith("postgres://")) {
                    databaseUrl = databaseUrl.replace("postgres://", "postgresql://");
                }

                URI dbUri = new URI(databaseUrl);
                String userInfo = dbUri.getUserInfo();

                if (userInfo != null) {
                    String[] credentials = userInfo.split(":");
                    dbUser = credentials[0];
                    dbPassword = credentials.length > 1 ? credentials[1] : "";
                } else {
                    dbUser = "postgres";
                    dbPassword = "";
                }

                // Build JDBC URL
                dbUrl = "jdbc:postgresql://" + dbUri.getHost() + ":" + dbUri.getPort() + dbUri.getPath();

                System.out.println("[DBConnection] Using Fly.io DATABASE_URL");
                System.out.println("[DBConnection] Host: " + dbUri.getHost());
                System.out.println("[DBConnection] Port: " + dbUri.getPort());
                System.out.println("[DBConnection] Database: " + dbUri.getPath());
                System.out.println("[DBConnection] User: " + dbUser);

            } catch (Exception e) {
                System.err.println("[DBConnection] Error parsing DATABASE_URL: " + e.getMessage());
                e.printStackTrace();
                throw new SQLException("Failed to parse DATABASE_URL", e);
            }
        } else {
            // Local development fallback
            dbUrl = "jdbc:postgresql://localhost:5432/skylightstudio";
            dbUser = "postgres";
            dbPassword = "postgres";
            System.out.println("[DBConnection] Using local PostgreSQL");
        }

        try {
            Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            System.out.println("[DBConnection] Connection created successfully");
            System.out.println("[DBConnection] Database: " + conn.getMetaData().getDatabaseProductName());
            return conn;
        } catch (SQLException e) {
            System.err.println("[DBConnection] Error creating connection: " + e.getMessage());
            System.err.println("[DBConnection] JDBC URL: " + dbUrl);
            System.err.println("[DBConnection] User: " + dbUser);
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
