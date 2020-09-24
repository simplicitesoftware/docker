SETUP=/tmp/setup.sh.$$

cat << EOF > $SETUP
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

cat $SETUP

for i in {1..50}
do
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -i $SETUP
	if [ $? -eq 0 ]
	then
		echo "setup completed"
		break
	else
		echo "not ready yet..."
		sleep 5
	fi
done

rm -f $SETUP
