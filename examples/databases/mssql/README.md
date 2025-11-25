SQLServer example
-----------------

Build the custom images
-----------------------

### For SQLServer version 2019:

```bash
docker build --build-arg version=2019 -t registry.simplicite.io/mssql:2019 .
```

### For SQLServer bersion 2022 (default):

```bash
docker build --build-arg version=2022 -t registry.simplicite.io/mssql:2022 .
```

### For SQLServer bersion 2025 (latest):

```bash
docker build -t registry.simplicite.io/mssql:latest .
```

Test the images
---------------

Run a test **ephemeral** container:

```bash
docker run -it --rm -p 127.0.0.1:1433:1433 registry.simplicite.io/mssql:<version>
```

If you have SQLServer client installed on your host machine you can now connect to this database with:

```bash
sqlcmd -S 127.0.0.1,1433 -U simplicite -P simplicite -d simplicite
```
