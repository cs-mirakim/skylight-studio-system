package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.model.Registration;
import com.skylightstudio.classmanagement.util.SessionUtil;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/authenticate")
public class AuthenticationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String email = request.getParameter("login_email");
        String password = request.getParameter("login_password");
        String role = request.getParameter("role");

        // Debug
        System.out.println("=== AUTHENTICATION SERVLET ===");
        System.out.println("Path: " + request.getContextPath() + request.getServletPath());
        System.out.println("Email: " + email);
        System.out.println("Role: " + role);

        // Validation
        if (email == null || email.trim().isEmpty()
                || password == null || password.trim().isEmpty() || role == null) {
            response.sendRedirect("general/login.jsp?error=invalid_input");
            return;
        }

        email = email.trim();

        HttpSession session = request.getSession();

        try {
            if ("admin".equals(role)) {
                handleAdminLogin(email, password, session, response);
            } else if ("instructor".equals(role)) {
                handleInstructorLogin(email, password, session, response);
            } else {
                response.sendRedirect("general/login.jsp?error=invalid_role");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("general/login.jsp?error=database_error");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("general/login.jsp?error=server_error");
        }
    }

    private void handleAdminLogin(String email, String password,
            HttpSession session, HttpServletResponse response)
            throws SQLException, IOException {

        AdminDAO adminDAO = new AdminDAO();
        Admin admin = adminDAO.validateLogin(email, password);

        if (admin != null) {
            System.out.println("Admin found: " + admin.getName());

            RegistrationDAO regDAO = new RegistrationDAO();
            Registration reg = regDAO.getRegistrationById(admin.getRegisterID());

            if (reg != null && "approved".equals(reg.getStatus())) {
                SessionUtil.setAdminSession(session, admin);
                System.out.println("Redirecting to: admin/dashboard_admin.jsp");
                response.sendRedirect("admin/dashboard_admin.jsp");
            } else {
                System.out.println("Admin not approved");
                response.sendRedirect("general/login.jsp?error=not_approved&login_email=" + email);
            }
        } else {
            System.out.println("Invalid admin credentials");
            response.sendRedirect("general/login.jsp?error=invalid_credentials&login_email=" + email);
        }
    }

    private void handleInstructorLogin(String email, String password,
            HttpSession session, HttpServletResponse response)
            throws SQLException, IOException {

        InstructorDAO instructorDAO = new InstructorDAO();
        Instructor instructor = instructorDAO.validateLogin(email, password);

        if (instructor != null) {
            System.out.println("✓ Instructor credentials valid: " + instructor.getName());
            System.out.println("  Instructor Status: " + instructor.getStatus());

            RegistrationDAO regDAO = new RegistrationDAO();
            Registration reg = regDAO.getRegistrationById(instructor.getRegisterID());

            if (reg == null) {
                System.out.println("✗ Registration record not found for instructor");
                response.sendRedirect("general/login.jsp?error=access_denied&login_email=" + email);
                return;
            }

            System.out.println("  Registration Status: " + reg.getStatus());

            String regStatus = reg.getStatus();
            String instrStatus = instructor.getStatus();

            // Logic flow berdasarkan requirement:
            // 1. Pending approval (registration pending + instructor inactive)
            // 2. Rejected (registration rejected + instructor inactive)  
            // 3. Approved & Active (boleh login)
            // 4. Approved tapi Inactive (rare case)
            if ("pending".equals(regStatus)) {
                System.out.println("→ Registration still pending approval");
                response.sendRedirect("general/login.jsp?error=pending_approval&login_email=" + email);
            } else if ("rejected".equals(regStatus)) {
                System.out.println("→ Registration has been rejected");
                response.sendRedirect("general/login.jsp?error=registration_rejected&login_email=" + email);
            } else if ("approved".equals(regStatus)) {
                if ("active".equals(instrStatus)) {
                    System.out.println("✓ Login SUCCESS - Approved and Active");
                    SessionUtil.setInstructorSession(session, instructor);
                    response.sendRedirect("instructor/dashboard_instructor.jsp");
                } else {
                    System.out.println("✗ Account approved but still inactive");
                    response.sendRedirect("general/login.jsp?error=account_inactive&login_email=" + email);
                }
            } else {
                System.out.println("✗ Unknown registration status: " + regStatus);
                response.sendRedirect("general/login.jsp?error=access_denied&login_email=" + email);
            }
        } else {
            System.out.println("✗ Invalid instructor credentials for email: " + email);
            response.sendRedirect("general/login.jsp?error=invalid_credentials&login_email=" + email);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("logout".equals(action)) {
            System.out.println("Logout requested");
            HttpSession session = request.getSession(false);
            if (session != null) {
                SessionUtil.clearSession(session);
            }
            response.sendRedirect("general/login.jsp?msg=logged_out");
        } else {
            response.sendRedirect("general/login.jsp");
        }
    }
}
