package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.*;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.SessionUtil;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.time.DayOfWeek;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet(name = "DashboardInstructorServlet", urlPatterns = {"/DashboardInstructorServlet"})
public class DashboardInstructorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        // Check if instructor is logged in
        if (!SessionUtil.checkInstructorAccess(session)) {
            out.print("{\"success\":false,\"message\":\"Access denied. Please login as instructor.\"}");
            out.flush();
            return;
        }

        Instructor instructor = SessionUtil.getInstructorObject(session);
        if (instructor == null) {
            out.print("{\"success\":false,\"message\":\"Session expired. Please login again.\"}");
            out.flush();
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            out.print("{\"success\":false,\"message\":\"Action parameter is required\"}");
            out.flush();
            return;
        }

        try {
            switch (action) {
                case "getInstructorInfo":
                    getInstructorInfo(instructor, out);
                    break;
                case "getTodaySchedule":
                    getTodaySchedule(instructor, out);
                    break;
                case "getWeekOverview":
                    // Get custom week range if provided
                    String weekStartParam = request.getParameter("weekStart");
                    String weekEndParam = request.getParameter("weekEnd");

                    if (weekStartParam != null && weekEndParam != null) {
                        getCustomWeekOverview(instructor, weekStartParam, weekEndParam, out);
                    } else {
                        getCurrentWeekOverview(instructor, out);
                    }
                    break;
                default:
                    out.print("{\"success\":false,\"message\":\"Invalid action\"}");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error processing request: "
                    + e.getMessage().replace("\"", "\\\"") + "\"}");
        }

        out.flush();
    }

    private void getInstructorInfo(Instructor instructor, PrintWriter out) throws Exception {
        ClassDAO classDao = new ClassDAO();
        FeedbackDAO feedbackDao = new FeedbackDAO();

        LocalDate today = LocalDate.now();
        int currentMonth = today.getMonthValue();
        int currentYear = today.getYear();

        // Get monthly class count
        int monthlyClassCount = classDao.getMonthlyClassCount(instructor.getInstructorID(), currentMonth, currentYear);

        // Get average rating
        Map<String, Double> averageRatings = feedbackDao.getAverageRatingsForInstructor(instructor.getInstructorID());
        double overallRating = averageRatings.getOrDefault("overall", 0.0);

        // Calculate joined year
        int joinedYear = 2020; // default
        if (instructor.getDateJoined() != null) {
            Calendar cal = Calendar.getInstance();
            cal.setTime(instructor.getDateJoined());
            joinedYear = cal.get(Calendar.YEAR);
        }

        // Build JSON manually
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"instructor\":{");
        json.append("\"instructorID\":").append(instructor.getInstructorID()).append(",");
        json.append("\"name\":\"").append(escapeJson(instructor.getName())).append("\",");
        json.append("\"status\":\"").append(escapeJson(instructor.getStatus())).append("\",");
        json.append("\"joinedYear\":").append(joinedYear);
        json.append("},");
        json.append("\"stats\":{");
        json.append("\"monthlyClassCount\":").append(monthlyClassCount).append(",");
        json.append("\"overallRating\":").append(overallRating);
        json.append("}");
        json.append("}");
        json.append("}");

        out.print(json.toString());
    }

    private void getTodaySchedule(Instructor instructor, PrintWriter out) throws Exception {
        ClassDAO classDao = new ClassDAO();
        FeedbackDAO feedbackDao = new FeedbackDAO();

        int instructorId = instructor.getInstructorID();

        // Get today's classes
        List<Map<String, Object>> allTodayClasses = classDao.getTodayClassesForInstructor(instructorId);

        // ✅ FILTER: Only show CONFIRMED classes in Today's Schedule
        List<Map<String, Object>> confirmedClasses = allTodayClasses.stream()
                .filter(classData -> {
                    String status = (String) classData.get("status");
                    return "confirmed".equalsIgnoreCase(status);
                })
                .collect(Collectors.toList());

        // Format date
        LocalDate today = LocalDate.now();
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMMM d, yyyy");
        String formattedDate = today.format(dateFormatter);

        // Get average rating
        Map<String, Double> averageRatings = feedbackDao.getAverageRatingsForInstructor(instructorId);
        double overallRating = averageRatings.getOrDefault("overall", 0.0);

        // Build JSON for today classes (CONFIRMED ONLY)
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"formattedDate\":\"").append(escapeJson(formattedDate)).append("\",");
        json.append("\"todayClassesCount\":").append(confirmedClasses.size()).append(",");
        json.append("\"todayClasses\":[");

        boolean firstClass = true;
        for (Map<String, Object> classData : confirmedClasses) {
            if (!firstClass) {
                json.append(",");
            }
            firstClass = false;

            json.append("{");
            json.append("\"classID\":").append(classData.get("classID")).append(",");
            json.append("\"className\":\"").append(escapeJson((String) classData.get("className"))).append("\",");
            json.append("\"classStartTime\":\"").append(escapeJson(classData.get("classStartTime").toString())).append("\",");
            json.append("\"classEndTime\":\"").append(escapeJson(classData.get("classEndTime").toString())).append("\",");

            String location = (String) classData.get("location");
            json.append("\"location\":\"").append(escapeJson(location != null ? location : "")).append("\",");

            // FIX QR CODE PATH
            String qrPath = (String) classData.get("qrcodeFilePath");
            String qrPathToUse = "";
            if (qrPath != null && !qrPath.isEmpty()) {
                // Check if path already has "../"
                if (qrPath.startsWith("../")) {
                    qrPathToUse = qrPath;
                } else {
                    // Add "../" if not present
                    qrPathToUse = "../" + qrPath;
                }
            } else {
                qrPathToUse = "../qr_codes/dummy.png";
            }
            json.append("\"qrcodeFilePath\":\"").append(escapeJson(qrPathToUse)).append("\",");

            String status = (String) classData.get("status");
            json.append("\"status\":\"").append(escapeJson(status != null ? status : "")).append("\",");
            json.append("\"instructorName\":\"").append(escapeJson(instructor.getName())).append("\",");
            json.append("\"averageRating\":").append(overallRating);
            json.append("}");
        }

        json.append("]");
        json.append("}");
        json.append("}");

        out.print(json.toString());
    }

    private void getCurrentWeekOverview(Instructor instructor, PrintWriter out) throws Exception {
        ClassDAO classDao = new ClassDAO();

        int instructorId = instructor.getInstructorID();
        LocalDate today = LocalDate.now();

        // Get week range (Monday to Sunday)
        LocalDate monday = today.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate sunday = today.with(TemporalAdjusters.nextOrSame(DayOfWeek.SUNDAY));

        // Convert to SQL Date
        Date sqlMonday = Date.valueOf(monday);
        Date sqlSunday = Date.valueOf(sunday);

        // Get weekly data
        getWeekData(instructorId, monday, sunday, sqlMonday, sqlSunday, out);
    }

    private void getCustomWeekOverview(Instructor instructor, String weekStartStr, String weekEndStr, PrintWriter out) throws Exception {
        ClassDAO classDao = new ClassDAO();

        int instructorId = instructor.getInstructorID();

        // Parse custom dates
        LocalDate monday = LocalDate.parse(weekStartStr);
        LocalDate sunday = LocalDate.parse(weekEndStr);

        // Convert to SQL Date
        Date sqlMonday = Date.valueOf(monday);
        Date sqlSunday = Date.valueOf(sunday);

        // Get weekly data
        getWeekData(instructorId, monday, sunday, sqlMonday, sqlSunday, out);
    }

    private void getWeekData(int instructorId, LocalDate monday, LocalDate sunday,
            Date sqlMonday, Date sqlSunday, PrintWriter out) throws Exception {
        ClassDAO classDao = new ClassDAO();

        DateTimeFormatter weekFormatter = DateTimeFormatter.ofPattern("MMM d");
        String weekRange = monday.format(weekFormatter) + " - " + sunday.format(weekFormatter);

        // Get weekly classes
        List<Map<String, Object>> weeklyClasses = classDao.getWeeklyClassesForInstructor(instructorId, sqlMonday, sqlSunday);

        // Get weekly stats
        Map<String, Integer> weeklyStats = classDao.getWeeklyStats(instructorId, sqlMonday, sqlSunday);

        // Build JSON
        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":true,");
        json.append("\"data\":{");
        json.append("\"weekRange\":\"").append(escapeJson(weekRange)).append("\",");
        json.append("\"weekStart\":\"").append(monday.toString()).append("\",");
        json.append("\"weekEnd\":\"").append(sunday.toString()).append("\",");
        json.append("\"weeklyStats\":{");
        json.append("\"confirmed\":").append(weeklyStats.getOrDefault("confirmed", 0)).append(",");
        json.append("\"pending\":").append(weeklyStats.getOrDefault("pending", 0));
        json.append("},");
        json.append("\"weeklyCalendar\":{");

        // Build weekly calendar
        Map<String, List<Map<String, Object>>> weeklyCalendar = prepareWeeklyCalendar(weeklyClasses, monday, sunday);
        boolean firstDay = true;

        for (Map.Entry<String, List<Map<String, Object>>> entry : weeklyCalendar.entrySet()) {
            if (!firstDay) {
                json.append(",");
            }
            firstDay = false;

            json.append("\"").append(entry.getKey()).append("\":[");

            boolean firstClass = true;
            for (Map<String, Object> classData : entry.getValue()) {
                if (!firstClass) {
                    json.append(",");
                }
                firstClass = false;

                json.append("{");
                json.append("\"className\":\"").append(escapeJson((String) classData.get("className"))).append("\",");
                json.append("\"classStartTime\":\"").append(escapeJson(classData.get("classStartTime").toString())).append("\",");

                // Add location if available
                String location = (String) classData.get("location");
                if (location != null) {
                    json.append("\"location\":\"").append(escapeJson(location)).append("\",");
                }

                json.append("\"classEndTime\":\"").append(escapeJson(classData.get("classEndTime").toString())).append("\",");
                json.append("\"status\":\"").append(escapeJson((String) classData.get("status"))).append("\"");
                json.append("}");
            }

            json.append("]");
        }

        json.append("}");
        json.append("}");
        json.append("}");

        out.print(json.toString());
    }

    private Map<String, List<Map<String, Object>>> prepareWeeklyCalendar(List<Map<String, Object>> weeklyClasses,
            LocalDate startDate, LocalDate endDate) {
        Map<String, List<Map<String, Object>>> calendar = new LinkedHashMap<>();

        // Initialize each day of week
        LocalDate current = startDate;
        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("EEE");

        while (!current.isAfter(endDate)) {
            String dayKey = current.format(dayFormatter) + "_" + current.getDayOfMonth();
            calendar.put(dayKey, new ArrayList<Map<String, Object>>());
            current = current.plusDays(1);
        }

        // Group classes by day
        for (Map<String, Object> classData : weeklyClasses) {
            Date classDate = (Date) classData.get("classDate");
            LocalDate localClassDate = classDate.toLocalDate();
            String dayKey = localClassDate.format(dayFormatter) + "_" + localClassDate.getDayOfMonth();

            if (calendar.containsKey(dayKey)) {
                calendar.get(dayKey).add(classData);
            }
        }

        return calendar;
    }

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
