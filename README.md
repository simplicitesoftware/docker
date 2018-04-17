![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

<a href="https://www.simplicite.io"><img src="https://img.shields.io/badge/author-Simplicite_Software-blue.svg?style=flat-square" alt="Author"></a>&nbsp;<img src="https://img.shields.io/badge/license-Apache--2.0-orange.svg?style=flat-square" alt="License"> [![Gitter chat](https://badges.gitter.im/org.png)](https://gitter.im/simplicite/Lobby)

Using Simplicit&eacute;&reg; server image
=========================================

Introduction
------------

This package corresponds to a simple [Docker](http://www.docker.com) image that contains a pre-configured.
Tomcat server on which you can run a [Simplicit&eacute;&reg;](http://www.simplicitesoftware.com) low code platform instance.

See the `BUILD.md` file for image building details. The built image is available on [DockerHub](https://hub.docker.com/r/simplicite/server/)

Pull
----

You can pull the image by:

	sudo docker pull simplicite/server

Add an instance
---------------

To add a Simplicit&eacute;&reg; platform instance you need to create a dedicated `Dockerfile`:

	vi Dockerfile

With this content:

```
FROM simplicite/server
ADD <location of your Simplict&eacute;&reg; application package> /usr/local/tomcat/webapps/ROOT
```

Then you can build your instance's image by:

	sudo docker build -t simplicite/<my application name> .

The image is configured to exposes the following ports for different usage:

- Toomcat HTTP port `8080` for direct access or to be exposed thru an HTTP reverse proxy (Apache, NGINX, ...)
- Tomcat HTTP port `8443` to be exposed thru an HTTPS reverse proxy (Apache, NGINX, ...)
- Tomcat AJP port `8009` to be exposed thru an HTTP/HTTPS reverse proxy (Apache)
- Tomcat admin port `8005` for starting/stopping Tomcat from outside of the container
- Tomcat JPDA port `8000` for remote debugging Tomcat (needs Tomcat to be (re)started with the `jpda` keyword)

Run
---

### Sandbox database

Run the container in "sandbox" mode with an embedded database by:

	sudo docker run [-it --rm | -d] -p <public port, e.g. 8080>:8080 [-p <secured HTTP port, e.g. 8443>:8443] [-p <AJP port, e.g. 8009>:8009] [-p <admin port, e.g. 8005>:8005] [-p <JPDA port, e.g. 8000>:8000] simplicite/<my application name>

### Standard mode

You can also run the container in standard mode with an external database by adding these arguments to the above run command:

	-e DB_SETUP=<setup database if empty = true | false>
	-e DB_VENDOR=<database vendor = "mysql" | "postgresql" | "oracle" | "mssql">
	-e DB_HOST=<hostname or IP address>
	-e DB_PORT=<port, defaults to 3306 for mysql, 5432 for postgresql, 1521 for oracle or 1433 for mssql>
	-e DB_USER=<database username>
	-e DB_PASSWORD=<database username's password>
	-e DB_NAME=<database name>```

### Others

You can adjust the JVM options by using `-e JAVA_OPTS="<other JVM options, e.g. -Xms...>"`

If you experience network issues within your container it is likely to be a DNS configuration issue
that you can solve by adding `--dns=8.8.8.8` to your run command above.

Licenses
--------

Copyright Simplicit&eacute; Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License [here](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Third party components
----------------------

The base server image is based on the official [CentOS image](https://hub.docker.com/_/centos/) and its
standard components (OpenJDK, ..). It also contains the following custom components:

- Apache Tomcat released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0)
- HyperSQL (HSQLDB) engine and JDBC driver released under [a custom BSD style license](http://hsqldb.org/web/hsqlLicense.html)
- MySQL connector/J JDBC driver released under [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.en.html)
- PostgreSQL JDBC driver released under [a custom BSD style license](https://jdbc.postgresql.org/about/license.html)
