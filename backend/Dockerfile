# ─── Stage 1: Build ───────────────────────────────────────────
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests -B

# ─── Stage 2: Runtime ─────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# FIX: The JDK ships its own internal timezone database, so no OS tzdata
# package is required — but without this the JVM defaults to UTC inside
# the container regardless of the host machine's timezone. Since the app's
# business logic uses LocalDateTime.now() (no zone info attached) for every
# createdAt/completedAt/deletedAt timestamp, an unset container timezone
# silently shifts every stored/displayed time by the UTC offset (5:30 for
# IST) as soon as this image runs anywhere other than a UTC-default host.
ENV TZ=Asia/Kolkata

# FIX: Create dirs and set permissions BEFORE switching to non-root user
RUN addgroup -S syntaxcore && adduser -S syntaxcore -G syntaxcore \
    && mkdir -p uploads logs \
    && chown -R syntaxcore:syntaxcore /app

USER syntaxcore

COPY --from=builder --chown=syntaxcore:syntaxcore /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-Duser.timezone=Asia/Kolkata", \
  "-jar", "app.jar"]
