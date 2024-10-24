# syntax=docker/dockerfile:experimental
FROM alpine as build

RUN apk upgrade --no-cache && \
    apk add --no-cache openjdk21 
    
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

RUN --mount=type=cache,target=/Users/dsilvamarsh/.m2/ ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM alpine

RUN apk upgrade --no-cache && \
    apk add --no-cache openjdk21-jre-headless

RUN addgroup -S core-bank && adduser -S core-bank -G core-bank
USER core-bank
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-cp","app:app/lib/*","com.bank.core.config.Application"]