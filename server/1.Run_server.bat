@echo off
REM Run Spring Boot Server

REM Run the JAR file
mvnw clean package && cd "target" && java -jar chat-0.0.1-SNAPSHOT.jar

REM Server Started
pause
