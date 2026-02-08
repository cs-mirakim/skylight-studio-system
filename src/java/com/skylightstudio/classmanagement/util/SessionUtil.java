package com.skylightstudio.classmanagement.util;

import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.model.Instructor;
import javax.servlet.http.HttpSession;

public class SessionUtil {

    // Session attribute keys
    private static final String USER_ID = "userId";
    private static final String USER_ROLE = "userRole";
    private static final String USER_NAME = "userName";
    private static final String USER_EMAIL = "userEmail";
    private static final String ADMIN_OBJECT = "adminObject";
    private static final String INSTRUCTOR_OBJECT = "instructorObject";

    // ========== SET SESSION ==========
    public static void setAdminSession(HttpSession session, Admin admin) {
        if (session != null && admin != null) {
            session.setAttribute(USER_ID, admin.getAdminID());
            session.setAttribute(USER_ROLE, "admin");
            session.setAttribute(USER_NAME, admin.getName());
            session.setAttribute(USER_EMAIL, admin.getEmail());
            session.setAttribute(ADMIN_OBJECT, admin);
            System.out.println("[SessionUtil] Admin session set: " + admin.getName());
        }
    }

    public static void setInstructorSession(HttpSession session, Instructor instructor) {
        if (session != null && instructor != null) {
            session.setAttribute(USER_ID, instructor.getInstructorID());
            session.setAttribute(USER_ROLE, "instructor");
            session.setAttribute(USER_NAME, instructor.getName());
            session.setAttribute(USER_EMAIL, instructor.getEmail());
            session.setAttribute(INSTRUCTOR_OBJECT, instructor);
            System.out.println("[SessionUtil] Instructor session set: " + instructor.getName());
        }
    }

    // ========== GET SESSION INFO ==========
    public static Integer getUserId(HttpSession session) {
        try {
            return (Integer) session.getAttribute(USER_ID);
        } catch (Exception e) {
            return null;
        }
    }

    public static String getUserRole(HttpSession session) {
        try {
            return (String) session.getAttribute(USER_ROLE);
        } catch (Exception e) {
            return null;
        }
    }

    public static String getUserName(HttpSession session) {
        try {
            return (String) session.getAttribute(USER_NAME);
        } catch (Exception e) {
            return null;
        }
    }

    public static String getUserEmail(HttpSession session) {
        try {
            return (String) session.getAttribute(USER_EMAIL);
        } catch (Exception e) {
            return null;
        }
    }

    public static Admin getAdminObject(HttpSession session) {
        try {
            return (Admin) session.getAttribute(ADMIN_OBJECT);
        } catch (Exception e) {
            return null;
        }
    }

    public static Instructor getInstructorObject(HttpSession session) {
        try {
            return (Instructor) session.getAttribute(INSTRUCTOR_OBJECT);
        } catch (Exception e) {
            return null;
        }
    }

    // ========== CHECK METHODS ==========
    public static boolean isLoggedIn(HttpSession session) {
        return getUserId(session) != null && getUserRole(session) != null;
    }

    public static boolean isAdmin(HttpSession session) {
        return "admin".equals(getUserRole(session));
    }

    public static boolean isInstructor(HttpSession session) {
        return "instructor".equals(getUserRole(session));
    }

    public static boolean checkAdminAccess(HttpSession session) {
        return isLoggedIn(session) && isAdmin(session);
    }

    public static boolean checkInstructorAccess(HttpSession session) {
        return isLoggedIn(session) && isInstructor(session);
    }

    // ========== LOGOUT ==========
    public static void clearSession(HttpSession session) {
        if (session != null) {
            try {
                session.removeAttribute(USER_ID);
                session.removeAttribute(USER_ROLE);
                session.removeAttribute(USER_NAME);
                session.removeAttribute(USER_EMAIL);
                session.removeAttribute(ADMIN_OBJECT);
                session.removeAttribute(INSTRUCTOR_OBJECT);
                System.out.println("[SessionUtil] Session cleared");
            } catch (Exception e) {
                System.err.println("[SessionUtil] Error clearing session: " + e.getMessage());
            }
        }
    }

    // ========== NEW METHODS FOR SCHEDULE ==========
    public static Integer getCurrentInstructorId(HttpSession session) {
        if (!isInstructor(session)) {
            return null;
        }
        return getUserId(session);
    }

    public static String getCurrentInstructorName(HttpSession session) {
        if (!isInstructor(session)) {
            return null;
        }
        return getUserName(session);
    }

    public static String getCurrentInstructorInitials(HttpSession session) {
        String name = getCurrentInstructorName(session);
        if (name == null || name.trim().isEmpty()) {
            return "??";
        }
        String[] parts = name.split(" ");
        if (parts.length >= 2) {
            return (parts[0].charAt(0) + "" + parts[parts.length - 1].charAt(0)).toUpperCase();
        }
        return name.substring(0, Math.min(2, name.length())).toUpperCase();
    }

    // ========== NOTIFICATION COUNT METHODS ==========
    public static void setInboxCount(HttpSession session, int count) {
        if (session != null) {
            session.setAttribute("inboxCount", count);
        }
    }

    public static int getInboxCount(HttpSession session) {
        try {
            Integer count = (Integer) session.getAttribute("inboxCount");
            return count != null ? count : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    public static void updateInboxCountForAdmin(HttpSession session, int count) {
        if (isAdmin(session)) {
            setInboxCount(session, count);
        }
    }

    public static void updateInboxCountForInstructor(HttpSession session, int count) {
        if (isInstructor(session)) {
            setInboxCount(session, count);
        }
    }
}
