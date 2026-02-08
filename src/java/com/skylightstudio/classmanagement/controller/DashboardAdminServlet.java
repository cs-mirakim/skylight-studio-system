package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.dao.FeedbackDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Date;

@WebServlet("/admin/DashboardAdminServlet")
public class DashboardAdminServlet extends HttpServlet {

    private ClassDAO classDAO;
    private FeedbackDAO feedbackDAO;
    private InstructorDAO instructorDAO;
    private RegistrationDAO registrationDAO;

    @Override
    public void init() throws ServletException {
        classDAO = new ClassDAO();
        feedbackDAO = new FeedbackDAO();
        instructorDAO = new InstructorDAO();
        registrationDAO = new RegistrationDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== [DashboardAdminServlet] Request received ===");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // Get real data from database
            Map<String, Object> dashboardData = getDashboardData();

            // Build JSON response manually
            StringBuilder json = new StringBuilder();
            json.append("{");

            // Add statistics
            json.append("\"totalActiveClasses\":").append(dashboardData.get("totalActiveClasses")).append(",");
            json.append("\"totalActiveInstructors\":").append(dashboardData.get("totalActiveInstructors")).append(",");
            json.append("\"averageRating\":").append(dashboardData.get("averageRating")).append(",");
            json.append("\"todaysClasses\":").append(dashboardData.get("todaysClasses")).append(",");
            json.append("\"pendingRegistrations\":").append(dashboardData.get("pendingRegistrations")).append(",");

            // Add monthly classes data
            json.append("\"monthlyClassesData\":{");
            json.append("\"labels\":[");
            List<String> monthLabels = (List<String>) dashboardData.get("monthLabels");
            for (int i = 0; i < monthLabels.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append("\"").append(monthLabels.get(i)).append("\"");
            }
            json.append("],");
            json.append("\"data\":[");
            List<Integer> monthlyCounts = (List<Integer>) dashboardData.get("monthlyCounts");
            for (int i = 0; i < monthlyCounts.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append(monthlyCounts.get(i));
            }
            json.append("]},");

            // Add class type distribution
            json.append("\"classTypeData\":{");
            json.append("\"labels\":[");
            List<String> typeLabels = (List<String>) dashboardData.get("typeLabels");
            for (int i = 0; i < typeLabels.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append("\"").append(typeLabels.get(i)).append("\"");
            }
            json.append("],");
            json.append("\"data\":[");
            List<Integer> typeCounts = (List<Integer>) dashboardData.get("typeCounts");
            for (int i = 0; i < typeCounts.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                json.append(typeCounts.get(i));
            }
            json.append("]},");

            // Add top instructors - TAMBAHKAN field hasRating untuk frontend
            json.append("\"topInstructors\":[");
            List<Map<String, Object>> topInstructors = (List<Map<String, Object>>) dashboardData.get("topInstructors");
            for (int i = 0; i < topInstructors.size(); i++) {
                if (i > 0) {
                    json.append(",");
                }
                Map<String, Object> instructor = topInstructors.get(i);
                json.append("{");
                json.append("\"id\":").append(instructor.get("id")).append(",");
                json.append("\"name\":\"").append(instructor.get("name")).append("\",");
                json.append("\"specialization\":\"").append(instructor.get("specialization")).append("\",");
                json.append("\"rating\":").append(instructor.get("rating")).append(",");
                json.append("\"hasRating\":").append(instructor.get("hasRating")).append(","); // New field
                json.append("\"initials\":\"").append(instructor.get("initials")).append("\"");
                json.append("}");
            }
            json.append("]");

            json.append("}");

            String jsonResponse = json.toString();
            System.out.println("=== [DashboardAdminServlet] Response sent ===");
            out.print(jsonResponse);

        } catch (Exception e) {
            System.err.println("=== [DashboardAdminServlet] ERROR ===");
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\":\"Server error: " + e.getMessage().replace("\"", "'") + "\"}");
        } finally {
            out.close();
        }
    }

    private Map<String, Object> getDashboardData() throws SQLException {
        Map<String, Object> data = new HashMap<>();

        // Get current date
        Calendar cal = Calendar.getInstance();
        int currentYear = cal.get(Calendar.YEAR);
        int currentMonth = cal.get(Calendar.MONTH) + 1; // Month is 0-based

        System.out.println("=== [DashboardAdminServlet] Getting data ===");
        System.out.println("Current Year: " + currentYear + ", Current Month: " + currentMonth);

        // Get statistics
        int totalActiveClasses = countTotalActiveClasses(); // Changed to count ALL active classes
        int totalActiveInstructors = countActiveInstructors();
        double averageRating = getAverageRating();
        int todaysClasses = countTodaysClasses();
        int pendingRegistrations = countPendingRegistrations();

        System.out.println("Statistics:");
        System.out.println("- Total Active Classes: " + totalActiveClasses);
        System.out.println("- Total Active Instructors: " + totalActiveInstructors);
        System.out.println("- Average Rating: " + averageRating);
        System.out.println("- Today's Classes: " + todaysClasses);
        System.out.println("- Pending Registrations: " + pendingRegistrations);

        data.put("totalActiveClasses", totalActiveClasses);
        data.put("totalActiveInstructors", totalActiveInstructors);
        data.put("averageRating", averageRating);
        data.put("todaysClasses", todaysClasses);
        data.put("pendingRegistrations", pendingRegistrations);

        // Get last 6 months data for chart
        List<String> monthLabels = new ArrayList<>();
        List<Integer> monthlyCounts = new ArrayList<>();

        try {
            SimpleDateFormat monthFormat = new SimpleDateFormat("MMM");

            // Get current date
            java.util.Date currentDate = new java.util.Date();

            // For last 6 months (from oldest to newest: 5 months ago to current month)
            for (int i = 5; i >= 0; i--) {
                Calendar monthCal = Calendar.getInstance();
                monthCal.setTime(currentDate);
                monthCal.add(Calendar.MONTH, -i); // -5, -4, -3, -2, -1, 0

                String monthName = monthFormat.format(monthCal.getTime());
                monthLabels.add(monthName);

                int year = monthCal.get(Calendar.YEAR);
                int month = monthCal.get(Calendar.MONTH) + 1;
                int count = countMonthlyClasses(year, month);
                monthlyCounts.add(count);

                System.out.println("Month " + monthName + " (" + year + "-" + month + "): " + count + " classes");
            }
        } catch (Exception e) {
            System.err.println("Error generating monthly data: " + e.getMessage());
            // Add default data if there's an error
            monthLabels = Arrays.asList("Jan", "Feb", "Mar", "Apr", "May", "Jun");
            monthlyCounts = Arrays.asList(0, 0, 0, 0, 0, 0);
        }

        data.put("monthLabels", monthLabels);
        data.put("monthlyCounts", monthlyCounts);

        // Get class type distribution for current month
        cal.set(Calendar.DAY_OF_MONTH, 1);
        java.sql.Date firstDay = new java.sql.Date(cal.getTimeInMillis());
        cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
        java.sql.Date lastDay = new java.sql.Date(cal.getTimeInMillis());

        Map<String, Integer> classTypeDist = getClassTypeDistribution(firstDay, lastDay);
        List<String> typeLabels = new ArrayList<>(classTypeDist.keySet());
        List<Integer> typeCounts = new ArrayList<>();

        System.out.println("Class Type Distribution:");
        for (String label : typeLabels) {
            int count = classTypeDist.get(label);
            typeCounts.add(count);
            System.out.println("- " + label + ": " + count);
        }

        data.put("typeLabels", typeLabels);
        data.put("typeCounts", typeCounts);

        // Get top instructors - UPDATED: tanpa dummy data
        List<Map<String, Object>> topInstructors = getTopInstructors(3);
        data.put("topInstructors", topInstructors);

        return data;
    }

    // NEW METHOD: Count ALL active classes (not just current month)
    private int countTotalActiveClasses() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            stmt = conn.createStatement();

            // Count ALL active classes regardless of date
            String sql = "SELECT COUNT(*) as count FROM class WHERE classStatus = 'active'";
            System.out.println("Executing query: " + sql);

            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("Total active classes found: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("Error counting total active classes: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

    private int countMonthlyClasses(int year, int month) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();

            // GANTI dengan syntax yang compatible dengan Derby
            String sql = "SELECT COUNT(*) as count FROM class "
                    + "WHERE classStatus = 'active' "
                    + "AND YEAR(classDate) = ? "
                    + "AND MONTH(classDate) = ?";

            System.out.println("Executing monthly query for " + year + "-" + month + ": " + sql);

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, year);
            stmt.setInt(2, month);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.err.println("Error counting monthly classes: " + e.getMessage());
            e.printStackTrace();

            // Fallback: try alternative approach
            return countMonthlyClassesAlternative(year, month);
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

// Alternative method jika query pertama gagal
    private int countMonthlyClassesAlternative(int year, int month) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();

            // Create start and end dates in Java
            Calendar cal = Calendar.getInstance();
            cal.set(year, month - 1, 1); // month is 0-based
            Date firstDay = new Date(cal.getTimeInMillis());

            cal.set(Calendar.DAY_OF_MONTH, cal.getActualMaximum(Calendar.DAY_OF_MONTH));
            Date lastDay = new Date(cal.getTimeInMillis());

            String sql = "SELECT COUNT(*) as count FROM class "
                    + "WHERE classStatus = 'active' "
                    + "AND classDate >= ? "
                    + "AND classDate <= ?";

            System.out.println("Executing alternative monthly query for " + year + "-" + month);

            stmt = conn.prepareStatement(sql);
            stmt.setDate(1, firstDay);
            stmt.setDate(2, lastDay);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException e) {
            System.err.println("Error in alternative monthly count: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

    private int countActiveInstructors() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT COUNT(*) as count FROM instructor WHERE status = 'active'";
            System.out.println("Executing query: " + sql);

            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("Active instructors found: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("Error counting active instructors: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

    // UPDATED METHOD: Get overall average rating
    private double getAverageRating() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT AVG(overallRating) as avg_rating FROM feedback";
            System.out.println("Executing query: " + sql);

            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                double avg = rs.getDouble("avg_rating");
                System.out.println("Average rating found: " + avg);
                return rs.wasNull() ? 0.0 : Math.round(avg * 10.0) / 10.0;
            }
        } catch (SQLException e) {
            System.err.println("Error getting average rating: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0.0;
    }

    private int countTodaysClasses() {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();

            // Get today's date
            java.util.Date today = new java.util.Date();
            java.sql.Date sqlDate = new java.sql.Date(today.getTime());

            String sql = "SELECT COUNT(*) as count FROM class WHERE classStatus = 'active' "
                    + "AND classDate = ?";
            System.out.println("Executing query for today's classes: " + sql);
            System.out.println("Today's date: " + sqlDate);

            stmt = conn.prepareStatement(sql);
            stmt.setDate(1, sqlDate);
            rs = stmt.executeQuery();

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("Today's classes found: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("Error counting today's classes: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

    private int countPendingRegistrations() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            stmt = conn.createStatement();
            String sql = "SELECT COUNT(*) as count FROM registration WHERE status = 'pending' "
                    + "AND userType = 'instructor'";
            System.out.println("Executing query: " + sql);

            rs = stmt.executeQuery(sql);

            if (rs.next()) {
                int count = rs.getInt("count");
                System.out.println("Pending registrations found: " + count);
                return count;
            }
        } catch (SQLException e) {
            System.err.println("Error counting pending registrations: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }
        return 0;
    }

    private Map<String, Integer> getClassTypeDistribution(java.sql.Date startDate, java.sql.Date endDate) {
        Map<String, Integer> distribution = new HashMap<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            String sql = "SELECT classType, COUNT(*) as count FROM class "
                    + "WHERE classStatus = 'active' AND classDate BETWEEN ? AND ? "
                    + "GROUP BY classType";

            System.out.println("Executing class type distribution query: " + sql);
            System.out.println("Start date: " + startDate + ", End date: " + endDate);

            stmt = conn.prepareStatement(sql);
            stmt.setDate(1, startDate);
            stmt.setDate(2, endDate);
            rs = stmt.executeQuery();

            while (rs.next()) {
                String type = rs.getString("classType");
                if (type == null || type.trim().isEmpty()) {
                    type = "Unspecified";
                }
                int count = rs.getInt("count");
                distribution.put(type, count);
            }
        } catch (SQLException e) {
            System.err.println("Error getting class type distribution: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }

        // Ensure we always have some data for the chart
        if (distribution.isEmpty()) {
            distribution.put("Mat Pilates", 0);
            distribution.put("Reformer", 0);
        }

        return distribution;
    }

    // UPDATED METHOD: Get top instructors - HANYA data real, TANPA dummy
    private List<Map<String, Object>> getTopInstructors(int limit) {
        List<Map<String, Object>> instructors = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();

            // Query untuk mendapatkan instructor dengan rating dari feedback
            // Hanya yang memiliki feedback dan rating
            String sql = "SELECT i.instructorID, i.name, "
                    + "AVG(f.overallRating) as avg_rating, "
                    + "COUNT(f.feedbackID) as feedback_count "
                    + "FROM instructor i "
                    + "INNER JOIN feedback f ON i.instructorID = f.instructorID "
                    + "WHERE i.status = 'active' "
                    + "GROUP BY i.instructorID, i.name "
                    + "HAVING COUNT(f.feedbackID) > 0 "
                    + "ORDER BY avg_rating DESC "
                    + "FETCH FIRST ? ROWS ONLY";

            System.out.println("Executing top instructors query: " + sql);

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, limit);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> instructor = new HashMap<>();
                String name = rs.getString("name");
                double avgRating = rs.getDouble("avg_rating");
                int feedbackCount = rs.getInt("feedback_count");

                // Hanya tambahkan jika ada rating yang valid
                if (avgRating > 0) {
                    instructor.put("id", rs.getInt("instructorID"));
                    instructor.put("name", name);
                    instructor.put("rating", Math.round(avgRating * 10.0) / 10.0);
                    instructor.put("hasRating", true);
                    instructor.put("feedbackCount", feedbackCount);
                    instructor.put("specialization", getSpecializationFromName(name));
                    instructor.put("initials", getInitials(name));

                    instructors.add(instructor);
                    System.out.println("Found rated instructor: " + name
                            + ", Rating: " + avgRating
                            + ", Feedbacks: " + feedbackCount);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting top instructors: " + e.getMessage());
            e.printStackTrace();

            // Jika query kompleks error, coba query sederhana
            return getSimpleTopInstructors(limit);
        } finally {
            closeResources(rs, stmt, conn);
        }

        System.out.println("Total rated instructors found: " + instructors.size());

        // Jika tidak ada instructor dengan rating, return list kosong
        // TIDAK ADA placeholder/dummy data
        return instructors;
    }

    // Fallback method: Query sederhana jika query kompleks error
    private List<Map<String, Object>> getSimpleTopInstructors(int limit) {
        List<Map<String, Object>> instructors = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            conn = com.skylightstudio.classmanagement.util.DBConnection.getConnection();
            stmt = conn.createStatement();

            // Query sederhana: hanya ambil active instructors
            String sql = "SELECT instructorID, name FROM instructor "
                    + "WHERE status = 'active' "
                    + "ORDER BY name "
                    + "FETCH FIRST " + limit + " ROWS ONLY";

            System.out.println("Executing simple top instructors query: " + sql);

            rs = stmt.executeQuery(sql);

            while (rs.next()) {
                Map<String, Object> instructor = new HashMap<>();
                String name = rs.getString("name");

                instructor.put("id", rs.getInt("instructorID"));
                instructor.put("name", name);
                instructor.put("rating", 0.0); // Rating 0 karena tidak ada data feedback
                instructor.put("hasRating", false); // Flag bahwa tidak ada rating
                instructor.put("specialization", getSpecializationFromName(name));
                instructor.put("initials", getInitials(name));

                instructors.add(instructor);
                System.out.println("Found instructor (no rating): " + name);
            }
        } catch (SQLException e) {
            System.err.println("Error in simple top instructors query: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(rs, stmt, conn);
        }

        return instructors; // Bisa return list kosong
    }

    private String getSpecializationFromName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "General Instructor";
        }

        String[] specializations = {
            "Mat Pilates Specialist",
            "Reformer Expert",
            "Beginner Classes",
            "Advanced Pilates",
            "Yoga Fusion"
        };

        int hash = Math.abs(name.hashCode());
        return specializations[hash % specializations.length];
    }

    private String getInitials(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "??";
        }

        String[] parts = name.split(" ");
        if (parts.length >= 2) {
            String firstChar = parts[0].substring(0, 1);
            String lastChar = parts[parts.length - 1].substring(0, 1);
            return (firstChar + lastChar).toUpperCase();
        } else if (parts.length == 1 && parts[0].length() >= 2) {
            return parts[0].substring(0, 2).toUpperCase();
        } else {
            return name.substring(0, Math.min(2, name.length())).toUpperCase();
        }
    }

    private void closeResources(ResultSet rs, Statement stmt, Connection conn) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (stmt != null) {
                stmt.close();
            }
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
