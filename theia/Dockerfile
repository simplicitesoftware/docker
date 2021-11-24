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

ARG GIT_VERSION=2.34.0
ARG ANT_VERSION=1.10.12
ARG MAVEN_VERSION=3.8.4
ARG GRADLE_VERSION=7.3
ARG NODE_VERSION=v16.13.0

RUN dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y bash vim-enhanced pkgconf libsecret-devel autoconf gcc gcc-c++ make zlib-devel libcurl-devel nmap openssh-clients openssl curl wget zip unzip ca-certificates libjpeg fontconfig mariadb postgresql java-11-openjdk-devel && \
    dnf clean all && \
    groupadd -g 1000 simplicite && useradd -N -g 1000 -u 1000 -M simplicite && \
    cd /usr/local && \
    echo "Installing Git $GIT_VERSION" && \
    wget -qO- https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VERSION.tar.xz | tar xfJ - && \
    cd git-$GIT_VERSION && make configure && ./configure --prefix=/usr/local && make install && cd .. && rm -fr git-$GIT_VERSION && \
    echo "Installing Apache Ant $ANT_VERSION" && \
    wget -qO- https://www-eu.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xfz - && \
    echo "Installing Apache Maven $MAVEN_VERSION" && \
    wget -qO- https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xfz - && \
    echo "Installing Gradle $GRADLE_VERSION" && \
    wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && unzip -q gradle-$GRADLE_VERSION-bin.zip && rm -f gradle-$GRADLE_VERSION-bin.zip && \
    echo "Installing Node.js $NODE_VERSION" && \
    wget -qO- https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-x64.tar.xz | tar xfJ - && \
    echo "Installing Theia" && \
    ./node-$NODE_VERSION/bin/npm install -g yarn && \
    git clone https://github.com/eclipse-theia/theia theia && cd theia && \
    yarn && yarn download:plugins && yarn browser build && \
    ln -s /var/simplicite/projects .

ENV LANG=en_US.UTF-8 \
    ANT_HOME=/usr/local/apache-ant-$ANT_VERSION \
    MAVEN_HOME=/usr/local/apache-maven-$MAVEN_VERSION \
    GRADLE_HOME=/usr/local/gradle-$GRADLE_VERSION \
    NODE_HOME=/usr/local/node-$NODE_VERSION-linux-x64 \
    PATH=/usr/local/bin:/usr/local/apache-ant-$ANT_VERSION/bin:/usr/local/apache-maven-$MAVEN_VERSION/bin:/usr/local/gradle-$GRADLE_VERSION/bin:/usr/local/node-$NODE_VERSION-linux-x64/bin:$PATH:$PATH \

USER simplicite
COPY --chown=simplicite:simplicite default.theia-workspace /var/simplicite/projects/
COPY --chown=simplicite:simplicite settings.xml /var/simplicite/.m2/
RUN git config --global user.name "Simplicite VSCode IDE" && \
    git config --global user.email "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false" && \
    echo -e "alias vi=vim\n\
alias rm='rm -i'\n\
alias cp='cp -i'\n\
alias mv='mv -i'\n\
alias dir='ls -alF --color=always'" >> /var/simplicite/.bashrc

EXPOSE 3030 3000 8080 8000

WORKDIR /usr/local/theia
CMD [ "yarn browser start" ]
