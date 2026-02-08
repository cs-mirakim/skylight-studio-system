package com.skylightstudio.classmanagement.controller;

import com.skylightstudio.classmanagement.dao.AdminDAO;
import com.skylightstudio.classmanagement.dao.InstructorDAO;
import com.skylightstudio.classmanagement.model.Admin;
import com.skylightstudio.classmanagement.model.Instructor;
import com.skylightstudio.classmanagement.util.SessionUtil;
import java.io.*;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ProfileServlet extends HttpServlet {

    private static final Logger logger = Logger.getLogger(ProfileServlet.class.getName());

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

    // ========== UNIFIED FILE SAVING METHOD ==========
    private String saveUploadedFile(Part filePart, HttpServletRequest request,
            String username, String fileType, String userRole) throws IOException {

        if (filePart == null || filePart.getSize() == 0 || filePart.getSubmittedFileName() == null) {
            logger.info("No " + fileType + " file uploaded or empty file");
            return null;
        }

        try {
            // === DEBUG LOGGING ===
            logger.info("=== PROFILE FILE UPLOAD DEBUG START ===");
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

            // Save file using the proven method
            boolean filesSaved = saveFileToMultipleLocations(filePart, webappFilePath, projectFilePath);

            logger.info("Files saved successfully: " + filesSaved);

            // Verify files exist
            File webappFile = new File(webappFilePath);
            File projectFile = new File(projectFilePath);

            logger.info("Webapp file exists: " + webappFile.exists() + ", size: "
                    + (webappFile.exists() ? webappFile.length() : 0) + " bytes");
            logger.info("Project file exists: " + projectFile.exists() + ", size: "
                    + (projectFile.exists() ? projectFile.length() : 0) + " bytes");

            logger.info("=== PROFILE FILE UPLOAD DEBUG END ===");

            // Return relative path for database (MUST BE RELATIVE!)
            return folderName + fileName;

        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error in saveUploadedFile method", e);
            return null;
        }
    }

    // ========== SAME METHOD AS REGISTRATION ==========
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

    // Delete old file if exists
    private void deleteOldFile(HttpServletRequest request, String filePath) {
        if (filePath == null || filePath.isEmpty()) {
            return;
        }

        try {
            ServletContext context = request.getServletContext();
            String webappPath = context.getRealPath("");

            if (webappPath != null && !webappPath.isEmpty()) {
                // Delete from webapp directory
                String webappFilePath = webappPath + filePath;
                File webappFile = new File(webappFilePath);

                if (webappFile.exists()) {
                    boolean deleted = webappFile.delete();
                    logger.info("Deleted webapp file: " + filePath + " - " + deleted);
                }

                // Also try to delete from project directory
                try {
                    File webappDir = new File(webappPath);
                    File buildDir = webappDir.getParentFile();
                    if (buildDir != null) {
                        File projectRoot = buildDir.getParentFile();
                        if (projectRoot != null) {
                            String projectFilePath = projectRoot.getAbsolutePath()
                                    + File.separator + "web"
                                    + File.separator + filePath;
                            File projectFile = new File(projectFilePath);

                            if (projectFile.exists()) {
                                boolean projectDeleted = projectFile.delete();
                                logger.info("Deleted project file: " + projectFilePath + " - " + projectDeleted);
                            }
                        }
                    }
                } catch (Exception e) {
                    logger.log(Level.WARNING, "Could not delete project file: " + e.getMessage());
                }
            }
        } catch (Exception e) {
            logger.log(Level.WARNING, "Error deleting old file: " + filePath, e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("general/login.jsp?error=access_denied&message=Please_login_to_access_this_page");
            return;
        }

        request.getRequestDispatcher("/general/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        logger.info("\n=== PROFILE UPDATE START ===");

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();

        if (!SessionUtil.isLoggedIn(session)) {
            response.sendRedirect("general/login.jsp?error=access_denied");
            return;
        }

        String userRole = SessionUtil.getUserRole(session);
        Integer userId = SessionUtil.getUserId(session);
        String userEmail = SessionUtil.getUserEmail(session);

        try {
            if ("admin".equals(userRole)) {
                updateAdminProfile(request, response, session, userId, userEmail);
            } else if ("instructor".equals(userRole)) {
                updateInstructorProfile(request, response, session, userId, userEmail);
            } else {
                response.sendRedirect("general/profile.jsp?error=invalid_role");
            }

        } catch (Exception e) {
            logger.log(Level.SEVERE, "✗ Profile update ERROR: " + e.getMessage());
            response.sendRedirect("general/profile.jsp?error=update_failed&message="
                    + e.getMessage().replace(" ", "_"));
        } finally {
            logger.info("=== PROFILE UPDATE END ===\n");
        }
    }

    private void updateAdminProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, Integer userId, String currentEmail)
            throws SQLException, IOException, ServletException, Exception {

        AdminDAO adminDAO = new AdminDAO();
        Admin admin = adminDAO.getAdminById(userId);

        if (admin == null) {
            throw new Exception("Admin not found");
        }

        // Get form parameters
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String nric = request.getParameter("nric");
        String bodStr = request.getParameter("bod");
        String address = request.getParameter("address");

        // Get file parts
        Part profileImagePart = request.getPart("profileImage");
        Part certificationPart = request.getPart("certification");

        // Get password fields (optional)
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate username uniqueness across BOTH tables (admin & instructor)
        if (!username.equals(admin.getUsername())) {
            // Check in admin table (exclude current admin)
            Admin existingAdmin = adminDAO.getAdminByUsername(username);
            if (existingAdmin != null && existingAdmin.getAdminID() != userId) {
                throw new Exception("Username already taken by another admin");
            }

            // Check in instructor table
            InstructorDAO instructorDAO = new InstructorDAO();
            Instructor existingInstructor = instructorDAO.getInstructorByUsername(username);
            if (existingInstructor != null) {
                throw new Exception("Username already taken by an instructor");
            }
        }

        // Validate email uniqueness (if changed)
        if (!email.equals(currentEmail)) {
            Admin existingAdmin = adminDAO.getAdminByEmail(email);
            if (existingAdmin != null) {
                throw new Exception("Email already registered by another user");
            }
        }

        // Validate password change if provided
        if (currentPassword != null && !currentPassword.isEmpty()) {
            if (newPassword == null || newPassword.isEmpty()
                    || confirmPassword == null || confirmPassword.isEmpty()) {
                throw new Exception("Please fill all password fields to change password");
            }

            if (!newPassword.equals(confirmPassword)) {
                throw new Exception("New passwords do not match");
            }

            if (newPassword.length() < 6) {
                throw new Exception("New password must be at least 6 characters");
            }

            String hashedCurrentPassword = hashPassword(currentPassword);
            if (!hashedCurrentPassword.equals(admin.getPassword())) {
                throw new Exception("Current password is incorrect");
            }

            boolean passwordUpdated = adminDAO.updatePassword(userId, newPassword);
            if (!passwordUpdated) {
                throw new Exception("Failed to update password");
            }
        }

        // Handle profile image upload
        String profileImagePath = admin.getProfileImageFilePath();
        if (profileImagePart != null && profileImagePart.getSize() > 0) {
            // Delete old profile image if exists
            if (profileImagePath != null && !profileImagePath.isEmpty()) {
                deleteOldFile(request, profileImagePath);
            }

            // Save new profile image USING THE SAME METHOD
            profileImagePath = saveUploadedFile(profileImagePart, request,
                    username, "profile", "admin");

            // Update only if new file was saved
            if (profileImagePath != null) {
                admin.setProfileImageFilePath(profileImagePath);
                logger.info("Updated profile image path: " + profileImagePath);
            }
        }

        // Handle certification upload
        String certificationPath = admin.getCertificationFilePath();
        if (certificationPart != null && certificationPart.getSize() > 0) {
            // Delete old certification if exists
            if (certificationPath != null && !certificationPath.isEmpty()) {
                deleteOldFile(request, certificationPath);
            }

            // Save new certification USING THE SAME METHOD
            certificationPath = saveUploadedFile(certificationPart, request,
                    username, "certification", "admin");

            // Update only if new file was saved
            if (certificationPath != null) {
                admin.setCertificationFilePath(certificationPath);
                logger.info("Updated certification path: " + certificationPath);
            }
        }

        // Convert date - FIX FOR HTML DATE INPUT FORMAT
        java.sql.Date bod = null;
        if (bodStr != null && !bodStr.isEmpty()) {
            try {
                // HTML input date format is yyyy-MM-dd
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date parsedDate = sdf.parse(bodStr);
                bod = new java.sql.Date(parsedDate.getTime());
                logger.info("Parsed BOD: " + bod);
            } catch (Exception e) {
                logger.warning("Invalid date format: " + bodStr);
                // Keep existing date if invalid
                bod = admin.getBod();
            }
        } else {
            // Keep existing date if not provided
            bod = admin.getBod();
        }

        // Update admin object
        admin.setUsername(username);
        admin.setName(name);
        admin.setEmail(email);
        admin.setPhone(phone);
        admin.setNric(nric);
        admin.setBod(bod);
        admin.setAddress(address);
        // Note: Status removed - not editable by user

        logger.info("Updating admin with data:");
        logger.info("Username: " + username);
        logger.info("Name: " + name);
        logger.info("Email: " + email);
        logger.info("BOD: " + bod);
        logger.info("Profile Image: " + profileImagePath);
        logger.info("Certification: " + certificationPath);

        // Update in database using DAO method
        boolean updated = adminDAO.updateAdmin(admin);

        if (updated) {
            // Refresh admin data from database
            Admin updatedAdmin = adminDAO.getAdminById(userId);
            SessionUtil.setAdminSession(session, updatedAdmin);
            logger.info("✓ Admin profile updated successfully!");
            response.sendRedirect("general/profile.jsp?message=profile_updated_successfully");
        } else {
            throw new Exception("Failed to update admin profile");
        }
    }

    private void updateInstructorProfile(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, Integer userId, String currentEmail)
            throws SQLException, IOException, ServletException, Exception {

        InstructorDAO instructorDAO = new InstructorDAO();
        Instructor instructor = instructorDAO.getInstructorById(userId);

        if (instructor == null) {
            throw new Exception("Instructor not found");
        }

        // Get form parameters
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String nric = request.getParameter("nric");
        String bodStr = request.getParameter("bod");
        String address = request.getParameter("address");
        String yearOfExperienceStr = request.getParameter("yearOfExperience");

        // Get file parts
        Part profileImagePart = request.getPart("profileImage");
        Part certificationPart = request.getPart("certification");

        // Get password fields (optional)
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Validate username uniqueness across BOTH tables (admin & instructor)
        if (!username.equals(instructor.getUsername())) {
            // Check in instructor table (exclude current instructor)
            Instructor existingInstructor = instructorDAO.getInstructorByUsername(username);
            if (existingInstructor != null && existingInstructor.getInstructorID() != userId) {
                throw new Exception("Username already taken by another instructor");
            }

            // Check in admin table
            AdminDAO adminDAO = new AdminDAO();
            Admin existingAdmin = adminDAO.getAdminByUsername(username);
            if (existingAdmin != null) {
                throw new Exception("Username already taken by an admin");
            }
        }

        // Validate email uniqueness (if changed)
        if (!email.equals(currentEmail)) {
            Instructor existingInstructor = instructorDAO.getInstructorByEmail(email);
            if (existingInstructor != null) {
                throw new Exception("Email already registered by another user");
            }
        }

        // Validate password change if provided
        if (currentPassword != null && !currentPassword.isEmpty()) {
            if (newPassword == null || newPassword.isEmpty()
                    || confirmPassword == null || confirmPassword.isEmpty()) {
                throw new Exception("Please fill all password fields to change password");
            }

            if (!newPassword.equals(confirmPassword)) {
                throw new Exception("New passwords do not match");
            }

            if (newPassword.length() < 6) {
                throw new Exception("New password must be at least 6 characters");
            }

            String hashedCurrentPassword = hashPassword(currentPassword);
            if (!hashedCurrentPassword.equals(instructor.getPassword())) {
                throw new Exception("Current password is incorrect");
            }

            boolean passwordUpdated = instructorDAO.updatePassword(userId, newPassword);
            if (!passwordUpdated) {
                throw new Exception("Failed to update password");
            }
        }

        // Handle profile image upload
        String profileImagePath = instructor.getProfileImageFilePath();
        if (profileImagePart != null && profileImagePart.getSize() > 0) {
            // Delete old profile image if exists
            if (profileImagePath != null && !profileImagePath.isEmpty()) {
                deleteOldFile(request, profileImagePath);
            }

            // Save new profile image USING THE SAME METHOD
            profileImagePath = saveUploadedFile(profileImagePart, request,
                    username, "profile", "instructor");

            // Update only if new file was saved
            if (profileImagePath != null) {
                instructor.setProfileImageFilePath(profileImagePath);
                logger.info("Updated profile image path: " + profileImagePath);
            }
        }

        // Handle certification upload
        String certificationPath = instructor.getCertificationFilePath();
        if (certificationPart != null && certificationPart.getSize() > 0) {
            // Delete old certification if exists
            if (certificationPath != null && !certificationPath.isEmpty()) {
                deleteOldFile(request, certificationPath);
            }

            // Save new certification USING THE SAME METHOD
            certificationPath = saveUploadedFile(certificationPart, request,
                    username, "certification", "instructor");

            // Update only if new file was saved
            if (certificationPath != null) {
                instructor.setCertificationFilePath(certificationPath);
                logger.info("Updated certification path: " + certificationPath);
            }
        }

        // Convert date - FIX FOR HTML DATE INPUT FORMAT
        java.sql.Date bod = null;
        if (bodStr != null && !bodStr.isEmpty()) {
            try {
                // HTML input date format is yyyy-MM-dd
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                Date parsedDate = sdf.parse(bodStr);
                bod = new java.sql.Date(parsedDate.getTime());
                logger.info("Parsed BOD: " + bod);
            } catch (Exception e) {
                logger.warning("Invalid date format: " + bodStr);
                // Keep existing date if invalid
                bod = instructor.getBod();
            }
        } else {
            // Keep existing date if not provided
            bod = instructor.getBod();
        }

        // Convert year of experience
        Integer yearOfExperience = null;
        if (yearOfExperienceStr != null && !yearOfExperienceStr.isEmpty()) {
            try {
                yearOfExperience = Integer.parseInt(yearOfExperienceStr);
            } catch (NumberFormatException e) {
                logger.warning("Invalid year of experience: " + yearOfExperienceStr);
                yearOfExperience = instructor.getYearOfExperience();
            }
        }

        // Update instructor object
        instructor.setUsername(username);
        instructor.setName(name);
        instructor.setEmail(email);
        instructor.setPhone(phone);
        instructor.setNric(nric);
        instructor.setBod(bod);
        instructor.setYearOfExperience(yearOfExperience);
        instructor.setAddress(address);
        // Note: Status removed - not editable by user

        logger.info("Updating instructor with data:");
        logger.info("Username: " + username);
        logger.info("Name: " + name);
        logger.info("Email: " + email);
        logger.info("BOD: " + bod);
        logger.info("Profile Image: " + profileImagePath);
        logger.info("Certification: " + certificationPath);

        // Update in database using DAO method
        boolean updated = instructorDAO.updateInstructor(instructor);

        if (updated) {
            // Refresh instructor data from database
            Instructor updatedInstructor = instructorDAO.getInstructorById(userId);
            SessionUtil.setInstructorSession(session, updatedInstructor);
            logger.info("✓ Instructor profile updated successfully!");
            response.sendRedirect("general/profile.jsp?message=profile_updated_successfully");
        } else {
            throw new Exception("Failed to update instructor profile");
        }
    }
}
