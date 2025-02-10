#!/bin/bash

# Don't recreate database if it already exists
[ -f /var/opt/mssql/data/${DB_NAME:-simplicite}.mdf ] && exit 0

CREATEDB=/tmp/createdb.$$

cat << EOF > $CREATEDB
print "-- Running setup script for database ${DB_NAME:-simplicite} and user  ${DB_USER:-simplicite}";
go
create database ${DB_NAME:-simplicite};
go
use ${DB_NAME:-simplicite};
go
create login ${DB_USER:-simplicite} with password = '${DB_PASSWORD:-simplicite}', check_policy = off;
go
create user ${DB_USER:-simplicite} for login ${DB_USER:-simplicite};
go
grant connect to ${DB_USER:-simplicite};
go
grant control to ${DB_USER:-simplicite};
go
print "-- Done"
go
EOF

for i in {1..60}
do
	/opt/mssql-tools18/bin/sqlcmd -C -S 127.0.0.1 -U sa -P $SA_PASSWORD -i $CREATEDB
	if [ $? -eq 0 ]
	then
		echo "Database ${DB_NAME:-simplicite} created"
		break
	else
		echo "Not ready yet..."
		sleep 3
	fi
done

rm -f $CREATEDB
