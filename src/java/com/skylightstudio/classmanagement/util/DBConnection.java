package com.skylightstudio.classmanagement.util;

import java.sql.*;
import java.util.Properties;

public class DBConnection {

    static {
        try {
            Class.forName("org.postgresql.Driver");
            System.out.println("✅ PostgreSQL Driver Loaded");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        // Baca dari environment variables
        String dbHost = System.getenv("DB_HOST");
        String dbPort = System.getenv("DB_PORT");
        String dbName = System.getenv("DB_NAME");
        String username = System.getenv("DB_USER");
        String password = System.getenv("DB_PASSWORD");

        // Fallback ke DATABASE_URL kalau secrets tak set
        if (dbHost == null || username == null) {
            String databaseUrl = System.getenv("DATABASE_URL");
            if (databaseUrl != null) {
                return getConnectionFromUrl(databaseUrl);
            }
            throw new SQLException("No database configuration found!");
        }

        String jdbcUrl = String.format("jdbc:postgresql://%s:%s/%s",
                dbHost, dbPort, dbName);

        System.out.println("🔗 Connecting to: " + jdbcUrl);
        System.out.println("👤 User: " + username);

        Properties props = new Properties();
        props.setProperty("user", username);
        props.setProperty("password", password);
        props.setProperty("ssl", "false");
        props.setProperty("sslmode", "disable");

        try {
            Connection conn = DriverManager.getConnection(jdbcUrl, props);
            System.out.println("✅ CONNECTION SUCCESS!");
            return conn;
        } catch (SQLException e) {
            System.err.println("❌ CONNECTION FAILED: " + e.getMessage());
            throw e;
        }
    }

    // Backup method: Parse DATABASE_URL
    private static Connection getConnectionFromUrl(String databaseUrl) throws SQLException {
        try {
            System.out.println("🔄 Parsing DATABASE_URL...");

            // Remove postgres:// and split
            String cleanUrl = databaseUrl.replace("postgres://", "");

            // Format: user:password@host:port/database?params
            String[] parts = cleanUrl.split("@");
            String[] credentials = parts[0].split(":");
            String username = credentials[0];
            String password = credentials[1];

            String[] hostParts = parts[1].split("/");
            String hostAndPort = hostParts[0];
            String[] dbParts = hostParts[1].split("\\?");
            String dbName = dbParts[0];

            String jdbcUrl = "jdbc:postgresql://" + hostAndPort + "/" + dbName;

            System.out.println("🔗 Parsed URL: " + jdbcUrl);

            Properties props = new Properties();
            props.setProperty("user", username);
            props.setProperty("password", password);
            props.setProperty("ssl", "false");

            return DriverManager.getConnection(jdbcUrl, props);

        } catch (Exception e) {
            throw new SQLException("Failed to parse DATABASE_URL", e);
        }
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                if (!conn.isClosed()) {
                    conn.close();
                    System.out.println("🔌 Connection closed");
                }
            } catch (SQLException e) {
                System.err.println("Error closing connection: " + e.getMessage());
            }
        }
    }
}
