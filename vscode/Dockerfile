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

USER root
RUN echo "Installing VSCode server" && \
    curl -fsSL https://code-server.dev/install.sh | sh
COPY letterpress* /usr/lib/code-server/vendor/modules/code-oss-dev/out/vs/workbench/browser/parts/editor/media/
COPY favicon* /usr/lib/code-server/src/browser/media/
COPY pwa* /usr/lib/code-server/src/browser/media/

ENV SERVICE_URL=https://open-vsx.org/vscode/gallery \
    ITEM_URL=https://open-vsx.org/vscode/item

USER simplicite
COPY --chown=simplicite:simplicite config.yaml /var/simplicite/.config/code-server/
COPY --chown=simplicite:simplicite settings.json /var/simplicite/.local/share/code-server/User/
COPY --chown=simplicite:simplicite settings.xml /var/simplicite/.m2/
RUN /usr/bin/code-server \
    --install-extension vscjava.vscode-java-pack \
    --install-extension redhat.vscode-xml \
    --install-extension simpliciteSoftware.simplicite-vscode-tools

WORKDIR /var/simplicite
CMD [ "/usr/bin/code-server" ]
