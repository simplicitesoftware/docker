FROM simplicite/ide-base:latest

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-theia" \
      org.label-schema.vendor="Theia server / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-theia" \
      org.opencontainers.image.title="Theia server IDE for Simplicite" \
      org.opencontainers.image.description="Theia server IDE for Simplicite" \
      org.opencontainers.image.vendor="Theia server / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

ARG NODE_VERSION=v12.22.7

USER root
RUN cd /usr/local && \
    dnf install -y libX11-devel libxkbcommon-x11 xorg-x11-xkb-utils python3 && dnf clean all && \
    echo "Installing Node.js $NODE_VERSION" && \
    wget -qO- https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz | tar xfJ -

ENV NODE_HOME=/usr/local/node-$NODE_VERSION-linux-x64 \
    PATH=/usr/local/node-$NODE_VERSION-linux-x64/bin:$PATH

COPY theia /usr/local/theia
RUN npm install -g yarn && \
    echo "Getting Theia" && \
    #git clone https://github.com/eclipse-theia/theia theia && \
    echo "Building Theia" && \
    cd /usr/local/theia && yarn && yarn download:plugins && yarn browser build && \
    ln -s /var/simplicite/projects .

USER simplicite
COPY --chown=simplicite:simplicite default.theia-workspace /var/simplicite/projects/
COPY --chown=simplicite:simplicite settings.xml /var/simplicite/.m2/

EXPOSE 3030 3000 8080 8000

WORKDIR /usr/local/theia
CMD [ "yarn browser start /var/simplicite/projects --hostname 0.0.0.0 --port 3030" ]
