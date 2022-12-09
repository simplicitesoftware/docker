#!/bin/bash

echo "  ___ _            _ _    _ _    __   _"
echo " / __(_)_ __  _ __| (_)__(_) |_ /_/  (_)___"
echo " \\__ \\ | '  \\| '_ \\ | / _| |  _/ -_)_| / _ \\"
echo " |___/_|_|_|_| .__/_|_\\__|_|\\__\\___(_)_\\___/"
echo "             |_| Running on $DOCKER, powered by Jetty"
echo ""

JETTY_HOME=/usr/local/jetty
JETTY_BASE=$JETTY_HOME/default
if [ ! -d $JETTY_BASE/webapps ]
then
	mkdir $JETTY_BASE/webapps
	mkdir $JETTY_BASE/webapps/ROOT
	cat > $JETTY_BASE/webapps/ROOT/index.jsp << EOF
<% java.util.logging.Logger.getLogger(getClass().getName()).info("Request from " + request.getRemoteAddr()); %><!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<title>It works!</title>
</head>
<body>
<pre>
OS: <%= System.getProperty("os.name") + " " + System.getProperty("os.arch") + " " + System.getProperty("os.version") %>
JVM: <%= System.getProperty("java.version") + " " + System.getProperty("java.vendor") + " " + System.getProperty("java.vm.name") + " " + System.getProperty("java.vm.version") %>
Encoding: <%= System.getProperty("file.encoding") %>
Server: <%= request.getServletContext().getServerInfo() %>
Hostname: <%= java.net.InetAddress.getLocalHost().getHostName() %>
Requested URI: <%= request.getRequestURI() %>
Requested URL: <%= request.getRequestURL() %>
Session ID: <%= request.getSession().getId() %>
System date: <%= new java.util.Date() %>
Environment variables:
<%
java.util.Map<String, String> env = System.getenv();
for (String name : env.keySet())
	out.println("\t" + name + " = " + env.get(name));
%>System properties:
<%
java.util.Properties p = System.getProperties();
java.util.Enumeration keys = p.keys();
while (keys.hasMoreElements()) {
	Object key = keys.nextElement();
	out.println("\t" + key + " = " + p.get(key));
}
%></pre>
</body>
</html>
EOF
fi

JAVA_OPTS="$JAVA_OPTS -server -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Duser.timezone=${USER_TIMEZONE:-`date +%Z`} -Dplatform.autoupgrade=true"
JAVA_OPTS="$JAVA_OPTS -Dserver.vendor=jetty -Dserver.version=10 -Djetty.home=$JETTY_HOME -Djetty.base=$JETTY_BASE -Dorg.eclipse.jetty.annotations.AnnotationParser.LEVEL=OFF"
JAVA_OPTS="$JAVA_OPTS -Ddb.vendor=hsqldb -Ddb.driver=org.hsqldb.jdbcDriver -Ddb.user=sa -Ddb.password= -Ddb.url=hsqldb:file:$JETTY_BASE/webapps/ROOT/WEB-INF/db/simplicite\;shutdown=true\;sql.ignore_case=true"

JETTY_START="java $JAVA_OPTS -jar ./start.jar"

if [ "$JETTY_USER" != "" ]
then
	JETTY_UID=`id -u $JETTY_USER`
	if [ $? -ne 0 ]
	then
		echo "ERROR: User $JETTY_USER does not exist"
		exit 1
	fi
	JETTY_GID=`id -g $JETTY_USER`
	chown -f -R $JETTY_UID:$JETTY_GID $JETTY_HOME
	echo "Running Jetty as $JETTY_USER (user ID $JETTY_UID, group ID $JETTY_GID)"
	exec su $JETTY_USER -c "cd $JETTY_HOME && $JETTY_START"
else
	cd $JETTY_HOME && exec $JETTY_START
fi
