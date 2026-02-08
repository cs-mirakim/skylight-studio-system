package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.RegistrationDAO;
import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.SessionUtil;
import com.skylightstudio.classmanagement.util.EmailUtility;
import com.skylightstudio.classmanagement.util.DBConnection;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "RegistrationServlet", urlPatterns = {"/register"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class RegistrationServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(RegistrationServlet.class.getName());

    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hashedBytes = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hashedBytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password", e);
        }
    }

    // ========== FILE SAVING METHOD ==========
    private String saveUploadedFile(Part filePart, HttpServletRequest request,
            String username, String fileType, String userRole) throws IOException {

        if (filePart == null || filePart.getSize() == 0 || filePart.getSubmittedFileName() == null) {
            logger.info("No " + fileType + " file uploaded or empty file");
            return null;
        }

        try {
            // === DEBUG LOGGING ===
            logger.info("=== FILE UPLOAD DEBUG START ===");
            logger.info("User Role: " + userRole);
            logger.info("Username: " + username);
            logger.info("File Type: " + fileType);
            logger.info("Original filename: " + filePart.getSubmittedFileName());
            logger.info("File size: " + filePart.getSize() + " bytes");

            // Determine folder based on file type and user role
            String folderName;
            if ("profile".equals(fileType)) {
                folderName = "profile_pictures/" + userRole.toLowerCase() + "/";
            } else {
                folderName = "certifications/" + userRole.toLowerCase() + "/";
            }

            // Get application context path
            ServletContext context = request.getServletContext();
            String webappPath = context.getRealPath("");

            if (webappPath == null) {
                webappPath = "";
            }

            // Fix path separator
            String fullWebappPath = webappPath;
            if (!fullWebappPath.endsWith(File.separator)) {
                fullWebappPath += File.separator;
            }
            fullWebappPath += folderName;

            // Also try to save to project directory for development
            String projectPath = "";
            try {
                File webappDir = new File(webappPath);
                File buildDir = webappDir.getParentFile(); // build folder
                if (buildDir != null) {
                    File projectRoot = buildDir.getParentFile(); // project root
                    if (projectRoot != null) {
                        projectPath = projectRoot.getAbsolutePath()
                                + File.separator + "web"
                                + File.separator + folderName;
                    }
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Could not build project path: " + e.getMessage());
                projectPath = fullWebappPath; // fallback
            }

            logger.info("Webapp Path: " + fullWebappPath);
            logger.info("Project Path: " + projectPath);

            // Create directories
            File webappDir = new File(fullWebappPath);
            File projectDir = new File(projectPath);

            if (!webappDir.exists()) {
                boolean created = webappDir.mkdirs();
                logger.info("Created webapp directory: " + created + " at " + fullWebappPath);
            }

            if (!projectDir.exists() && !projectPath.equals(fullWebappPath)) {
                boolean created = projectDir.mkdirs();
                logger.info("Created project directory: " + created + " at " + projectPath);
            }

            // Generate unique filename
            String originalFileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String fileExtension = "";

            int dotIndex = originalFileName.lastIndexOf('.');
            if (dotIndex > 0) {
                fileExtension = originalFileName.substring(dotIndex).toLowerCase();
            }

            // Sanitize username for filename
            String sanitizedUsername = username.replaceAll("[^a-zA-Z0-9._-]", "_");
            String fileName = sanitizedUsername + "_" + System.currentTimeMillis() + fileExtension;

            logger.info("Generated filename: " + fileName);

            // Save to multiple locations
            String webappFilePath = fullWebappPath + fileName;
            String projectFilePath = projectPath + fileName;

            // Use the successful approach from other project
            boolean filesSaved = saveFileToMultipleLocations(filePart, webappFilePath, projectFilePath);

            logger.info("Files saved successfully: " + filesSaved);

            // Verify files exist
            File webappFile = new File(webappFilePath);
            File projectFile = new File(projectFilePath);

            logger.info("Webapp file exists: " + webappFile.exists() + ", size: "
                    + (webappFile.exists() ? webappFile.length() : 0) + " bytes");
            logger.info("Project file exists: " + projectFile.exists() + ", size: "
                    + (projectFile.exists() ? projectFile.length() : 0) + " bytes");

            logger.info("=== FILE UPLOAD DEBUG END ===");

            // Return relative path for database
            return folderName + fileName;

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in saveUploadedFile method", e);
            return null;
        }
    }

    // ========== METHOD TO SAVE FILE TO MULTIPLE LOCATIONS ==========
    private boolean saveFileToMultipleLocations(Part filePart, String... filePaths) throws IOException {
        try (InputStream input = filePart.getInputStream()) {
            // Read all data first
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = input.read(buffer)) != -1) {
                baos.write(buffer, 0, bytesRead);
            }
            byte[] fileData = baos.toByteArray();

            logger.info("File data read: " + fileData.length + " bytes");

            // Write to each location
            boolean allSuccess = true;
            for (String filePath : filePaths) {
                try (FileOutputStream output = new FileOutputStream(filePath)) {
                    output.write(fileData);
                    logger.info("Saved to: " + filePath);
                } catch (IOException e) {
                    logger.log(Level.WARNING, "Failed to save to: " + filePath, e);
                    allSuccess = false;
                }
            }
            return allSuccess;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        // Handle get registrations data for review page
        if ("getRegistrations".equals(action)) {
            getRegistrationData(request, response);
        } else {
            // Original redirect to registration page
            response.sendRedirect(request.getContextPath() + "/general/register_account.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("approve".equals(action) || "reject".equals(action)) {
            processRegistrationReview(request, response, action);
        } else {
            // Original registration logic
            processNewRegistration(request, response);
        }
    }

    // ========== METHOD: Handle registration review (approve/reject) ==========
    private void processRegistrationReview(HttpServletRequest request, HttpServletResponse response, String action)
            throws ServletException, IOException {

        logger.info("\n=== REGISTRATION REVIEW START ===");

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        PrintWriter out = response.getWriter();

        try {
            // Check if admin is logged in
            if (!SessionUtil.checkAdminAccess(session)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Admin access required\"}");
                return;
            }

            // Get parameters
            String registerIDStr = request.getParameter("registerID");
            String instructorIDStr = request.getParameter("instructorID");
            String adminMessage = request.getParameter("message");

            if (registerIDStr == null || instructorIDStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Missing required parameters\"}");
                return;
            }

            int registerID = Integer.parseInt(registerIDStr);
            int instructorID = Integer.parseInt(instructorIDStr);
            int adminID = SessionUtil.getUserId(session);

            // Get instructor details for email
            InstructorDAO instructorDAO = new InstructorDAO();
            Instructor instructor = instructorDAO.getInstructorById(instructorID);

            if (instructor == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Instructor not found\"}");
                return;
            }

            // Determine statuses based on action
            String registrationStatus;
            String instructorStatus;

            if ("approve".equals(action)) {
                registrationStatus = "approved";
                instructorStatus = "active";
            } else {
                registrationStatus = "rejected";
                instructorStatus = "inactive";
            }

            // Update both registration and instructor
            RegistrationDAO registrationDAO = new RegistrationDAO();
            boolean updated = registrationDAO.updateRegistrationAndInstructorStatus(
                    registerID, registrationStatus, adminMessage,
                    instructorID, instructorStatus, adminID);

            if (updated) {
                // Send email notification
                try {
                    ServletContext context = getServletContext();
                    boolean emailSent = EmailUtility.sendRegistrationDecisionEmail(
                            context,
                            instructor.getEmail(),
                            instructor.getName(),
                            "approve".equals(action),
                            adminMessage);

                    if (emailSent) {
                        logger.info("✓ Email sent to " + instructor.getEmail());
                    } else {
                        logger.warning("✗ Failed to send email to " + instructor.getEmail());
                    }
                } catch (Exception e) {
                    logger.log(Level.WARNING, "Error sending email: " + e.getMessage(), e);
                }

                logger.info("✓ Registration " + action + "ed successfully for registerID: " + registerID);
                out.print("{\"success\": true, \"message\": \"Registration " + action + "ed successfully\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\": false, \"message\": \"Failed to update registration\"}");
            }

        } catch (NumberFormatException e) {
            logger.log(Level.SEVERE, "Invalid parameter format", e);
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Invalid parameter format\"}");
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        } finally {
            out.flush();
            logger.info("=== REGISTRATION REVIEW END ===\n");
        }
    }

    // ========== METHOD: Get registration data for review page ==========
    private void getRegistrationData(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        PrintWriter out = response.getWriter();

        try {
            // Check if admin is logged in
            if (!SessionUtil.checkAdminAccess(session)) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.print("{\"success\": false, \"message\": \"Admin access required\"}");
                return;
            }

            // Get registration data
            RegistrationDAO registrationDAO = new RegistrationDAO();
            List<Map<String, Object>> registrations = registrationDAO.getAllInstructorRegistrations();

            // Convert to JSON
            StringBuilder json = new StringBuilder();
            json.append("{\"success\": true, \"data\": [");

            for (int i = 0; i < registrations.size(); i++) {
                Map<String, Object> reg = registrations.get(i);

                json.append("{");
                json.append("\"id\": ").append(reg.get("instructorID")).append(",");
                json.append("\"registerID\": ").append(reg.get("registerID")).append(",");
                json.append("\"name\": \"").append(escapeJson(reg.get("name").toString())).append("\",");
                json.append("\"email\": \"").append(escapeJson(reg.get("email").toString())).append("\",");
                json.append("\"phone\": \"").append(escapeJson(reg.get("phone").toString())).append("\",");
                json.append("\"nric\": \"").append(escapeJson(reg.get("nric").toString())).append("\",");
                json.append("\"bod\": \"").append(reg.get("bod")).append("\",");
                json.append("\"yearOfExperience\": ").append(reg.get("yearOfExperience")).append(",");
                json.append("\"address\": \"").append(escapeJson(reg.get("address").toString())).append("\",");
                json.append("\"registerDate\": \"").append(reg.get("registerDate")).append("\",");
                json.append("\"status\": \"").append(reg.get("registrationStatus")).append("\",");

                // Handle file paths
                String profileImagePath = reg.get("profileImageFilePath") != null
                        ? reg.get("profileImageFilePath").toString() : "profile_pictures/instructor/dummy.png";
                String certificationPath = reg.get("certificationFilePath") != null
                        ? reg.get("certificationFilePath").toString() : "certifications/instructor/dummy.pdf";

                json.append("\"profileImagePath\": \"").append(profileImagePath).append("\",");
                json.append("\"certification\": \"").append(certificationPath).append("\"");

                json.append("}");

                if (i < registrations.size() - 1) {
                    json.append(",");
                }
            }

            json.append("]}");

            out.print(json.toString());
            logger.info("✓ Sent " + registrations.size() + " registration records");

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Database error: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\": false, \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        } finally {
            out.flush();
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

    // ========== UPDATED METHOD: Delete rejected records before new registration ==========
    // SOLUSI BARU: Hapuskan SEMUA record rejected dengan data yang sama sebelum buat registration baru
    private void deleteRejectedRecords(String email, String username, String nric) throws SQLException {
        Connection conn = null;
        PreparedStatement deleteStmt = null;

        logger.info("=== DELETE REJECTED RECORDS START ===");
        logger.info("Email: " + email + ", Username: " + username + ", NRIC: " + nric);

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Cari semua rejected instructor dengan data yang sama
            String findSql = "SELECT i.instructorID, i.registerID, i.profileImageFilePath, i.certificationFilePath "
                    + "FROM instructor i "
                    + "JOIN registration r ON i.registerID = r.registerID "
                    + "WHERE r.status = 'rejected' "
                    + "AND (i.email = ? OR i.username = ? OR i.nric = ?)";

            try (PreparedStatement findStmt = conn.prepareStatement(findSql)) {
                findStmt.setString(1, email);
                findStmt.setString(2, username);
                findStmt.setString(3, nric);

                ResultSet rs = findStmt.executeQuery();

                int count = 0;
                while (rs.next()) {
                    count++;
                    int instructorID = rs.getInt("instructorID");
                    int registerID = rs.getInt("registerID");
                    String profileImagePath = rs.getString("profileImageFilePath");
                    String certificationPath = rs.getString("certificationFilePath");

                    logger.info("Found rejected record #" + count + ":");
                    logger.info("  instructorID: " + instructorID);
                    logger.info("  registerID: " + registerID);
                    logger.info("  profileImagePath: " + profileImagePath);
                    logger.info("  certificationPath: " + certificationPath);

                    // 2. Hapuskan file-file fizikal jika ada
                    deletePhysicalFiles(profileImagePath, certificationPath);

                    // 3. Hapuskan dari table class_confirmation (jika ada)
                    String deleteConfirmationSql = "DELETE FROM class_confirmation WHERE instructorID = ?";
                    try (PreparedStatement deleteConfStmt = conn.prepareStatement(deleteConfirmationSql)) {
                        deleteConfStmt.setInt(1, instructorID);
                        int deletedConf = deleteConfStmt.executeUpdate();
                        if (deletedConf > 0) {
                            logger.info("  Deleted " + deletedConf + " class confirmation records");
                        }
                    }

                    // 4. Hapuskan dari table feedback (jika ada)
                    String deleteFeedbackSql = "DELETE FROM feedback WHERE instructorID = ?";
                    try (PreparedStatement deleteFeedbackStmt = conn.prepareStatement(deleteFeedbackSql)) {
                        deleteFeedbackStmt.setInt(1, instructorID);
                        int deletedFeedback = deleteFeedbackStmt.executeUpdate();
                        if (deletedFeedback > 0) {
                            logger.info("  Deleted " + deletedFeedback + " feedback records");
                        }
                    }

                    // 5. Hapuskan instructor
                    String deleteInstructorSql = "DELETE FROM instructor WHERE instructorID = ?";
                    try (PreparedStatement deleteInstStmt = conn.prepareStatement(deleteInstructorSql)) {
                        deleteInstStmt.setInt(1, instructorID);
                        int deletedInst = deleteInstStmt.executeUpdate();
                        logger.info("  Deleted instructor: " + (deletedInst > 0 ? "SUCCESS" : "FAILED"));
                    }

                    // 6. Hapuskan registration
                    String deleteRegistrationSql = "DELETE FROM registration WHERE registerID = ?";
                    try (PreparedStatement deleteRegStmt = conn.prepareStatement(deleteRegistrationSql)) {
                        deleteRegStmt.setInt(1, registerID);
                        int deletedReg = deleteRegStmt.executeUpdate();
                        logger.info("  Deleted registration: " + (deletedReg > 0 ? "SUCCESS" : "FAILED"));
                    }
                }

                if (count == 0) {
                    logger.info("No rejected records found to delete.");
                } else {
                    logger.info("Successfully deleted " + count + " rejected records.");
                }
            }

            conn.commit();
            logger.info("=== DELETE REJECTED RECORDS END (COMMITTED) ===");

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "✗ ERROR in deleteRejectedRecords: " + e.getMessage(), e);
            if (conn != null) {
                try {
                    conn.rollback();
                    logger.info("Transaction rolled back due to error.");
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Error during rollback: " + ex.getMessage(), ex);
                }
            }
            throw e;
        } finally {
            if (deleteStmt != null) {
                try {
                    deleteStmt.close();
                } catch (SQLException e) {
                    /* ignore */ }
            }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.log(Level.WARNING, "Error closing connection: " + e.getMessage(), e);
                }
            }
        }
    }

    // ========== HELPER METHOD: Delete physical files ==========
    private void deletePhysicalFiles(String profileImagePath, String certificationPath) {
        try {
            if (profileImagePath != null && !profileImagePath.isEmpty()
                    && !profileImagePath.equals("profile_pictures/instructor/dummy.png")) {
                // Delete from webapp directory
                ServletContext context = getServletContext();
                String webappPath = context.getRealPath("") + profileImagePath;
                File webappFile = new File(webappPath);
                if (webappFile.exists()) {
                    boolean deleted = webappFile.delete();
                    logger.info("  Deleted profile image (webapp): " + (deleted ? "SUCCESS" : "FAILED"));
                }

                // Delete from project directory (development)
                try {
                    File projectFile = new File("web/" + profileImagePath);
                    if (projectFile.exists()) {
                        boolean deleted = projectFile.delete();
                        logger.info("  Deleted profile image (project): " + (deleted ? "SUCCESS" : "FAILED"));
                    }
                } catch (Exception e) {
                    // Ignore if project path doesn't exist
                }
            }

            if (certificationPath != null && !certificationPath.isEmpty()
                    && !certificationPath.equals("certifications/instructor/dummy.pdf")) {
                // Delete from webapp directory
                ServletContext context = getServletContext();
                String webappPath = context.getRealPath("") + certificationPath;
                File webappFile = new File(webappPath);
                if (webappFile.exists()) {
                    boolean deleted = webappFile.delete();
                    logger.info("  Deleted certification (webapp): " + (deleted ? "SUCCESS" : "FAILED"));
                }

                // Delete from project directory (development)
                try {
                    File projectFile = new File("web/" + certificationPath);
                    if (projectFile.exists()) {
                        boolean deleted = projectFile.delete();
                        logger.info("  Deleted certification (project): " + (deleted ? "SUCCESS" : "FAILED"));
                    }
                } catch (Exception e) {
                    // Ignore if project path doesn't exist
                }
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error deleting physical files: " + e.getMessage(), e);
        }
    }

    // ========== UPDATED REGISTRATION METHOD - WITH REJECTED RECORDS DELETION ==========
    private void processNewRegistration(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        logger.info("\n=== REGISTRATION START ===");

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            // Get form parameters
            String userType = request.getParameter("reg_role");
            String username = request.getParameter("username").trim();
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirm_password");
            String name = request.getParameter("name").trim();
            String email = request.getParameter("email").trim();
            String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";
            String nric = request.getParameter("nric").trim();
            String bodStr = request.getParameter("bod");
            String address = request.getParameter("address").trim();

            logger.info("Processing registration for: " + username + ", Role: " + userType);

            // Get file parts
            Part profileImagePart = request.getPart("profileImage");
            Part certificationPart = request.getPart("certification");

            // Validate
            if (!password.equals(confirmPassword)) {
                throw new Exception("Passwords do not match.");
            }

            nric = nric.replace("-", "");
            if (!nric.matches("\\d{12}")) {
                throw new Exception("NRIC must be 12 digits.");
            }

            // TAMBAH: Delete rejected records TERLEBIH DAHULU untuk instructor
            if ("instructor".equals(userType)) {
                try {
                    logger.info("Deleting rejected records for instructor...");
                    deleteRejectedRecords(email, username, nric);
                    logger.info("✓ Rejected records deletion completed for: " + email);
                } catch (SQLException e) {
                    logger.log(Level.WARNING, "⚠ Warning in rejected records deletion: " + e.getMessage(), e);
                    // Jangan throw exception, continue dengan registration biasa
                }
            }

            // Sekarang check existing data (DAOs sudah exclude rejected)
            RegistrationDAO registrationDAO = new RegistrationDAO();

            if (registrationDAO.isUsernameTaken(username)) {
                throw new Exception("Username '" + username + "' already taken.");
            }

            if (registrationDAO.isEmailRegistered(email)) {
                throw new Exception("Email '" + email + "' already registered.");
            }

            if (registrationDAO.isNricTaken(nric)) {
                throw new Exception("NRIC already registered.");
            }

            // Convert date
            java.sql.Date bod = null;
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date parsedDate = sdf.parse(bodStr);
                bod = new java.sql.Date(parsedDate.getTime());
            } catch (Exception e) {
                throw new Exception("Invalid date of birth format.");
            }

            // ========== SAVE FILES USING NEW METHOD ==========
            logger.info("Saving uploaded files...");

            String profileImagePath = null;
            if (profileImagePart != null && profileImagePart.getSize() > 0) {
                profileImagePath = saveUploadedFile(profileImagePart, request, username, "profile", userType);
                logger.info("Profile image path: " + profileImagePath);
            }

            String certificationPath = saveUploadedFile(certificationPart, request, username, "certification", userType);
            logger.info("Certification path: " + certificationPath);

            if (certificationPath == null) {
                throw new Exception("Certification document is required.");
            }

            // Create registration record
            String adminMessage = "admin".equals(userType)
                    ? "Auto-approved during registration"
                    : "Pending admin review";

            int registerID = registrationDAO.createRegistration(userType, adminMessage);

            if (registerID == -1) {
                throw new Exception("Failed to create registration record.");
            }

            logger.info("Registration ID created: " + registerID);

            // Create user record
            boolean userCreated = false;

            if ("admin".equals(userType)) {
                Admin admin = new Admin();
                admin.setRegisterID(registerID);
                admin.setUsername(username);
                admin.setPassword(password);
                admin.setName(name);
                admin.setEmail(email);
                admin.setPhone(phone);
                admin.setNric(nric);
                admin.setProfileImageFilePath(profileImagePath);
                admin.setBod(bod);
                admin.setCertificationFilePath(certificationPath);
                admin.setAddress(address);

                AdminDAO adminDAO = new AdminDAO();
                userCreated = adminDAO.createAdmin(admin);

            } else if ("instructor".equals(userType)) {
                String yearStr = request.getParameter("yearOfExperience");
                Integer yearOfExperience = null;
                if (yearStr != null && !yearStr.trim().isEmpty()) {
                    yearOfExperience = Integer.parseInt(yearStr);
                }

                Instructor instructor = new Instructor();
                instructor.setRegisterID(registerID);
                instructor.setUsername(username);
                instructor.setPassword(password);
                instructor.setName(name);
                instructor.setEmail(email);
                instructor.setPhone(phone);
                instructor.setNric(nric);
                instructor.setProfileImageFilePath(profileImagePath);
                instructor.setBod(bod);
                instructor.setCertificationFilePath(certificationPath);
                instructor.setYearOfExperience(yearOfExperience);
                instructor.setAddress(address);

                InstructorDAO instructorDAO = new InstructorDAO();
                userCreated = instructorDAO.createInstructor(instructor);
            }

            if (!userCreated) {
                throw new Exception("Failed to create user account.");
            }

            // SUCCESS
            logger.info("✓ Registration COMPLETED successfully!");

            // SELEPAS:
            String message = "admin".equals(userType)
                    ? "Admin_account_created_successfully!_You_can_now_login."
                    : "Instructor_registration_submitted_successfully!_Please_wait_for_admin_approval.";

            response.sendRedirect(request.getContextPath() + "/general/login.jsp?message=" + message);

        } catch (Exception e) {
            logger.log(Level.SEVERE, "✗ Registration ERROR: " + e.getMessage());

            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/general/register_account.jsp").forward(request, response);

        } finally {
            logger.info("=== REGISTRATION END ===\n");
        }
    }
}
