# Option 1 — Eclipse Temurin (Most Recommended)
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8082

CMD ["java", "-jar", "app.jar"]
