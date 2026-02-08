package com.skylightstudio.classmanagement.dao;

import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.model.ClassConfirmation;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.sql.*;
import java.util.*;
import java.sql.Date;

public class ClassDAO {

    // Get ALL classes that should appear for an instructor
    public List<Class> getClassesForInstructor(int instructorId) {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT c.* FROM class c "
                + "WHERE c.classStatus = 'active' "
                + "AND c.classDate >= CURRENT_DATE "
                + "ORDER BY c.classDate, c.classStartTime";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Class cls = mapResultSetToClass(rs);
                classes.add(cls);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return classes;
    }

    // Get class by ID
    public Class getClassById(int classId) {
        String sql = "SELECT * FROM class WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToClass(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Count instructors for a class
    public int countInstructorsForClass(int classId) {
        String sql = "SELECT COUNT(DISTINCT instructorID) as count FROM class_confirmation "
                + "WHERE classID = ? AND action IN ('confirmed', 'pending')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Check if instructor is already in class
    public boolean isInstructorInClass(int classId, int instructorId) {
        String sql = "SELECT COUNT(*) as count FROM class_confirmation "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Check instructor's status in a class - UPDATED for Apache Derby
    public String getInstructorStatusInClass(int classId, int instructorId) {
        String sql = "SELECT action FROM class_confirmation "
                + "WHERE classID = ? AND instructorID = ? "
                + "AND action IN ('confirmed', 'pending') "
                + "ORDER BY actionAt DESC FETCH FIRST 1 ROW ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            stmt.setInt(2, instructorId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getString("action");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // Update class status
    public boolean updateClassStatus(int classId, String status) {
        String sql = "UPDATE class SET classStatus = ? WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setInt(2, classId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Get classes that need auto-cancellation (24-hour rule) - UPDATED for Apache Derby
    public List<Class> getClassesForAutoCancellation() {
        List<Class> classes = new ArrayList<>();
        String sql = "SELECT c.* FROM class c "
                + "WHERE c.classStatus = 'active' "
                + "AND (TIMESTAMP(c.classDate, c.classStartTime) < (CURRENT_TIMESTAMP + 24 HOURS)) "
                + "AND NOT EXISTS (SELECT 1 FROM class_confirmation cc "
                + "               WHERE cc.classID = c.classID AND cc.action = 'confirmed')";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Class cls = mapResultSetToClass(rs);
                classes.add(cls);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return classes;
    }

    // Get class with instructor details - UPDATED for Apache Derby
    public Map<String, Object> getClassWithInstructors(int classId) {
        Map<String, Object> result = new HashMap<>();

        // Get class details
        Class cls = getClassById(classId);
        if (cls == null) {
            return null;
        }

        result.put("class", cls);

        // Get main instructor (confirmed) - UPDATED for Apache Derby
        String mainSql = "SELECT cc.*, i.name FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "WHERE cc.classID = ? AND cc.action = 'confirmed' "
                + "ORDER BY cc.actionAt DESC FETCH FIRST 1 ROW ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(mainSql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ClassConfirmation main = new ClassConfirmation();
                main.setConfirmID(rs.getInt("confirmID"));
                main.setClassID(rs.getInt("classID"));
                main.setInstructorID(rs.getInt("instructorID"));
                main.setAction(rs.getString("action"));
                main.setActionAt(rs.getTimestamp("actionAt"));

                // Create a map for instructor details
                Map<String, Object> mainInstructor = new HashMap<>();
                mainInstructor.put("id", rs.getInt("instructorID"));
                mainInstructor.put("name", rs.getString("name"));
                mainInstructor.put("initials", getInitials(rs.getString("name")));
                result.put("mainInstructor", mainInstructor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Get relief instructor (pending) - UPDATED for Apache Derby
        String reliefSql = "SELECT cc.*, i.name FROM class_confirmation cc "
                + "JOIN instructor i ON cc.instructorID = i.instructorID "
                + "WHERE cc.classID = ? AND cc.action = 'pending' "
                + "ORDER BY cc.actionAt ASC FETCH FIRST 1 ROW ONLY";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(reliefSql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                ClassConfirmation relief = new ClassConfirmation();
                relief.setConfirmID(rs.getInt("confirmID"));
                relief.setClassID(rs.getInt("classID"));
                relief.setInstructorID(rs.getInt("instructorID"));
                relief.setAction(rs.getString("action"));
                relief.setActionAt(rs.getTimestamp("actionAt"));

                // Create a map for instructor details
                Map<String, Object> reliefInstructor = new HashMap<>();
                reliefInstructor.put("id", rs.getInt("instructorID"));
                reliefInstructor.put("name", rs.getString("name"));
                reliefInstructor.put("initials", getInitials(rs.getString("name")));
                result.put("reliefInstructor", reliefInstructor);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    // Helper method to get initials
    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "??";
        }
        String[] parts = name.split(" ");
        if (parts.length >= 2) {
            return (parts[0].charAt(0) + "" + parts[parts.length - 1].charAt(0)).toUpperCase();
        }
        return name.substring(0, Math.min(2, name.length())).toUpperCase();
    }

    // Helper method to map ResultSet to Class object
    private Class mapResultSetToClass(ResultSet rs) throws SQLException {
        Class cls = new Class();
        cls.setClassID(rs.getInt("classID"));
        cls.setClassName(rs.getString("className"));
        cls.setClassType(rs.getString("classType"));
        cls.setClassLevel(rs.getString("classLevel"));
        cls.setClassDate(rs.getDate("classDate"));
        cls.setClassStartTime(rs.getTime("classStartTime"));
        cls.setClassEndTime(rs.getTime("classEndTime"));
        cls.setNoOfParticipant(rs.getInt("noOfParticipant"));
        cls.setLocation(rs.getString("location"));
        cls.setDescription(rs.getString("description"));
        cls.setClassStatus(rs.getString("classStatus"));
        cls.setQrcodeFilePath(rs.getString("qrcodeFilePath"));
        cls.setAdminID(rs.getInt("adminID"));
        return cls;
    }

    // Check if class can be deleted (no instructors assigned and more than 24 hours away)
    public boolean canDeleteClass(int classId) {
        String sql = "SELECT c.*, "
                + "(SELECT COUNT(*) FROM class_confirmation WHERE classID = c.classID AND action IN ('confirmed', 'pending')) as instructorCount "
                + "FROM class c WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                int instructorCount = rs.getInt("instructorCount");

                // Get the date and time from database
                java.sql.Date sqlClassDate = rs.getDate("classDate");
                java.sql.Time sqlClassTime = rs.getTime("classStartTime");

                // Check if class has instructors
                if (instructorCount > 0) {
                    return false;
                }

                // Check if class is more than 24 hours away
                java.util.Date now = new java.util.Date();

                // Create a java.util.Date object from sql.Date and sql.Time
                java.util.Date classDateTime = new java.util.Date(
                        sqlClassDate.getTime() + sqlClassTime.getTime()
                );

                long hoursDifference = (classDateTime.getTime() - now.getTime()) / (1000 * 60 * 60);

                return hoursDifference > 24;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Delete class
    public boolean deleteClass(int classId) {
        String sql = "DELETE FROM class WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, classId);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Map<String, Object>> getAllClassesForAdmin(String statusFilter, String dateFilter,
            String typeFilter, String levelFilter) throws SQLException {
        List<Map<String, Object>> classes = new ArrayList<>();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT ");
        sql.append("c.classID, c.className, c.classType, c.classLevel, ");
        sql.append("c.classDate, c.classStartTime, c.classEndTime, ");
        sql.append("c.noOfParticipant, c.location, c.description, ");
        sql.append("c.classStatus, c.qrcodeFilePath, c.adminID, ");
        sql.append("confirmed_i.name as confirmedInstructor, ");
        sql.append("confirmed_i.instructorID as confirmedInstructorID, ");
        sql.append("pending_i.name as pendingInstructor, ");
        sql.append("pending_i.instructorID as pendingInstructorID ");
        sql.append("FROM class c ");
        sql.append("LEFT JOIN class_confirmation confirmed_cc ON c.classID = confirmed_cc.classID AND confirmed_cc.action = 'confirmed' ");
        sql.append("LEFT JOIN instructor confirmed_i ON confirmed_cc.instructorID = confirmed_i.instructorID ");
        sql.append("LEFT JOIN class_confirmation pending_cc ON c.classID = pending_cc.classID AND pending_cc.action = 'pending' ");
        sql.append("LEFT JOIN instructor pending_i ON pending_cc.instructorID = pending_i.instructorID ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.isEmpty() && !"auto-inactive".equals(statusFilter)) {
            sql.append("AND c.classStatus = ? ");
            params.add(statusFilter);
        }

        if (dateFilter != null && !dateFilter.isEmpty()) {
            sql.append("AND c.classDate = ? ");
            params.add(Date.valueOf(dateFilter));
        }

        if (typeFilter != null && !typeFilter.isEmpty()) {
            sql.append("AND c.classType = ? ");
            params.add(typeFilter);
        }

        if (levelFilter != null && !levelFilter.isEmpty()) {
            sql.append("AND c.classLevel = ? ");
            params.add(levelFilter);
        }

        sql.append("ORDER BY c.classDate, c.classStartTime");

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    stmt.setString(i + 1, (String) param);
                } else if (param instanceof Date) {
                    stmt.setDate(i + 1, (Date) param);
                }
            }

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> classData = new HashMap<>();
                classData.put("classID", rs.getInt("classID"));
                classData.put("className", rs.getString("className"));
                classData.put("classType", rs.getString("classType"));
                classData.put("classLevel", rs.getString("classLevel"));
                classData.put("classDate", rs.getDate("classDate"));
                classData.put("classStartTime", rs.getTime("classStartTime"));
                classData.put("classEndTime", rs.getTime("classEndTime"));
                classData.put("noOfParticipant", rs.getInt("noOfParticipant"));
                classData.put("location", rs.getString("location"));
                classData.put("description", rs.getString("description"));
                classData.put("classStatus", rs.getString("classStatus"));
                classData.put("qrcodeFilePath", rs.getString("qrcodeFilePath"));
                classData.put("adminID", rs.getInt("adminID"));
                classData.put("confirmedInstructor", rs.getString("confirmedInstructor"));
                classData.put("confirmedInstructorID", rs.getInt("confirmedInstructorID"));
                classData.put("pendingInstructor", rs.getString("pendingInstructor"));
                classData.put("pendingInstructorID", rs.getInt("pendingInstructorID"));

                classes.add(classData);
            }
        }

        return classes;
    }

    // Create new class
    public int createClass(Class cls) throws SQLException {
        String sql = "INSERT INTO class (className, classType, classLevel, classDate, classStartTime, "
                + "classEndTime, noOfParticipant, location, description, classStatus, adminID) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, cls.getClassName());
            stmt.setString(2, cls.getClassType());
            stmt.setString(3, cls.getClassLevel());
            stmt.setDate(4, cls.getClassDate());
            stmt.setTime(5, cls.getClassStartTime());
            stmt.setTime(6, cls.getClassEndTime());
            stmt.setInt(7, cls.getNoOfParticipant());
            stmt.setString(8, cls.getLocation());
            stmt.setString(9, cls.getDescription());
            stmt.setString(10, cls.getClassStatus());
            stmt.setInt(11, cls.getAdminID());

            stmt.executeUpdate();

            ResultSet rs = stmt.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }

        return -1;
    }

    // Update class
    public boolean updateClass(Class cls) throws SQLException {
        String sql = "UPDATE class SET className = ?, classType = ?, classLevel = ?, "
                + "classDate = ?, classStartTime = ?, classEndTime = ?, "
                + "noOfParticipant = ?, location = ?, description = ?, classStatus = ? "
                + "WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, cls.getClassName());
            stmt.setString(2, cls.getClassType());
            stmt.setString(3, cls.getClassLevel());
            stmt.setDate(4, cls.getClassDate());
            stmt.setTime(5, cls.getClassStartTime());
            stmt.setTime(6, cls.getClassEndTime());
            stmt.setInt(7, cls.getNoOfParticipant());
            stmt.setString(8, cls.getLocation());
            stmt.setString(9, cls.getDescription());
            stmt.setString(10, cls.getClassStatus());
            stmt.setInt(11, cls.getClassID());

            return stmt.executeUpdate() > 0;
        }
    }

    // Update QR code path
    public boolean updateQRCodePath(int classId, String qrCodePath) throws SQLException {
        String sql = "UPDATE class SET qrcodeFilePath = ? WHERE classID = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, qrCodePath);
            stmt.setInt(2, classId);

            return stmt.executeUpdate() > 0;
        }
    }

    // Tambah method ini dalam ClassDAO.java
    public List<Map<String, Object>> getTodayClassesForInstructor(int instructorId) throws SQLException {
        List<Map<String, Object>> classes = new ArrayList<>();
        String sql = "SELECT c.*, cc.action as status FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? AND c.classStatus = 'active' "
                + "AND c.classDate = CURRENT_DATE "
                + "AND cc.action IN ('confirmed', 'pending') "
                + "ORDER BY c.classStartTime";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> classData = new HashMap<>();
                classData.put("classID", rs.getInt("classID"));
                classData.put("className", rs.getString("className"));
                classData.put("classType", rs.getString("classType"));
                classData.put("classDate", rs.getDate("classDate"));
                classData.put("classStartTime", rs.getTime("classStartTime"));
                classData.put("classEndTime", rs.getTime("classEndTime"));
                classData.put("location", rs.getString("location"));
                classData.put("qrcodeFilePath", rs.getString("qrcodeFilePath"));
                classData.put("status", rs.getString("status"));
                classes.add(classData);
            }
        }
        return classes;
    }

    public List<Map<String, Object>> getWeeklyClassesForInstructor(int instructorId, Date startDate, Date endDate) throws SQLException {
        List<Map<String, Object>> classes = new ArrayList<>();
        String sql = "SELECT c.*, cc.action as status FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? AND c.classStatus = 'active' "
                + "AND c.classDate BETWEEN ? AND ? "
                + "AND cc.action IN ('confirmed', 'pending') "
                + "ORDER BY c.classDate, c.classStartTime";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            stmt.setDate(2, startDate);
            stmt.setDate(3, endDate);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> classData = new HashMap<>();
                classData.put("classID", rs.getInt("classID"));
                classData.put("className", rs.getString("className"));
                classData.put("classType", rs.getString("classType"));
                classData.put("classDate", rs.getDate("classDate"));
                classData.put("classStartTime", rs.getTime("classStartTime"));
                classData.put("classEndTime", rs.getTime("classEndTime"));
                classData.put("status", rs.getString("status"));
                classes.add(classData);
            }
        }
        return classes;
    }

    public int getMonthlyClassCount(int instructorId, int month, int year) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? AND c.classStatus = 'active' "
                + "AND MONTH(c.classDate) = ? AND YEAR(c.classDate) = ? "
                + "AND cc.action = 'confirmed'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            stmt.setInt(2, month);
            stmt.setInt(3, year);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    public Map<String, Integer> getWeeklyStats(int instructorId, Date startDate, Date endDate) throws SQLException {
        Map<String, Integer> stats = new HashMap<>();

        String confirmedSql = "SELECT COUNT(DISTINCT c.classID) as count FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? AND c.classStatus = 'active' "
                + "AND c.classDate BETWEEN ? AND ? "
                + "AND cc.action = 'confirmed'";

        String pendingSql = "SELECT COUNT(DISTINCT c.classID) as count FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? AND c.classStatus = 'active' "
                + "AND c.classDate BETWEEN ? AND ? "
                + "AND cc.action = 'pending'";

        try (Connection conn = DBConnection.getConnection()) {
            // Count confirmed classes
            try (PreparedStatement stmt = conn.prepareStatement(confirmedSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, startDate);
                stmt.setDate(3, endDate);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    stats.put("confirmed", rs.getInt("count"));
                }
            }

            // Count pending relief
            try (PreparedStatement stmt = conn.prepareStatement(pendingSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, startDate);
                stmt.setDate(3, endDate);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    stats.put("pending", rs.getInt("count"));
                }
            }
        }

        return stats;
    }

    /**
     * Get notifications for a specific instructor
     */
    public List<Map<String, Object>> getNotificationsForInstructor(int instructorId) throws SQLException {
        List<Map<String, Object>> notifications = new ArrayList<>();

        // Calculate dates in Java for Apache Derby compatibility
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        java.sql.Date tomorrow = new java.sql.Date(System.currentTimeMillis() + (24 * 60 * 60 * 1000L));
        java.sql.Date dayAfterTomorrow = new java.sql.Date(System.currentTimeMillis() + (2 * 24 * 60 * 60 * 1000L));
        java.sql.Date thirtyDaysAgo = new java.sql.Date(System.currentTimeMillis() - (30L * 24 * 60 * 60 * 1000L));

        // 1. New Class Available - Active classes with no confirmed instructor
        String newClassSql = "SELECT c.* FROM class c "
                + "WHERE c.classStatus = 'active' "
                + "AND c.classDate >= ? "
                + "AND NOT EXISTS (SELECT 1 FROM class_confirmation cc "
                + "                WHERE cc.classID = c.classID AND cc.action = 'confirmed') "
                + "ORDER BY c.classDate, c.classStartTime";

        // 2. Class Tomorrow - Classes tomorrow where instructor is confirmed
        String tomorrowSql = "SELECT c.* FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE c.classStatus = 'active' "
                + "AND cc.instructorID = ? "
                + "AND cc.action = 'confirmed' "
                + "AND c.classDate = ? "
                + "ORDER BY c.classDate, c.classStartTime";

        // 3. Class Reminder - Classes day after tomorrow where instructor is confirmed
        String reminderSql = "SELECT c.* FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE c.classStatus = 'active' "
                + "AND cc.instructorID = ? "
                + "AND cc.action = 'confirmed' "
                + "AND c.classDate = ? "
                + "ORDER BY c.classDate, c.classStartTime";

        // 4. Class Cancelled - Classes where instructor was involved and now cancelled
        String cancelledSql = "SELECT c.*, cc.cancelledAt, cc.cancellationReason "
                + "FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? "
                + "AND cc.action = 'cancelled' "
                + "AND c.classDate >= ? "
                + "ORDER BY cc.cancelledAt DESC";

        // 5. Waitlist Update - Instructor is pending (relief position)
        String waitlistSql = "SELECT c.*, cc.actionAt as waitlistTime "
                + "FROM class c "
                + "JOIN class_confirmation cc ON c.classID = cc.classID "
                + "WHERE cc.instructorID = ? "
                + "AND cc.action = 'pending' "
                + "AND c.classDate >= ? "
                + "ORDER BY cc.actionAt DESC";

        try (Connection conn = DBConnection.getConnection()) {

            System.out.println("[ClassDAO] Getting notifications for instructor ID: " + instructorId);
            System.out.println("[ClassDAO] Today: " + today);
            System.out.println("[ClassDAO] Tomorrow: " + tomorrow);
            System.out.println("[ClassDAO] Day after tomorrow: " + dayAfterTomorrow);
            System.out.println("[ClassDAO] 30 days ago: " + thirtyDaysAgo);

            // New Class Available
            try (PreparedStatement stmt = conn.prepareStatement(newClassSql)) {
                stmt.setDate(1, today);
                ResultSet rs = stmt.executeQuery();
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> notif = new HashMap<>();
                    notif.put("type", "new_class");
                    notif.put("class", mapResultSetToClass(rs));
                    notif.put("timestamp", new Timestamp(System.currentTimeMillis()));
                    notif.put("message", "New class available: " + rs.getString("className"));
                    notifications.add(notif);
                }
                System.out.println("[ClassDAO] Found " + count + " new classes available");
            }

            // Class Tomorrow
            try (PreparedStatement stmt = conn.prepareStatement(tomorrowSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, tomorrow);
                ResultSet rs = stmt.executeQuery();
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> notif = new HashMap<>();
                    notif.put("type", "tomorrow");
                    notif.put("class", mapResultSetToClass(rs));
                    notif.put("timestamp", new Timestamp(System.currentTimeMillis()));
                    notif.put("message", "You have a class tomorrow: " + rs.getString("className"));
                    notifications.add(notif);
                }
                System.out.println("[ClassDAO] Found " + count + " classes tomorrow");
            }

            // Class Reminder
            try (PreparedStatement stmt = conn.prepareStatement(reminderSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, dayAfterTomorrow);
                ResultSet rs = stmt.executeQuery();
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> notif = new HashMap<>();
                    notif.put("type", "reminder");
                    notif.put("class", mapResultSetToClass(rs));
                    notif.put("timestamp", new Timestamp(System.currentTimeMillis()));
                    notif.put("message", "Class reminder: " + rs.getString("className"));
                    notifications.add(notif);
                }
                System.out.println("[ClassDAO] Found " + count + " class reminders");
            }

            // Class Cancelled
            try (PreparedStatement stmt = conn.prepareStatement(cancelledSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, thirtyDaysAgo);
                ResultSet rs = stmt.executeQuery();
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> notif = new HashMap<>();
                    notif.put("type", "cancelled");
                    Class cls = mapResultSetToClass(rs);
                    notif.put("class", cls);
                    notif.put("timestamp", rs.getTimestamp("cancelledAt"));
                    notif.put("message", "Class cancelled: " + cls.getClassName());
                    notif.put("reason", rs.getString("cancellationReason"));
                    notifications.add(notif);
                }
                System.out.println("[ClassDAO] Found " + count + " cancelled classes");
            }

            // Waitlist Update
            try (PreparedStatement stmt = conn.prepareStatement(waitlistSql)) {
                stmt.setInt(1, instructorId);
                stmt.setDate(2, today);
                ResultSet rs = stmt.executeQuery();
                int count = 0;
                while (rs.next()) {
                    count++;
                    Map<String, Object> notif = new HashMap<>();
                    notif.put("type", "waitlist");
                    notif.put("class", mapResultSetToClass(rs));
                    notif.put("timestamp", rs.getTimestamp("waitlistTime"));
                    notif.put("message", "You're on waitlist for: " + rs.getString("className"));
                    notifications.add(notif);
                }
                System.out.println("[ClassDAO] Found " + count + " waitlist updates");
            }

        } catch (SQLException e) {
            System.err.println("[ClassDAO ERROR] SQL Exception: " + e.getMessage());
            System.err.println("[ClassDAO ERROR] SQL State: " + e.getSQLState());
            e.printStackTrace();
            throw e;
        }

        System.out.println("[ClassDAO] Total notifications found: " + notifications.size());

        // Sort all notifications by timestamp (newest first)
        if (!notifications.isEmpty()) {
            notifications.sort(new java.util.Comparator<Map<String, Object>>() {
                @Override
                public int compare(Map<String, Object> a, Map<String, Object> b) {
                    Timestamp ts1 = (Timestamp) b.get("timestamp");
                    Timestamp ts2 = (Timestamp) a.get("timestamp");
                    return ts1.compareTo(ts2);
                }
            });
        }

        return notifications;
    }

    // Get active classes count this month
    public int getActiveClassesThisMonthCount() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class "
                + "WHERE classStatus = 'active' "
                + "AND MONTH(classDate) = MONTH(CURRENT_DATE) "
                + "AND YEAR(classDate) = YEAR(CURRENT_DATE)";

        System.out.println("[ClassDAO] Executing SQL: " + sql);

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("[ClassDAO] Active classes this month count: " + count);
                return count;
            }
        }
        return 0;
    }

    // Get today's classes count
    public int getTodaysClassesCount() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class "
                + "WHERE classStatus = 'active' "
                + "AND classDate = CURRENT_DATE";

        System.out.println("[ClassDAO] Executing SQL: " + sql);

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("[ClassDAO] Today's classes count: " + count);
                return count;
            }
        }
        return 0;
    }

    // Get monthly classes for last 6 months
    public Map<String, Integer> getMonthlyClassesLast6Months() throws SQLException {
        Map<String, Integer> monthlyData = new HashMap<String, Integer>();

        // Untuk Derby, kita perlu approach yang berbeza
        String sql = "SELECT "
                + "CASE MONTH(classDate) "
                + "  WHEN 1 THEN 'January' "
                + "  WHEN 2 THEN 'February' "
                + "  WHEN 3 THEN 'March' "
                + "  WHEN 4 THEN 'April' "
                + "  WHEN 5 THEN 'May' "
                + "  WHEN 6 THEN 'June' "
                + "  WHEN 7 THEN 'July' "
                + "  WHEN 8 THEN 'August' "
                + "  WHEN 9 THEN 'September' "
                + "  WHEN 10 THEN 'October' "
                + "  WHEN 11 THEN 'November' "
                + "  WHEN 12 THEN 'December' "
                + "END as month, "
                + "COUNT(*) as count "
                + "FROM class "
                + "WHERE classStatus = 'active' "
                + "AND classDate >= (CURRENT_DATE - 180 DAYS) "
                + "GROUP BY MONTH(classDate) "
                + "ORDER BY MONTH(classDate)";

        System.out.println("[ClassDAO] Executing SQL: " + sql);

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String month = rs.getString("month");
                int count = rs.getInt("count");
                System.out.println("[ClassDAO] Month: " + month + ", Count: " + count);
                monthlyData.put(month, count);
            }
        }

        // Jika tiada data, return default data untuk testing
        if (monthlyData.isEmpty()) {
            System.out.println("[ClassDAO] No monthly data found, returning test data");
            monthlyData.put("January", 10);
            monthlyData.put("February", 15);
            monthlyData.put("March", 20);
            monthlyData.put("April", 18);
            monthlyData.put("May", 25);
            monthlyData.put("June", 22);
        }

        return monthlyData;
    }

    // Get class type distribution for current month
    public Map<String, Integer> getClassTypeDistributionThisMonth() throws SQLException {
        Map<String, Integer> distribution = new HashMap<>();

        String sql = "SELECT classType, COUNT(*) as count "
                + "FROM class "
                + "WHERE classStatus = 'active' "
                + "AND MONTH(classDate) = MONTH(CURRENT_DATE) "
                + "AND YEAR(classDate) = YEAR(CURRENT_DATE) "
                + "GROUP BY classType";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                String classType = rs.getString("classType");
                int count = rs.getInt("count");

                if (classType == null || classType.isEmpty()) {
                    classType = "Other";
                }

                distribution.put(classType, count);
            }
        }
        return distribution;
    }

    // Add these methods to existing ClassDAO class:
    public int getMonthlyClassCount(int year, int month) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class WHERE classStatus = 'active' "
                + "AND EXTRACT(YEAR FROM classDate) = ? "
                + "AND EXTRACT(MONTH FROM classDate) = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, year);
            stmt.setInt(2, month);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    public int getTodayClassCount() throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM class WHERE classStatus = 'active' AND classDate = CURRENT_DATE";

        try (Connection conn = DBConnection.getConnection();
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }

    public Map<String, Integer> getClassTypeDistribution(Date startDate, Date endDate) throws SQLException {
        Map<String, Integer> distribution = new HashMap<>();
        String sql = "SELECT classType, COUNT(*) as count FROM class WHERE classStatus = 'active' "
                + "AND classDate BETWEEN ? AND ? GROUP BY classType";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setDate(1, startDate);
            stmt.setDate(2, endDate);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                String type = rs.getString("classType");
                if (type == null) {
                    type = "Other";
                }
                distribution.put(type, rs.getInt("count"));
            }
        }
        return distribution;
    }

    public int countNotificationsForInstructor(Integer instructorId) throws SQLException {
        if (instructorId == null) {
            return 0;
        }

        List<Map<String, Object>> notifications = getNotificationsForInstructor(instructorId);
        return notifications.size();
    }
}
