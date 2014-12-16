#!/bin/bash
rm -fr conf/Catalina work/Catalina logs
mkdir logs
cd bin
chmod +x *.sh
./startup.sh
LOG=../logs/catalina.out
while [ ! -f $LOG ]
do
        echo "Waiting for Tomcat to start..."
        sleep 1
done
tail -f $LOG

