package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.dao.ClassConfirmationDAO;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.SessionUtil;
import com.skylightstudio.classmanagement.util.QRCodeUtility;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.sql.Date;

@WebServlet(name = "ClassManagementServlet", urlPatterns = {"/ClassManagementServlet"})
public class ClassManagementServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(ClassManagementServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        // Check admin access
        if (!SessionUtil.checkAdminAccess(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Admin access required\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("getClasses".equals(action)) {
                getClasses(request, response);
            } else if ("getClass".equals(action)) {
                getClassById(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in doGet: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        // Check admin access
        if (!SessionUtil.checkAdminAccess(session)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"success\": false, \"message\": \"Admin access required\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("addClass".equals(action)) {
                addClass(request, response);
            } else if ("updateClass".equals(action)) {
                updateClass(request, response);
            } else if ("deleteClass".equals(action)) {
                deleteClass(request, response);
            } else if ("emergencyWithdraw".equals(action)) {
                emergencyWithdraw(request, response);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in doPost: " + e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }

    // ========== GET CLASSES WITH FILTERS ==========
    private void getClasses(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        PrintWriter out = response.getWriter();

        // Get filter parameters
        String statusFilter = request.getParameter("status");
        String dateFilter = request.getParameter("date");
        String typeFilter = request.getParameter("type");
        String levelFilter = request.getParameter("level");

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();

            // Build dynamic SQL query for Apache Derby
            StringBuilder sql = new StringBuilder();
            sql.append("SELECT ");
            sql.append("c.classID, c.className, c.classType, c.classLevel, ");
            sql.append("c.classDate, c.classStartTime, c.classEndTime, ");
            sql.append("c.noOfParticipant, c.location, c.description, ");
            sql.append("c.classStatus, c.qrcodeFilePath, c.adminID, ");

            // Use subqueries for instructors (Apache Derby syntax)
            sql.append("(SELECT i.name FROM class_confirmation cc ");
            sql.append("JOIN instructor i ON cc.instructorID = i.instructorID ");
            sql.append("WHERE cc.classID = c.classID AND cc.action = 'confirmed' ");
            sql.append("ORDER BY cc.actionAt DESC ");
            sql.append("FETCH FIRST 1 ROW ONLY) as confirmedInstructor, ");

            sql.append("(SELECT i.instructorID FROM class_confirmation cc ");
            sql.append("JOIN instructor i ON cc.instructorID = i.instructorID ");
            sql.append("WHERE cc.classID = c.classID AND cc.action = 'confirmed' ");
            sql.append("ORDER BY cc.actionAt DESC ");
            sql.append("FETCH FIRST 1 ROW ONLY) as confirmedInstructorID, ");

            sql.append("(SELECT i.name FROM class_confirmation cc ");
            sql.append("JOIN instructor i ON cc.instructorID = i.instructorID ");
            sql.append("WHERE cc.classID = c.classID AND cc.action = 'pending' ");
            sql.append("ORDER BY cc.actionAt ASC ");
            sql.append("FETCH FIRST 1 ROW ONLY) as pendingInstructor, ");

            sql.append("(SELECT i.instructorID FROM class_confirmation cc ");
            sql.append("JOIN instructor i ON cc.instructorID = i.instructorID ");
            sql.append("WHERE cc.classID = c.classID AND cc.action = 'pending' ");
            sql.append("ORDER BY cc.actionAt ASC ");
            sql.append("FETCH FIRST 1 ROW ONLY) as pendingInstructorID ");

            sql.append("FROM class c ");
            sql.append("WHERE 1=1 ");

            List<Object> params = new ArrayList<>();

            // Apply filters
            if (statusFilter != null && !statusFilter.isEmpty()) {
                if ("auto-inactive".equals(statusFilter)) {
                    sql.append("AND c.classStatus = 'active' ");
                    sql.append("AND NOT EXISTS (SELECT 1 FROM class_confirmation cc2 ");
                    sql.append("WHERE cc2.classID = c.classID AND cc2.action = 'confirmed') ");
                    // Apache Derby: Use scalar function for time addition
                    sql.append("AND ((TIMESTAMP(c.classDate, c.classStartTime)) < (CURRENT_TIMESTAMP + 24 HOURS)) ");
                } else {
                    sql.append("AND c.classStatus = ? ");
                    params.add(statusFilter);
                }
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

            sql.append("ORDER BY c.classDate DESC, c.classStartTime DESC");

            logger.info("Executing SQL: " + sql.toString());

            stmt = conn.prepareStatement(sql.toString());

            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    stmt.setString(i + 1, (String) param);
                } else if (param instanceof Date) {
                    stmt.setDate(i + 1, (Date) param);
                }
            }

            rs = stmt.executeQuery();

            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"data\": [");

            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
            boolean first = true;
            int count = 0;

            while (rs.next()) {
                if (!first) {
                    json.append(",");
                }
                first = false;
                count++;

                // Calculate hours remaining
                Date classDate = rs.getDate("classDate");
                Time startTime = rs.getTime("classStartTime");
                long classDateTime = classDate.getTime() + startTime.getTime();
                long now = System.currentTimeMillis();
                long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

                // Determine if auto-inactive
                boolean isAutoInactive = false;
                if ("active".equals(rs.getString("classStatus"))
                        && rs.getString("confirmedInstructor") == null
                        && hoursRemaining < 24 && hoursRemaining >= 0) {
                    isAutoInactive = true;
                }

                json.append("{");
                json.append("\"classID\": ").append(rs.getInt("classID")).append(",");
                json.append("\"className\": \"").append(escapeJson(rs.getString("className"))).append("\",");
                json.append("\"classType\": \"").append(escapeJson(rs.getString("classType"))).append("\",");
                json.append("\"classLevel\": \"").append(escapeJson(rs.getString("classLevel"))).append("\",");
                json.append("\"classDate\": \"").append(dateFormat.format(classDate)).append("\",");
                json.append("\"classStartTime\": \"").append(timeFormat.format(startTime)).append("\",");
                json.append("\"classEndTime\": \"").append(timeFormat.format(rs.getTime("classEndTime"))).append("\",");
                json.append("\"noOfParticipant\": ").append(rs.getInt("noOfParticipant")).append(",");
                json.append("\"location\": \"").append(escapeJson(rs.getString("location"))).append("\",");
                json.append("\"description\": \"").append(escapeJson(rs.getString("description"))).append("\",");
                json.append("\"classStatus\": \"").append(rs.getString("classStatus")).append("\",");
                json.append("\"qrcode\": \"").append(rs.getString("qrcodeFilePath") != null
                        ? escapeJson(rs.getString("qrcodeFilePath")) : QRCodeUtility.getDummyQRPath()).append("\",");
                json.append("\"adminID\": ").append(rs.getInt("adminID")).append(",");
                json.append("\"confirmedInstructor\": \"").append(
                        rs.getString("confirmedInstructor") != null
                        ? escapeJson(rs.getString("confirmedInstructor")) : "N/A").append("\",");

                Object confirmedIdObj = rs.getObject("confirmedInstructorID");
                json.append("\"confirmedInstructorID\": ").append(
                        confirmedIdObj != null ? rs.getInt("confirmedInstructorID") : 0).append(",");

                json.append("\"pendingInstructor\": \"").append(
                        rs.getString("pendingInstructor") != null
                        ? escapeJson(rs.getString("pendingInstructor")) : "").append("\",");

                Object pendingIdObj = rs.getObject("pendingInstructorID");
                json.append("\"pendingInstructorID\": ").append(
                        pendingIdObj != null ? rs.getInt("pendingInstructorID") : 0).append(",");

                json.append("\"hasReliefInstructor\": ").append(
                        rs.getString("pendingInstructor") != null).append(",");
                json.append("\"isAutoInactive\": ").append(isAutoInactive);
                json.append("}");
            }

            json.append("], \"count\": ").append(count).append("}");

            logger.info("Returning " + count + " classes");
            out.print(json.toString());

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in getClasses: " + e.getMessage(), e);
            out.print("{\"success\": false, \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
        }
    }

    // ========== GET SINGLE CLASS BY ID ==========
    private void getClassById(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String classIdStr = request.getParameter("classId");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Class ID required\"}");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        ClassDAO classDAO = new ClassDAO();
        Class cls = classDAO.getClassById(classId);

        if (cls == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().print("{\"success\": false, \"message\": \"Class not found\"}");
            return;
        }

        // Get instructor info
        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);

        PrintWriter out = response.getWriter();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

        StringBuilder json = new StringBuilder();
        json.append("{\"success\": true, \"data\": {");
        json.append("\"classID\": ").append(cls.getClassID()).append(",");
        json.append("\"className\": \"").append(escapeJson(cls.getClassName())).append("\",");
        json.append("\"classType\": \"").append(escapeJson(cls.getClassType())).append("\",");
        json.append("\"classLevel\": \"").append(escapeJson(cls.getClassLevel())).append("\",");
        json.append("\"classDate\": \"").append(dateFormat.format(cls.getClassDate())).append("\",");
        json.append("\"classStartTime\": \"").append(timeFormat.format(cls.getClassStartTime())).append("\",");
        json.append("\"classEndTime\": \"").append(timeFormat.format(cls.getClassEndTime())).append("\",");
        json.append("\"noOfParticipant\": ").append(cls.getNoOfParticipant()).append(",");
        json.append("\"location\": \"").append(escapeJson(cls.getLocation())).append("\",");
        json.append("\"description\": \"").append(escapeJson(cls.getDescription())).append("\",");
        json.append("\"classStatus\": \"").append(cls.getClassStatus()).append("\",");
        json.append("\"qrcode\": \"").append(
                cls.getQrcodeFilePath() != null
                ? escapeJson(cls.getQrcodeFilePath()) : QRCodeUtility.getDummyQRPath()).append("\",");
        json.append("\"adminID\": ").append(cls.getAdminID());

        // Add instructor info if available
        if (classDetails != null) {
            if (classDetails.containsKey("mainInstructor")) {
                Map<String, Object> mainInstructor = (Map<String, Object>) classDetails.get("mainInstructor");
                json.append(",\"confirmedInstructor\": \"").append(escapeJson(mainInstructor.get("name").toString())).append("\"");
                json.append(",\"confirmedInstructorID\": ").append(mainInstructor.get("id"));
            } else {
                json.append(",\"confirmedInstructor\": \"N/A\"");
                json.append(",\"confirmedInstructorID\": 0");
            }

            if (classDetails.containsKey("reliefInstructor")) {
                Map<String, Object> reliefInstructor = (Map<String, Object>) classDetails.get("reliefInstructor");
                json.append(",\"pendingInstructor\": \"").append(escapeJson(reliefInstructor.get("name").toString())).append("\"");
                json.append(",\"pendingInstructorID\": ").append(reliefInstructor.get("id"));
                json.append(",\"hasReliefInstructor\": true");
            } else {
                json.append(",\"pendingInstructor\": \"\"");
                json.append(",\"pendingInstructorID\": 0");
                json.append(",\"hasReliefInstructor\": false");
            }
        }

        json.append("}}");
        out.print(json.toString());
    }

    // ========== ADD NEW CLASS ==========
    private void addClass(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession();
        Integer adminId = SessionUtil.getUserId(session);

        if (adminId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().print("{\"success\": false, \"message\": \"Admin not logged in\"}");
            return;
        }

        // Get form parameters
        String className = request.getParameter("className");
        String classType = request.getParameter("classType");
        String classLevel = request.getParameter("classLevel");
        String classStatus = request.getParameter("classStatus");
        String classDate = request.getParameter("classDate");
        String classStartTime = request.getParameter("classStartTime");
        String classEndTime = request.getParameter("classEndTime");
        String noOfParticipantStr = request.getParameter("noOfParticipant");
        String location = request.getParameter("location");
        String description = request.getParameter("description");

        // Validate required fields
        if (className == null || className.isEmpty()
                || classType == null || classType.isEmpty()
                || classLevel == null || classLevel.isEmpty()
                || classDate == null || classDate.isEmpty()
                || classStartTime == null || classStartTime.isEmpty()
                || classEndTime == null || classEndTime.isEmpty()
                || location == null || location.isEmpty()) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"All required fields must be filled\"}");
            return;
        }

        int noOfParticipant = 0;
        try {
            noOfParticipant = Integer.parseInt(noOfParticipantStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Invalid number of participants\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Insert class - Apache Derby syntax
            String sql = "INSERT INTO class (className, classType, classLevel, classDate, classStartTime, "
                    + "classEndTime, noOfParticipant, location, description, classStatus, adminID) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, className);
            stmt.setString(2, classType);
            stmt.setString(3, classLevel);
            stmt.setDate(4, Date.valueOf(classDate));

            // Apache Derby time format
            String startTimeFormatted = classStartTime.length() == 5 ? classStartTime + ":00" : classStartTime;
            String endTimeFormatted = classEndTime.length() == 5 ? classEndTime + ":00" : classEndTime;

            stmt.setTime(5, Time.valueOf(startTimeFormatted));
            stmt.setTime(6, Time.valueOf(endTimeFormatted));
            stmt.setInt(7, noOfParticipant);
            stmt.setString(8, location);
            stmt.setString(9, description);
            stmt.setString(10, classStatus);
            stmt.setInt(11, adminId);

            int rows = stmt.executeUpdate();

            if (rows == 0) {
                throw new SQLException("Failed to insert class");
            }

            // Get generated class ID - Apache Derby approach
            int classId = 0;
            // Try to get the generated key
            rs = stmt.getGeneratedKeys();
            if (rs != null && rs.next()) {
                classId = rs.getInt(1);
            } else {
                // Fallback: query the last identity value
                try (Statement idStmt = conn.createStatement()) {
                    rs = idStmt.executeQuery("VALUES IDENTITY_VAL_LOCAL()");
                    if (rs.next()) {
                        classId = rs.getInt(1);
                    }
                }
            }

            // Generate QR code
            String qrContent = QRCodeUtility.generateQRContent(classId, request);
            String qrFileName = "class_" + classId + ".png";
            String qrFilePath = QRCodeUtility.generateAndSaveQRCode(qrContent, qrFileName, request);

            // Update class with QR code path
            String updateSql = "UPDATE class SET qrcodeFilePath = ? WHERE classID = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setString(1, qrFilePath);
                updateStmt.setInt(2, classId);
                updateStmt.executeUpdate();
            }

            conn.commit();

            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"message\": \"Class created successfully\", \"classId\": " + classId + "}");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Error rolling back transaction", ex);
                }
            }
            throw e;
        } finally {
            if (rs != null) {
                try {
                    rs.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
        }
    }

    // ========== UPDATE CLASS ==========
    // ========== UPDATE CLASS ==========
    private void updateClass(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String classIdStr = request.getParameter("classId");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Class ID required\"}");
            return;
        }

        int classId = Integer.parseInt(classIdStr);

        // Get current class info
        ClassDAO classDAO = new ClassDAO();
        Class currentClass = classDAO.getClassById(classId);

        if (currentClass == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().print("{\"success\": false, \"message\": \"Class not found\"}");
            return;
        }

        // Check if class has already passed
        long classDateTime = currentClass.getClassDate().getTime() + currentClass.getClassStartTime().getTime();
        long now = System.currentTimeMillis();
        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

        // Block update if class has passed (hoursRemaining negative means class already happened)
        if (hoursRemaining < 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot update: Class has already passed\"}");
            return;
        }

        // Get form parameters
        String className = request.getParameter("className");
        String classType = request.getParameter("classType");
        String classLevel = request.getParameter("classLevel");
        String classStatus = request.getParameter("classStatus");
        String classDate = request.getParameter("classDate");
        String classStartTime = request.getParameter("classStartTime");
        String classEndTime = request.getParameter("classEndTime");
        String noOfParticipantStr = request.getParameter("noOfParticipant");
        String location = request.getParameter("location");
        String description = request.getParameter("description");
        String generateNewQR = request.getParameter("generateNewQR");

        // Check 24-hour rule for status change
        // Cannot set to inactive if less than 24 hours remaining
        if ("inactive".equals(classStatus)
                && !"inactive".equals(currentClass.getClassStatus())
                && hoursRemaining < 24 && hoursRemaining >= 0) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot set to inactive: Less than 24 hours remaining\"}");
            return;
        }

        // Cannot reactivate if less than 24 hours remaining
        if ("active".equals(classStatus)
                && "inactive".equals(currentClass.getClassStatus())
                && hoursRemaining < 24 && hoursRemaining >= 0) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot reactivate: Less than 24 hours remaining\"}");
            return;
        }

        // Check if trying to inactive a class with instructor
        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);
        if ("inactive".equals(classStatus)
                && classDetails != null
                && classDetails.containsKey("mainInstructor")) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot set to inactive: Class has a confirmed instructor. Use Emergency Withdraw instead.\"}");
            return;
        }

        int noOfParticipant = 0;
        try {
            noOfParticipant = Integer.parseInt(noOfParticipantStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Invalid number of participants\"}");
            return;
        }

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Update class
            String sql = "UPDATE class SET className = ?, classType = ?, classLevel = ?, "
                    + "classDate = ?, classStartTime = ?, classEndTime = ?, "
                    + "noOfParticipant = ?, location = ?, description = ?, classStatus = ? "
                    + "WHERE classID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, className);
            stmt.setString(2, classType);
            stmt.setString(3, classLevel);
            stmt.setDate(4, Date.valueOf(classDate));

            // Apache Derby time format
            String startTimeFormatted = classStartTime.length() == 5 ? classStartTime + ":00" : classStartTime;
            String endTimeFormatted = classEndTime.length() == 5 ? classEndTime + ":00" : classEndTime;

            stmt.setTime(5, Time.valueOf(startTimeFormatted));
            stmt.setTime(6, Time.valueOf(endTimeFormatted));
            stmt.setInt(7, noOfParticipant);
            stmt.setString(8, location);
            stmt.setString(9, description);
            stmt.setString(10, classStatus);
            stmt.setInt(11, classId);

            int rows = stmt.executeUpdate();

            if (rows == 0) {
                throw new SQLException("Failed to update class");
            }

            // Generate new QR code if requested
            String qrFilePath = null;
            if ("true".equals(generateNewQR)) {
                String qrContent = QRCodeUtility.generateQRContent(classId, request);
                String qrFileName = "class_" + classId + "_updated.png";
                qrFilePath = QRCodeUtility.generateAndSaveQRCode(qrContent, qrFileName, request);

                String updateQRSql = "UPDATE class SET qrcodeFilePath = ? WHERE classID = ?";
                try (PreparedStatement updateQRStmt = conn.prepareStatement(updateQRSql)) {
                    updateQRStmt.setString(1, qrFilePath);
                    updateQRStmt.setInt(2, classId);
                    updateQRStmt.executeUpdate();
                }
            }

            conn.commit();

            PrintWriter out = response.getWriter();
            String message = "Class updated successfully";
            if ("true".equals(generateNewQR)) {
                message += " and new QR code generated";
            }
            out.print("{\"success\": true, \"message\": \"" + message + "\"}");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Error rolling back transaction", ex);
                }
            }
            throw e;
        } finally {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
        }
    }

    // ========== DELETE CLASS ==========
    // ========== DELETE CLASS ==========
    private void deleteClass(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String classIdStr = request.getParameter("classId");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Class ID required\"}");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        ClassDAO classDAO = new ClassDAO();
        ClassConfirmationDAO confirmationDAO = new ClassConfirmationDAO();

        // Get class info first
        Class cls = classDAO.getClassById(classId);
        if (cls == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().print("{\"success\": false, \"message\": \"Class not found\"}");
            return;
        }

        // Check if class has already passed
        long classDateTime = cls.getClassDate().getTime() + cls.getClassStartTime().getTime();
        long now = System.currentTimeMillis();
        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

        // Block delete if class has passed
        if (hoursRemaining < 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot delete: Class has already passed\"}");
            return;
        }

        // Check if class has instructors
        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);
        if (classDetails != null
                && (classDetails.containsKey("mainInstructor") || classDetails.containsKey("reliefInstructor"))) {

            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot delete class: Class has instructors assigned. Use Emergency Withdraw first.\"}");
            return;
        }

        // Delete class
        boolean deleted = classDAO.deleteClass(classId);

        if (deleted) {
            response.getWriter().print("{\"success\": true, \"message\": \"Class deleted successfully\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\": false, \"message\": \"Failed to delete class\"}");
        }
    }

    // ========== EMERGENCY WITHDRAW ==========
    // ========== EMERGENCY WITHDRAW ==========
    private void emergencyWithdraw(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String classIdStr = request.getParameter("classId");
        if (classIdStr == null || classIdStr.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Class ID required\"}");
            return;
        }

        int classId = Integer.parseInt(classIdStr);
        ClassDAO classDAO = new ClassDAO();
        ClassConfirmationDAO confirmationDAO = new ClassConfirmationDAO();

        // Get class details
        Class cls = classDAO.getClassById(classId);
        if (cls == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().print("{\"success\": false, \"message\": \"Class not found\"}");
            return;
        }

        // Calculate hours remaining
        long classDateTime = cls.getClassDate().getTime() + cls.getClassStartTime().getTime();
        long now = System.currentTimeMillis();
        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

        // Block emergency withdraw if class has passed
        if (hoursRemaining < 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Cannot withdraw: Class has already passed\"}");
            return;
        }

        // Get instructor info
        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);
        if (classDetails == null || !classDetails.containsKey("mainInstructor")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"success\": false, \"message\": \"Class has no confirmed instructor\"}");
            return;
        }

        Map<String, Object> mainInstructor = (Map<String, Object>) classDetails.get("mainInstructor");
        int mainInstructorId = (int) mainInstructor.get("id");
        String mainInstructorName = (String) mainInstructor.get("name");

        Map<String, Object> reliefInstructor = null;
        boolean hasRelief = classDetails.containsKey("reliefInstructor");
        if (hasRelief) {
            reliefInstructor = (Map<String, Object>) classDetails.get("reliefInstructor");
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String resultMessage = "";

            // Scenario 1: Ada relief instructor → AUTO BECOMES CONFIRMED (any time)
            if (hasRelief && reliefInstructor != null) {
                int reliefInstructorId = (int) reliefInstructor.get("id");
                String reliefInstructorName = (String) reliefInstructor.get("name");

                // Update relief to confirmed
                String updateReliefSql = "UPDATE class_confirmation SET action = 'confirmed', actionAt = CURRENT_TIMESTAMP "
                        + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";
                try (PreparedStatement stmt = conn.prepareStatement(updateReliefSql)) {
                    stmt.setInt(1, classId);
                    stmt.setInt(2, reliefInstructorId);
                    stmt.executeUpdate();
                }

                // Set main instructor to cancelled
                String cancelMainSql = "UPDATE class_confirmation SET action = 'cancelled', cancelledAt = CURRENT_TIMESTAMP, "
                        + "cancellationReason = 'Emergency withdrawal - replaced by relief instructor' "
                        + "WHERE classID = ? AND instructorID = ? AND action = 'confirmed'";
                try (PreparedStatement stmt = conn.prepareStatement(cancelMainSql)) {
                    stmt.setInt(1, classId);
                    stmt.setInt(2, mainInstructorId);
                    stmt.executeUpdate();
                }

                // Class remains active
                String updateClassSql = "UPDATE class SET classStatus = 'active' WHERE classID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateClassSql)) {
                    stmt.setInt(1, classId);
                    stmt.executeUpdate();
                }

                resultMessage = mainInstructorName + " has been withdrawn. Relief instructor " + reliefInstructorName
                        + " is now the confirmed instructor. Class will continue as scheduled.";
            } // Scenario 2: Takde relief, tapi >24 hours - Just withdraw, class tetap active
            else if (hoursRemaining >= 24) {
                // Set main instructor to cancelled
                String cancelSql = "UPDATE class_confirmation SET action = 'cancelled', cancelledAt = CURRENT_TIMESTAMP, "
                        + "cancellationReason = 'Emergency withdrawal - no replacement' "
                        + "WHERE classID = ? AND instructorID = ? AND action = 'confirmed'";
                try (PreparedStatement stmt = conn.prepareStatement(cancelSql)) {
                    stmt.setInt(1, classId);
                    stmt.setInt(2, mainInstructorId);
                    stmt.executeUpdate();
                }

                // Class remains active
                String updateClassSql = "UPDATE class SET classStatus = 'active' WHERE classID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateClassSql)) {
                    stmt.setInt(1, classId);
                    stmt.executeUpdate();
                }

                resultMessage = mainInstructorName + " has been withdrawn from this class. "
                        + "Class status remains active and available for new instructor assignments.";
            } // Scenario 3: Takde relief & <24 hours - Cancel class
            else if (hoursRemaining < 24 && hoursRemaining >= 0) {
                // Set main instructor to cancelled
                String cancelSql = "UPDATE class_confirmation SET action = 'cancelled', cancelledAt = CURRENT_TIMESTAMP, "
                        + "cancellationReason = 'Emergency withdrawal - class cancelled (less than 24 hours)' "
                        + "WHERE classID = ? AND instructorID = ? AND action = 'confirmed'";
                try (PreparedStatement stmt = conn.prepareStatement(cancelSql)) {
                    stmt.setInt(1, classId);
                    stmt.setInt(2, mainInstructorId);
                    stmt.executeUpdate();
                }

                // Set class to inactive
                String updateClassSql = "UPDATE class SET classStatus = 'inactive' WHERE classID = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateClassSql)) {
                    stmt.setInt(1, classId);
                    stmt.executeUpdate();
                }

                resultMessage = "Class has been cancelled. " + mainInstructorName
                        + " has been withdrawn and class set to inactive (no relief instructor available within 24 hours).";
            }

            conn.commit();

            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"message\": \"" + escapeJson(resultMessage) + "\"}");

        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Error rolling back transaction", ex);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
        }
    }

    // ========== HELPER METHOD: Escape JSON strings ==========
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
