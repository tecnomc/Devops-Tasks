FROM adoptopenjdk/openjdk11:alpine-jre

WORKDIR /opt/app

# Copy the artifact into the container
COPY spring-boot-web.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]



=========================================================================



FROM python:3.9

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]



============================================================================



##artifact build stage
FROM maven AS buildstage
RUN mkdir /opt/mindcircuit13
WORKDIR /opt/mindcircuit13
COPY . .
RUN mvn clean install    ## artifact -- .war

### tomcat deploy stage
FROM tomcat
WORKDIR webapps
COPY --from=buildstage /opt/mindcircuit13/target/*.war .
RUN rm -rf ROOT && mv *.war ROOT.war
EXPOSE 8080



==============================================================================



FROM openjdk:8-jdk-alpine
WORKDIR /app
COPY /target/demoapp-1.0.jar app.jar
ENTRYPOINT [ "java","-jar", "app.jar"]
EXPOSE 8080



===============================================================================



# Example Dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y nginx
COPY index.html /var/www/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]



================================================================================



FROM node:24-alpine

# Create app user and group
-S → Creates a system user (no password, no home directory login).
-G app → Assigns the user to the app group.
Last app → Username
RUN addgroup app && adduser -S -G app app

WORKDIR /usr/src/app

# Copy package files and install dependencies as root
COPY package*.json ./

# Skips development dependencies
RUN npm ci --omit=dev

# Copy rest of the app
COPY . .

# Switch to non-root user for runtime
USER app

EXPOSE 3000
CMD ["node", "app.js"]



===============================================================================


FROM nginx

COPY index.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY index.js /usr/share/nginx/html/


=================================================================================



# Stage 1: Build React app
FROM public.ecr.aws/docker/library/node:18 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM public.ecr.aws/docker/library/nginx:latest
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]


