ARG version=2022
FROM mcr.microsoft.com/mssql/server:${version}-latest
ENV ACCEPT_EULA=Y CONFIG_EDGE_BUILD=0 SA_PASSWORD=_Str0ng_Passw0rd_
COPY setup.sh /opt/mssql/bin
CMD /opt/mssql/bin/setup.sh & /opt/mssql/bin/sqlservr
