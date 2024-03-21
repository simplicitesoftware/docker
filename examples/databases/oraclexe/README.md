Oracle XE example
------------------

> **Warning**: this is just an example to launch an **ephemeral** Oracle XE database.
> **Never** use this example for production!

Build the base Oracle 21xe image:

```bash
git clone https://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 21.3.0 -x
```

Build the custom image:

```bash
docker build -t registry.simplicite.io/oracle:21xe .
```

Run a **test** ephemeral container:

```bash
docker run -it --rm -p 127.0.0.1:1521:1521 registry.simplicite.io/oracle:21xe
```

If you have SQL*Plus installed on your host machine you can now connect to this database with:

```bash
sqlplus simplicite/simplicite@127.0.0.1:1521/xe
```