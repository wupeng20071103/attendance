# Single-stage build: compile the servlet with Tomcat's own servlet-api.jar,
# then run as the standard Tomcat 9 + Java 11 image.
# No local NetBeans / Ant / war build required.

FROM tomcat:9.0-jdk11-corretto

WORKDIR /build

# Compile Attend.java against the servlet API that ships inside Tomcat.
RUN mkdir -p /usr/local/tomcat/webapps/attendance/WEB-INF/classes
COPY src/java/attendance/Attend.java /build/attendance/Attend.java
RUN javac -cp /usr/local/tomcat/lib/servlet-api.jar \
          -d /usr/local/tomcat/webapps/attendance/WEB-INF/classes \
          /build/attendance/Attend.java

# Copy the static web content (index.html, web.xml) into the deployed webapp.
COPY web/ /usr/local/tomcat/webapps/attendance/

# Remove Tomcat's default welcome apps to keep the service clean.
RUN rm -rf /usr/local/tomcat/webapps/ROOT \
           /usr/local/tomcat/webapps/docs \
           /usr/local/tomcat/webapps/examples \
           /usr/local/tomcat/webapps/host-manager \
           /usr/local/tomcat/webapps/manager

# Entry point that adapts Tomcat's port to Render's $PORT variable.
COPY entrypoint.sh /usr/local/tomcat/bin/entrypoint.sh
RUN chmod +x /usr/local/tomcat/bin/entrypoint.sh && dos2unix /usr/local/tomcat/bin/entrypoint.sh 2>/dev/null || true

EXPOSE 8080
CMD ["/usr/local/tomcat/bin/entrypoint.sh"]
