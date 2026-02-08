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

    public static String generateAndSaveQRCode(String content, String fileName, HttpServletRequest request) {
        try {
            ServletContext context = request.getServletContext();
            String webappPath = context.getRealPath("");
            if (webappPath == null) {
                webappPath = "";
            }

            String folderName = "qr_codes/";
            String fullWebappPath = webappPath;
            if (!fullWebappPath.endsWith(File.separator)) {
                fullWebappPath += File.separator;
            }
            fullWebappPath += folderName;

            String projectPath = "";
            try {
                File webappDir = new File(webappPath);
                File buildDir = webappDir.getParentFile();
                if (buildDir != null) {
                    File projectRoot = buildDir.getParentFile();
                    if (projectRoot != null) {
                        projectPath = projectRoot.getAbsolutePath()
                                + File.separator + "web"
                                + File.separator + folderName;
                    }
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Could not build project path: " + e.getMessage());
                projectPath = fullWebappPath;
            }

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

            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(content, BarcodeFormat.QR_CODE, 300, 300);
            BufferedImage qrImage = MatrixToImageWriter.toBufferedImage(bitMatrix);

            String webappFilePath = fullWebappPath + fileName;
            File webappFile = new File(webappFilePath);
            ImageIO.write(qrImage, "PNG", webappFile);
            logger.info("QR code saved to webapp: " + webappFilePath);

            if (!projectPath.equals(fullWebappPath)) {
                String projectFilePath = projectPath + fileName;
                File projectFile = new File(projectFilePath);
                ImageIO.write(qrImage, "PNG", projectFile);
                logger.info("QR code saved to project: " + projectFilePath);
            }

            return folderName + fileName;
        } catch (WriterException | IOException e) {
            logger.log(Level.SEVERE, "Error generating QR code: " + e.getMessage(), e);
            return "qr_codes/dummy.png";
        }
    }

    public static String generateQRContent(int classId, HttpServletRequest request) {
        String appUrl = System.getenv("APP_URL");

        if (appUrl != null && !appUrl.isEmpty()) {
            // Production: use APP_URL
            return appUrl + "/general/feedback.jsp?classId=" + classId;
        } else {
            // Local development: build from request
            String baseUrl = request.getRequestURL().toString();
            String contextPath = request.getContextPath();
            String url = baseUrl.substring(0, baseUrl.indexOf(contextPath)) + contextPath;
            return url + "/general/feedback.jsp?classId=" + classId;
        }
    }

    public static String getDummyQRPath() {
        return "qr_codes/dummy.png";
    }
}
