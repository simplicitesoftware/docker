FROM openjdk:15-alpine

RUN apk update && \
    apk upgrade && \
    apk add --update bash && \
    rm -rf /var/cache/apk/* && \
    mkdir /usr/local/hsqldb && mkdir /var/lib/hsqldb
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8
# JAVA_HOME is defined by default

COPY hsqldb-2.6.1.jar /usr/local/hsqldb/hsqldb.jar
COPY sqltool-2.6.1.jar /usr/local/hsqldb/sqltool.jar
COPY run.sh /usr/local/hsqldb/run
RUN chmod +x /usr/local/hsqldb/run

WORKDIR /usr/local/hsqldb

EXPOSE 9001
CMD [ "/usr/local/hsqldb/run" ]
