# Use Tomcat 9 with JDK 8
FROM tomcat:9.0-jdk8

# Remove default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file
COPY dist/SkylightStudioClassManagementSystem.war /tmp/app.war

# Extract WAR to ROOT directory
RUN cd /usr/local/tomcat/webapps && \
    mkdir ROOT && \
    cd ROOT && \
    jar -xvf /tmp/app.war && \
    rm /tmp/app.war

# Create upload directories with proper permissions
RUN mkdir -p /usr/local/tomcat/webapps/ROOT/profile_pictures && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/certifications && \
    mkdir -p /usr/local/tomcat/webapps/ROOT/qr_codes && \
    chmod -R 777 /usr/local/tomcat/webapps/ROOT

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]