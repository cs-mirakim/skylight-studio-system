package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.ClassDAO;
import com.skylightstudio.classmanagement.util.SessionUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/instructor/inboxMessages_instructor")
public class InboxMessagesInstructorServlet extends HttpServlet {

    private ClassDAO classDAO;

    @Override
    public void init() throws ServletException {
        classDAO = new ClassDAO();
        System.out.println("[INFO] InboxMessagesInstructorServlet initialized");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("[INFO] Accessing InboxMessagesInstructorServlet via URL: " + request.getRequestURI());

        HttpSession session = request.getSession();

        // Check if user is instructor
        if (!SessionUtil.checkInstructorAccess(session)) {
            if (!SessionUtil.isLoggedIn(session)) {
                response.sendRedirect(request.getContextPath() + "/general/login.jsp?error=access_denied&message=Please_login_to_access_instructor_pages");
            } else {
                response.sendRedirect(request.getContextPath() + "/general/login.jsp?error=instructor_access_required&message=Instructor_privileges_required_to_access_this_page");
            }
            return;
        }

        // Get instructor ID from session
        Integer instructorId = SessionUtil.getCurrentInstructorId(session);
        System.out.println("[INFO] Instructor ID from session: " + instructorId);

        if (instructorId == null) {
            response.sendRedirect(request.getContextPath() + "/general/login.jsp?error=session_expired&message=Please_login_again");
            return;
        }

        // Handle AJAX count request
        String action = request.getParameter("action");
        if ("count-unread".equals(action)) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            try {
                List<Map<String, Object>> notifications = classDAO.getNotificationsForInstructor(instructorId);
                int totalCount = notifications.size();

                response.getWriter().print("{\"totalCount\":" + totalCount + ",\"unreadCount\":" + totalCount + "}");
            } catch (SQLException e) {
                response.getWriter().print("{\"totalCount\":0,\"unreadCount\":0}");
            }
            return;
        }

        try {
            // Get notifications for instructor
            List<Map<String, Object>> notifications = classDAO.getNotificationsForInstructor(instructorId);

            System.out.println("[INFO] Found " + notifications.size() + " notifications");

            // Count notifications by type for badge
            int totalCount = notifications.size();
            int newClassCount = 0;
            int cancelledCount = 0;
            int waitlistCount = 0;
            int reminderCount = 0;
            int tomorrowCount = 0;

            for (Map<String, Object> notif : notifications) {
                String type = (String) notif.get("type");
                if ("new_class".equals(type)) {
                    newClassCount++;
                } else if ("cancelled".equals(type)) {
                    cancelledCount++;
                } else if ("waitlist".equals(type)) {
                    waitlistCount++;
                } else if ("reminder".equals(type)) {
                    reminderCount++;
                } else if ("tomorrow".equals(type)) {
                    tomorrowCount++;
                }
            }

            // Prepare data for JSP
            Map<String, Object> notificationData = new HashMap<>();
            notificationData.put("allNotifications", notifications);
            notificationData.put("totalCount", totalCount);
            notificationData.put("newClassCount", newClassCount);
            notificationData.put("cancelledCount", cancelledCount);
            notificationData.put("waitlistCount", waitlistCount);
            notificationData.put("reminderCount", reminderCount);
            notificationData.put("tomorrowCount", tomorrowCount);

            // Set attributes for JSP
            request.setAttribute("notificationData", notificationData);
            request.setAttribute("instructorName", SessionUtil.getCurrentInstructorName(session));

            System.out.println("[INFO] Forwarding to inboxMessages_instructor.jsp with " + totalCount + " notifications");

            // Forward to JSP
            request.getRequestDispatcher("/instructor/inboxMessages_instructor.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("[ERROR] Database error in InboxMessagesInstructorServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Database error occurred: " + e.getMessage());
            request.getRequestDispatcher("/instructor/inboxMessages_instructor.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("[ERROR] General error in InboxMessagesInstructorServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/instructor/inboxMessages_instructor.jsp").forward(request, response);
        }
    }
}
