# Use the official Tomcat image as the base
FROM tomcat:9.0

# Set environment variables for Tomcat
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV TOMCAT_ADMIN_USER admin
ENV TOMCAT_ADMIN_PASS ##PASS##

# Enable the manager page and allow access
RUN cp -r /usr/local/tomcat/webapps.dist/manager $CATALINA_HOME/webapps/
COPY ./context.xml $CATALINA_HOME/webapps/manager/META-INF/

# Copy a custom tomcat-users.xml to enable the admin GUI
COPY tomcat-users.xml $CATALINA_HOME/conf/

# Copy the disabled lockoutrealm version of the server.xml file to allow brute forcing
COPY server.xml $CATALINA_HOME/conf/server.xml

# Copy the WAR file into the webapps directory
COPY ./webapps/warlog.war $CATALINA_HOME/webapps/

# Create a token for half points in the starting directory
RUN echo "TOKEN 1: ##TOKEN1##" > /TOKEN1.txt

# Expose the Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

