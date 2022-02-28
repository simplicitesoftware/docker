ARG SIMPLICITE_BASE

# ---IMAGE 1---- Use simplicité image to get webapp (for now)
FROM $SIMPLICITE_BASE as simplicite-main

# ---IMAGE 2---- Using Alpine's JDK
FROM alpine:latest as java-jdk-jre
RUN apk add --no-cache openjdk17 binutils
COPY HealthCheck.java /usr/local/HealthCheck.java
RUN javac /usr/local/HealthCheck.java
RUN jlink --no-man-pages --no-header-files --compress=2 --output /javaruntime \
    # TODO this has to be tested
    --strip-debug \
    # TODO this can be optimized
    --add-modules ALL-MODULE-PATH
#     --add-modules \
# java.base,\
# java.compiler,\
# # java.datatransfer,\
# java.desktop,\
# # java.instrument,\
# # java.logging,\
# java.management,\
# # java.management.rmi,\
# java.naming,\
# # java.net.http,\
# # java.prefs,\
# java.rmi,\
# java.scripting,\
# # java.se,\
# # java.security.jgss,\
# # java.security.sasl,\
# # java.smartcardio,\
# java.sql
# # java.sql.rowset,\
# # java.transaction.xa,\
# # java.xml,\
# # java.xml.crypto,\

# ---IMAGE 3----
FROM alpine:latest
ENV DOCKER=alpine LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8 LOG4J_FORMAT_MSG_NO_LOOKUPS=true
# TODO missing MANY ARGS & LABELS & env variables compared to standard simplicité images

# Import Simplicité
COPY --from=simplicite-main /usr/local/tomcat /usr/local/tomcat

RUN apk upgrade --no-cache && apk add --no-cache bash libjpeg && \ 
    chmod +x /usr/local/tomcat/run && \
    addgroup -g 2000 simplicite && adduser -D -H -G simplicite -u 2000 simplicite

# Set HealthCheck 
COPY --from=java-jdk-jre /usr/local/HealthCheck.class /opt/java/HealthCheck.class
HEALTHCHECK --interval=10s --timeout=1s --start-period=300s CMD java -cp /opt/java/ HealthCheck

# Import Custom JDK
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH "${JAVA_HOME}/bin:${PATH}"
COPY --from=java-jdk-jre /javaruntime $JAVA_HOME

# https://pythonspeed.com/articles/root-capabilities-docker-security/
# USER simplicite

WORKDIR /usr/local/tomcat
EXPOSE 8080 8443 8444 8009 8005 8555
CMD [ "/usr/local/tomcat/run" ]
