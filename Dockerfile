# Use a Maven image to build the Spring Boot application
FROM maven:3.8.8-amazoncorretto-17 AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the entire application and build the JAR
COPY src /app/src

# Copy source code and application.properties
COPY src /app/src
COPY src/main/resources/application.properties /app/application.properties

# Set Spring Boot config location to include external file
ENV SPRING_CONFIG_LOCATION=classpath:/,file:/app/application.properties

RUN mvn clean package -DskipTests

# Use OpenJDK to run the Spring Boot application
FROM eclipse-temurin:17-jdk

# Set the working directory
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/*.jar /app/app.jar

# ✅ Copy application.properties from build stage
COPY --from=build /app/application.properties /app/application.properties

# Set the config location again
ENV SPRING_CONFIG_LOCATION=classpath:/,file:/app/application.properties

# Expose the port the app will run on
EXPOSE 8080

# Command to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]

