package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.ClassConfirmation;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.*;

public class ClassConfirmationDAO {

    public boolean confirmAsMainInstructor(int classId, int instructorId) {
        ClassDAO classDao = new ClassDAO();
        int instructorCount = classDao.countInstructorsForClass(classId);

        if (instructorCount >= 2) {
            return false;
        }

        if (classDao.isInstructorInClass(classId, instructorId)) {
            return false;
        }

        Class cls = classDao.getClassById(classId);
        if (cls == null || !"active".equals(cls.getClassStatus())) {
            return false;
        }

        String sql = "INSERT INTO class_confirmation (classID, instructorID, action, actionAt) "
                + "VALUES (?, ?, 'confirmed', CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean requestAsReliefInstructor(int classId, int instructorId) {
        ClassDAO classDao = new ClassDAO();
        int instructorCount = classDao.countInstructorsForClass(classId);

        if (instructorCount >= 2) {
            return false;
        }

        if (classDao.isInstructorInClass(classId, instructorId)) {
            return false;
        }

        Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
        if (classDetails == null || !classDetails.containsKey("mainInstructor")) {
            return false;
        }

        Class cls = classDao.getClassById(classId);
        if (cls == null || !"active".equals(cls.getClassStatus())) {
            return false;
        }

        String sql = "INSERT INTO class_confirmation (classID, instructorID, action, actionAt) "
                + "VALUES (?, ?, 'pending', CURRENT_TIMESTAMP)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean withdrawFromClass(int classId, int instructorId) {
        ClassConfirmation current = getLatestConfirmation(classId, instructorId);
        if (current == null) {
            return false;
        }

        String currentAction = current.getAction();

        if ("confirmed".equals(currentAction)) {
            promoteReliefToMain(classId);
        }

        String sql = "UPDATE class_confirmation SET action = 'cancelled', "
                + "cancelledAt = CURRENT_TIMESTAMP, "
                + "cancellationReason = 'Instructor withdrew' "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public void promoteReliefToMain(int classId) {
        String getReliefSql = "SELECT instructorID FROM class_confirmation "
                + "WHERE classID = ? AND action = 'pending' "
                + "ORDER BY actionAt ASC FETCH FIRST 1 ROWS ONLY";

        String updateSql = "UPDATE class_confirmation SET action = 'confirmed', "
                + "actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement getStmt = conn.prepareStatement(getReliefSql);
                PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {

            getStmt.setInt(1, classId);
            ResultSet rs = getStmt.executeQuery();

            if (rs.next()) {
                int reliefInstructorId = rs.getInt("instructorID");

                updateStmt.setInt(1, classId);
                updateStmt.setInt(2, reliefInstructorId);
                updateStmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public ClassConfirmation getLatestConfirmation(int classId, int instructorId) {
        String sql = "SELECT * FROM class_confirmation "
                + "WHERE classID = ? AND instructorID = ? "
                + "ORDER BY actionAt DESC FETCH FIRST 1 ROWS ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ClassConfirmation cc = new ClassConfirmation();
                cc.setConfirmID(rs.getInt("confirmID"));
                cc.setClassID(rs.getInt("classID"));
                cc.setInstructorID(rs.getInt("instructorID"));
                cc.setAction(rs.getString("action"));
                cc.setActionAt(rs.getTimestamp("actionAt"));
                cc.setCancellationReason(rs.getString("cancellationReason"));
                cc.setCancelledAt(rs.getTimestamp("cancelledAt"));
                return cc;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ClassConfirmation> getConfirmationsForClass(int classId) {
        List<ClassConfirmation> confirmations = new ArrayList<>();
        String sql = "SELECT cc.*, i.name FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "WHERE cc.classID = ? "
                + "ORDER BY cc.actionAt DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                ClassConfirmation cc = new ClassConfirmation();
                cc.setConfirmID(rs.getInt("confirmID"));
                cc.setClassID(rs.getInt("classID"));
                cc.setInstructorID(rs.getInt("instructorID"));
                cc.setAction(rs.getString("action"));
                cc.setActionAt(rs.getTimestamp("actionAt"));
                cc.setCancellationReason(rs.getString("cancellationReason"));
                cc.setCancelledAt(rs.getTimestamp("cancelledAt"));
                confirmations.add(cc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return confirmations;
    }

    public String getInstructorStatus(int classId, int instructorId) {
        ClassConfirmation cc = getLatestConfirmation(classId, instructorId);
        if (cc == null) {
            return null;
        }

        if ("cancelled".equals(cc.getAction())) {
            return null;
        }
        return cc.getAction();
    }

    // Tambahkan method ini di ClassConfirmationDAO.java
    public List<Map<String, Object>> getCancelledClasses() throws SQLException {
        String sql = "SELECT cc.*, i.name as instructorName, i.email as instructorEmail, "
                + "c.className, c.classType, c.classLevel, c.classDate, "
                + "c.classStartTime, c.classEndTime, c.location "
                + "FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.action = 'cancelled' "
                + "ORDER BY cc.cancelledAt DESC";

        List<Map<String, Object>> cancelledClasses = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> cancelledClass = new HashMap<>();
                cancelledClass.put("confirmID", rs.getInt("confirmID"));
                cancelledClass.put("classID", rs.getInt("classID"));
                cancelledClass.put("instructorID", rs.getInt("instructorID"));
                cancelledClass.put("instructorName", rs.getString("instructorName"));
                cancelledClass.put("instructorEmail", rs.getString("instructorEmail"));
                cancelledClass.put("className", rs.getString("className"));
                cancelledClass.put("classType", rs.getString("classType"));
                cancelledClass.put("classLevel", rs.getString("classLevel"));
                cancelledClass.put("classDate", rs.getDate("classDate"));
                cancelledClass.put("classStartTime", rs.getTime("classStartTime"));
                cancelledClass.put("classEndTime", rs.getTime("classEndTime"));
                cancelledClass.put("location", rs.getString("location"));
                cancelledClass.put("cancellationReason", rs.getString("cancellationReason"));
                cancelledClass.put("cancelledAt", rs.getTimestamp("cancelledAt"));
                cancelledClass.put("actionAt", rs.getTimestamp("actionAt"));

                cancelledClasses.add(cancelledClass);
            }
        }
        return cancelledClasses;
    }

    // METHOD BARU: Count confirmed classes sahaja
    public int countConfirmedClassesForInstructor(int instructorId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class_confirmation "
                + "WHERE instructorID = ? AND action = 'confirmed'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
            return 0;
        }
    }

    public int countClassesForInstructor(int instructorId) throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM class_confirmation "
                + "WHERE instructorID = ? AND action IN ('confirmed', 'completed')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }

    public int countCancelledClassesForInstructor(int instructorId) throws SQLException {
        String sql = "SELECT COUNT(*) as total FROM class_confirmation "
                + "WHERE instructorID = ? AND action = 'cancelled'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }

    // Tambah method ini ke dalam ClassConfirmationDAO:
    public boolean cancelInstructorFromClass(int classId, int instructorId, String reason) throws SQLException {
        String sql = "UPDATE class_confirmation SET action = 'cancelled', "
                + "cancelledAt = CURRENT_TIMESTAMP, "
                + "cancellationReason = ? "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, reason);
            stmt.setInt(2, classId);
            stmt.setInt(3, instructorId);

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean promoteReliefToConfirmed(int classId) throws SQLException {
        String sql = "UPDATE class_confirmation SET action = 'confirmed', actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND action = 'pending' "
                + "AND instructorID = (SELECT instructorID FROM class_confirmation "
                + "WHERE classID = ? AND action = 'pending' "
                + "ORDER BY actionAt ASC FETCH FIRST 1 ROWS ONLY)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, classId);

            return stmt.executeUpdate() > 0;
        }
    }

    public int countCancelledClasses() throws SQLException {
        String query = "SELECT COUNT(*) as total FROM classconfirmation WHERE confirmationStatus = 'cancelled'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("total");
            }
            return 0;
        }
    }
}
