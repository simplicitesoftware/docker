#!/bin/bash

if [ "$MAVEN_HOME" = "" ]
then
	echo "Maven is not installed" >&2
	exit -1
fi

if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage `basename $0` <list of groupId:artifactId:version>" >&2
	exit 1
fi

FORCE=0
if [ "$1" = "--force" ]
then
	FORCE=1
	shift
fi

REG="$HOME/.m2"
DIR=`dirname $0`
TMP="$DIR/`basename $0 .sh`-$$"
trap "rm -fr $REG $TMP" EXIT

mkdir $TMP
pushd $TMP

cat << EOF > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.simplicite</groupId>
  <artifactId>tmp</artifactId>
  <version>0.0.0</version>
  <name>Temporary</name>
EOF

N=0
for DEP in $*
do
	GROUP=`echo $DEP | cut -d : -f 1`
	ARTIFACT=`echo $DEP | cut -d : -f 2`
	VERSION=`echo $DEP | cut -d : -f 3`

	if [ ! -z "$GROUP" -a ! -z "$ARTIFACT" -a ! -z "$VERSION" ]
	then
		cat << EOF >> pom.xml
  <dependencies>
    <dependency>
      <groupId>$GROUP</groupId>
      <artifactId>$ARTIFACT</artifactId>
      <version>$VERSION</version>
    </dependency>
  </dependencies>
EOF
		echo "Added dependency: $DEP"
		N=`expr $N + 1`
	else
		echo "Ignored malformed dependency: $DEP" >&2
	fi
done

cat << EOF >> pom.xml
</project>
EOF

if [ $N -eq 0 ]
then
	echo "No dependency to add: $DEP" >&2
	exit 3
fi

mvn -U dependency:copy-dependencies

ls -alF target/lib
# TODO
# - check each JAR vs instance JARs
# - copy each JAR (takin FORCE into acount)

popd

exit 0
