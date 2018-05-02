#!/bin/bash

if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "Starting postfix SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_DIR=/usr/local/tomcat
TEMPLATE_DIR=/usr/local/template
if [ -d $TEMPLATE_DIR/.git ]
then
	echo "Pulling up-to-date version..."
	cd $TEMPLATE_DIR
	git pull
	echo "...done"
	echo "Upgrading webapp..."
	SYNC_EXCLUDES=""
	if [ -d $TOMCAT_DIR/webapps/ROOT ]
	then
		mkdir $TOMCAT_DIR/webapps
		mkdir $TOMCAT_DIR/webapps/ROOT
		SYNC_EXCLUDES="--exclude='app/META-INF/context.xml' --exclude='app/WEB-INF/web.xml' --exclude='app/WEB-INF/classes/log4j.xml' --exclude='app/WEB-INF/WEB-INF/patches/V*/patches.properties' --exclude='app/WEB-INF/db' --exclude='app/WEB-INF/dbdoc'"
	fi
	rsync -avhrW --no-compress --progress $SYNC_EXCLUDES app/ $TOMCAT_DIR/webapps/ROOT
	echo "...done"
fi

cd /usr/local/tomcat
./run.sh -t