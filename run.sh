#!/bin/bash
[ "$LOCAL_SMTP_SERVER" = "true" ] && postfix start
cd /usr/local/tomcat
./run.sh -t