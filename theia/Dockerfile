FROM centos:8

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-theia" \
      org.label-schema.vendor="Theia server / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-theia" \
      org.opencontainers.image.title="Theia server IDE for Simplicite" \
      org.opencontainers.image.description="Theia server IDE for Simplicite" \
      org.opencontainers.image.vendor="Theia server / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

USER root
RUN echo "Installing Theia" && \
    npm install -g yarn && \
    git clone https://github.com/eclipse-theia/theia theia && cd theia && \
    yarn && yarn download:plugins && yarn browser build && \
    ln -s /var/simplicite/projects .

USER simplicite
COPY --chown=simplicite:simplicite default.theia-workspace /var/simplicite/projects/
COPY --chown=simplicite:simplicite settings.xml /var/simplicite/.m2/

WORKDIR /usr/local/theia
CMD [ "yarn browser start /var/simplicite/projects --hostname 0.0.0.0 --port 3030" ]
