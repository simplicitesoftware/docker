#!/bin/bash

if [ "$MAVEN_HOME" = "" ]
then
	echo "Maven is not installed" >&2
	exit -1
fi

if [ "$1" = "" -o "$1" = "--help"]
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

DIR="/tmp/`basename $0 .sh`-$$"
mkdir $DIR
pushd $DIR

cat << EOF > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.simplicite</groupId>
  <artifactId>tmp</artifactId>
  <version>0.0.0</version>
  <name>Temporary</name>
EOF

for DEP in $*
do
	GROUP=`echo $DEP | cut -d : -f 1`
	ARTIFACT=`echo $DEP | cut -d : -f 2`
	VERSION=`echo $DEP | cut -d : -f 3`

	if [ !-z "$GROUP" -a !-z "$ARTIFACT" -a !-z "$VERSION" ]
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
	else
		echo "Ignored malformed dependency: $DEP"
	fi
done

cat << EOF >> pom.xml
</project>
EOF

mvn -U dependency:copy-dependencies

ls -alF target/lib

popd
rm -fr $DIR

exit 0