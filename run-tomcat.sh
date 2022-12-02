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

if [ -d $TOMCAT_ROOT/.ssh -o ! -z "$SSH_KNOWN_HOSTS" ]
then
	rm -fr  $HOME/.ssh
	mkdir $HOME/.ssh
	[ -d $TOMCAT_ROOT/.ssh ] && cp -r $TOMCAT_ROOT/.ssh/* $HOME/.ssh
	# Convert OpenSSH key if needed
	[ -f $HOME/.ssh/id_rsa ] && grep -q 'BEGIN OPENSSH PRIVATE KEY' $HOME/.ssh/id_rsa && ssh-keygen -p -N "" -m pem -f $HOME/.ssh/id_rsa
	if [ ! -z "$SSH_KNOWN_HOSTS" ]
	then
		touch $HOME/.ssh/known_hosts
		for HOST in $SSH_KNOWN_HOSTS
		do
			H=`grep "^$HOST " $HOME/.ssh/known_hosts`
			[ "$H" = "" ] && ssh-keyscan $HOST >> $HOME/.ssh/known_hosts
		done
	fi
	chmod -R go-rwX $HOME/.ssh
fi

[ "$TOMCAT_USER" = "" ] && TOMCAT_USER=`id -un`
TOMCAT_UID=`id -u $TOMCAT_USER`
if [ $? -ne 0 ]
then
	echo "ERROR: User $TOMCAT_USER does not exist"
	exit 1
fi
TOMCAT_GID=`id -g $TOMCAT_USER`
if [ $TOMCAT_USER = "root" ]
then
	echo "------------------------------------------------------------------------"
	echo "WARNING: Running Tomcat as root, this may not be suitable for production"
	echo "------------------------------------------------------------------------"
else
	echo "Running Tomcat as $TOMCAT_USER (user ID $TOMCAT_UID, group ID $TOMCAT_GID)"
fi
if [ `id -u` = $TOMCAT_UID ]
then
	cd $TOMCAT_ROOT && ./start.sh -t
else
	su $TOMCAT_USER -c "cd $TOMCAT_ROOT && ./start.sh -t"
fi
