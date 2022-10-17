FROM quay.io/centos/centos:stream8

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-vscode" \
      org.label-schema.vendor="VSCode server / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.label-schema.license="NONE" \
      org.opencontainers.image.ref.name="simplicite-vscode" \
      org.opencontainers.image.title="VSCode server IDE for Simplicite" \
      org.opencontainers.image.description="VSCode server IDE for Simplicite" \
      org.opencontainers.image.vendor="VSCode server / Simplicite Software" \
      org.opencontainers.image.licenses="NONE" \
      org.opencontainers.image.created="$BUILD_DATE"

ARG ANT_VERSION=1.10.12
ARG MAVEN_VERSION=3.8.6
ARG GRADLE_VERSION=7.5.1
ARG NODE_VERSION=v16.18.0

USER root
RUN dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y bash git vim-enhanced nmap openssh-clients openssl curl wget zip unzip xz ca-certificates libjpeg fontconfig mariadb postgresql java-17-openjdk-devel && \
    dnf clean all && \
    cd /usr/local && \
    echo "Installing Apache Ant $ANT_VERSION" && \
    wget -qO- https://www-eu.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xfz - && \
    echo "Installing Apache Maven $MAVEN_VERSION" && \
    wget -qO- https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xfz - && \
    echo "Installing Gradle $GRADLE_VERSION" && \
    wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && unzip -q gradle-$GRADLE_VERSION-bin.zip && rm -f gradle-$GRADLE_VERSION-bin.zip && \
    echo "Installing Node.js $NODE_VERSION" && \
    wget -qO- https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz | tar xfJ - && \
    echo "Installing VSCode server" && \
    curl -fsSL https://code-server.dev/install.sh | sh && \
    groupadd -g 2000 simplicite && useradd -N -g 2000 -u 2000 -d /var/simplicite simplicite

COPY letterpress* /usr/lib/code-server/lib/vscode/out/vs/workbench/browser/parts/editor/media/
COPY favicon* /usr/lib/code-server/src/browser/media/
COPY pwa* /usr/lib/code-server/src/browser/media/

ENV LANG=en_US.UTF-8 \
    ANT_HOME=/usr/local/apache-ant-$ANT_VERSION \
    MAVEN_HOME=/usr/local/apache-maven-$MAVEN_VERSION \
    GRADLE_HOME=/usr/local/gradle-$GRADLE_VERSION \
    NODE_HOME=/usr/local/node-$NODE_VERSION-linux-x64 \
    NODE_HOME=/usr/local/node-$NODE_VERSION-linux-x64 \
    PATH=/usr/local/bin:/usr/local/apache-ant-$ANT_VERSION/bin:/usr/local/apache-maven-$MAVEN_VERSION/bin:/usr/local/gradle-$GRADLE_VERSION/bin:/usr/local/node-$NODE_VERSION-linux-x64/bin:$PATH \
    SERVICE_URL=https://open-vsx.org/vscode/gallery \
    ITEM_URL=https://open-vsx.org/vscode/item \
    LOG4J_FORMAT_MSG_NO_LOOKUPS=true

USER simplicite
COPY --chown=simplicite:simplicite config.yaml /var/simplicite/.config/code-server/
COPY --chown=simplicite:simplicite settings.json /var/simplicite/.local/share/code-server/User/
COPY --chown=simplicite:simplicite settings.xml /var/simplicite/.m2/
RUN git config --global user.name "Simplicite Software" && \
    git config --global user.email "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false" && \
    mkdir /var/simplicite/projects && \
    /usr/bin/code-server \
    --install-extension vscjava.vscode-java-pack \
    --install-extension redhat.vscode-xml \
    --install-extension simpliciteSoftware.simplicite-vscode-tools && \
    echo -e "alias vi=vim\n\
alias rm='rm -i'\n\
alias cp='cp -i'\n\
alias mv='mv -i'\n\
alias dir='ls -alF --color=always'" >> /var/simplicite/.bashrc

EXPOSE 3030 3000 8080 8443 8444 8000

WORKDIR /var/simplicite
CMD [ "/usr/bin/code-server" ]
