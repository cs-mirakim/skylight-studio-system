package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.dao.ClassConfirmationDAO;
import com.skylightstudio.classmanagement.model.Class;
import com.skylightstudio.classmanagement.util.SessionUtil;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;


@WebServlet(name = "ClassConfirmationServlet", urlPatterns = {"/ClassConfirmationServlet"})
public class ClassConfirmationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== ClassConfirmationServlet.doGet() called ===");
        System.out.println("Request URL: " + request.getRequestURL());
        System.out.println("Query String: " + request.getQueryString());

        HttpSession session = request.getSession(false);
        System.out.println("Session exists: " + (session != null));

        // Check instructor access
        if (!SessionUtil.checkInstructorAccess(session)) {
            System.out.println("ERROR: Instructor access denied");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Instructor access required");
            return;
        }

        Integer instructorId = SessionUtil.getCurrentInstructorId(session);
        System.out.println("Instructor ID from session: " + instructorId);

        if (instructorId == null) {
            System.out.println("ERROR: Not logged in");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        String action = request.getParameter("action");
        System.out.println("Action parameter: " + action);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            if ("getClasses".equals(action)) {
                System.out.println("Getting available classes for instructor: " + instructorId);
                getAvailableClasses(instructorId, out);
            } else if ("getClassDetails".equals(action)) {
                String classIdStr = request.getParameter("classId");
                System.out.println("Getting class details for classId: " + classIdStr);
                if (classIdStr != null) {
                    int classId = Integer.parseInt(classIdStr);
                    getClassDetails(classId, instructorId, out);
                } else {
                    out.print("{\"error\": \"Class ID required\"}");
                }
            } else {
                System.out.println("ERROR: Invalid action: " + action);
                out.print("{\"error\": \"Invalid action\"}");
            }
        } catch (Exception e) {
            System.out.println("ERROR in doGet: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"error\": \"Server error: " + e.getMessage().replace("\"", "'") + "\"}");
        }

        System.out.println("=== ClassConfirmationServlet.doGet() completed ===");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("=== ClassConfirmationServlet.doPost() called ===");
        System.out.println("Request URL: " + request.getRequestURL());

        // Log all parameters
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            System.out.println("Parameter: " + paramName + " = " + request.getParameter(paramName));
        }

        HttpSession session = request.getSession(false);
        System.out.println("Session exists: " + (session != null));

        // Check instructor access
        if (!SessionUtil.checkInstructorAccess(session)) {
            System.out.println("ERROR: Instructor access denied in POST");
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Instructor access required");
            return;
        }

        Integer instructorId = SessionUtil.getCurrentInstructorId(session);
        System.out.println("Instructor ID from session: " + instructorId);

        if (instructorId == null) {
            System.out.println("ERROR: Not logged in");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }

        String action = request.getParameter("action");
        String classIdStr = request.getParameter("classId");

        System.out.println("Action: " + action);
        System.out.println("ClassId: " + classIdStr);

        if (classIdStr == null || classIdStr.isEmpty()) {
            System.out.println("ERROR: Class ID is null or empty");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Class ID required");
            return;
        }

        int classId = 0;
        try {
            classId = Integer.parseInt(classIdStr);
            System.out.println("Parsed classId: " + classId);
        } catch (NumberFormatException e) {
            System.out.println("ERROR: Invalid classId format: " + classIdStr);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Class ID format");
            return;
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        ClassConfirmationDAO ccDao = new ClassConfirmationDAO();
        ClassDAO classDao = new ClassDAO();
        Map<String, Object> result = new HashMap<>();

        try {
            // Check if class exists and is active
            System.out.println("Getting class by ID: " + classId);
            Class cls = classDao.getClassById(classId);
            if (cls == null) {
                System.out.println("ERROR: Class not found for ID: " + classId);
                result.put("success", false);
                result.put("message", "Class not found");
                out.print(mapToJson(result));
                return;
            }

            System.out.println("Class found: " + cls.getClassName() + ", Status: " + cls.getClassStatus());

            if (!"active".equals(cls.getClassStatus())) {
                System.out.println("ERROR: Class is not active. Status: " + cls.getClassStatus());
                result.put("success", false);
                result.put("message", "Class is cancelled/inactive");
                out.print(mapToJson(result));
                return;
            }

            boolean success = false;
            String message = "";

            if ("confirm".equals(action)) {
                System.out.println("Processing CONFIRM action");

                // Check if instructor already in class
                System.out.println("Checking if instructor " + instructorId + " is already in class " + classId);
                boolean isInstructorInClass = classDao.isInstructorInClass(classId, instructorId);
                System.out.println("Instructor already in class: " + isInstructorInClass);

                if (isInstructorInClass) {
                    System.out.println("ERROR: Instructor already in this class");
                    result.put("success", false);
                    result.put("message", "Instructor already in this class");
                    out.print(mapToJson(result));
                    return;
                }

                // Check current number of instructors
                int instructorCount = classDao.countInstructorsForClass(classId);
                System.out.println("Current instructor count for class " + classId + ": " + instructorCount);

                // Check if there's already a main instructor
                Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
                boolean hasMainInstructor = classDetails != null && classDetails.containsKey("mainInstructor");
                System.out.println("Has main instructor: " + hasMainInstructor);

                if (hasMainInstructor) {
                    System.out.println("ERROR: Class already has a main instructor");
                    result.put("success", false);
                    result.put("message", "Class already has a main instructor");
                    out.print(mapToJson(result));
                    return;
                }

                if (instructorCount >= 2) {
                    System.out.println("ERROR: Class already has maximum instructors (2)");
                    result.put("success", false);
                    result.put("message", "Class already has maximum instructors");
                    out.print(mapToJson(result));
                    return;
                }

                success = ccDao.confirmAsMainInstructor(classId, instructorId);
                message = success ? "Confirmed as main instructor" : "Cannot confirm as main instructor";
                System.out.println("Confirm action result: " + success + ", Message: " + message);

            } else if ("requestRelief".equals(action)) {
                System.out.println("Processing REQUEST RELIEF action");

                // Check if instructor already in class
                System.out.println("Checking if instructor " + instructorId + " is already in class " + classId);
                boolean isInstructorInClass = classDao.isInstructorInClass(classId, instructorId);
                System.out.println("Instructor already in class: " + isInstructorInClass);

                if (isInstructorInClass) {
                    System.out.println("ERROR: Instructor already in this class");
                    result.put("success", false);
                    result.put("message", "Instructor already in this class");
                    out.print(mapToJson(result));
                    return;
                }

                // Check current number of instructors
                int instructorCount = classDao.countInstructorsForClass(classId);
                System.out.println("Current instructor count for class " + classId + ": " + instructorCount);

                // Check if there's already a main instructor
                Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
                boolean hasMainInstructor = classDetails != null && classDetails.containsKey("mainInstructor");
                System.out.println("Has main instructor: " + hasMainInstructor);

                if (!hasMainInstructor) {
                    System.out.println("ERROR: Cannot request relief - no main instructor assigned yet");
                    result.put("success", false);
                    result.put("message", "Please wait for main instructor to confirm first");
                    out.print(mapToJson(result));
                    return;
                }

                // Check if there's already a relief instructor
                boolean hasReliefInstructor = classDetails != null && classDetails.containsKey("reliefInstructor");
                System.out.println("Has relief instructor: " + hasReliefInstructor);

                if (hasReliefInstructor) {
                    System.out.println("ERROR: Class already has a relief instructor");
                    result.put("success", false);
                    result.put("message", "Class already has a relief instructor");
                    out.print(mapToJson(result));
                    return;
                }

                if (instructorCount >= 2) {
                    System.out.println("ERROR: Class already has maximum instructors (2)");
                    result.put("success", false);
                    result.put("message", "Class already has maximum instructors");
                    out.print(mapToJson(result));
                    return;
                }

                success = ccDao.requestAsReliefInstructor(classId, instructorId);
                message = success ? "Requested as relief instructor" : "Cannot request as relief instructor";
                System.out.println("Request relief action result: " + success + ", Message: " + message);

            } else if ("withdraw".equals(action)) {
                System.out.println("Processing WITHDRAW action");

                // First check if instructor is actually in the class
                String instructorStatus = ccDao.getInstructorStatus(classId, instructorId);
                System.out.println("Instructor status for class " + classId + ": " + instructorStatus);

                if (instructorStatus == null) {
                    System.out.println("ERROR: Instructor not found in class");
                    result.put("success", false);
                    result.put("message", "You are not assigned to this class");
                    out.print(mapToJson(result));
                    return;
                }

                // IMPORTANT: For withdrawal, we DON'T check if instructor is in class
                // because withdrawal is only for instructors who ARE in the class
                success = ccDao.withdrawFromClass(classId, instructorId);
                message = success ? "Withdrawn from class" : "Cannot withdraw from class";
                System.out.println("Withdraw action result: " + success + ", Message: " + message);

            } else {
                System.out.println("ERROR: Invalid action: " + action);
                result.put("success", false);
                result.put("message", "Invalid action");
                out.print(mapToJson(result));
                return;
            }

            result.put("success", success);
            result.put("message", message);

            if (success) {
                // Get updated class details
                Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
                result.put("classDetails", classDetails);
                System.out.println("Action successful, returning updated class details");
            }

            System.out.println("Final result: " + mapToJson(result));
            out.print(mapToJson(result));

        } catch (Exception e) {
            System.out.println("ERROR in doPost: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "Server error: " + e.getMessage().replace("\"", "'"));
            out.print(mapToJson(result));
        }

        System.out.println("=== ClassConfirmationServlet.doPost() completed ===");
    }

    // In ClassConfirmationServlet.java - update the getAvailableClasses method
    private void getAvailableClasses(int instructorId, PrintWriter out) {
        System.out.println("=== getAvailableClasses() for instructor: " + instructorId + " ===");

        ClassDAO classDao = new ClassDAO();
        // Use the new method that gets ALL active classes
        List<Class> classes = classDao.getClassesForInstructor(instructorId);
        System.out.println("Found " + classes.size() + " total active classes");

        // Format for FullCalendar
        List<Map<String, Object>> events = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm:ss");

        for (Class cls : classes) {
            System.out.println("Processing class: " + cls.getClassName() + " (ID: " + cls.getClassID() + ")");

            Map<String, Object> event = new HashMap<>();
            event.put("id", cls.getClassID());
            event.put("title", cls.getClassName());

            // Format dates
            String startDate = dateFormat.format(cls.getClassDate());
            String startTime = timeFormat.format(cls.getClassStartTime());
            String endDate = dateFormat.format(cls.getClassDate());
            String endTime = timeFormat.format(cls.getClassEndTime());

            event.put("start", startDate + "T" + startTime);
            event.put("end", endDate + "T" + endTime);

            System.out.println("Event start: " + event.get("start") + ", end: " + event.get("end"));

            // Get instructor status and details
            ClassConfirmationDAO ccDao = new ClassConfirmationDAO();
            String status = ccDao.getInstructorStatus(cls.getClassID(), instructorId);
            System.out.println("Instructor status: " + status);

            Map<String, Object> extendedProps = new HashMap<>();
            extendedProps.put("location", cls.getLocation());
            extendedProps.put("description", cls.getDescription());
            extendedProps.put("capacity", cls.getNoOfParticipant());
            extendedProps.put("currentStudents", 0); // You can implement this
            extendedProps.put("classId", cls.getClassID());

            // Get instructor assignments
            Map<String, Object> classDetails = classDao.getClassWithInstructors(cls.getClassID());

            if (classDetails != null) {
                if (classDetails.containsKey("mainInstructor")) {
                    extendedProps.put("mainInstructor", classDetails.get("mainInstructor"));
                    System.out.println("Has main instructor");
                } else {
                    System.out.println("No main instructor");
                }

                if (classDetails.containsKey("reliefInstructor")) {
                    extendedProps.put("reliefInstructor", classDetails.get("reliefInstructor"));
                    System.out.println("Has relief instructor");
                } else {
                    System.out.println("No relief instructor");
                }
            }

            // Set event color based on instructor's status in this class
            if (status != null) {
                if ("confirmed".equals(status)) {
                    event.put("className", "fc-event-confirmed");
                    extendedProps.put("status", "confirmed");
                    System.out.println("Setting status: confirmed (Green)");
                } else if ("pending".equals(status)) {
                    event.put("className", "fc-event-pending");
                    extendedProps.put("status", "pending");
                    System.out.println("Setting status: pending (Yellow)");
                }
            } else {
                // Check if class has both instructors
                boolean hasMainInstructor = classDetails != null && classDetails.containsKey("mainInstructor");
                boolean hasReliefInstructor = classDetails != null && classDetails.containsKey("reliefInstructor");

                if (hasMainInstructor && hasReliefInstructor) {
                    // Class has both instructors - instructor is not involved
                    event.put("className", "fc-event-available");
                    extendedProps.put("status", "unavailable");
                    System.out.println("Setting status: unavailable (Blue but hidden from others)");
                } else if (hasMainInstructor && !hasReliefInstructor) {
                    // Class has main instructor but needs relief
                    event.put("className", "fc-event-available");
                    extendedProps.put("status", "available_relief");
                    System.out.println("Setting status: available for relief (Blue)");
                } else {
                    // Class has no instructors
                    event.put("className", "fc-event-available");
                    extendedProps.put("status", "available_main");
                    System.out.println("Setting status: available for main (Blue)");
                }
            }

            event.put("extendedProps", extendedProps);
            events.add(event);
        }

        String jsonResponse = "{\"events\": " + mapToJson(events) + "}";
        System.out.println("Sending JSON response with " + events.size() + " events");
        out.print(jsonResponse);

        System.out.println("=== getAvailableClasses() completed ===");
    }

    // ADD THIS METHOD - it was missing!
    private void getClassDetails(int classId, int instructorId, PrintWriter out) {
        System.out.println("=== getClassDetails() for class: " + classId + " ===");

        ClassDAO classDao = new ClassDAO();
        ClassConfirmationDAO ccDao = new ClassConfirmationDAO();

        Map<String, Object> classDetails = classDao.getClassWithInstructors(classId);
        if (classDetails == null) {
            System.out.println("ERROR: Class not found");
            out.print("{\"error\": \"Class not found\"}");
            return;
        }

        Class cls = (Class) classDetails.get("class");
        String instructorStatus = ccDao.getInstructorStatus(classId, instructorId);

        System.out.println("Class: " + cls.getClassName() + ", Instructor status: " + instructorStatus);

        Map<String, Object> result = new HashMap<>();
        result.put("class", cls);
        result.put("instructorStatus", instructorStatus);

        if (classDetails.containsKey("mainInstructor")) {
            result.put("mainInstructor", classDetails.get("mainInstructor"));
        }

        if (classDetails.containsKey("reliefInstructor")) {
            result.put("reliefInstructor", classDetails.get("reliefInstructor"));
        }

        String jsonResult = mapToJson(result);
        System.out.println("Sending class details JSON: " + jsonResult);
        out.print(jsonResult);

        System.out.println("=== getClassDetails() completed ===");
    }

    // Simple JSON conversion methods
    private String mapToJson(Object obj) {
        if (obj instanceof Map) {
            Map<?, ?> map = (Map<?, ?>) obj;
            StringBuilder json = new StringBuilder("{");
            boolean first = true;
            for (Map.Entry<?, ?> entry : map.entrySet()) {
                if (!first) {
                    json.append(",");
                }
                json.append("\"").append(entry.getKey()).append("\":");
                json.append(valueToJson(entry.getValue()));
                first = false;
            }
            json.append("}");
            return json.toString();
        } else if (obj instanceof List) {
            List<?> list = (List<?>) obj;
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            for (Object item : list) {
                if (!first) {
                    json.append(",");
                }
                json.append(valueToJson(item));
                first = false;
            }
            json.append("]");
            return json.toString();
        }
        return valueToJson(obj);
    }

    private String valueToJson(Object value) {
        if (value == null) {
            return "null";
        }
        if (value instanceof String) {
            return "\"" + escapeJson((String) value) + "\"";
        }
        if (value instanceof Number || value instanceof Boolean) {
            return value.toString();
        }
        if (value instanceof java.util.Date) {
            return "\"" + new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value) + "\"";
        }
        if (value instanceof Class) {
            Class cls = (Class) value;
            Map<String, Object> classMap = new HashMap<>();
            classMap.put("classID", cls.getClassID());
            classMap.put("className", cls.getClassName());
            classMap.put("classDate", new SimpleDateFormat("yyyy-MM-dd").format(cls.getClassDate()));
            classMap.put("classStartTime", new SimpleDateFormat("HH:mm:ss").format(cls.getClassStartTime()));
            classMap.put("classEndTime", new SimpleDateFormat("HH:mm:ss").format(cls.getClassEndTime()));
            classMap.put("location", cls.getLocation());
            classMap.put("description", cls.getDescription());
            classMap.put("capacity", cls.getNoOfParticipant());
            classMap.put("classStatus", cls.getClassStatus());
            return mapToJson(classMap);
        }
        return mapToJson(value);
    }

    private String escapeJson(String str) {
        if (str == null) {
            return "";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    @Override
    public String getServletInfo() {
        return "Handles class confirmation for instructors";
    }
}
