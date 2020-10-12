FROM node:lts

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-theia" \
      org.label-schema.vendor="Theia / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-theia" \
      org.opencontainers.image.title="Theia IDE for Simplicite" \
      org.opencontainers.image.description="Theia IDE for Simplicite" \
      org.opencontainers.image.vendor="Theia / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

RUN apt-get update && \
  apt-get install -y sudo vim zip unzip curl wget uni2ascii apt-transport-https && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn && \
  rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://download.java.net/java/GA/jdk15/779bf45e88a44cbd9ea6621d33e33db1/36/GPL/openjdk-15_linux-x64_bin.tar.gz | tar xfz - -C /opt
ENV JAVA_HOME=/opt/jdk-15 PATH=/opt/jdk-15/bin/:$PATH

ARG ANT_VERSION=1.10.9
RUN wget -qO- https://www-eu.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz | tar xfz - -C /opt
ENV ANT_HOME=/opt/apache-ant-$ANT_VERSION PATH=/opt/apache-ant-$ANT_VERSION/bin/:$PATH

ARG MAVEN_VERSION=3.6.3
RUN wget -qO- https://www-eu.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xfz - -C /opt
ENV MAVEN_HOME=/opt/apache-maven-$MAVEN_VERSION PATH=/opt/apache-maven-$MAVEN_VERSION/bin/:$PATH

ARG GRADLE_VERSION=6.6.1
RUN cd /opt && wget -q https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip && unzip -q gradle-$GRADLE_VERSION-bin.zip && rm -f gradle-$GRADLE_VERSION-bin.zip
ENV GRADLE_HOME=/opt/gradle-$GRADLE_VERSION PATH=/opt/gradle-$GRADLE_VERSION/bin/:$PATH

ARG THEIA_TAG
COPY $THEIA_TAG-package.json /home/theia/package.json

RUN adduser --disabled-password --gecos '' theia && echo "theia ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chmod g+rw /home && \
    mkdir -p /home/theia/projects/.m2/repository && \
    ln -s /home/theia/projects/.m2 /home/theia/.m2 && \
    chown -R theia:theia /home/theia

WORKDIR /home/theia
USER theia

RUN echo 'alias ls="ls --color=auto"\n\
alias dir="ls -alF"\n\
alias egrep='egrep --color=auto'\n\
alias fgrep='fgrep --color=auto'\n\
alias grep='grep --color=auto'\n\
alias rm="rm -i"\n\
alias mv="mv -i"\n\
alias cp="cp -i\n"' > .bashrc

RUN echo '{\n\
  "folders": [],\n\
  "settings": {\n\
     "java.configuration.updateBuildConfiguration": "automatic",\n\
	 "editor.fontSize": 12,\n\
	 "terminal.integrated.fontSize": 12,\n\
     "launch": {\n\
        "configurations": [\n\
            {\n\
              "type": "java",\n\
              "name": "Debug (remote)",\n\
              "request": "attach",\n\
              "hostName": "_a_remote_hostname_ior_ip_address_",\n\
              "port": 8000\n\
           }\n\
        ]\n\
     },\n\
     "files.exclude": {\n\
        "**/.classpath": true,\n\
        "**/.project": true,\n\
        "**/.settings": true\n\
     }\n\
  }\n\
}' > projects/default.theia-workspace

RUN git config --global user.name "Simplicite Theia IDE" && \
    git config --global user.name "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false"

RUN yarn --cache-folder ./ycache && rm -rf ./ycache && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build ; \
    yarn theia download:plugins
EXPOSE 3030 3000 8080
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENTRYPOINT [ "yarn", "theia", "start", "/home/theia/projects/default.theia-workspace", "--hostname=0.0.0.0", "--port=3030" ]
