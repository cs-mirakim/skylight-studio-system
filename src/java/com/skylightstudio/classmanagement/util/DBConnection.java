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
        // HARDCODE DENGAN CREDENTIAL BETUL dari DATABASE_URL
        String jdbcUrl = "jdbc:postgresql://skylight-studio-db.flycast:5432/skylight_studio";
        String username = "skylight_studio";
        String password = "AbxXCf8wR9KExwD";

        System.out.println("🔗 Connecting to: jdbc:postgresql://skylight-studio-db.flycast:5432/skylight_studio");
        System.out.println("👤 User: skylight_studio");

        try {
            Properties props = new Properties();
            props.setProperty("user", username);
            props.setProperty("password", password);
            props.setProperty("ssl", "false");
            props.setProperty("sslmode", "disable");

            Connection conn = DriverManager.getConnection(jdbcUrl, props);
            System.out.println("✅ CONNECTION SUCCESS!");
            System.out.println("📊 Database: " + conn.getCatalog());

            return conn;

        } catch (SQLException e) {
            System.err.println("❌ CONNECTION FAILED: " + e.getMessage());

            // Cuba fallback ke internal address
            try {
                System.out.println("🔄 Trying fallback to internal address...");
                String fallbackUrl = "jdbc:postgresql://skylight-studio-db.internal:5432/skylight_studio";
                Properties fallbackProps = new Properties();
                fallbackProps.setProperty("user", username);
                fallbackProps.setProperty("password", password);
                fallbackProps.setProperty("ssl", "false");
                fallbackProps.setProperty("sslmode", "disable");

                Connection conn = DriverManager.getConnection(fallbackUrl, fallbackProps);
                System.out.println("✅ FALLBACK CONNECTION SUCCESS!");
                return conn;
            } catch (SQLException e2) {
                System.err.println("❌ FALLBACK ALSO FAILED: " + e2.getMessage());
                throw e; // Throw original error
            }
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
                System.err.println("[DBConnection] Error closing connection: " + e.getMessage());
            }
        }
    }

    public static boolean testConnection() {
        System.out.println("🧪 Testing database connection...");
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                // Test dengan query simple
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT 1");
                if (rs.next()) {
                    System.out.println("✅ Test connection SUCCESS - Database is responsive");
                }
                rs.close();
                stmt.close();
                return true;
            }
            return false;
        } catch (SQLException e) {
            System.err.println("❌ Test connection FAILED: " + e.getMessage());
            return false;
        }
    }

    // Test connection dengan lebih detail
    public static void testConnectionDetails() {
        System.out.println("🧪=== DATABASE CONNECTION TEST ===");

        String[] testUrls = {
            "jdbc:postgresql://skylight-studio-db.flycast:5432/skylight_studio",
            "jdbc:postgresql://skylight-studio-db.internal:5432/skylight_studio",
            "jdbc:postgresql://skylight-studio-db.flycast:5432/postgres",
            "jdbc:postgresql://skylight-studio-db.internal:5432/postgres"
        };

        String username = "skylight_studio";
        String password = "AbxXCf8wR9KExwD";

        for (String url : testUrls) {
            System.out.println("\n🔍 Testing URL: " + url);

            try {
                Properties props = new Properties();
                props.setProperty("user", username);
                props.setProperty("password", password);
                props.setProperty("ssl", "false");
                props.setProperty("sslmode", "disable");

                Connection conn = DriverManager.getConnection(url, props);
                System.out.println("✅ Connected successfully!");
                System.out.println("   Database: " + conn.getCatalog());
                System.out.println("   Product: " + conn.getMetaData().getDatabaseProductName());

                // Test query
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM admin");
                if (rs.next()) {
                    System.out.println("   Admin count: " + rs.getInt(1));
                }

                rs.close();
                stmt.close();
                conn.close();

            } catch (SQLException e) {
                System.out.println("❌ Failed: " + e.getMessage());
            }
        }
        System.out.println("=== TEST COMPLETE ===");
    }

    // Quick test untuk servlet/jsp
    public static String getConnectionStatus() {
        if (testConnection()) {
            return "✅ Database connection is ACTIVE";
        } else {
            return "❌ Database connection FAILED";
        }
    }
}
