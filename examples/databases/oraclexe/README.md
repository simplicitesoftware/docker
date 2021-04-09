Oracle XE example
------------------

> **Warning**: this is just an example to launch an **ephemeral** Oracle 18c XE database.
> **Never** use this example for production!

Build the base Oracle 18c XE image (see [this document](https://blogs.oracle.com/oraclemagazine/deliver-oracle-database-18c-express-edition-in-containers)):

```bash
git clone https://github.com/oracle/docker-images.git
cd docker-images/OracleDatabase/SingleInstance/dockerfiles
./buildContainerImage.sh -v 18.4.0 -x
```

Build the custom image:

```bash
docker build -t myoraclexe .
```

Run a **test** ephemeral container:

```bash
docker run -it --rm -p 127.0.0.1:1521:1521 myoraclexe
```

If you have SQL*Plus installed on your host machine you can now connect to this database with:

```bash
sqlplus simplicite/simplicite@127.0.0.1:1521/xe
```