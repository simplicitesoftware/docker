FROM centos:7

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-postfix" \
      org.label-schema.vendor="Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-postfix" \
      org.opencontainers.image.title="Minimalistic postfix server" \
      org.opencontainers.image.description="Minimalistic postfix server" \
      org.opencontainers.image.vendor="Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN yum -y update && yum -y install postfix && yum clean all && rm -rf /var/cache/yum
RUN sed -i 's/^inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf

EXPOSE 25
CMD [ "postfix start-fg" ]
