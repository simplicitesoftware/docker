[ "$DB_SETUP" != "true" ] && exit

CREATEDB=/tmp/createdb.$$

cat << EOF > $CREATEDB
create database ${DB_NAME:-simplicite}
go
use ${DB_NAME:-simplicite}
go
create login ${DB_USER:-simplicite} with password = '${DB_PASSWORD:-simplicite}', check_policy = off
go
create user ${DB_USER:-simplicite} for login ${DB_USER:-simplicite}
go
grant connect to ${DB_USER:-simplicite}
go
grant control to ${DB_USER:-simplicite}
go
EOF

for i in {1..60}
do
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -i $CREATEDB
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

SETUP=/opt/mssql/setup/${DB_SETUP_SCRIPT:-simplicite-mssql.sql}
if [ -f $SETUP ]
then
	/opt/mssql-tools/bin/sqlcmd -S localhost -U ${DB_USER:-simplicite} -P $${DB_PASSWORD:-simplicite} -d ${DB_NAME:-simplicite} -i $SETUP
	RES=$?
	if [ $? -eq 0 ]
	then
		echo "Setup script succeeded"
	else
		echo "Setup script error: $RES"
	fi
fi
