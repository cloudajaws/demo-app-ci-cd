# Use Maven to build the app
FROM maven:3.9.2-eclipse-temurin-17 AS build
WORKDIR /app
COPY sareestore/pom.xml .
COPY sareestore/src ./src
RUN mvn clean package -DskipTests

# Run the Spring Boot app
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/sareestore-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]

