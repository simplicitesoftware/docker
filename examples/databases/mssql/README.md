SQLServer example
-----------------

> **Warning**: this is just an example to launch an **ephemeral** SQLServer 2019 database.
> **Never** use this example for production!

Build the custom image:

```bash
docker build -t mymssql .
```

Run a **test** ephemeral container:

```bash
docker run -it --rm -p 127.0.0.1:1433:1433 mymssql
```

If you have SQLServer client installed on your host machine you can now connect to this database with:

```bash
sqlcmd -S 127.0.0.1,1433 -U simplicite -P simplicite -d simplicite
```
