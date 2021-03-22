Oracle XE example
------------------

> **Warning**: this is just an example to launch an **epthemereal** Oracle 11g XE database from an **unofficial** Docker image.
> **Never** use this example for production!

Build the custom image:

```bash
sudo docker build -t oraclexe .
```

Run a container:

```bash
sudo docker run -it --rm -p 127.0.0.1:1521:1521 oraclexe
```

If you have SQL*Plus installed you can now connect to this database as `simplicite` with:

```bash
sqlplus simplicite/simplicite@127.0.0.1:1521/xe
```
