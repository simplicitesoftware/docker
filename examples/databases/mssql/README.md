SQLServer example
-----------------

> **Warning**: this is just an example to launch an **ephemeral** SQLServer 2019 database.
> **Never** use this example for production!

Build the custom image:

```bash
sudo docker build -t mysqlserver .
```

Run a container:

```bash
sudo docker run -it --rm -p 127.0.0.1:1433:1433 mysqlserver
```
