FROM registry.simplicite.io/platform:7-alpha
USER simplicite
ARG maven=3.9.16
ARG snowflake=4.2.0
RUN wget -qO- https://www-eu.apache.org/dist/maven/maven-3/$maven/binaries/apache-maven-$maven-bin.tar.gz | tar xfz - && \
    MAVEN_HOME=/usr/local/tomcat/apache-maven-$maven ./adddeps.sh net.snowflake:snowflake-jdbc-thin:$snowflake && \
    rm -fr /usr/local/tomcat/apache-maven-$maven
