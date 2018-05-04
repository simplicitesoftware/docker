#!/bin/bash

if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "Starting SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_DIR=/usr/local/tomcat
[ ! -d $TOMCAT_DIR/webapps ] && mkdir $TOMCAT_DIR/webapps

TEMPLATE_DIR=/usr/local/template
if [ ! -d $TEMPLATE_DIR -a "$GIT_URL" != "" ]
then
	echo "Cloning template..."
	git clone --single-branch $GIT_URL $TEMPLATE_DIR
	echo "...done"
fi
if [ -d $TEMPLATE_DIR ]
then
	cd $TEMPLATE_DIR
	if [ -w $TEMPLATE_DIR ]
	then
		echo "Pulling template..."
		git pull
		echo "...done"
	fi
	if [ ! -d $TOMCAT_DIR/webapps/ROOT ]
	then
		echo "Deploying webapp..."
		ant -Dtomcat.root=$TOMCAT_DIR deploy-war
		echo "...done"
	else
		echo "Upgrading webapp..."
		ant -Dtomcat.root=$TOMCAT_DIR upgrade-war
		echo "...done"
	fi
fi

cd $TOMCAT_DIR
./run.sh -t