#!/bin/bash

if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "Starting postfix SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_DIR=/usr/local/tomcat
[ ! -d $TOMCAT_DIR/webapps ] && mkdir $TOMCAT_DIR/webapps
TEMPLATE_DIR=/usr/local/template
if [ -d $TEMPLATE_DIR/.git ]
then
	echo "Pulling up-to-date version..."
	cd $TEMPLATE_DIR
	git pull
	cd ..
	echo "...done"
	echo "Upgrading webapp..."
	SYNC_OPTS=""
	[ -d $TOMCAT_DIR/webapps/ROOT ] && SYNC_OPTS="--delete --exclude='META-INF/context.xml' --exclude='WEB-INF/web.xml' --exclude='WEB-INF/classes/log4j.xml' --exclude='WEB-INF/WEB-INF/patches/V*/patches.properties' --exclude='WEB-INF/db' --exclude='WEB-INF/dbdoc'"
	rsync -avhrW --no-compress $SYNC_OPTS $TEMPLATE_DIR/app/ $TOMCAT_DIR/webapps/ROOT
	RES=$?
	[ $RES -ne 0 ] && exit $RES
	echo "...done"
fi

cd /usr/local/tomcat
./run.sh -t