# Multi-stage Docker build for JWT Example Application

# Stage 1: Builder
FROM maven:3.9-eclipse-temurin-25-alpine AS builder

WORKDIR /build

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY src/ src/

# Build application
RUN mvn clean package -DskipTests -q

# Stage 2: Runtime
FROM eclipse-temurin:25-jre-alpine

# Labels for metadata
LABEL maintainer="Your Organization"
LABEL version="1.0.0"
LABEL description="JWT Authentication Example - Spring Boot Application"

# Set environment variables
ENV APP_HOME=/opt/app \
    JAVA_OPTS="-server -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Dfile.encoding=UTF-8" \
    LOG_LEVEL="INFO"

# Create app user (non-root for security)
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser && \
    mkdir -p ${APP_HOME} && \
    chown -R appuser:appgroup ${APP_HOME}

WORKDIR ${APP_HOME}

# Copy JAR from builder stage
COPY --from=builder --chown=appuser:appgroup /build/target/*.jar app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/api/health || exit 1

# Expose port
EXPOSE 8080

# Switch to non-root user
USER appuser

# Run application
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]

