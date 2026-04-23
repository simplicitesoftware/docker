Minimal Simplicité images
=========================

Introduction
------------

These docker files are provided as minimal examples to build **custom** Simplicité images from a base OS (Almalinux or Alpine) with:

- An up-to-date JVM from the OS distribution
- An "out of the box" Tomcat server downloaded from the [Tomcat website](https://tomcat.apache.org)
- A Simplicité WAR package downloaded from the [Simplicité download page](https://platform.simplicite.io/downloads/),
  accessing this page requires credentials.

Instructions
------------

1. Set the Tomcat and Simplicité revision (replace the `x`s with the actual values) in the chosen `Dockerfile-<almalinux|alpine>`

2. Build the image

```text
<docker|podman> build -f Dockerfile-<almalinux|alpine> -t mysimplicite .
```

3. Test the container (with the default embedded HSQLDB database)

```text
<docker|podman> run -it --rm -p 127.0.0.1:8080:8080 mysimplicite
```

The instance is then available on `http://localhost:8080`

**Note**:

To use another type of database (e.g. PostgreSQL or MySQL) you need to :

- Add the appropriate JDBC driver to the image in the docker file
  (put it in the `/home/simplicite/tomcat/lib` folder)
- Adjust the JVM properties in the `JAVA_OPTS` environment variable in the docker file
  or pass it using `-e` when running the container
- Prior to the **first** start of the container you need to load the **initial** database dump
  (the dumps are located in the WAR package in the `WEB-INF/db` folder).

