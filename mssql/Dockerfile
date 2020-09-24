FROM mcr.microsoft.com/mssql/server:2019-latest
COPY entrypoint.sh /opt/mssql/bin
COPY setup.sh /opt/mssql/bin
CMD /bin/bash /opt/mssql/bin/entrypoint.sh