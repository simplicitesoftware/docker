Oracle free example
-------------------

> **Warning**: this is just an example to launch an **ephemeral** Oracle FREE database.
> **Never** use this example for production!

Build the custom image:

```bash
docker build -t registry.simplicite.io/oracle:free .
```

Run a **test** ephemeral container:

```bash
docker run -it --rm -p 127.0.0.1:1521:1521 registry.simplicite.io/oracle:free
```

If you have SQL*Plus installed on your host machine you can now connect to this database with:

```bash
sqlplus simplicite/simplicite@127.0.0.1:1521/free
```