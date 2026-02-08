package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.dao.ClassConfirmationDAO;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet(name = "inboxMessageAdminServlet", urlPatterns = {"/admin/inbox-messages"})
public class inboxMessageAdminServlet extends HttpServlet {

    private RegistrationDAO registrationDAO;
    private ClassConfirmationDAO classConfirmationDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        registrationDAO = new RegistrationDAO();
        classConfirmationDAO = new ClassConfirmationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        try {
            String action = request.getParameter("action");
            
            if ("count-unread".equals(action)) {
                int unreadCount = countUnreadNotifications();
                out.print("{\"unreadCount\":" + unreadCount + "}");
                
            } else if ("list".equals(action)) {
                String typeFilter = request.getParameter("type") != null ? request.getParameter("type") : "all";
                String statusFilter = request.getParameter("readStatus") != null ? request.getParameter("readStatus") : "all";
                String showArchived = request.getParameter("showArchived") != null ? request.getParameter("showArchived") : "false";
                int page = request.getParameter("page") != null ? Integer.parseInt(request.getParameter("page")) : 1;
                int limit = request.getParameter("limit") != null ? Integer.parseInt(request.getParameter("limit")) : 10;
                
                // Get session for notification status
                HttpSession session = request.getSession();
                Map<String, Boolean> readStatusMap = getReadStatusMap(session);
                Map<String, Boolean> archiveStatusMap = getArchiveStatusMap(session);
                
                List<Map<String, Object>> notifications = getNotifications(
                    typeFilter, statusFilter, showArchived, readStatusMap, archiveStatusMap);
                
                // Apply pagination
                int totalCount = notifications.size();
                int startIndex = (page - 1) * limit;
                int endIndex = Math.min(startIndex + limit, totalCount);
                List<Map<String, Object>> paginatedNotifications = new ArrayList<>();
                if (startIndex < totalCount) {
                    paginatedNotifications = notifications.subList(startIndex, endIndex);
                }
                
                // Build JSON response
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"notifications\":[");
                
                for (int i = 0; i < paginatedNotifications.size(); i++) {
                    Map<String, Object> notification = paginatedNotifications.get(i);
                    if (i > 0) json.append(",");
                    json.append(buildNotificationJson(notification));
                }
                
                json.append("],");
                json.append("\"totalCount\":").append(totalCount).append(",");
                json.append("\"currentPage\":").append(page).append(",");
                json.append("\"totalPages\":").append((int) Math.ceil((double) totalCount / limit));
                json.append("}");
                
                out.print(json.toString());
                
            } else if ("detail".equals(action)) {
                String notificationId = request.getParameter("id");
                String type = request.getParameter("type");
                
                if (notificationId != null && type != null) {
                    // Get session for notification status
                    HttpSession session = request.getSession();
                    Map<String, Boolean> readStatusMap = getReadStatusMap(session);
                    Map<String, Boolean> archiveStatusMap = getArchiveStatusMap(session);
                    
                    Map<String, Object> notificationDetail = getNotificationDetail(
                        notificationId, type, readStatusMap, archiveStatusMap);
                    
                    if (notificationDetail != null) {
                        out.print(buildNotificationJson(notificationDetail));
                    } else {
                        out.print("{\"error\":\"Notification not found\"}");
                    }
                } else {
                    out.print("{\"error\":\"Missing parameters\"}");
                }
                
            } else {
                // Default
                HttpSession session = request.getSession();
                Map<String, Boolean> readStatusMap = getReadStatusMap(session);
                Map<String, Boolean> archiveStatusMap = getArchiveStatusMap(session);
                
                List<Map<String, Object>> notifications = getNotifications(
                    "all", "all", "false", readStatusMap, archiveStatusMap);
                int unreadCount = countUnreadNotifications();
                
                StringBuilder json = new StringBuilder();
                json.append("{\"notifications\":[");
                
                for (int i = 0; i < notifications.size(); i++) {
                    Map<String, Object> notification = notifications.get(i);
                    if (i > 0) json.append(",");
                    json.append(buildNotificationJson(notification));
                }
                
                json.append("],\"unreadCount\":").append(unreadCount).append("}");
                
                out.print(json.toString());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        PrintWriter out = response.getWriter();
        HttpSession session = request.getSession();

        try {
            String action = request.getParameter("action");

            if ("mark-read".equals(action) || "mark-unread".equals(action)) {
                String notificationId = request.getParameter("id");
                String type = request.getParameter("type");

                if (notificationId != null && type != null) {
                    // Update read status in session
                    @SuppressWarnings("unchecked")
                    Map<String, Boolean> readStatusMap = (Map<String, Boolean>) session.getAttribute("notificationReadStatus");
                    if (readStatusMap == null) {
                        readStatusMap = new HashMap<>();
                        session.setAttribute("notificationReadStatus", readStatusMap);
                    }

                    boolean isRead = "mark-read".equals(action);
                    String mapKey = notificationId + "_" + type;
                    readStatusMap.put(mapKey, isRead);

                    System.out.println("[DEBUG] Updated read status for " + mapKey + " to " + isRead);
                    System.out.println("[DEBUG] Read status map size: " + readStatusMap.size());

                    out.print("{\"success\":true,\"message\":\"Notification status updated\"}");
                } else {
                    out.print("{\"error\":\"Missing parameters\"}");
                }

            } else if ("archive".equals(action) || "unarchive".equals(action)) {
                String notificationId = request.getParameter("id");
                String type = request.getParameter("type");

                if (notificationId != null && type != null) {
                    // Update archive status in session
                    @SuppressWarnings("unchecked")
                    Map<String, Boolean> archiveStatusMap = (Map<String, Boolean>) session.getAttribute("notificationArchiveStatus");
                    if (archiveStatusMap == null) {
                        archiveStatusMap = new HashMap<>();
                        session.setAttribute("notificationArchiveStatus", archiveStatusMap);
                    }

                    boolean isArchived = "archive".equals(action);
                    String mapKey = notificationId + "_" + type;
                    archiveStatusMap.put(mapKey, isArchived);

                    System.out.println("[DEBUG] Updated archive status for " + mapKey + " to " + isArchived);
                    System.out.println("[DEBUG] Archive status map size: " + archiveStatusMap.size());

                    out.print("{\"success\":true,\"message\":\"Notification archive status updated\"}");
                } else {
                    out.print("{\"error\":\"Missing parameters\"}");
                }

            } else if ("refresh".equals(action)) {
                int unreadCount = countUnreadNotifications();
                out.print("{\"success\":true,\"unreadCount\":" + unreadCount + "}");

            } else {
                out.print("{\"error\":\"Invalid action\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private int countUnreadNotifications() throws SQLException {
        int count = 0;
        
        // Count pending instructor registrations (these are unread by default)
        List<Map<String, Object>> registrations = registrationDAO.getAllInstructorRegistrations();
        for (Map<String, Object> reg : registrations) {
            String status = (String) reg.get("registrationStatus");
            if ("pending".equals(status)) {
                count++;
            }
        }
        
        // Count cancelled classes (all are unread by default)
        List<Map<String, Object>> cancelledClasses = classConfirmationDAO.getCancelledClasses();
        count += cancelledClasses.size();
        
        return count;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Boolean> getReadStatusMap(HttpSession session) {
        Map<String, Boolean> readStatusMap = (Map<String, Boolean>) session.getAttribute("notificationReadStatus");
        if (readStatusMap == null) {
            readStatusMap = new HashMap<>();
            session.setAttribute("notificationReadStatus", readStatusMap);
        }
        return readStatusMap;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Boolean> getArchiveStatusMap(HttpSession session) {
        Map<String, Boolean> archiveStatusMap = (Map<String, Boolean>) session.getAttribute("notificationArchiveStatus");
        if (archiveStatusMap == null) {
            archiveStatusMap = new HashMap<>();
            session.setAttribute("notificationArchiveStatus", archiveStatusMap);
        }
        return archiveStatusMap;
    }

    private List<Map<String, Object>> getNotifications(String typeFilter, String statusFilter, 
                                                      String showArchived, 
                                                      Map<String, Boolean> readStatusMap,
                                                      Map<String, Boolean> archiveStatusMap) 
            throws SQLException {
        
        List<Map<String, Object>> allNotifications = new ArrayList<>();
        
        // Get instructor registrations
        if ("all".equals(typeFilter) || "register".equals(typeFilter)) {
            List<Map<String, Object>> registrations = registrationDAO.getAllInstructorRegistrations();
            
            for (Map<String, Object> reg : registrations) {
                String registrationStatus = (String) reg.get("registrationStatus");
                String notificationId = "reg_" + reg.get("registerID");
                
                // Get read status from session
                boolean isRead = readStatusMap.getOrDefault(notificationId + "_register", 
                    !"pending".equals(registrationStatus)); // Default: pending = unread
                
                // Get archive status from session
                boolean isArchived = archiveStatusMap.getOrDefault(notificationId + "_register", false);
                
                // Filter by archive status
                if ("true".equals(showArchived) && !isArchived) {
                    continue;
                }
                if ("false".equals(showArchived) && isArchived) {
                    continue;
                }
                
                // Filter by read status
                if (!"all".equals(statusFilter)) {
                    if ("unread".equals(statusFilter) && isRead) {
                        continue;
                    }
                    if ("read".equals(statusFilter) && !isRead) {
                        continue;
                    }
                }
                
                Map<String, Object> notification = new HashMap<>();
                notification.put("id", notificationId);
                notification.put("type", "register");
                notification.put("title", "New Instructor Registration Request");
                notification.put("instructorName", reg.get("name"));
                notification.put("instructorEmail", reg.get("email"));
                notification.put("instructorPhone", reg.get("phone") != null ? reg.get("phone") : "");
                notification.put("instructorNric", reg.get("nric") != null ? reg.get("nric") : "");
                
                Timestamp registerDate = (Timestamp) reg.get("registerDate");
                if (registerDate != null) {
                    notification.put("registerDate", formatDate(registerDate));
                    notification.put("date", registerDate.getTime());
                    notification.put("displayDate", formatDisplayDate(registerDate));
                } else {
                    notification.put("registerDate", "");
                    notification.put("date", 0);
                    notification.put("displayDate", "");
                }
                
                notification.put("status", registrationStatus);
                notification.put("isRead", isRead);
                notification.put("archived", isArchived);
                
                allNotifications.add(notification);
            }
        }
        
        // Get cancelled classes
        if ("all".equals(typeFilter) || "cancel".equals(typeFilter)) {
            List<Map<String, Object>> cancelledClasses = classConfirmationDAO.getCancelledClasses();
            
            for (Map<String, Object> cc : cancelledClasses) {
                String notificationId = "cancel_" + cc.get("confirmID");
                
                // Get read status from session (default: false/unread)
                boolean isRead = readStatusMap.getOrDefault(notificationId + "_cancel", false);
                
                // Get archive status from session
                boolean isArchived = archiveStatusMap.getOrDefault(notificationId + "_cancel", false);
                
                // Filter by archive status
                if ("true".equals(showArchived) && !isArchived) {
                    continue;
                }
                if ("false".equals(showArchived) && isArchived) {
                    continue;
                }
                
                // Filter by read status
                if (!"all".equals(statusFilter)) {
                    if ("unread".equals(statusFilter) && isRead) {
                        continue;
                    }
                    if ("read".equals(statusFilter) && !isRead) {
                        continue;
                    }
                }
                
                Map<String, Object> notification = new HashMap<>();
                notification.put("id", notificationId);
                notification.put("type", "cancel");
                notification.put("title", "Class Cancellation Alert");
                notification.put("instructorName", cc.get("instructorName"));
                notification.put("instructorEmail", cc.get("instructorEmail"));
                notification.put("className", cc.get("className"));
                notification.put("classType", cc.get("classType"));
                notification.put("classLevel", cc.get("classLevel"));
                notification.put("classDate", formatDate((java.sql.Date) cc.get("classDate")));
                notification.put("cancellationReason", cc.get("cancellationReason"));
                notification.put("status", "pending");
                notification.put("isRead", isRead);
                notification.put("archived", isArchived);
                
                Timestamp cancelledAt = (Timestamp) cc.get("cancelledAt");
                if (cancelledAt != null) {
                    notification.put("date", cancelledAt.getTime());
                    notification.put("displayDate", formatDisplayDate(cancelledAt));
                } else {
                    notification.put("date", 0);
                    notification.put("displayDate", "");
                }
                
                // Format waktu
                java.sql.Time startTime = (java.sql.Time) cc.get("classStartTime");
                java.sql.Time endTime = (java.sql.Time) cc.get("classEndTime");
                if (startTime != null && endTime != null) {
                    notification.put("classTime", formatTime(startTime) + " - " + formatTime(endTime));
                }
                
                allNotifications.add(notification);
            }
        }
        
        // Sort by date (newest first)
        allNotifications.sort((a, b) -> {
            long dateA = (Long) b.get("date");
            long dateB = (Long) a.get("date");
            return Long.compare(dateA, dateB);
        });
        
        return allNotifications;
    }

    private Map<String, Object> getNotificationDetail(String notificationId, String type,
                                                     Map<String, Boolean> readStatusMap,
                                                     Map<String, Boolean> archiveStatusMap) 
            throws SQLException {
        
        if ("register".equals(type)) {
            int registerID = Integer.parseInt(notificationId.substring(4));
            
            List<Map<String, Object>> registrations = registrationDAO.getAllInstructorRegistrations();
            
            for (Map<String, Object> reg : registrations) {
                if (registerID == (Integer) reg.get("registerID")) {
                    boolean isRead = readStatusMap.getOrDefault(notificationId + "_register", 
                        !"pending".equals(reg.get("registrationStatus")));
                    boolean isArchived = archiveStatusMap.getOrDefault(notificationId + "_register", false);
                    
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("id", notificationId);
                    detail.put("type", "register");
                    detail.put("title", "New Instructor Registration Request");
                    detail.put("instructorName", reg.get("name"));
                    detail.put("instructorEmail", reg.get("email"));
                    detail.put("instructorPhone", reg.get("phone"));
                    detail.put("instructorNric", reg.get("nric"));
                    
                    Timestamp registerDate = (Timestamp) reg.get("registerDate");
                    if (registerDate != null) {
                        detail.put("registerDate", formatDate(registerDate));
                        detail.put("date", registerDate.getTime());
                        detail.put("displayDate", formatDisplayDate(registerDate));
                    }
                    
                    detail.put("status", reg.get("registrationStatus"));
                    detail.put("isRead", isRead);
                    detail.put("archived", isArchived);
                    
                    // Additional details
                    detail.put("address", reg.get("address"));
                    detail.put("bod", reg.get("bod"));
                    detail.put("yearOfExperience", reg.get("yearOfExperience"));
                    detail.put("certificationFilePath", reg.get("certificationFilePath"));
                    
                    return detail;
                }
            }
        } else if ("cancel".equals(type)) {
            int confirmID = Integer.parseInt(notificationId.substring(7));
            
            List<Map<String, Object>> cancelledClasses = classConfirmationDAO.getCancelledClasses();
            
            for (Map<String, Object> cc : cancelledClasses) {
                if (confirmID == (Integer) cc.get("confirmID")) {
                    boolean isRead = readStatusMap.getOrDefault(notificationId + "_cancel", false);
                    boolean isArchived = archiveStatusMap.getOrDefault(notificationId + "_cancel", false);
                    
                    Map<String, Object> detail = new HashMap<>();
                    detail.put("id", notificationId);
                    detail.put("type", "cancel");
                    detail.put("title", "Class Cancellation Alert");
                    detail.put("instructorName", cc.get("instructorName"));
                    detail.put("instructorEmail", cc.get("instructorEmail"));
                    detail.put("instructorPhone", cc.get("instructorPhone"));
                    detail.put("className", cc.get("className"));
                    detail.put("classType", cc.get("classType"));
                    detail.put("classLevel", cc.get("classLevel"));
                    detail.put("classDate", formatDate((java.sql.Date) cc.get("classDate")));
                    detail.put("cancellationReason", cc.get("cancellationReason"));
                    detail.put("status", "pending");
                    detail.put("isRead", isRead);
                    detail.put("archived", isArchived);
                    
                    Timestamp cancelledAt = (Timestamp) cc.get("cancelledAt");
                    if (cancelledAt != null) {
                        detail.put("date", cancelledAt.getTime());
                        detail.put("displayDate", formatDisplayDate(cancelledAt));
                    }
                    
                    // Format waktu
                    java.sql.Time startTime = (java.sql.Time) cc.get("classStartTime");
                    java.sql.Time endTime = (java.sql.Time) cc.get("classEndTime");
                    if (startTime != null && endTime != null) {
                        detail.put("classTime", formatTime(startTime) + " - " + formatTime(endTime));
                    }
                    
                    return detail;
                }
            }
        }
        
        return null;
    }

    private String buildNotificationJson(Map<String, Object> notification) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        
        List<String> keys = new ArrayList<>(notification.keySet());
        for (int i = 0; i < keys.size(); i++) {
            String key = keys.get(i);
            if (i > 0) json.append(",");
            
            json.append("\"").append(key).append("\":");
            
            Object value = notification.get(key);
            if (value == null) {
                json.append("null");
            } else if (value instanceof String) {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            } else if (value instanceof Integer || value instanceof Long || value instanceof Boolean) {
                json.append(value);
            } else {
                json.append("\"").append(escapeJson(value.toString())).append("\"");
            }
        }
        
        json.append("}");
        return json.toString();
    }

    private String formatDate(java.sql.Date date) {
        if (date == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new Date(date.getTime()));
    }

    private String formatDate(Timestamp timestamp) {
        if (timestamp == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        return sdf.format(new Date(timestamp.getTime()));
    }

    private String formatTime(java.sql.Time time) {
        if (time == null) return "";
        SimpleDateFormat sdf = new SimpleDateFormat("hh:mm a");
        return sdf.format(new Date(time.getTime()));
    }

    private String formatDisplayDate(Timestamp timestamp) {
        if (timestamp == null) return "";
        
        Date date = new Date(timestamp.getTime());
        Date now = new Date();
        long diff = now.getTime() - date.getTime();
        long diffDays = diff / (24 * 60 * 60 * 1000);
        
        if (diffDays == 0) {
            SimpleDateFormat sdf = new SimpleDateFormat("'Today,' hh:mm a");
            return sdf.format(date);
        } else if (diffDays == 1) {
            return "Yesterday";
        } else if (diffDays < 7) {
            return diffDays + " days ago";
        } else {
            SimpleDateFormat sdf = new SimpleDateFormat("MMM dd");
            return sdf.format(date);
        }
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}