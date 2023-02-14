#!/bin/bash

echo "  ___ _            _ _    _ _    __   _"
echo " / __(_)_ __  _ __| (_)__(_) |_ /_/  (_)___"
echo " \\__ \\ | '  \\| '_ \\ | / _| |  _/ -_)_| / _ \\"
echo " |___/_|_|_|_| .__/_|_\\__|_|\\__\\___(_)_\\___/"
echo "             |_| Running on $DOCKER"
echo ""

# Start a local SMTP server for development
if [ "$LOCAL_SMTP_SERVER" = "true" ]
then
	echo "------------------------------------------------------------------------"
	echo "WARNING: Starting a local SMTP server is ABSOLUTELY not suitable for production"
	echo "------------------------------------------------------------------------"
	echo "Starting SMTP server..."
	postfix start
	echo "...done"
fi

TOMCAT_ROOT=/usr/local/tomcat
[ "$TOMCAT_USER" = "" ] && TOMCAT_USER=$(id -un)
TOMCAT_UID=$(id -u $TOMCAT_USER)
if [ $? -ne 0 ]
then
	echo "ERROR: User $TOMCAT_USER does not exist"
	exit 1
fi

TOMCAT_GID=$(id -g $TOMCAT_USER)
if [ $TOMCAT_USER = "root" ]
then
	echo "------------------------------------------------------------------------"
	echo "WARNING: Running Tomcat as root, this MAY not be suitable for production"
	echo "------------------------------------------------------------------------"
else
	echo "Running Tomcat as $TOMCAT_USER (user ID $TOMCAT_UID, group ID $TOMCAT_GID)"
fi

function shutdown {
	echo "Shutting down..."
	if [ -x $TOMCAT_ROOT/shutdown.sh ]
	then
		if [ $(id -u) = $TOMCAT_UID ]
		then
			cd $TOMCAT_ROOT && exec ./shutdown.sh
		else
			exec su $TOMCAT_USER -c "cd $TOMCAT_ROOT && ./shutdown.sh"
		fi
	fi
}

trap shutdown SIGTERM

if [ $(id -u) = $TOMCAT_UID ]
then
	cd $TOMCAT_ROOT && exec ./start.sh -r
else
	exec su $TOMCAT_USER -c "cd $TOMCAT_ROOT && ./start.sh -r"
fi
