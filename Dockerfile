FROM centos
MAINTAINER Simplicite.io <contact@simplicite.io>
RUN yum upgrade -y && yum clean all
RUN yum -y install java-1.8.0-openjdk && yum clean all
COPY tomcat /usr/local/tomcat
RUN mkdir /usr/local/tomcat/logs /usr/local/tomcat/temp && chmod +x /usr/local/tomcat/run.sh
EXPOSE 8080
CMD cd /usr/local/tomcat; ./run.sh
