FROM mcr.microsoft.com/mssql/server:2019-latest
ENV ACCEPT_EULA=Y SA_PASSWORD=_Str0ng_Passw0rd_
COPY entrypoint.sh /opt/mssql/bin
COPY setup.sh /opt/mssql/bin
CMD /bin/bash /opt/mssql/bin/entrypoint.sh
