package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Registration;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class RegistrationDAO {

    // Create new registration record
    public int createRegistration(String userType, String adminMessage) throws SQLException {
        String sql = "INSERT INTO registration (userType, status, adminMessage) VALUES (?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, userType);

            // Auto-approve admin, pending for instructor
            String status = userType.equalsIgnoreCase("admin") ? "approved" : "pending";
            stmt.setString(2, status);

            stmt.setString(3, adminMessage);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
            return -1;
        }
    }

    // Get registration by ID
    public Registration getRegistrationById(int registerID) throws SQLException {
        String sql = "SELECT * FROM registration WHERE registerID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, registerID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Registration registration = new Registration();
                registration.setRegisterID(rs.getInt("registerID"));
                registration.setUserType(rs.getString("userType"));
                registration.setStatus(rs.getString("status"));
                registration.setRegisterDate(rs.getTimestamp("registerDate"));
                registration.setAdminMessage(rs.getString("adminMessage"));
                return registration;
            }
            return null;
        }
    }

    // Update registration status
    public boolean updateRegistrationStatus(int registerID, String status, String adminMessage) throws SQLException {
        String sql = "UPDATE registration SET status = ?, adminMessage = ? WHERE registerID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, adminMessage);
            stmt.setInt(3, registerID);

            return stmt.executeUpdate() > 0;
        }
    }

    // Get all pending registrations
    public List<Registration> getPendingRegistrations() throws SQLException {
        String sql = "SELECT * FROM registration WHERE status = 'pending' ORDER BY registerDate DESC";
        List<Registration> registrations = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Registration registration = new Registration();
                registration.setRegisterID(rs.getInt("registerID"));
                registration.setUserType(rs.getString("userType"));
                registration.setStatus(rs.getString("status"));
                registration.setRegisterDate(rs.getTimestamp("registerDate"));
                registration.setAdminMessage(rs.getString("adminMessage"));
                registrations.add(registration);
            }
        }
        return registrations;
    }

    // ========== FIXED: Check if email already exists (EXCLUDE REJECTED REGISTRATIONS) ==========
    public boolean isEmailRegistered(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE (a.email = ? OR i.email = ?) "
                + "AND r.status != 'rejected'";  // EXCLUDE rejected registrations

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // ========== FIXED: Check if username already exists (EXCLUDE REJECTED REGISTRATIONS) ==========
    public boolean isUsernameTaken(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE (a.username = ? OR i.username = ?) "
                + "AND r.status != 'rejected'";  // EXCLUDE rejected registrations

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setString(2, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // ========== FIXED: Check if NRIC already exists (EXCLUDE REJECTED REGISTRATIONS) ==========
    public boolean isNricTaken(String nric) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "LEFT JOIN admin a ON r.registerID = a.registerID "
                + "LEFT JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE (a.nric = ? OR i.nric = ?) "
                + "AND r.status != 'rejected'";  // EXCLUDE rejected registrations

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, nric);
            stmt.setString(2, nric);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // ========== NEW METHOD: Get all instructor registrations with instructor details ==========
    public List<Map<String, Object>> getAllInstructorRegistrations() throws SQLException {
        System.out.println("[DEBUG] RegistrationDAO.getAllInstructorRegistrations() called");

        // ✅ ADD: i.dateJoined to the SELECT statement
        String sql = "SELECT r.registerID, r.status as registrationStatus, r.registerDate, r.adminMessage, "
                + "i.instructorID, i.username, i.name, i.email, i.phone, i.nric, i.profileImageFilePath, "
                + "i.BOD, i.certificationFilePath, i.yearOfExperience, i.address, i.status as instructorStatus, "
                + "i.dateJoined, " // ✅ THIS WAS MISSING!
                + "i.reviewedBy, i.reviewedAt "
                + "FROM registration r "
                + "INNER JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE r.userType = 'instructor' "
                + "ORDER BY r.registerDate DESC";

        System.out.println("[DEBUG] SQL: " + sql);

        List<Map<String, Object>> result = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            System.out.println("[DEBUG] Connection successful, executing query");

            int count = 0;
            while (rs.next()) {
                count++;
                Map<String, Object> registration = new HashMap<>();

                // Registration details
                registration.put("registerID", rs.getInt("registerID"));
                registration.put("registrationStatus", rs.getString("registrationStatus"));
                registration.put("registerDate", rs.getTimestamp("registerDate"));
                registration.put("adminMessage", rs.getString("adminMessage"));

                // Instructor details
                registration.put("id", rs.getInt("instructorID"));
                registration.put("instructorID", rs.getInt("instructorID"));
                registration.put("username", rs.getString("username"));
                registration.put("name", rs.getString("name"));
                registration.put("email", rs.getString("email"));
                registration.put("phone", rs.getString("phone"));
                registration.put("nric", rs.getString("nric"));
                registration.put("profileImageFilePath", rs.getString("profileImageFilePath"));
                registration.put("bod", rs.getDate("BOD"));
                registration.put("certificationFilePath", rs.getString("certificationFilePath"));
                registration.put("yearOfExperience", rs.getInt("yearOfExperience"));
                registration.put("address", rs.getString("address"));
                registration.put("instructorStatus", rs.getString("instructorStatus"));

                // ✅ ADD: dateJoined to the map
                registration.put("dateJoined", rs.getTimestamp("dateJoined"));

                registration.put("reviewedBy", rs.getInt("reviewedBy"));
                registration.put("reviewedAt", rs.getTimestamp("reviewedAt"));
                registration.put("status", rs.getString("registrationStatus"));

                result.add(registration);
            }

            System.out.println("[DEBUG] Found " + count + " registrations");

        } catch (SQLException e) {
            System.err.println("[ERROR] SQLException in getAllInstructorRegistrations: " + e.getMessage());
            throw e;
        }
        return result;
    }

    // ========== NEW METHOD: Update both registration and instructor status ==========
    public boolean updateRegistrationAndInstructorStatus(int registerID, String registrationStatus,
            String adminMessage, int instructorID, String instructorStatus, int reviewedBy) throws SQLException {

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Update registration
            String sql1 = "UPDATE registration SET status = ?, adminMessage = ? WHERE registerID = ?";
            try (PreparedStatement stmt1 = conn.prepareStatement(sql1)) {
                stmt1.setString(1, registrationStatus);
                stmt1.setString(2, adminMessage);
                stmt1.setInt(3, registerID);
                stmt1.executeUpdate();
            }

            // Update instructor
            String sql2 = "UPDATE instructor SET status = ?, reviewedBy = ?, reviewedAt = CURRENT_TIMESTAMP WHERE instructorID = ?";
            try (PreparedStatement stmt2 = conn.prepareStatement(sql2)) {
                stmt2.setString(1, instructorStatus);
                stmt2.setInt(2, reviewedBy);
                stmt2.setInt(3, instructorID);
                stmt2.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // ========== NEW METHOD: Check for any existing registration (approved or pending) ==========
    public boolean hasExistingRegistration(String email, String username, String nric) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE r.status IN ('approved', 'pending') "
                + "AND (i.email = ? OR i.username = ? OR i.nric = ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, username);
            stmt.setString(3, nric);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // ========== NEW METHOD: Check if specific instructor is rejected ==========
    public boolean isInstructorRejected(int instructorID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration r "
                + "JOIN instructor i ON r.registerID = i.registerID "
                + "WHERE i.instructorID = ? AND r.status = 'rejected'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    public int countPendingRegistrations() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM registration WHERE status = 'pending' AND userType = 'instructor'";

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

}
