FROM centos:8

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-vscode" \
      org.label-schema.vendor="VSCode server / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-vscode" \
      org.opencontainers.image.title="VSCode server IDE for Simplicite" \
      org.opencontainers.image.description="VSCode server IDE for Simplicite" \
      org.opencontainers.image.vendor="VSCode server / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

ENV DOCKER=centos8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

ARG ANT_VERSION=1.10.12
ARG MAVEN_VERSION=3.8.3
ARG GRADLE_VERSION=7.3
ARG NODE_VERSION=v16.13.0

COPY *.crt /etc/pki/ca-trust/source/anchors/
COPY jdk-${jvm} /usr/local/jdk
RUN cd /opt && \
    wget -qO- https://www-eu.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xfz - -C /opt && \
    wget -qO- https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xfz - -C /opt && \
    wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && unzip -q gradle-$GRADLE_VERSION-bin.zip && rm -f gradle-$GRADLE_VERSION-bin.zip && \
    wget -qO- https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz | tar xfJ - -C /opt && \
    npm install -g yarn && \
    dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y bash vim-enhanced gcc gcc-c++ make nmap openssh-clients openssl git curl wget zip unzip ca-certificates libjpeg fontconfig mariadb postgresql && \
    dnf clean all && \
    mkdir /root/.ssh && chmod 700 /root/.ssh && \
    /bin/update-ca-trust extract && \
    groupadd -g 1000 vscode && useradd -N -g 1000 -u 1000 vscode && \
    curl -fsSL https://code-server.dev/install.sh | sh

ENV JAVA_HOME=/usr/local/jdk \
    ANT_HOME=/opt/apache-ant-$ANT_VERSION PATH=/opt/apache-ant-$ANT_VERSION/bin/:$PATH \
    MAVEN_HOME=/opt/apache-maven-$MAVEN_VERSION PATH=/opt/apache-maven-$MAVEN_VERSION/bin/:$PATH \
    GRADLE_HOME=/opt/gradle-$GRADLE_VERSION PATH=/opt/gradle-$GRADLE_VERSION/bin/:$PATH \
    NODE_HOME=/opt/node-$NODE_VERSION-linux-x64 PATH=/opt/node-$NODE_VERSION-linux-x64/bin/:$PATH

USER vscode
RUN git config --global user.name "Simplicite VSCode IDE" && \
    git config --global user.name "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false" && \
    echo 'alias ls="ls --color=auto"\n\
alias vi=vim\n\
alias dir="ls -alF"\n\
alias egrep='egrep --color=auto'\n\
alias fgrep='fgrep --color=auto'\n\
alias grep='grep --color=auto'\n\
alias rm="rm -i"\n\
alias mv="mv -i"\n\
alias cp="cp -i"\n' >> /home/vscode/.bashrc

EXPOSE 3030 3000 8080 8000
ENTRYPOINT [ "vscode-server" ]
