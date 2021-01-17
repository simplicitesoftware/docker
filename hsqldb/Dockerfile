FROM openjdk:15-alpine

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-hsqldb" \
      org.label-schema.vendor="HyperSQL / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-hsqldb" \
      org.opencontainers.image.title="HyperSQL server for Simplicite" \
      org.opencontainers.image.description="HyperSQL server for Simplicite " \
      org.opencontainers.image.vendor="HyperSQL / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/* && \
    mkdir /usr/local/hsqldb && mkdir /var/lib/hsqldb
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8
# JAVA_HOME is defined by default

COPY hsqldb-2.5.1.jar /usr/local/hsqldb/hsqldb.jar
COPY sqltool-2.5.1.jar /usr/local/hsqldb/sqltool.jar

WORKDIR /usr/local/hsqldb

EXPOSE 9001
CMD [ "java", "-cp", "/usr/local/hsqldb/hsqldb.jar", "org.hsqldb.server.Server", "--database.0", "file:/var/lib/hsqldb/simplicite", "--dbname.0", "simplicite" ]
