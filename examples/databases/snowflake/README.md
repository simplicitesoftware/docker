Snowflake example
-----------------

> **Warning**: Only tested with Simplicité v7

Build a Simplicité custom image with the Snowflake JDBC "thin" driver

```bash
docker build -t registry.simplicite.io/platform:snowflake .
```

Run this image then you can configure a Snowflake datasource, e.g. using a `MY_SNOWFLAKE_DS` system parameter with the following JSON settings:

```json
{
	"driver": "net.snowflake.client.jdbc.SnowflakeDriver",
	"username": "<Your Snowflake username>",
	"password": "<Your Snowflake password>",
	"url": "snowflake://<your Snowflake account>.snowflakecomputing.com/?db=<your Snowfalke database name>&schema=<your schema name>",
	"max_active": 10,
	"min_idle": 5,
	"scroll_type": "forward_only",
	"concurrency": "read_only"
}
```