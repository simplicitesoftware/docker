cat << EOF > /tmp/setup.sql
create database $DB_NAME
go
use $DB_NAME
go
create login $DB_USER with password = '$DB_PASSWORD', check_policy = off
go
create user $DB_USER for login $DB_USER
go
grant connect to $DB_USER
go
grant control to $DB_USER
go
EOF

for i in {1..50}
do
	/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i /tmp/setup.sql
	if [ $? -eq 0 ]
	then
		echo "setup completed"
		break
	else
		echo "not ready yet..."
		sleep 1
	fi
done

rm -f /tmp/setup.sql