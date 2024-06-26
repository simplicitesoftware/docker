ARG SIMPLICITE_BASE

# ---SETP 1---- 
# Use simplicité main image to get webapp (for now)
FROM $SIMPLICITE_BASE as simplicite-main

# ---STEP 2---- 
# Using Alpine's JDK to
# - build HealthCheck
# - build custom JRE

FROM alpine:latest as java-jdk-jre
RUN apk add --no-cache openjdk17 binutils findutils

# build HealthCheck.java
COPY HealthCheck.java /usr/local/HealthCheck.java
RUN javac /usr/local/HealthCheck.java

# build custom JRE ()
COPY --from=simplicite-main /usr/local/tomcat /usr/local/tomcat
RUN jlink --no-man-pages --no-header-files --compress=2 --output /javaruntime \
    # TODO this has to be tested
    --strip-debug \
    # TODO this can be optimized
    #--add-modules ALL-MODULE-PATH
    # TODO not working : https://stackoverflow.com/questions/71276373/how-to-calculate-list-of-needed-java-modules-with-jdeps
    # - manually added jdk.zipfs because com.simplicite.util.tools.JARTool uses "jar://"" filesystemprovider   
    --add-modules "$(jdeps --multi-release 17 --recursive -cp "$(find . -name *.jar -printf "%h/*\n" | sort -u | paste -sd ":")" --ignore-missing-deps --print-module-deps ./ | tail -1),jdk.zipfs"

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
#COPY --from=java-jdk-jre /usr/lib/jvm/java-17-openjdk $JAVA_HOME

# https://pythonspeed.com/articles/root-capabilities-docker-security/
USER simplicite

WORKDIR /usr/local/tomcat
EXPOSE 8080 8443 8444 8009
CMD [ "/usr/local/tomcat/run" ]
