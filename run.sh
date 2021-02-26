#!/bin/bash

echo "  ___ _            _ _    _ _    __   _"
echo " / __(_)_ __  _ __| (_)__(_) |_ /_/  (_)___"
echo " \\__ \\ | '  \\| '_ \\ | / _| |  _/ -_)_| / _ \\"
echo " |___/_|_|_|_| .__/_|_\\__|_|\\__\\___(_)_\\___/"
echo "             |_|"
echo ""

if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "Starting SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_DIR=/usr/local/tomcat
[ ! -d $TOMCAT_DIR/webapps ] && mkdir $TOMCAT_DIR/webapps

if [ ! -z "$SSH_KNOWN_HOSTS" ]
then
	if [ -w /root ]
	then
		[ -d $TOMCAT_DIR/.ssh ] && cp -fr $TOMCAT_DIR/.ssh /root
		[ ! -d /root/.ssh ] && mkdir /root/.ssh
		touch /root/.ssh/known_hosts
		for HOST in $SSH_KNOWN_HOSTS
		do
			H=`grep "^$HOST " /root/.ssh/known_hosts`
			[ "$H" = "" ] && ssh-keyscan -t rsa $HOST >> /root/.ssh/known_hosts
		done
		chmod -R go-rwX /root/.ssh
	else
		echo "WARNING: /root is read-only, unable to register known hosts"
	fi
fi

TEMPLATE_DIR=/usr/local/tomcat/template
if [ ! -d $TEMPLATE_DIR -a "$GIT_URL" != "" ]
then
	BRANCH="master"
	[ "$GIT_BRANCH" != "" ] && BRANCH=$GIT_BRANCH
	echo "Cloning template (branch $BRANCH)..."
	git clone --single-branch --branch $BRANCH $GIT_URL $TEMPLATE_DIR
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
	if [ ! -f $TOMCAT_DIR/webapps/ROOT/META-INF/context.xml ]
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

cd $TOMCAT_DIR && ./start.sh -t
