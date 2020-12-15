ARG THEIA_TAG
FROM theiaide/theia-full:$THEIA_TAG

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-theia" \
      org.label-schema.vendor="Theia / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-theia" \
      org.opencontainers.image.title="Theia IDE for Simplicite" \
      org.opencontainers.image.description="Theia IDE for Simplicite" \
      org.opencontainers.image.vendor="Theia / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

USER root
RUN apt-get update && apt-get install -y vim curl wget

USER theia
RUN echo 'alias ls="ls --color=auto"\n\
alias dir="ls -alF"\n\
alias egrep='egrep --color=auto'\n\
alias fgrep='fgrep --color=auto'\n\
alias grep='grep --color=auto'\n\
alias rm="rm -i"\n\
alias mv="mv -i"\n\
alias cp="cp -i"\n' >> /home/theia/.bashrc
RUN ln -s /home/project /home/theia && echo '{\n\
  "folders": [],\n\
  "settings": {\n\
     "java.configuration.updateBuildConfiguration": "automatic",\n\
     "editor.fontSize": 12,\n\
     "terminal.integrated.fontSize": 12,\n\
     "files.exclude": {\n\
        "**/.classpath": true,\n\
        "**/.project": true,\n\
        "**/.settings": true\n\
     }\n\
  }\n\
}' > /home/project/default.theia-workspace
RUN git config --global user.name "Simplicite Theia IDE" && \
    git config --global user.name "contact@simplicitesoftware.com" && \
    git config --global http.sslVerify "false"

EXPOSE 3030 3000 8080
ENTRYPOINT [ "node", "/home/theia/src-gen/backend/main.js", "/home/project/default.theia-workspace", "--hostname=0.0.0.0", "--port=3030" ]
