FROM almalinux:10

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

ADD jdk-21 /usr/local/jvm
ADD ant /usr/local/ant
ADD maven /usr/local/maven
ADD node /usr/local/node

RUN groupadd -g 2000 simplicite && \
    useradd -N -g 2000 -u 2000 -d /var/simplicite simplicite && \
    mkdir /var/simplicite/data /var/simplicite/projects /var/simplicite/extensions && \
    chown -R simplicite:simplicite /var/simplicite/data /var/simplicite/projects /var/simplicite/extensions && \
    dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y procps git vim-enhanced bind bind-utils nmap openssh-clients wget zip unzip xz libjpeg fontconfig mariadb postgresql glibc-all-langpacks sudo gpg pinentry && \
    dnf clean all && \
    echo 'simplicite ALL=(ALL) NOPASSWD: /usr/bin/dnf' >> /etc/sudoers && \
    echo 'Installing VSCode server' && \
    curl -fsSL https://code-server.dev/install.sh | sh

COPY vscode/favicon* vscode/pwa* /usr/lib/code-server/src/browser/media/
# Useless, should be overriden before code-server build...
#COPY vscode/letterpress-light.svg vscode/letterpress-dark.svg vscode/code-icon.svg /usr/lib/code-server/lib/out/media/

COPY --chown=simplicite:simplicite vscode/config.yaml /var/simplicite/.config/code-server/
COPY --chown=simplicite:simplicite vscode/settings.json vscode/keybindings.json /var/simplicite/data/User/
COPY --chown=simplicite:simplicite vscode/simplicite.code-snippets /var/simplicite/data/User/snippets/
COPY --chown=simplicite:simplicite vscode/settings.xml /var/simplicite/.m2/

USER simplicite

ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/local/jvm \
    ANT_HOME=/usr/local/ant \
    MAVEN_HOME=/usr/local/maven \
    NODE_HOME=/usr/local/node \
    PATH=/usr/local/jvm/bin:/usr/local/bin:/usr/local/ant/bin:/usr/local/maven/bin:/usr/local/node/bin:$PATH \
    SERVICE_URL=https://open-vsx.org/vscode/gallery \
    ITEM_URL=https://open-vsx.org/vscode/item \
    LOG4J_FORMAT_MSG_NO_LOOKUPS=true \
    GIT_CONFIG_GLOBAL=/var/simplicite/projects/.gitconfig

RUN echo "set completion-ignore-case on" >> /var/simplicite/.inputrc && \
    echo -e "alias vi=vim\n\
alias rm='rm -i'\n\
alias cp='cp -i'\n\
alias mv='mv -i'\n\
alias dir='ls -alF --color=always'" >> /var/simplicite/.bashrc && \
    git config --global user.name 'Simplicite Software' && \
    git config --global user.email 'contact@simplicitesoftware.com' && \
    git config --global http.sslVerify 'false' && \
    git config --global credential.helper 'store --file /var/simplicite/projects/.git-credentials'
# Not possible anymore at that stage => talled when opening a project with suggestions
#    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension vscjava.vscode-java-pack
#    /usr/bin/code-server --verbose --extensions-dir=/var/simplicite/extensions --install-extension simpliciteSoftware.simplicite-vscode-tool

EXPOSE 3030 3000 8080 8443 8444 8000

WORKDIR /var/simplicite
CMD [ "/usr/bin/code-server", "--user-data-dir=/var/simplicite/data", "--extensions-dir=/var/simplicite/extensions" ]
