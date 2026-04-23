Minimal Simplicité images
=========================

Introduction
------------

These docker files are provided as minimal examples to build Simplicité images from a base OS (Almalinux or Alpine) with:

- An up-to-date JVM from the OS distribution
- An "out of the box" Tomcat server downloaded from the [Tomcat website](https://tomcat.apache.org)
- A Simplicité WAR package downloaded from the [Simplicité download page](https://platform.simplicite.io/downloads/),
  accessing this page requires credentials.

Instructions
------------

1. Check the versions in the chosen `Dockerfile-<almalinux|alpine>`

2. Build the image

```text
<docker|podman> build -f Dockerfile-<almalinux|alpine> -t mysimplicite .
```

3. Test the container (with an embedded HSQLDB database)

```text
<docker|podman> run -it --rm -p 127.0.0.1:8080:8080 -e JAVA_OPTS="-Ddb.user='sa' -Ddb.password='' -Ddb.driver='org.hsqldb.jdbcDriver' -Ddb.url='hsqldb:file:/home/simplicite/tomcat/webapps/ROOT/WEB-INF/db/simplicite;shutdown=true;sql.ignore_case=true'" mysimplicite
```

The instance is then available on `http://localhost:8080`

**Note**: to use another type of database (e.g. PostgreSQL or MySQL) you need to set the above JVM properties accordingly
and, if needed, load the **initial** database dumps (they are located in the WAR package in the `WEB-INF/db` folder).

