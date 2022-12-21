#!/bin/bash

NAME=${DB_NAME:-db};
USER=${DB_USER:-sa}

echo "================================="
echo "Java:"
`java -version`
echo "Database name: $NAME"
echo "Database user: $USER"
echo "================================="

java -cp /usr/local/hsqldb/hsqldb-${DB_VERSION:-2.7.1}.jar org.hsqldb.server.Server --database.0 "file:/var/lib/hsqldb/${NAME};user=${USER};password=${DB_PASSWORD}" --dbname.0 ${NAME}
