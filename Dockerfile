# Use Tomcat 9 with JDK 8 (compatible with your NetBeans project)
FROM tomcat:9.0-jdk8

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file to Tomcat webapps as ROOT.war (so it runs at /)
COPY dist/SkylightStudioClassManagementSystem.war /usr/local/tomcat/webapps/ROOT.war

# Create directories for file uploads
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/profile_pictures && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/certifications && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/qr_codes && \
    chmod -R 777 /usr/local/tomcat/webapps/ROOT

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]