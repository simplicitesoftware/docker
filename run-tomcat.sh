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

if [ -w $HOME -a ! -d $HOME/.ssh ]
then
	mkdir $HOME/.ssh
	chmod go-rwX $HOME/.ssh
fi
if [ -w $HOME/.ssh ]
then
	[ -d $TOMCAT_ROOT/.ssh ] && cp -fr $TOMCAT_ROOT/.ssh/* $HOME/.ssh/
	[ -f $HOME/.ssh/id_rsa ] && grep -q 'BEGIN OPENSSH PRIVATE KEY' $HOME/.ssh/id_rsa && ssh-keygen -p -N "" -m pem -f $HOME/.ssh/id_rsa
	touch $HOME/.ssh/known_hosts
	if [ ! -z "$SSH_KNOWN_HOSTS" ]
	then
		for HOST in $SSH_KNOWN_HOSTS
		do
			H=`grep "^$HOST " $HOME/.ssh/known_hosts`
			[ "$H" = "" ] && ssh-keyscan -t rsa $HOST >> $HOME/.ssh/known_hosts
		done
	fi
	chmod -R go-rwX $HOME/.ssh
else
	echo "WARNING: $HOME/.ssh is read-only, unable to register keys and/or known hosts"
fi

[ "$TOMCAT_USER" = "" ] && TOMCAT_USER=`id -un`
TOMCAT_UID=`id -u $TOMCAT_USER`
if [ $? -ne 0 ]
then
	echo "ERROR: User $TOMCAT_USER does not exist"
	exit 1
fi
TOMCAT_GID=`id -g $TOMCAT_USER`
if [ `id -un` = "root" ]
then
	echo "--------------------------------------------------------------------------"
	echo "WARNING: Tomcat is running as root, this my not be suitable for production"
	echo "--------------------------------------------------------------------------"
else
	echo "Running Tomcat as $TOMCAT_USER (user ID $TOMCAT_UID, group ID $TOMCAT_GID)"
fi
if [ `id -u` = $TOMCAT_UID ]
then
	cd $TOMCAT_ROOT && ./start.sh -t
else
	su $TOMCAT_USER -c "cd $TOMCAT_ROOT && ./start.sh -t"
fi
