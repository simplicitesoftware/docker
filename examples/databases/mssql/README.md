SQLServer example
-----------------

> **Warning**: this is just an example to launch an **ephemeral** SQLServer 2019 database.
> **Never** use this example for production!

Build the custom images
-----------------------

### Version 2019:

```bash
docker build --build-arg version=2019 -t simplicite/mssql:2019 .
```

### Version 2022 (default):

```bash
docker build -t simplicite/mssql:2022 .
```

Test the images
---------------

Run a **test** ephemeral container:

```bash
docker run -it --rm -p 127.0.0.1:1433:1433 simplicite/mssql:<version>
```

If you have SQLServer client installed on your host machine you can now connect to this database with:

```bash
sqlcmd -S 127.0.0.1,1433 -U simplicite -P simplicite -d simplicite
```
