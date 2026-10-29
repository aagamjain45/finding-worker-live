# ── Stage 1: Build ────────────────────────────────────────────────
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper & config first (better Docker cache)
COPY finding-worker-release/.mvn/ .mvn/
COPY finding-worker-release/mvnw finding-worker-release/pom.xml ./
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy sources and build
COPY finding-worker-release/src/ src/
RUN ./mvnw package -DskipTests -B

# ── Stage 2: Runtime ──────────────────────────────────────────────
FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "exec java -Dserver.port=${PORT:-8080} -jar app.jar"]
