# Stage 1: Build the Maven application
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy the pom.xml and download dependencies to optimize caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build war
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Deploy to Tomcat
FROM tomcat:10.1-jre17-temurin-jammy

# Remove default Tomcat web applications to avoid conflicts and save space
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the generated WAR file as ROOT.war to the Tomcat webapps directory.
# This deploys the app to the root context (/) of the server.
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Render routes HTTP traffic to the port defined in the PORT environment variable.
# We dynamic-bind Tomcat's HTTP port to $PORT on startup using a sed replacement.
EXPOSE 8080

CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-8080}\\\"/g\" /usr/local/tomcat/conf/server.xml && catalina.sh run"]
