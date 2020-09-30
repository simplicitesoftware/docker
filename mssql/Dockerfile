FROM mcr.microsoft.com/mssql/server:2019-latest

ARG BUILD_DATE
LABEL org.label-schema.name="simplicite-mssql" \
      org.label-schema.vendor="Microsoft / Simplicite Software" \
      org.label-schema.build-date="$BUILD_DATE" \
      org.opencontainers.image.ref.name="simplicite-mssql" \
      org.opencontainers.image.title="Microsoft SQL server for Simplicite" \
      org.opencontainers.image.description="Microsoft SQL server for Simplicite " \
      org.opencontainers.image.vendor="iMicrosoft / Simplicite Software" \
      org.opencontainers.image.created="$BUILD_DATE"

ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=_Str0ng_Passw0rd_
COPY entrypoint.sh /opt/mssql/bin
COPY setup.sh /opt/mssql/bin
CMD /bin/bash /opt/mssql/bin/entrypoint.sh
