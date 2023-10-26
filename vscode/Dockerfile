FROM almalinux:8

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

USER root
RUN groupadd -g 2000 simplicite && \
    useradd -N -g 2000 -u 2000 -d /var/simplicite simplicite && \
    mkdir /var/simplicite/data /var/simplicite/projects /var/simplicite/extensions && \
    chown -R simplicite:simplicite /var/simplicite/data /var/simplicite/projects /var/simplicite/extensions && \
    dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y bash git vim-enhanced iputils bind bind-utils nmap openssh-clients openssl curl wget zip unzip xz ca-certificates libjpeg fontconfig mariadb postgresql glibc-all-langpacks && \
    dnf clean all && \
    echo "Installing VSCode server" && \
    curl -fsSL https://code-server.dev/install.sh | sh

COPY vscode/letterpress* /usr/lib/code-server/lib/vscode/out/vs/workbench/browser/parts/editor/media/
COPY vscode/favicon* /usr/lib/code-server/src/browser/media/
COPY vscode/pwa* /usr/lib/code-server/src/browser/media/

ADD jdk-21 /usr/local/jdk
ADD ant /usr/local/ant
ADD maven /usr/local/maven
ADD node /usr/local/node

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/local/jdk \
    ANT_HOME=/usr/local/ant \
    MAVEN_HOME=/usr/local/maven \
    NODE_HOME=/usr/local/node \
    PATH=/usr/local/jdk/bin:/usr/local/bin:/usr/local/ant/bin:/usr/local/maven/bin:/usr/local/node/bin:$PATH \
    SERVICE_URL=https://open-vsx.org/vscode/gallery \
    ITEM_URL=https://open-vsx.org/vscode/item \
    LOG4J_FORMAT_MSG_NO_LOOKUPS=true

USER simplicite
COPY --chown=simplicite:simplicite vscode/config.yaml /var/simplicite/.config/code-server/
COPY --chown=simplicite:simplicite vscode/settings.json /var/simplicite/data/User/
COPY --chown=simplicite:simplicite vscode/keybindings.json /var/simplicite/data/User/
COPY --chown=simplicite:simplicite vscode/simplicite.code-snippets /var/simplicite/data/User/snippets/
COPY --chown=simplicite:simplicite vscode/settings.xml /var/simplicite/.m2/
RUN git config --global user.name "Simplicite Software" && \
    git config --global user.email "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false" && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension redhat.java && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension vscjava.vscode-java-debug && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension vscjava.vscode-java-dependency && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension vscjava.vscode-java-test && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension vscjava.vscode-maven && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension redhat.vscode-xml && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension octref.vetur && \
    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension simpliciteSoftware.simplicite-vscode-tools && \
    echo -e "alias vi=vim\n\
alias rm='rm -i'\n\
alias cp='cp -i'\n\
alias mv='mv -i'\n\
alias dir='ls -alF --color=always'" >> /var/simplicite/.bashrc

EXPOSE 3030 3000 8080 8443 8444 8000

WORKDIR /var/simplicite
CMD [ "/usr/bin/code-server", "--user-data-dir=/var/simplicite/data", "--extensions-dir=/var/simplicite/extensions" ]
