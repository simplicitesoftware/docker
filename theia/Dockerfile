ARG NODE_VERSION=12.18.3

FROM node:${NODE_VERSION}-alpine
RUN apk add --no-cache make pkgconfig gcc g++ python libx11-dev libxkbfile-dev libsecret-dev
ARG version=latest
WORKDIR /home/theia
ADD package.json ./package.json
ARG GITHUB_TOKEN
RUN yarn --pure-lockfile && \
    NODE_OPTIONS="--max_old_space_size=4096" yarn theia build && \
    yarn theia download:plugins && \
    yarn --production && \
    yarn autoclean --init && \
    echo *.ts >> .yarnclean && \
    echo *.ts.map >> .yarnclean && \
    echo *.spec.* >> .yarnclean && \
    yarn autoclean --force && \
    yarn cache clean

FROM node:${NODE_VERSION}-alpine
ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-theia" \
      org.label-schema.vendor="Theia server / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-theia" \
      org.opencontainers.image.title="Theia server IDE for Simplicite" \
      org.opencontainers.image.description="Theia server IDE for Simplicite" \
      org.opencontainers.image.vendor="Theia server / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"
RUN apk update && apk upgrade && \
    apk add --no-cache git openssh bash libsecret bash git curl wget zip unzip openssl ca-certificates libjpeg fontconfig ttf-dejavu openjdk11 maven apache-ant mysql-client postgresql-client && \
    rm -rf /var/cache/apk/* && \
    addgroup -g 2000 theia && \
    adduser -G theia -u 2000 -s /bin/bash -D theia && \
    chmod g+rw /home && \
    mkdir -p /home/projects && \
    chown -R theia:theia /home/theia && \
    chown -R theia:theia /home/projects
ENV HOME /home/theia
WORKDIR /home/theia
COPY --from=0 --chown=theia:theia /home/theia /home/theia
EXPOSE 3000
ENV SHELL=/bin/bash \
    THEIA_DEFAULT_PLUGINS=local-dir:/home/theia/plugins
ENV USE_LOCAL_GIT true
USER theia
CMD [ "node", "/home/theia/src-gen/backend/main.js", "/home/projects", "--hostname=0.0.0.0", "--port=3030" ]
