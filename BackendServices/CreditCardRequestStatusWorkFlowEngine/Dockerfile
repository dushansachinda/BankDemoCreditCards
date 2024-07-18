# 1. Building the App with Maven
FROM maven:3.9.4-eclipse-temurin-17-alpine AS builder

WORKDIR /app
COPY . /app

WORKDIR /app/CreditCardRequestStatusWorkFlowEngine
RUN mvn clean install

# 2. Using the build artifact and creating a new image
FROM openjdk:17-alpine

WORKDIR /app

# Copy the JAR file from the Maven build stage
COPY --from=builder /app/CreditCardRequestStatusWorkFlowEngine/target/creditCard-request.jar app.jar

# Copy only the requests.json file to the /app/CMS directory in the image
COPY CMS/requests.json /app/requests.json

# Expose the port your application will run on
EXPOSE 8090

# Specify the command to run on container startup
ENTRYPOINT ["java", "-jar", "app.jar"]
