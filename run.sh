#!/bin/bash
rm -fr conf/Catalina work/Catalina logs temp
mkdir logs temp
cd bin
chmod +x *.sh
export JAVA_OPTS="-Dtomcat.adminport=8005 -Dtomcat.httpport=8080 -Dtomcat.httpsport=8181
./startup.sh
LOG=../logs/catalina.out
while [ ! -f $LOG ]
do
	echo "Waiting for Tomcat to start..."
	sleep 1
done
tail -f $LOG