package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AdminDAO {

    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());

            // Convert byte array to hexadecimal string
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // Create new admin
    public boolean createAdmin(Admin admin) throws SQLException {
        String sql = "INSERT INTO admin (registerID, username, password, name, email, phone, nric, "
                + "profileImageFilePath, BOD, certificationFilePath, address) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, admin.getRegisterID());
            stmt.setString(2, admin.getUsername());

            // Hash password before storing
            String hashedPassword = hashPassword(admin.getPassword());
            stmt.setString(3, hashedPassword);

            stmt.setString(4, admin.getName());
            stmt.setString(5, admin.getEmail());
            stmt.setString(6, admin.getPhone());
            stmt.setString(7, admin.getNric());
            stmt.setString(8, admin.getProfileImageFilePath());

            // Handle Date conversion
            if (admin.getBod() != null) {
                stmt.setDate(9, admin.getBod());
            } else {
                stmt.setNull(9, Types.DATE);
            }

            stmt.setString(10, admin.getCertificationFilePath());
            stmt.setString(11, admin.getAddress());

            return stmt.executeUpdate() > 0;
        }
    }

    // Get admin by ID
    public Admin getAdminById(int adminID) throws SQLException {
        String sql = "SELECT * FROM admin WHERE adminID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, adminID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractAdminFromResultSet(rs);
            }
            return null;
        }
    }

    // Get admin by email (NEW METHOD - untuk login)
    public Admin getAdminByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM admin WHERE email = ? AND status = 'active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractAdminFromResultSet(rs);
            }
            return null;
        }
    }

    // Get admin by username (keep for other uses)
    public Admin getAdminByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM admin WHERE username = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractAdminFromResultSet(rs);
            }
            return null;
        }
    }

    // Validate login using EMAIL (UPDATED METHOD)
    public Admin validateLogin(String email, String password) throws SQLException {
        String hashedPassword = hashPassword(password);
        String sql = "SELECT * FROM admin WHERE email = ? AND password = ? AND status = 'active'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            stmt.setString(2, hashedPassword);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return extractAdminFromResultSet(rs);
            }
            return null;
        }
    }

    // Get all admins
    public List<Admin> getAllAdmins() throws SQLException {
        String sql = "SELECT * FROM admin ORDER BY name";
        List<Admin> admins = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                admins.add(extractAdminFromResultSet(rs));
            }
        }
        return admins;
    }

    // Update admin
    public boolean updateAdmin(Admin admin) throws SQLException {
        String sql = "UPDATE admin SET username = ?, name = ?, email = ?, phone = ?, nric = ?, "
                + "profileImageFilePath = ?, BOD = ?, certificationFilePath = ?, "
                + "address = ?, status = ? WHERE adminID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            // TAMBAH: username sebagai parameter pertama
            stmt.setString(1, admin.getUsername());
            stmt.setString(2, admin.getName());
            stmt.setString(3, admin.getEmail());
            stmt.setString(4, admin.getPhone());
            stmt.setString(5, admin.getNric());
            stmt.setString(6, admin.getProfileImageFilePath());

            if (admin.getBod() != null) {
                stmt.setDate(7, admin.getBod());
            } else {
                stmt.setNull(7, Types.DATE);
            }

            stmt.setString(8, admin.getCertificationFilePath());
            stmt.setString(9, admin.getAddress());
            stmt.setString(10, admin.getStatus());
            stmt.setInt(11, admin.getAdminID());

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean isUsernameExists(String username, int excludeAdminID) throws SQLException {
        String sql = "SELECT COUNT(*) FROM admin WHERE username = ? AND adminID != ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
            stmt.setInt(2, excludeAdminID);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        }
    }

    // Update password
    public boolean updatePassword(int adminID, String newPassword) throws SQLException {
        String hashedPassword = hashPassword(newPassword);
        String sql = "UPDATE admin SET password = ? WHERE adminID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, hashedPassword);
            stmt.setInt(2, adminID);

            return stmt.executeUpdate() > 0;
        }
    }

    // Helper method to extract Admin from ResultSet
    private Admin extractAdminFromResultSet(ResultSet rs) throws SQLException {
        Admin admin = new Admin();
        admin.setAdminID(rs.getInt("adminID"));
        admin.setRegisterID(rs.getInt("registerID"));
        admin.setUsername(rs.getString("username"));
        admin.setPassword(rs.getString("password"));
        admin.setName(rs.getString("name"));
        admin.setEmail(rs.getString("email"));
        admin.setPhone(rs.getString("phone"));
        admin.setNric(rs.getString("nric"));
        admin.setProfileImageFilePath(rs.getString("profileImageFilePath"));
        admin.setBod(rs.getDate("BOD"));
        admin.setCertificationFilePath(rs.getString("certificationFilePath"));
        admin.setAddress(rs.getString("address"));
        admin.setStatus(rs.getString("status"));
        admin.setDateJoined(rs.getTimestamp("dateJoined"));
        return admin;
    }

    // Update password by email (for forgot password)
    public boolean updatePasswordByEmail(String email, String newPassword) throws SQLException {
        String hashedPassword = hashPassword(newPassword);
        String sql = "UPDATE admin SET password = ? WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, hashedPassword);
            stmt.setString(2, email);

            int rows = stmt.executeUpdate();
            System.out.println("[AdminDAO] Password updated for email " + email + ": " + (rows > 0));
            return rows > 0;
        }
    }
}
