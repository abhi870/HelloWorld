# Use a Maven image to build the Spring Boot application
FROM public.ecr.aws/amazoncorretto/maven:3.8.8-amazoncorretto-17 AS build

# Set the working directory
WORKDIR /app

# Copy the pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the entire application and build the JAR
COPY src /app/src
RUN mvn clean package -DskipTests

# Use OpenJDK to run the Spring Boot application
FROM public.ecr.aws/amazoncorretto/maven:3.8.8-amazoncorretto-17

# Set the working directory
WORKDIR /app

# Copy the built JAR file from the build stage
COPY --from=build /app/target/*.jar /app/app.jar

# Expose the port the app will run on
EXPOSE 8080

# Command to run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]

