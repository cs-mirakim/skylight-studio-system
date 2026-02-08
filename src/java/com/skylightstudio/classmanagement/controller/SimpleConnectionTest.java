package com.skylightstudio.classmanagement.controller;

import java.io.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;

@WebServlet("/test-simple-connection")
public class SimpleConnectionTest extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<h1>Simple Connection Test</h1>");

        try {
            // Direct connection tanpa DBConnection class
            Class.forName("org.apache.derby.jdbc.ClientDriver");

            String url = "jdbc:derby://localhost:1527/SkylightStudioDB";
            String user = "app";
            String pass = "app";

            out.println("<p>Connecting to: " + url + "</p>");

            Connection conn = DriverManager.getConnection(url, user, pass);

            if (conn != null) {
                out.println("<p style='color:green'>✓ DIRECT CONNECTION SUCCESS</p>");

                // Try to insert test record
                Statement stmt = conn.createStatement();
                try {
                    stmt.execute("CREATE TABLE test_table (id INT)");
                    out.println("<p>Test table created</p>");
                } catch (SQLException e) {
                    out.println("<p>Table may already exist</p>");
                }

                stmt.execute("INSERT INTO test_table VALUES (1)");
                out.println("<p>Test record inserted</p>");

                ResultSet rs = stmt.executeQuery("SELECT * FROM test_table");
                out.println("<p>Test query executed: " + (rs.next() ? "Data found" : "No data") + "</p>");

                rs.close();
                stmt.close();
                conn.close();

                out.println("<p style='color:green'>✓ All tests passed!</p>");
            }

        } catch (ClassNotFoundException e) {
            out.println("<p style='color:red'>✗ Driver not found: " + e.getMessage() + "</p>");
        } catch (SQLException e) {
            out.println("<p style='color:red'>✗ SQL Error: " + e.getMessage() + "</p>");
            out.println("<p>SQL State: " + e.getSQLState() + "</p>");
            out.println("<p>Error Code: " + e.getErrorCode() + "</p>");
        }

        out.println("<br><a href='diagnostic.jsp'>Back to Diagnostic</a>");
    }
}
