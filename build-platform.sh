#!/bin/bash

TAGS="centos alpine"
[ "$1" != "" ] && TAGS=$1
SRVS="tomcat tomee"
[ "$2" != "" ] && SRVS=$2

SERVER=simplicite/server
PLATFORM=simplicite/platform
DB=docker
IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`

echo "Updating and copying template..."
cd template-4.0-release
git pull
cd ..
rm -fr template
rsync -a --exclude='.git' --exclude='.gitignore' template-4.0-release/ template
rm -f template/app/WEB-INF/db/*.dmp
sed -i "/INSERT INTO M_SYSTEM VALUES.*'PUBLIC_PAGES'/s/'yes'/'no'/" template/app/WEB-INF/db/simplicite.script
echo "Done"

cd template/tools

echo "Preparing MySQL dump..."
echo "    Converting"
./convert-mysql.sh > /dev/null
echo "    Loading"
echo "create database $DB default character set utf8;
grant all privileges on $DB.* to $DB@localhost identified by '$DB';
flush privileges;" | mysql -u root
RET=$?
[ "$RET" -ne 0 ] && exit $RET
mysql --user=$DB --password=$DB $DB < simplicite-mysql.sql
RET=$?
[ "$RET" -ne 0 ] && exit $RET
echo "update m_system set sys_value = 'BLOB' where sys_code = 'DOC_DIR'" | mysql --user=$DB --password=$DB $DB
RET=$?
[ "$RET" -ne 0 ] && exit $RET
echo "    Dumping"
mysqldump --user=$DB --password=$DB $DB > ../app/WEB-INF/db/simplicite-mysql.dmp
RET=$?
[ "$RET" -ne 0 ] && exit $RET
echo "drop database $DB;
drop user $DB@localhost;
flush privileges;" | mysql -u root
echo "Done"

echo "Preparing PostgreSQL dump..."
echo "    Converting"
./convert-postgresql.sh > /dev/null
echo "    Loading"
PGPASSWORD=postgres psql -q -h localhost -U postgres -c "create user $DB with password '$DB'"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=postgres psql -q -h localhost  -U postgres -c "create database $DB encoding 'UTF8' lc_ctype 'en_US.UTF-8' lc_collate 'en_US.UTF-8' template template0;"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=postgres psql -q -h localhost  -U postgres -c "grant all privileges on database $DB to $DB;"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=$DB psql -q -h localhost  -U $DB $DB < simplicite-postgresql.sql
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=$DB psql -q -h localhost  -U $DB $DB -c "update m_system set sys_value = 'BLOB' where sys_code = 'DOC_DIR'"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
echo "    Dumping"
PGPASSWORD=$DB pg_dump -h localhost  -U $DB $DB --no-owner > ../app/WEB-INF/db/simplicite-postgresql.dmp
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=postgres psql -q -h localhost  -U postgres -c "drop database $DB"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
PGPASSWORD=postgres psql -q -h localhost  -U postgres -c "drop user $DB"
RET=$?
[ "$RET" -ne 0 ] && exit $RET
echo "Done"

cd ../..

for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "Building $PLATFORM:$TAG$TAGEXT image..."
		cat > Dockerfile << EOF
FROM $SERVER:$TAG$TAGEXT
MAINTAINER Simplicite.io <contact@simplicite.io>
COPY template/app /usr/local/tomcat/webapps/ROOT
EOF
		sudo docker build -f Dockerfile -t $PLATFORM:$TAG$TAGEXT .
		rm -f Dockerfile
		echo "Done"
	done
done
rm -fr template

echo ""
for SRV in $SRVS
do
	TAGEXT=""
	[ $SRV != "tomcat" ] && TAGEXT="-$SRV"
	for TAG in $TAGS
	do
		echo "-- $PLATFORM:$TAG$TAGEXT ------------------"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=mysql -e DB_HOST=$IP -e DB_PORT=3306 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker run -it --rm -p 9090:8080 -p 9443:8443 -e DB_SETUP=true -e DB_VENDOR=postgresql -e DB_HOST=$IP -e DB_PORT=5432 -e DB_USER=$DB -e DB_PASSWORD=$DB -e DB_NAME=$DB $PLATFORM:$TAG$TAGEXT"
		echo "sudo docker push $PLATFORM:$TAG$TAGEXT"
		if [ $TAG = "centos" -a $SRV = "tomcat" ]
		then
			echo "sudo docker tag $PLATFORM:$TAG$TAGEXT $PLATFORM:latest"
			echo "sudo docker push $PLATFORM:latest"
		fi
		# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
		if [ $TAG = "centos" ]
		then
			DT=`date +%Y%m%d`
			echo "sudo docker tag $PLATFORM:$TAG$TAGEXT $PLATFORM:$TAG$TAGEXT-$DT"
			echo "sudo docker push $PLATFORM:$TAG$TAGEXT-$DT"
		fi
		# ZZZ Temporary ZZZZZZZZZZZZZZZZZZZZ
		echo ""
	done
done

exit 0
