package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.UUID;
import java.util.Calendar;

public class PasswordResetDAO {

    // Generate token dan create reset request
    public String createResetRequest(String email, String userRole) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Check rate limiting - max 5 requests in last 3 hours
            // DERBY SYNTAX: Use {fn TIMESTAMPADD(SQL_TSI_HOUR, -3, CURRENT_TIMESTAMP)}
            String checkSql = "SELECT COUNT(*) FROM password_reset WHERE email = ? AND userRole = ? "
                    + "AND createdTime > {fn TIMESTAMPADD(SQL_TSI_HOUR, -3, CURRENT_TIMESTAMP)}";

            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, email);
            pstmt.setString(2, userRole);
            rs = pstmt.executeQuery();

            if (rs.next() && rs.getInt(1) >= 5) {
                throw new SQLException("Too many reset requests. Please wait 3 hours.");
            }
            rs.close();
            pstmt.close();

            // Generate token (UUID version 4)
            String token = UUID.randomUUID().toString();

            // Calculate expiry time (1 hour from now)
            Calendar cal = Calendar.getInstance();
            cal.add(Calendar.HOUR, 1);
            Timestamp expiryTime = new Timestamp(cal.getTimeInMillis());

            // Insert into password_reset table
            String insertSql = "INSERT INTO password_reset (email, userRole, token, expiryTime) "
                    + "VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, email);
            pstmt.setString(2, userRole);
            pstmt.setString(3, token);
            pstmt.setTimestamp(4, expiryTime);

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                System.out.println("Reset token created for email: " + email + ", token: " + token);
                return token;
            }

            return null;

        } finally {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }

    // Validate token
    public boolean validateToken(String token) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // DERBY SYNTAX: Use {fn TIMESTAMPADD(SQL_TSI_HOUR, -3, CURRENT_TIMESTAMP)}
            String sql = "SELECT email, userRole FROM password_reset "
                    + "WHERE token = ? AND used = 'N' AND expiryTime > CURRENT_TIMESTAMP";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, token);
            rs = pstmt.executeQuery();

            boolean isValid = rs.next();
            System.out.println("Token validation for " + token + ": " + isValid);
            return isValid;

        } finally {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }

    // Get email and role from token
    public String[] getEmailAndRoleFromToken(String token) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT email, userRole FROM password_reset "
                    + "WHERE token = ? AND used = 'N' AND expiryTime > CURRENT_TIMESTAMP";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, token);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String[] result = new String[2];
                result[0] = rs.getString("email");
                result[1] = rs.getString("userRole");
                System.out.println("Token info - Email: " + result[0] + ", Role: " + result[1]);
                return result;
            }

            return null;

        } finally {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }

    // Mark token as used
    public boolean markTokenAsUsed(String token) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "UPDATE password_reset SET used = 'Y' WHERE token = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, token);

            int rows = pstmt.executeUpdate();
            System.out.println("Token marked as used: " + token + " (" + rows + " rows affected)");
            return rows > 0;

        } finally {
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }

    // Check if email exists in system (admin or instructor)
    public boolean emailExists(String email, String userRole) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            String sql;
            if ("admin".equals(userRole)) {
                sql = "SELECT COUNT(*) FROM admin WHERE email = ?";
            } else if ("instructor".equals(userRole)) {
                sql = "SELECT COUNT(*) FROM instructor WHERE email = ?";
            } else {
                return false;
            }

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            rs = pstmt.executeQuery();

            boolean exists = rs.next() && rs.getInt(1) > 0;
            System.out.println("Email exists check for " + email + " (" + userRole + "): " + exists);
            return exists;

        } finally {
            if (rs != null) {
                rs.close();
            }
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }

    // Clean up expired tokens (optional utility method)
    public void cleanupExpiredTokens() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = DBConnection.getConnection();

            // Delete tokens that are expired or used
            String sql = "DELETE FROM password_reset WHERE used = 'Y' OR expiryTime <= CURRENT_TIMESTAMP";
            pstmt = conn.prepareStatement(sql);

            int rows = pstmt.executeUpdate();
            System.out.println("Cleaned up " + rows + " expired/used tokens");

        } finally {
            if (pstmt != null) {
                pstmt.close();
            }
            if (conn != null) {
                DBConnection.closeConnection(conn);
            }
        }
    }
}
