package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.PasswordResetDAO;
import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.util.EmailUtility;
import java.io.*;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/resetPassword"})
public class ResetPasswordServlet extends HttpServlet {

    // ========== HANDLE INITIAL REQUEST (SEND EMAIL) ==========
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String userRole = request.getParameter("role");

        System.out.println("=== RESET PASSWORD REQUEST ===");
        System.out.println("Email: " + email);
        System.out.println("Role: " + userRole);

        PasswordResetDAO resetDAO = new PasswordResetDAO();

        try {
            // 1. Check if email exists in system
            if (!resetDAO.emailExists(email, userRole)) {
                System.out.println("Email not found: " + email);
                response.sendRedirect("general/login.jsp?error=email_not_found&login_email=" + email);
                return;
            }

            // 2. Create reset request and generate token
            String token = resetDAO.createResetRequest(email, userRole);

            if (token == null) {
                throw new Exception("Failed to create reset request");
            }

            // 3. Send email with reset link
            boolean emailSent = EmailUtility.sendResetPasswordEmail(
                    getServletContext(), email, token);

            if (emailSent) {
                System.out.println("Reset email sent successfully to: " + email);
                response.sendRedirect("general/login.jsp?message=reset_email_sent");
            } else {
                throw new Exception("Failed to send reset email");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("SQL Error: " + e.getMessage());

            if (e.getMessage().contains("Too many reset requests")) {
                response.sendRedirect("general/login.jsp?error=too_many_requests&login_email=" + email);
            } else {
                response.sendRedirect("general/login.jsp?error=reset_failed&login_email=" + email);
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("General Error: " + e.getMessage());
            response.sendRedirect("general/login.jsp?error=reset_failed&login_email=" + email);
        }
    }

    // ========== HANDLE PASSWORD UPDATE (FROM RESET PAGE) ==========
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // This method handles the password update from reset_password.jsp
        String token = request.getParameter("token");
        String newPassword = request.getParameter("new_password");
        String confirmPassword = request.getParameter("confirm_password");

        System.out.println("=== PROCESSING PASSWORD UPDATE ===");
        System.out.println("Token: " + token);

        // Check if this is a token validation request (from reset_password.jsp page load)
        if (newPassword == null) {
            // Just forward to reset_password.jsp with token for validation
            request.getRequestDispatcher("/general/reset_password.jsp").forward(request, response);
            return;
        }

        // Process password update
        PasswordResetDAO resetDAO = new PasswordResetDAO();

        try {
            // 1. Validate token
            if (!resetDAO.validateToken(token)) {
                System.out.println("Invalid or expired token: " + token);
                response.sendRedirect("general/login.jsp?error=invalid_token");
                return;
            }

            // 2. Check password match
            if (!newPassword.equals(confirmPassword)) {
                request.setAttribute("error", "password_mismatch");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/general/reset_password.jsp").forward(request, response);
                return;
            }

            // 3. Check password strength (min 6 characters)
            if (newPassword.length() < 6) {
                request.setAttribute("error", "weak_password");
                request.setAttribute("token", token);
                request.getRequestDispatcher("/general/reset_password.jsp").forward(request, response);
                return;
            }

            // 4. Get email and role from token
            String[] userInfo = resetDAO.getEmailAndRoleFromToken(token);
            if (userInfo == null) {
                response.sendRedirect("general/login.jsp?error=invalid_token");
                return;
            }

            String email = userInfo[0];
            String userRole = userInfo[1];

            // 5. Update password in appropriate table
            boolean passwordUpdated = false;

            if ("admin".equals(userRole)) {
                AdminDAO adminDAO = new AdminDAO();
                passwordUpdated = adminDAO.updatePasswordByEmail(email, newPassword);
            } else if ("instructor".equals(userRole)) {
                InstructorDAO instructorDAO = new InstructorDAO();
                passwordUpdated = instructorDAO.updatePasswordByEmail(email, newPassword);
            }

            if (passwordUpdated) {
                // 6. Mark token as used
                resetDAO.markTokenAsUsed(token);

                System.out.println("Password updated successfully for: " + email);
                response.sendRedirect("general/login.jsp?message=password_reset_success");
            } else {
                throw new Exception("Failed to update password");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("general/login.jsp?error=database_error");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("general/login.jsp?error=reset_failed");
        }
    }
}
