#!/bin/bash


if [ "$1" = "" -o "$1" = "--help" ]
then
	echo "Usage `basename $0` <list of groupId:artifactId:version>" >&2
	exit 1
fi

if [ "$MAVEN_HOME" = "" ]
then
	echo -e "\e[31mERROR: Maven is not installed (MAVEN_HOME not defined)\e[0m" >&2
	exit -1
fi

FORCE=0
if [ "$1" = "--force" ]
then
	FORCE=1
	shift
fi

pushd `dirname $0` > /dev/null
DIR=`pwd`
popd > /dev/null
TMP="/tmp/`basename $0 .sh`-$$"

LIB="${TOMCAT_ROOT:-/usr/local/tomcat}/webapps/ROOT/WEB-INF/lib"
if [ ! -w $LIB ]
then
	echo -e "\e[31mERROR: Target lib directory does not exists or is not writeable\e[0m" >&2
	exit 2
fi

REG="$HOME/.m2"

trap "rm -fr $REG $TMP" EXIT

mkdir $TMP
pushd $TMP > /dev/null

echo "Generating pom.xml..."

cat << EOF > pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>com.simplicite</groupId>
  <artifactId>tmp</artifactId>
  <version>0.0.0</version>
  <name>Temporary</name>
  <dependencies>
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
    <dependency>
      <groupId>$GROUP</groupId>
      <artifactId>$ARTIFACT</artifactId>
      <version>$VERSION</version>
    </dependency>
EOF
		N=`expr $N + 1`
	else
		echo -e "\e[31mERROR: Ignored malformed dependency: $DEP\e[0m" >&2
	fi
done

cat << EOF >> pom.xml
  </dependencies>
</project>
EOF

if [ $N -eq 0 ]
then
	echo -e "\e[31mERROR: No dependency to add: $DEP\e[0m" >&2
	exit 3
fi

echo "Done"

echo "Resolution of dependencies..."
mvn -q -U dependency:copy-dependencies
RES=$?
[ $RES -ne 0 ] && exit 4
echo "Done"

TRG="target/dependency"

echo "Copying dependencies..."
for FILE in `ls -1 $TRG`
do
	if [ -f $LIB/$FILE ]
	then
		echo -e "\e[33mWARNING: $FILE already exists, ignored\e[0m"
	else
		P=`echo $FILE | sed -r 's/-[0-9]+(\.[0-9]+).jar$//'`
		F=`ls $LIB/$P* 2>/dev/null`
		if [ ! -z "$F" ]
		then
			if [ $FORCE -eq 0 ]
			then
				echo -e "\e[31mERROR: Another version of $FILE already exists (`basename $F`), ignored\e[0m"
			else
				echo -e "\e[33mWARNING: Another version of $FILE already exists: (`basename $F`), copied but \e[1mZZZZZ THIS MAY RESULT IN UNEXPECTED BEHAVIOR ZZZZZ\e[0m"
				cp $TRG/$FILE $LIB
			fi
		else
			echo -e "\e[32mINFO: $FILE copied\e[0m"
			cp $TRG/$FILE $LIB
		fi
	fi
done
echo "Done"

popd > /dev/null

exit 0
