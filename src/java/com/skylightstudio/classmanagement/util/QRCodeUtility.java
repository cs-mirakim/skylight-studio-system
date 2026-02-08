package com.skylightstudio.classmanagement.util;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;

public class QRCodeUtility {

    private static final Logger logger = Logger.getLogger(QRCodeUtility.class.getName());

    // Generate QR code and save to file
    public static String generateAndSaveQRCode(String content, String fileName, HttpServletRequest request) {
        try {
            // Get application context
            ServletContext context = request.getServletContext();
            String webappPath = context.getRealPath("");

            if (webappPath == null) {
                webappPath = "";
            }

            // Folder path
            String folderName = "qr_codes/";
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

            // Generate QR code
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(content, BarcodeFormat.QR_CODE, 300, 300);

            // Convert to BufferedImage
            BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(bitMatrix);

            // Save to webapp directory
            String webappFilePath = fullWebappPath + fileName;
            File webappFile = new File(webappFilePath);
            ImageIO.write(qrImage, "PNG", webappFile);
            logger.info("QR code saved to webapp: " + webappFilePath);

            // Save to project directory (for development)
            if (!projectPath.equals(fullWebappPath)) {
                String projectFilePath = projectPath + fileName;
                File projectFile = new File(projectFilePath);
                ImageIO.write(qrImage, "PNG", projectFile);
                logger.info("QR code saved to project: " + projectFilePath);
            }

            // Return relative path
            return folderName + fileName;

        } catch (WriterException | IOException e) {
            logger.log(Level.SEVERE, "Error generating QR code: " + e.getMessage(), e);
            return "qr_codes/dummy.png"; // Fallback to dummy QR code
        }
    }

    // Generate QR content URL
    public static String generateQRContent(int classId, HttpServletRequest request) {
        String baseUrl = request.getRequestURL().toString();
        String contextPath = request.getContextPath();

        // Extract protocol and host
        String url = baseUrl.substring(0, baseUrl.indexOf(contextPath)) + contextPath;

        // Generate feedback URL
        return url + "/feedback.jsp?classId=" + classId;
    }

    // Get dummy QR code path
    public static String getDummyQRPath() {
        return "qr_codes/dummy.png";
    }
}
