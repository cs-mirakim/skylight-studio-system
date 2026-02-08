<%@ page import="com.skylightstudio.classmanagement.util.DBConnection, java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Database Diagnostic</title>
        <style>
            .success { color: green; font-weight: bold; }
            .error { color: red; font-weight: bold; }
            .info { color: blue; }
        </style>
    </head>
    <body>
        <h1>Database Diagnostic Tool</h1>

        <h2>1. Connection Test</h2>
        <%
            try {
                Connection conn = DBConnection.getConnection();
                if (conn != null && !conn.isClosed()) {
                    out.println("<p class='success'>✓ Database connection SUCCESS</p>");
                    out.println("<p class='info'>Auto-commit: " + conn.getAutoCommit() + "</p>");
                    out.println("<p class='info'>Is closed: " + conn.isClosed() + "</p>");

                    // Test query
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM SYS.SYSTABLES");
                    if (rs.next()) {
                        out.println("<p class='success'>✓ System query executed: " + rs.getInt("count") + " system tables</p>");
                    }
                    rs.close();
                    stmt.close();

                } else {
                    out.println("<p class='error'>✗ Database connection FAILED - connection is null or closed</p>");
                }
            } catch (Exception e) {
                out.println("<p class='error'>✗ Error: " + e.getMessage() + "</p>");
                e.printStackTrace();
            }
        %>

        <h2>2. Application Tables Check</h2>
        <%
            String[] tables = {"REGISTRATION", "ADMIN", "INSTRUCTOR"};
            try {
                Connection conn = DBConnection.getConnection();
                DatabaseMetaData meta = conn.getMetaData();

                for (String table : tables) {
                    ResultSet rs = meta.getTables(null, "APP", table, new String[]{"TABLE"});
                    if (rs.next()) {
                        out.println("<p class='success'>✓ Table " + table + " exists</p>");
                    } else {
                        out.println("<p class='error'>✗ Table " + table + " NOT FOUND</p>");
                    }
                    rs.close();
                }
            } catch (Exception e) {
                out.println("<p class='error'>✗ Error checking tables: " + e.getMessage() + "</p>");
            }
        %>

        <h2>3. System Information</h2>
        <%
            out.println("<p>Context Path: " + request.getContextPath() + "</p>");
            out.println("<p>Server Info: " + application.getServerInfo() + "</p>");
            out.println("<p>Servlet Version: " + application.getMajorVersion() + "." + application.getMinorVersion() + "</p>");
        %>

        <h2>4. Quick Fixes</h2>
        <form action="test-simple-connection" method="post">
            <button type="submit">Test Simple Connection</button>
        </form>
    </body>
</html>