package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.dao.ClassConfirmationDAO;
import com.skylightstudio.classmanagement.dao.FeedbackDAO;
import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/admin/monitor-instructor")
public class MonitorInstructorServlet extends HttpServlet {

    private InstructorDAO instructorDAO;
    private RegistrationDAO registrationDAO;
    private ClassConfirmationDAO classConfirmationDAO;
    private FeedbackDAO feedbackDAO;
    private ClassDAO classDAO;

    @Override
    public void init() throws ServletException {
        instructorDAO = new InstructorDAO();
        registrationDAO = new RegistrationDAO();
        classConfirmationDAO = new ClassConfirmationDAO();
        feedbackDAO = new FeedbackDAO();
        classDAO = new ClassDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // ✅ ADD: Debug logging
        System.out.println("=== DEBUG doGet ===");
        System.out.println("Action: " + action);
        System.out.println("Request URI: " + request.getRequestURI());

        try {
            if ("list".equals(action)) {
                getAllInstructors(response);
            } else if ("details".equals(action)) {
                getInstructorDetails(request, response);
            } else if ("stats".equals(action)) {
                getStats(response);
            } else if ("performance".equals(action)) {
                getPerformanceData(request, response);
            } else if ("completePerformance".equals(action)) {
                System.out.println("✅ Calling getCompletePerformanceData()"); // ✅ ADD THIS
                getCompletePerformanceData(request, response);
            } else if ("checkClasses".equals(action)) {
                checkInstructorClasses(request, response);
            } else {
                request.getRequestDispatcher("/admin/monitor_instructor.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            // ✅ IMPROVED: Detailed error logging
            System.err.println("❌ SQL ERROR in doGet:");
            System.err.println("Action: " + action);
            System.err.println("Error Message: " + e.getMessage());
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error>");
            out.print("<message>" + escapeXml(e.getMessage()) + "</message>");
            out.print("</error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            // ✅ IMPROVED: Catch all other exceptions
            System.err.println("❌ GENERAL ERROR in doGet:");
            System.err.println("Action: " + action);
            System.err.println("Error Message: " + e.getMessage());
            e.printStackTrace();

            response.setContentType("text/xml;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error>");
            out.print("<message>" + escapeXml(e.getMessage()) + "</message>");
            out.print("</error>");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void getAllInstructors(HttpServletResponse response) throws SQLException, IOException {
        List<Map<String, Object>> instructorRegistrations = registrationDAO.getAllInstructorRegistrations();

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<instructors>");
        for (Map<String, Object> instructor : instructorRegistrations) {
            out.print("<instructor>");
            out.print("<id>" + instructor.get("instructorID") + "</id>");
            out.print("<name>" + escapeXml(instructor.get("name").toString()) + "</name>");
            out.print("<email>" + escapeXml(instructor.get("email").toString()) + "</email>");
            out.print("<experience>" + getExperienceString(instructor.get("yearOfExperience")) + "</experience>");

            // ✅ FIX: Check if dateJoined exists and is not null
            Object dateJoined = instructor.get("dateJoined");
            if (dateJoined != null) {
                out.print("<dateJoined>" + formatDate(dateJoined) + "</dateJoined>");
            } else {
                out.print("<dateJoined>Not available</dateJoined>");
            }

            out.print("<status>" + escapeXml(instructor.get("instructorStatus").toString()) + "</status>");
            out.print("<registrationStatus>" + escapeXml(instructor.get("registrationStatus").toString()) + "</registrationStatus>");
            out.print("</instructor>");
        }
        out.print("</instructors>");
    }

    private void getInstructorDetails(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));

        // Get instructor from database
        com.skylightstudio.classmanagement.model.Instructor instructor = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        // Get registration details
        com.skylightstudio.classmanagement.model.Registration registration
                = registrationDAO.getRegistrationById(instructor.getRegisterID());

        // Get performance stats - CONFIRMED CLASSES SAHAJA
        int totalConfirmedClasses = classConfirmationDAO.countConfirmedClassesForInstructor(instructorId);
        int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
        int completedClasses = totalConfirmedClasses - cancelledClasses;

        // Get ALL 5 average ratings
        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

        // Dapatkan semua 5 rating
        double avgTeaching = averageRatings.getOrDefault("teaching", 0.0);
        double avgCommunication = averageRatings.getOrDefault("communication", 0.0);
        double avgSupport = averageRatings.getOrDefault("support", 0.0);
        double avgPunctuality = averageRatings.getOrDefault("punctuality", 0.0);
        double avgOverallRating = averageRatings.getOrDefault("overall", 0.0);

        // Kira average dari 5 rating
        double totalAllRatings = avgTeaching + avgCommunication + avgSupport + avgPunctuality + avgOverallRating;
        double averageAllRatings = totalAllRatings / 5.0;

        // Handle NaN atau infinite values
        if (Double.isNaN(averageAllRatings) || Double.isInfinite(averageAllRatings)) {
            averageAllRatings = 0.0;
        }

        int feedbackCount = feedbackDAO.getFeedbackCountForInstructor(instructorId);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<details>");

        // ========== BASIC INFORMATION ==========
        out.print("<name>" + escapeXml(instructor.getName()) + "</name>");
        out.print("<email>" + escapeXml(instructor.getEmail()) + "</email>");
        out.print("<phone>" + escapeXml(instructor.getPhone()) + "</phone>");
        out.print("<nric>" + escapeXml(instructor.getNric()) + "</nric>");

        if (instructor.getBod() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMMM yyyy");
            out.print("<bod>" + sdf.format(instructor.getBod()) + "</bod>");
        } else {
            out.print("<bod>Not specified</bod>");
        }

        if (instructor.getDateJoined() != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            out.print("<dateJoined>" + sdf.format(instructor.getDateJoined()) + "</dateJoined>");
        } else {
            out.print("<dateJoined>Not available</dateJoined>");
        }

        out.print("<experience>" + getExperienceString(instructor.getYearOfExperience()) + "</experience>");
        out.print("<address>" + escapeXml(instructor.getAddress()) + "</address>");
        out.print("<instructorStatus>" + escapeXml(instructor.getStatus()) + "</instructorStatus>");

        if (registration != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy hh:mm a");
            out.print("<regDate>" + sdf.format(registration.getRegisterDate()) + "</regDate>");
            out.print("<regStatus>" + escapeXml(registration.getStatus()) + "</regStatus>");
            out.print("<userType>" + escapeXml(registration.getUserType()) + "</userType>");
        }

        // ========== PERFORMANCE STATS ==========
        out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
        out.print("<cancelledClasses>" + cancelledClasses + "</cancelledClasses>");
        out.print("<completedClasses>" + completedClasses + "</completedClasses>");

        // ========== ALL 5 RATINGS ==========
        out.print("<avgTeaching>" + String.format("%.1f", avgTeaching) + "</avgTeaching>");
        out.print("<avgCommunication>" + String.format("%.1f", avgCommunication) + "</avgCommunication>");
        out.print("<avgSupport>" + String.format("%.1f", avgSupport) + "</avgSupport>");
        out.print("<avgPunctuality>" + String.format("%.1f", avgPunctuality) + "</avgPunctuality>");
        out.print("<overallRating>" + String.format("%.1f", avgOverallRating) + "</overallRating>");

        // ========== AVERAGE OF ALL 5 RATINGS (FOR PDF) ==========
        out.print("<averageAllRatings>" + String.format("%.1f", averageAllRatings) + "</averageAllRatings>");
        out.print("<feedbackCount>" + feedbackCount + "</feedbackCount>");

        // ========== PROFILE IMAGE PATH ==========
        String profileImage = instructor.getProfileImageFilePath();
        if (profileImage != null && !profileImage.isEmpty() && !profileImage.equals("null")) {
            if (!profileImage.startsWith("../")) {
                profileImage = "../" + profileImage;
            }
            out.print("<profileImage>" + escapeXml(profileImage) + "</profileImage>");
        } else {
            out.print("<profileImage>../profile_pictures/instructor/dummy.png</profileImage>");
        }

        // ========== CERTIFICATION PATH ==========
        String certification = instructor.getCertificationFilePath();
        System.out.println("DEBUG - Original certification path: " + certification);

        if (certification != null && !certification.isEmpty() && !certification.equals("null")) {
            certification = certification.trim();
            if (!certification.startsWith("../") && !certification.startsWith("/")) {
                certification = "../" + certification;
            }
            certification = certification.replace("//", "/");

            System.out.println("DEBUG - Processed certification path: " + certification);

            out.print("<certification>" + escapeXml(certification) + "</certification>");

            String fileName = getFileNameFromPath(certification);
            out.print("<certificationFileName>" + escapeXml(fileName) + "</certificationFileName>");
        } else {
            System.out.println("DEBUG - No certification found, using dummy");
            out.print("<certification>../certifications/instructor/dummy.pdf</certification>");
            out.print("<certificationFileName>dummy.pdf</certificationFileName>");
        }

        out.print("</details>");
    }

    private String getFileNameFromPath(String path) {
        if (path == null || path.isEmpty()) {
            return "No file";
        }
        String[] parts = path.split("/");
        return parts[parts.length - 1];
    }

    private void getStats(HttpServletResponse response) throws SQLException, IOException {
        List<Map<String, Object>> instructors = registrationDAO.getAllInstructorRegistrations();

        int activeCount = 0;
        int inactiveCount = 0;
        int newThisMonth = 0;
        double totalOverallRating = 0;
        int ratedCount = 0;

        // Get current month/year
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int currentMonth = cal.get(java.util.Calendar.MONTH) + 1;
        int currentYear = cal.get(java.util.Calendar.YEAR);

        for (Map<String, Object> instructor : instructors) {
            String status = instructor.get("instructorStatus").toString();

            if ("active".equals(status)) {
                activeCount++;
            } else {
                inactiveCount++;
            }

            // Check if joined this month
            java.sql.Timestamp dateJoined = (java.sql.Timestamp) instructor.get("dateJoined");
            if (dateJoined != null) {
                cal.setTime(dateJoined);
                int joinMonth = cal.get(java.util.Calendar.MONTH) + 1;
                int joinYear = cal.get(java.util.Calendar.YEAR);

                if (joinMonth == currentMonth && joinYear == currentYear) {
                    newThisMonth++;
                }
            }

            // Get ALL 5 ratings untuk instructor ini
            Integer instructorId = (Integer) instructor.get("instructorID");
            Map<String, Double> ratings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

            // KIRA AVERAGE DARI 5 RATING
            double teaching = ratings.getOrDefault("teaching", 0.0);
            double communication = ratings.getOrDefault("communication", 0.0);
            double support = ratings.getOrDefault("support", 0.0);
            double punctuality = ratings.getOrDefault("punctuality", 0.0);
            double overall = ratings.getOrDefault("overall", 0.0);

            double averageAllRatings = (teaching + communication + support + punctuality + overall) / 5.0;

            if (averageAllRatings > 0) {
                totalOverallRating += averageAllRatings;
                ratedCount++;
            }
        }

        double avgRating = ratedCount > 0 ? totalOverallRating / ratedCount : 0;

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<stats>");
        out.print("<active>" + activeCount + "</active>");
        out.print("<inactive>" + inactiveCount + "</inactive>");
        out.print("<newThisMonth>" + newThisMonth + "</newThisMonth>");
        out.print("<avgOverallRating>" + String.format("%.1f", avgRating) + "</avgOverallRating>");
        out.print("</stats>");
    }

    private void getPerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        int instructorId = Integer.parseInt(request.getParameter("id"));
        String period = request.getParameter("period");

        // Get instructor
        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Instructor not found");
            return;
        }

        // Get performance data
        int totalClasses = getTotalClassesForInstructor(instructorId);
        int cancelledClasses = getCancelledClassesForInstructor(instructorId);
        int completedClasses = totalClasses - cancelledClasses;
        double completionRate = totalClasses > 0 ? (completedClasses * 100.0 / totalClasses) : 0;

        // Get average ratings
        Map<String, Double> averageRatings = feedbackDAO.getAverageRatingsForInstructor(instructorId);
        double overall = averageRatings.getOrDefault("overall", 0.0);
        double teaching = averageRatings.getOrDefault("teaching", 0.0);
        double communication = averageRatings.getOrDefault("communication", 0.0);
        double support = averageRatings.getOrDefault("support", 0.0);
        double punctuality = averageRatings.getOrDefault("punctuality", 0.0);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<performance>");
        out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");
        out.print("<overallRating>" + String.format("%.1f", overall) + "</overallRating>");
        out.print("<totalClasses>" + totalClasses + "</totalClasses>");
        out.print("<cancelled>" + cancelledClasses + "</cancelled>");
        out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");
        out.print("<teaching>" + String.format("%.1f", teaching) + "</teaching>");
        out.print("<communication>" + String.format("%.1f", communication) + "</communication>");
        out.print("<support>" + String.format("%.1f", support) + "</support>");
        out.print("<punctuality>" + String.format("%.1f", punctuality) + "</punctuality>");
        out.print("</performance>");
    }

    // TAMBAHAN: Check jika instructor ada assigned classes
    private void checkInstructorClasses(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int instructorId = Integer.parseInt(request.getParameter("id"));

        // Check if instructor has assigned classes
        List<Map<String, Object>> assignedClasses = getAssignedClassesForInstructor(instructorId);

        response.setContentType("text/html");
        PrintWriter out = response.getWriter();

        out.print("<classCheck>");
        out.print("<hasClasses>" + (!assignedClasses.isEmpty()) + "</hasClasses>");
        out.print("<classCount>" + assignedClasses.size() + "</classCount>");

        if (!assignedClasses.isEmpty()) {
            out.print("<classes>");
            for (Map<String, Object> classData : assignedClasses) {
                out.print("<class>");
                out.print("<id>" + classData.get("classID") + "</id>");
                out.print("<name>" + escapeXml(classData.get("className").toString()) + "</name>");
                out.print("<action>" + escapeXml(classData.get("action").toString()) + "</action>");
                out.print("<date>" + formatDate(classData.get("classDate")) + "</date>");
                out.print("<startTime>" + formatTime(classData.get("classStartTime")) + "</startTime>");
                out.print("</class>");
            }
            out.print("</classes>");
        }

        out.print("</classCheck>");
    }

    // TAMBAHAN: Helper untuk format time
    private String formatTime(Object time) {
        if (time == null) {
            return "Not available";
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
            return sdf.format(time);
        } catch (Exception e) {
            return "Not available";
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Set default content type to XML
        response.setContentType("text/xml;charset=UTF-8");

        String action = request.getParameter("action");

        System.out.println("=== DEBUG POST REQUEST ===");
        System.out.println("Action: " + action);
        System.out.println("Request parameters:");
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("  " + paramName + ": " + request.getParameter(paramName));
        }

        try {
            if ("toggleStatus".equals(action)) {
                toggleInstructorStatus(request, response);
            } else {
                System.out.println("DEBUG - Invalid action: " + action);
                PrintWriter out = response.getWriter();
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Invalid action: " + escapeXml(action) + "</message></response>");
            }
        } catch (SQLException e) {
            System.err.println("DEBUG - SQL Exception: " + e.getMessage());
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Database error: " + escapeXml(e.getMessage()) + "</message></response>");
        } catch (Exception e) {
            System.err.println("DEBUG - General Exception: " + e.getMessage());
            e.printStackTrace();
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Server error: " + escapeXml(e.getMessage()) + "</message></response>");
        }
    }

    private void toggleInstructorStatus(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        // Set content type to XML
        response.setContentType("text/xml;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String idParam = request.getParameter("id");
        String newStatusParam = request.getParameter("newStatus");

        System.out.println("DEBUG - toggleStatus parameters:");
        System.out.println("  id: " + idParam);
        System.out.println("  newStatus: " + newStatusParam);

        if (idParam == null || newStatusParam == null) {
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Missing parameters</message></response>");
            return;
        }

        int instructorId;
        try {
            instructorId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Invalid instructor ID</message></response>");
            return;
        }

        String newStatus = newStatusParam;

        // Get current admin ID from session
        Integer adminId = (Integer) request.getSession().getAttribute("adminID");
        if (adminId == null) {
            adminId = 1;
        }

        System.out.println("DEBUG - Admin ID: " + adminId);

        com.skylightstudio.classmanagement.model.Instructor instructor
                = instructorDAO.getInstructorById(instructorId);

        if (instructor == null) {
            System.out.println("DEBUG - Instructor not found: " + instructorId);
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result><message>Instructor not found</message></response>");
            return;
        }

        String currentStatus = instructor.getStatus();
        System.out.println("DEBUG - Current instructor status: " + currentStatus);

        // ========== Pemeriksaan untuk deactivate ==========
        if ("inactive".equals(newStatus) && "active".equals(currentStatus)) {
            List<Map<String, Object>> assignedClasses = getAssignedClassesForInstructor(instructorId);

            if (!assignedClasses.isEmpty()) {
                System.out.println("DEBUG - Instructor has " + assignedClasses.size() + " assigned classes");

                Connection conn = null;
                try {
                    conn = DBConnection.getConnection();
                    conn.setAutoCommit(false); // Start transaction

                    int promotedCount = 0;
                    int cancelledCount = 0;
                    int withdrawnCount = 0;

                    // Process each assigned class
                    for (Map<String, Object> classData : assignedClasses) {
                        int classId = (Integer) classData.get("classID");
                        String action = (String) classData.get("action");
                        String className = (String) classData.get("className");
                        java.sql.Date classDate = (java.sql.Date) classData.get("classDate");
                        java.sql.Time classStartTime = (java.sql.Time) classData.get("classStartTime");

                        System.out.println("DEBUG - Processing class ID: " + classId + ", Action: " + action);

                        // Calculate hours remaining until class
                        long classDateTime = classDate.getTime() + classStartTime.getTime();
                        long now = System.currentTimeMillis();
                        long hoursRemaining = (classDateTime - now) / (1000 * 60 * 60);

                        // Get class details
                        Map<String, Object> classDetails = classDAO.getClassWithInstructors(classId);

                        if ("confirmed".equals(action)) {
                            // Instructor adalah main instructor untuk class ini

                            if (classDetails != null && classDetails.containsKey("reliefInstructor")) {
                                // Ada relief instructor - promote ke confirmed
                                Map<String, Object> reliefInstructor = (Map<String, Object>) classDetails.get("reliefInstructor");
                                int reliefInstructorId = (Integer) reliefInstructor.get("id");
                                String reliefInstructorName = (String) reliefInstructor.get("name");

                                // Promote relief to confirmed
                                promoteReliefInstructor(conn, classId, reliefInstructorId);

                                // Set current instructor to cancelled
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - replaced by relief instructor " + reliefInstructorName);

                                promotedCount++;
                                System.out.println("DEBUG - Promoted relief instructor " + reliefInstructorName
                                        + " for class ID: " + classId);

                            } else if (hoursRemaining >= 24) {
                                // Takde relief, tapi masih ada >24 jam - class tetap active, cari instructor lain
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class available for new instructor assignment");

                                withdrawnCount++;
                                System.out.println("DEBUG - Class " + classId + " remains active, looking for new instructor");

                            } else if (hoursRemaining < 24 && hoursRemaining >= 0) {
                                // Takde relief & <24 jam - cancel class
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class cancelled (less than 24 hours, no relief)");

                                // Set class to inactive
                                classDAO.updateClassStatus(classId, "inactive");

                                cancelledCount++;
                                System.out.println("DEBUG - Class " + classId + " cancelled due to <24 hours");

                            } else {
                                // Class sudah lepas
                                cancelInstructorFromClass(conn, classId, instructorId,
                                        "Instructor deactivated - class already passed");

                                withdrawnCount++;
                            }

                        } else if ("pending".equals(action)) {
                            // Instructor adalah relief instructor (pending)
                            cancelInstructorFromClass(conn, classId, instructorId,
                                    "Instructor deactivated - relief request cancelled");

                            withdrawnCount++;
                            System.out.println("DEBUG - Cancelled pending relief for class ID: " + classId);
                        }
                    }

                    // Update instructor status after processing all classes
                    boolean success = instructorDAO.updateInstructorStatus(instructorId, newStatus, adminId);

                    if (success) {
                        conn.commit(); // Commit transaction

                        String message = "Instructor deactivated successfully. ";
                        if (promotedCount > 0) {
                            message += promotedCount + " class(es) had relief instructor promoted. ";
                        }
                        if (cancelledCount > 0) {
                            message += cancelledCount + " class(es) were cancelled (no relief within 24 hours). ";
                        }
                        if (withdrawnCount > 0) {
                            message += withdrawnCount + " class(es) had instructor withdrawn. ";
                        }

                        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>success</result>"
                                + "<message>" + escapeXml(message) + "</message>"
                                + "<newStatus>" + escapeXml(newStatus) + "</newStatus>"
                                + "<totalClasses>" + assignedClasses.size() + "</totalClasses>"
                                + "<promoted>" + promotedCount + "</promoted>"
                                + "<cancelled>" + cancelledCount + "</cancelled>"
                                + "<withdrawn>" + withdrawnCount + "</withdrawn>"
                                + "</response>");
                    } else {
                        conn.rollback(); // Rollback if update fails
                        out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                                + "<message>Failed to update instructor status</message></response>");
                    }

                    return; // Return here since we've processed classes

                } catch (Exception e) {
                    if (conn != null) {
                        try {
                            conn.rollback();
                        } catch (SQLException ex) {
                            // Ignore
                        }
                    }
                    System.err.println("DEBUG - Error processing classes: " + e.getMessage());
                    e.printStackTrace();
                    // Continue with normal status update if error occurs
                } finally {
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                            // Ignore
                        }
                    }
                }
            }
        }
        // ========== END TAMBAHAN ==========

        // Original code untuk activate atau jika takde assigned classes
        boolean success;

        try {
            success = instructorDAO.updateInstructorStatus(instructorId, newStatus, adminId);
            System.out.println("DEBUG - Update success: " + success);

            if (success) {
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>success</result>"
                        + "<message>Status updated successfully</message>"
                        + "<newStatus>" + escapeXml(newStatus) + "</newStatus></response>");
            } else {
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                        + "<message>Failed to update status in database</message></response>");
            }
        } catch (Exception e) {
            System.err.println("DEBUG - Exception during update: " + e.getMessage());
            e.printStackTrace();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><result>error</result>"
                    + "<message>Database error: " + escapeXml(e.getMessage()) + "</message></response>");
        }
    }

    // ========== TAMBAHAN: Helper methods baru ==========
    /**
     * Get all assigned classes (confirmed or pending) for an instructor
     */
    private List<Map<String, Object>> getAssignedClassesForInstructor(int instructorId) throws SQLException {
        List<Map<String, Object>> assignedClasses = new ArrayList<>();

        String sql = "SELECT cc.classID, cc.action, c.className, c.classDate, c.classStartTime, "
                + "c.classEndTime, c.location, c.classStatus "
                + "FROM class_confirmation cc "
                + "JOIN class c ON cc.classID = c.classID "
                + "WHERE cc.instructorID = ? AND cc.action IN ('confirmed', 'pending') "
                + "AND (cc.cancelledAt IS NULL OR cc.cancelledAt = '') "
                + "AND c.classStatus = 'active' "
                + "ORDER BY c.classDate, c.classStartTime";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> classData = new HashMap<>();
                classData.put("classID", rs.getInt("classID"));
                classData.put("action", rs.getString("action"));
                classData.put("className", rs.getString("className"));
                classData.put("classDate", rs.getDate("classDate"));
                classData.put("classStartTime", rs.getTime("classStartTime"));
                classData.put("classEndTime", rs.getTime("classEndTime"));
                classData.put("location", rs.getString("location"));
                classData.put("classStatus", rs.getString("classStatus"));
                assignedClasses.add(classData);
            }
        }

        return assignedClasses;
    }

    /**
     * Promote relief instructor to confirmed
     */
    private void promoteReliefInstructor(Connection conn, int classId, int reliefInstructorId) throws SQLException {
        String sql = "UPDATE class_confirmation SET action = 'confirmed', actionAt = CURRENT_TIMESTAMP "
                + "WHERE classID = ? AND instructorID = ? AND action = 'pending'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, classId);
            stmt.setInt(2, reliefInstructorId);
            stmt.executeUpdate();
        }
    }

    /**
     * Cancel instructor from a class
     */
    private void cancelInstructorFromClass(Connection conn, int classId, int instructorId, String reason)
            throws SQLException {

        String sql = "UPDATE class_confirmation SET action = 'cancelled', "
                + "cancelledAt = CURRENT_TIMESTAMP, "
                + "cancellationReason = ? "
                + "WHERE classID = ? AND instructorID = ? AND action IN ('confirmed', 'pending')";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, reason);
            stmt.setInt(2, classId);
            stmt.setInt(3, instructorId);
            stmt.executeUpdate();
        }
    }

    // Helper methods
    private String escapeXml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String getExperienceString(Object years) {
        if (years == null) {
            return "Not specified";
        }
        try {
            int y = Integer.parseInt(years.toString());
            if (y >= 5) {
                return "5+ years";
            }
            return y + " year" + (y != 1 ? "s" : "");
        } catch (NumberFormatException e) {
            return "Not specified";
        }
    }

    private String formatDate(Object date) {
        if (date == null) {
            return "Not available";
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy");
            return sdf.format(date);
        } catch (Exception e) {
            return "Not available";
        }
    }

    private int getTotalClassesForInstructor(int instructorId) throws SQLException {
        // This is a simplified implementation
        // In real app, you would have a proper method in DAO
        return 0; // Placeholder
    }

    private int getCancelledClassesForInstructor(int instructorId) throws SQLException {
        // This is a simplified implementation
        // In real app, you would have a proper method in DAO
        return 0; // Placeholder
    }

    private void getCompletePerformanceData(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        System.out.println("=== getCompletePerformanceData START ===");

        String idParam = request.getParameter("id");
        String period = request.getParameter("period");

        System.out.println("ID param: " + idParam);
        System.out.println("Period param: " + period);

        if (idParam == null || idParam.trim().isEmpty()) {
            System.err.println("❌ ERROR: Missing instructor ID");
            response.setContentType("text/xml;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Missing instructor ID</message></error>");
            return;
        }

        int instructorId;
        try {
            instructorId = Integer.parseInt(idParam);
            System.out.println("✅ Parsed instructor ID: " + instructorId);
        } catch (NumberFormatException e) {
            System.err.println("❌ ERROR: Invalid instructor ID format: " + idParam);
            response.setContentType("text/xml;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Invalid instructor ID</message></error>");
            return;
        }

        if (period == null || period.trim().isEmpty()) {
            period = "all";
            System.out.println("⚠️ Period not provided, using default: all");
        }

        Connection conn = null;
        try {
            System.out.println("Getting instructor by ID...");
            com.skylightstudio.classmanagement.model.Instructor instructor
                    = instructorDAO.getInstructorById(instructorId);

            if (instructor == null) {
                System.err.println("❌ ERROR: Instructor not found with ID: " + instructorId);
                response.setContentType("text/xml;charset=UTF-8");
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                PrintWriter out = response.getWriter();
                out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                out.print("<error><message>Instructor not found</message></error>");
                return;
            }

            System.out.println("✅ Found instructor: " + instructor.getName());

            conn = DBConnection.getConnection();
            System.out.println("✅ Database connection established");

            int totalConfirmedClasses = classConfirmationDAO.countConfirmedClassesForInstructor(instructorId);
            int cancelledClasses = classConfirmationDAO.countCancelledClassesForInstructor(instructorId);
            int completedClasses = totalConfirmedClasses - cancelledClasses;
            double completionRate = totalConfirmedClasses > 0
                    ? (completedClasses * 100.0 / totalConfirmedClasses) : 0;

            System.out.println("Total classes: " + totalConfirmedClasses);
            System.out.println("Cancelled: " + cancelledClasses);
            System.out.println("Completed: " + completedClasses);

            Map<String, Double> ratings = feedbackDAO.getAverageRatingsForInstructor(instructorId);

            double avgTeaching = ratings.getOrDefault("teaching", 0.0);
            double avgCommunication = ratings.getOrDefault("communication", 0.0);
            double avgSupport = ratings.getOrDefault("support", 0.0);
            double avgPunctuality = ratings.getOrDefault("punctuality", 0.0);
            double avgOverall = ratings.getOrDefault("overall", 0.0);

            if (Double.isNaN(avgTeaching)) {
                avgTeaching = 0;
            }
            if (Double.isNaN(avgCommunication)) {
                avgCommunication = 0;
            }
            if (Double.isNaN(avgSupport)) {
                avgSupport = 0;
            }
            if (Double.isNaN(avgPunctuality)) {
                avgPunctuality = 0;
            }
            if (Double.isNaN(avgOverall)) {
                avgOverall = 0;
            }

            System.out.println("✅ Ratings retrieved successfully");

            Map<String, Object> ratingExtremes = getRatingExtremesForPeriod(instructorId, period);
            System.out.println("✅ Rating extremes retrieved");

            List<Map<String, Object>> monthlyTrend = getMonthlyTrendForPeriod(instructorId, period);
            System.out.println("✅ Monthly trend retrieved, count: " + monthlyTrend.size());

            // Generate XML
            response.setContentType("text/xml;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_OK);
            PrintWriter out = response.getWriter();

            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<performance>");
            out.print("<instructorName>" + escapeXml(instructor.getName()) + "</instructorName>");
            out.print("<totalClasses>" + totalConfirmedClasses + "</totalClasses>");
            out.print("<cancelled>" + cancelledClasses + "</cancelled>");
            out.print("<completion>" + String.format("%.0f", completionRate) + "%</completion>");
            out.print("<teaching>" + String.format("%.1f", avgTeaching) + "</teaching>");
            out.print("<communication>" + String.format("%.1f", avgCommunication) + "</communication>");
            out.print("<support>" + String.format("%.1f", avgSupport) + "</support>");
            out.print("<punctuality>" + String.format("%.1f", avgPunctuality) + "</punctuality>");
            out.print("<overallRating>" + String.format("%.1f", avgOverall) + "</overallRating>");
            out.print("<teachingHighest>" + ratingExtremes.getOrDefault("maxTeaching", String.format("%.1f", avgTeaching)) + "</teachingHighest>");
            out.print("<communicationHighest>" + ratingExtremes.getOrDefault("maxCommunication", String.format("%.1f", avgCommunication)) + "</communicationHighest>");
            out.print("<supportHighest>" + ratingExtremes.getOrDefault("maxSupport", String.format("%.1f", avgSupport)) + "</supportHighest>");
            out.print("<punctualityHighest>" + ratingExtremes.getOrDefault("maxPunctuality", String.format("%.1f", avgPunctuality)) + "</punctualityHighest>");
            out.print("<overallHighest>" + ratingExtremes.getOrDefault("maxOverall", String.format("%.1f", avgOverall)) + "</overallHighest>");
            out.print("<teachingLowest>" + ratingExtremes.getOrDefault("minTeaching", String.format("%.1f", avgTeaching)) + "</teachingLowest>");
            out.print("<communicationLowest>" + ratingExtremes.getOrDefault("minCommunication", String.format("%.1f", avgCommunication)) + "</communicationLowest>");
            out.print("<supportLowest>" + ratingExtremes.getOrDefault("minSupport", String.format("%.1f", avgSupport)) + "</supportLowest>");
            out.print("<punctualityLowest>" + ratingExtremes.getOrDefault("minPunctuality", String.format("%.1f", avgPunctuality)) + "</punctualityLowest>");
            out.print("<overallLowest>" + ratingExtremes.getOrDefault("minOverall", String.format("%.1f", avgOverall)) + "</overallLowest>");
            out.print("<monthlyTrend>");
            for (Map<String, Object> monthData : monthlyTrend) {
                out.print("<month>");
                out.print("<name>" + monthData.get("name") + "</name>");
                out.print("<rating>" + monthData.get("rating") + "</rating>");
                out.print("<totalClasses>" + monthData.get("totalClasses") + "</totalClasses>");
                out.print("</month>");
            }
            out.print("</monthlyTrend>");
            out.print("</performance>");

            System.out.println("✅ XML response sent successfully");
            System.out.println("=== getCompletePerformanceData END ===");

        } catch (SQLException e) {
            System.err.println("❌ SQL ERROR in getCompletePerformanceData:");
            e.printStackTrace();
            response.setContentType("text/xml;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Database error: " + escapeXml(e.getMessage()) + "</message></error>");
        } catch (Exception e) {
            System.err.println("❌ GENERAL ERROR in getCompletePerformanceData:");
            e.printStackTrace();
            response.setContentType("text/xml;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            PrintWriter out = response.getWriter();
            out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.print("<error><message>Server error: " + escapeXml(e.getMessage()) + "</message></error>");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                    System.out.println("✅ Database connection closed");
                } catch (SQLException e) {
                    System.err.println("⚠️ Error closing connection: " + e.getMessage());
                }
            }
        }
    }

    // Helper method untuk get monthly trend berdasarkan period
    // ✅ ULTIMATE FIX: Cast both sides to DATE type
    private Map<String, Object> getRatingExtremesForPeriod(int instructorId, String period) throws SQLException {
        Map<String, Object> extremes = new HashMap<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            StringBuilder sql = new StringBuilder();

            sql.append("SELECT ")
                    .append("MAX(teachingSkill) as maxTeaching, ")
                    .append("MIN(teachingSkill) as minTeaching, ")
                    .append("MAX(communication) as maxCommunication, ")
                    .append("MIN(communication) as minCommunication, ")
                    .append("MAX(supportInteraction) as maxSupport, ")
                    .append("MIN(supportInteraction) as minSupport, ")
                    .append("MAX(punctuality) as maxPunctuality, ")
                    .append("MIN(punctuality) as minPunctuality, ")
                    .append("MAX(overallRating) as maxOverall, ")
                    .append("MIN(overallRating) as minOverall ")
                    .append("FROM feedback WHERE instructorID = ? ");

            // ✅ ULTIMATE FIX: Cast TIMESTAMPADD result to DATE
            if ("3months".equals(period)) {
                sql.append("AND feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -90, CURRENT_DATE)} AS DATE) ");
            } else if ("6months".equals(period)) {
                sql.append("AND feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -180, CURRENT_DATE)} AS DATE) ");
            } else if ("1year".equals(period)) {
                sql.append("AND feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -365, CURRENT_DATE)} AS DATE) ");
            }
            // "all" - no filter

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            stmt.setInt(1, instructorId);

            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                extremes.put("maxTeaching", String.format("%.1f", rs.getDouble("maxTeaching")));
                extremes.put("minTeaching", String.format("%.1f", rs.getDouble("minTeaching")));
                extremes.put("maxCommunication", String.format("%.1f", rs.getDouble("maxCommunication")));
                extremes.put("minCommunication", String.format("%.1f", rs.getDouble("minCommunication")));
                extremes.put("maxSupport", String.format("%.1f", rs.getDouble("maxSupport")));
                extremes.put("minSupport", String.format("%.1f", rs.getDouble("minSupport")));
                extremes.put("maxPunctuality", String.format("%.1f", rs.getDouble("maxPunctuality")));
                extremes.put("minPunctuality", String.format("%.1f", rs.getDouble("minPunctuality")));
                extremes.put("maxOverall", String.format("%.1f", rs.getDouble("maxOverall")));
                extremes.put("minOverall", String.format("%.1f", rs.getDouble("minOverall")));
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return extremes;
    }

    // Get monthly trend (for 3months, 6months, 1year)
    // ✅ ULTIMATE FIX: Cast TIMESTAMPADD result to DATE
    private List<Map<String, Object>> getMonthlyTrend(int instructorId, String period) throws SQLException {
        List<Map<String, Object>> monthlyData = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            StringBuilder sql = new StringBuilder();

            sql.append("SELECT ")
                    .append("MONTH(f.feedbackDate) as month_num, ")
                    .append("YEAR(f.feedbackDate) as year_num, ")
                    .append("AVG(f.overallRating) as avg_rating, ")
                    .append("COUNT(DISTINCT f.feedbackID) as feedback_count, ")
                    .append("COUNT(DISTINCT cc.classID) as total_classes ")
                    .append("FROM feedback f ")
                    .append("LEFT JOIN class_confirmation cc ON f.instructorID = cc.instructorID ")
                    .append("AND MONTH(f.feedbackDate) = MONTH(cc.actionAt) ")
                    .append("AND YEAR(f.feedbackDate) = YEAR(cc.actionAt) ")
                    .append("WHERE f.instructorID = ? ");

            // ✅ ULTIMATE FIX: Cast TIMESTAMPADD result to DATE
            if ("3months".equals(period)) {
                sql.append("AND f.feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -90, CURRENT_DATE)} AS DATE) ");
            } else if ("6months".equals(period)) {
                sql.append("AND f.feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -180, CURRENT_DATE)} AS DATE) ");
            } else if ("1year".equals(period)) {
                sql.append("AND f.feedbackDate >= CAST({fn TIMESTAMPADD(SQL_TSI_DAY, -365, CURRENT_DATE)} AS DATE) ");
            }

            sql.append("GROUP BY YEAR(f.feedbackDate), MONTH(f.feedbackDate) ")
                    .append("ORDER BY YEAR(f.feedbackDate) DESC, MONTH(f.feedbackDate) DESC ");

            PreparedStatement stmt = conn.prepareStatement(sql.toString());
            stmt.setInt(1, instructorId);
            stmt.setMaxRows(12);

            ResultSet rs = stmt.executeQuery();

            String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

            while (rs.next()) {
                Map<String, Object> monthData = new HashMap<>();
                int monthNum = rs.getInt("month_num");
                int yearNum = rs.getInt("year_num");

                String monthYear = monthNames[monthNum - 1] + " " + yearNum;

                monthData.put("name", monthYear);
                monthData.put("rating", String.format("%.1f", rs.getDouble("avg_rating")));
                monthData.put("totalClasses", rs.getInt("total_classes"));

                monthlyData.add(monthData);
            }

            // If no data, create dummy data
            if (monthlyData.isEmpty()) {
                monthlyData = createDummyMonthlyData(period);
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return monthlyData;
    }

// Keep method getMonthlyTrendForPeriod() as is (takde masalah)
    private List<Map<String, Object>> getMonthlyTrendForPeriod(int instructorId, String period) throws SQLException {
        List<Map<String, Object>> monthlyData = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            if ("all".equals(period)) {
                // For "all time", group by year
                monthlyData = getYearlyTrend(instructorId);
            } else {
                // For other periods, group by month
                monthlyData = getMonthlyTrend(instructorId, period);
            }

        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return monthlyData;
    }

    // ✅ FIXED: Get yearly trend (DERBY COMPATIBLE)
    private List<Map<String, Object>> getYearlyTrend(int instructorId) throws SQLException {
        List<Map<String, Object>> yearlyData = new ArrayList<>();
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();

            String sql = "SELECT "
                    + "YEAR(f.feedbackDate) as year_num, "
                    + "AVG(f.overallRating) as avg_rating, "
                    + "COUNT(DISTINCT f.feedbackID) as feedback_count, "
                    + "COUNT(DISTINCT cc.classID) as total_classes "
                    + "FROM feedback f "
                    + "LEFT JOIN class_confirmation cc ON f.instructorID = cc.instructorID "
                    + "AND YEAR(f.feedbackDate) = YEAR(cc.actionAt) "
                    + "WHERE f.instructorID = ? "
                    + "GROUP BY YEAR(f.feedbackDate) "
                    + "ORDER BY YEAR(f.feedbackDate) DESC";

            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, instructorId);
            stmt.setMaxRows(5); // ✅ FIXED: Guna setMaxRows() instead of FETCH FIRST

            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> yearData = new HashMap<>();
                int yearNum = rs.getInt("year_num");

                yearData.put("name", String.valueOf(yearNum));
                yearData.put("rating", String.format("%.1f", rs.getDouble("avg_rating")));
                yearData.put("totalClasses", rs.getInt("total_classes"));

                yearlyData.add(yearData);
            }

            // If no data, create dummy data
            if (yearlyData.isEmpty()) {
                yearlyData = createDummyYearlyData();
            }

            stmt.close();
        } finally {
            if (conn != null) {
                conn.close();
            }
        }

        return yearlyData;
    }

    // Create dummy monthly data for testing
    private List<Map<String, Object>> createDummyMonthlyData(String period) {
        List<Map<String, Object>> dummyData = new ArrayList<>();
        String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        int monthsToShow = 6; // default
        if ("3months".equals(period)) {
            monthsToShow = 3;
        } else if ("6months".equals(period)) {
            monthsToShow = 6;
        } else if ("1year".equals(period)) {
            monthsToShow = 12;
        }

        int currentMonth = java.util.Calendar.getInstance().get(java.util.Calendar.MONTH);
        int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

        for (int i = 0; i < monthsToShow; i++) {
            Map<String, Object> monthData = new HashMap<>();
            int monthIndex = (currentMonth - i + 12) % 12;
            int year = currentYear;
            if (currentMonth - i < 0) {
                year = currentYear - 1;
            }

            String monthYear = monthNames[monthIndex] + " " + year;
            monthData.put("name", monthYear);
            monthData.put("rating", "4.0");
            monthData.put("totalClasses", "5");

            dummyData.add(monthData);
        }

        // Reverse to chronological order
        java.util.Collections.reverse(dummyData);

        return dummyData;
    }

    // Create dummy yearly data for testing
    private List<Map<String, Object>> createDummyYearlyData() {
        List<Map<String, Object>> dummyData = new ArrayList<>();
        int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);

        for (int i = 0; i < 3; i++) {
            Map<String, Object> yearData = new HashMap<>();
            int year = currentYear - i;

            yearData.put("name", String.valueOf(year));
            yearData.put("rating", "4.0");
            yearData.put("totalClasses", "15");

            dummyData.add(yearData);
        }

        return dummyData;
    }
}
