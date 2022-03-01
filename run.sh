#!/bin/bash

echo "  ___ _            _ _    _ _    __   _"
echo " / __(_)_ __  _ __| (_)__(_) |_ /_/  (_)___"
echo " \\__ \\ | '  \\| '_ \\ | / _| |  _/ -_)_| / _ \\"
echo " |___/_|_|_|_| .__/_|_\\__|_|\\__\\___(_)_\\___/"
echo "             |_| Running on $DOCKER"
echo ""

if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "Starting SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_ROOT=/usr/local/tomcat
[ ! -d $TOMCAT_ROOT/webapps ] && mkdir $TOMCAT_ROOT/webapps

if [ -w /root -a ! -d /root/.ssh ]
then
	mkdir /root/.ssh
	chmod go-rwX /root/.ssh
fi
if [ -w /root/.ssh ]
then
	[ -d $TOMCAT_ROOT/.ssh ] && cp -fr $TOMCAT_ROOT/.ssh/* /root/.ssh/
	[ -f /root/.ssh/id_rsa ] && grep -q 'BEGIN OPENSSH PRIVATE KEY' /root/.ssh/id_rsa && ssh-keygen -p -N "" -m pem -f /root/.ssh/id_rsa
	touch /root/.ssh/known_hosts
	if [ ! -z "$SSH_KNOWN_HOSTS" ]
	then
		for HOST in $SSH_KNOWN_HOSTS
		do
			H=`grep "^$HOST " /root/.ssh/known_hosts`
			[ "$H" = "" ] && ssh-keyscan -t rsa $HOST >> /root/.ssh/known_hosts
		done
	fi
	chmod -R go-rwX /root/.ssh
else
	echo "WARNING: /root/.ssh is read-only, unable to register keys and/or known hosts"
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
	if [ ! -f $TOMCAT_ROOT/webapps/${TOMCAT_WEBAPP:-ROOT}/META-INF/context.xml ]
	then
		echo "Deploying webapp..."
		ant -Dtomcat.root=$TOMCAT_ROOT deploy-war
		echo "...done"
	else
		echo "Upgrading webapp..."
		ant -Dtomcat.root=$TOMCAT_ROOT upgrade-war
		echo "...done"
	fi
fi

if [ "$TOMCAT_USER" != "" ]
then
	TOMCAT_UID=`id -u $TOMCAT_USER`
	if [ $? -ne 0 ]
	then
		echo "ERROR: User $TOMCAT_USER does not exist"
		exit 1
	fi
	TOMCAT_GID=`id -g $TOMCAT_USER`
	[ ! -O $TOMCAT_ROOT -a `id -n` = "root" ] && chown -f -R $TOMCAT_UID:$TOMCAT_GID $TOMCAT_ROOT
	echo "Running Tomcat as $TOMCAT_USER (user ID $TOMCAT_UID, group ID $TOMCAT_GID)"
	if [ `id -un` = $TOMCAT_UID ]
	then
		cd $TOMCAT_ROOT && ./start.sh -t
	else
		su $TOMCAT_USER -c "cd $TOMCAT_ROOT && ./start.sh -t"
	fi
else
	cd $TOMCAT_ROOT && ./start.sh -t
fi
