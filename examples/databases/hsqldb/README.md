Non embedded (server) HSQLDB example
------------------------------------

> **Warning**: this is just an example to launch an **ephemeral** HSQLDB database.
> **Never** use this example for production!

Build the custom image:

```bash
sudo docker build -t myhsqldb .
```

Run a container:

```bash
sudo docker run -it --rm -p 127.0.0.1:9001:9001 myhsqldb
```
