![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

<a href="https://www.simplicite.io"><img src="https://img.shields.io/badge/author-Simplicite_Software-blue.svg?style=flat-square" alt="Author"></a>&nbsp;<img src="https://img.shields.io/badge/license-Apache--2.0-orange.svg?style=flat-square" alt="License"> [![Gitter chat](https://badges.gitter.im/org.png)](https://gitter.im/simplicite/Lobby)

Using Simplicit&eacute;&reg; server image
=========================================

Introduction
------------

This repository contains tools to **build** [Docker](http://www.docker.com) images that contains a pre-configured
[Tomcat](http://tomcat.apache.org/) server on which can be run a [Simplicit&eacute;&reg;](http://www.simplicitesoftware.com)
low code platform instance.

The images built using these tools are **available on [DockerHub](https://hub.docker.com/r/simplicite/)**:

- Public **server** images (not containing the Simplicit&eacute; platform)
- Private **platform** images (containing the Simplicit&eacute; platform)

> **Warning**: Chances are what you are looking for are the above **pre-built images** available on **DockerHub**.

Add Simplicit&eacute;&reg; platform
-----------------------------------

There are two approaches to add Simplicit&eacute; platform to these **server** images:

### Build a custom image

To add a Simplicit&eacute;&reg; platform instance to the server image you need to create an image from the server image:

	vi Dockerfile

With this content:

```
FROM simplicite/server[:<tag>]
ADD <path to your Simplicit&eacute;&reg; webapp> /usr/local/tomcat/webapps/ROOT
```

> **Note**: the above path must be inside the build directory

Then you can build your instance's image by:

	sudo docker build -t simplicite/<my application name> .

And run it

### Use external Git repository

You can directly mount a template Git repository into your server container (see bellow).

Exposed ports
-------------

The images are configured to exposes the following ports for different usage:

- Tomcat HTTP port `8080` for direct access or to be exposed thru an HTTP reverse proxy (Apache, NGINX, ...)
- Tomcat HTTP port `8443` to be exposed thru an HTTPS reverse proxy (Apache, NGINX, ...)
- Tomcat AJP port `8009` to be exposed thru an HTTP/HTTPS reverse proxy (Apache)
- Tomcat admin port `8005` for starting/stopping Tomcat from outside of the container
- Tomcat JPDA port `8000` for remote debugging Tomcat (needs Tomcat to be (re)started with the `jpda` keyword)

Run
---

See [DockerHub](https://hub.docker.com/r/simplicite/) for run instructions of the standard pre-built iamges.

### Run in sandbox mode

Run the container in sandbox mode with an embedded database by:

	sudo docker run [-it --rm | -d] -p <public port, e.g. 8080>:8080 [-p <secured HTTP port, e.g. 8443>:8443] [-p <AJP port, e.g. 8009>:8009] [-p <admin port, e.g. 8005>:8005] [-e JPDA=true -p <JPDA port, e.g. 8000>:8000] simplicite/<my application name>

### Runn in standard mode

You can also run the container in standard mode with an external database by adding these arguments to the above run command:

	-e DB_SETUP=<setup database if empty = true|false>
	-e DB_VENDOR=<database vendor = mysql|postgresql|oracle|mssql>
	-e DB_HOST=<hostname or IP address>
	-e DB_PORT=<port, defaults to 3306 for mysql, 5432 for postgresql, 1521 for oracle or 1433 for mssql>
	-e DB_USER=<database username>
	-e DB_PASSWORD=<database username's password>
	-e DB_NAME=<database name>

### Using a template Git repository

In this case you can directly run a pre-built **server image** (`simplicite/server[:<tag>]`) either with:

- `-v <path to the template Git repository>:/usr/local/template:ro` to read-only mount the template repository located **outside** of the container
- `-e GIT_URL=<Git URL of the template repository>` to clone the template repository **inside** the container
  (optionaly you can specify a branch with `-e GIT_BRANCH=<branch name>` otherwise the default `master` branch is used)

When starting for the first time, the container will create the webapp from the template repository (after cloning it when it is located inside the container).
Then, at each restart, it will upgrade the webapp from the template repository (after pulling it when it is located inside the container).

### Others

You can force the timezone of the application server by using `-e TOMCAT_TIMEZONE=<timezone, e.g. Europe/paris>`

You can adjust any required JVM options by using `-e JAVA_OPTS="<other JVM options, e.g. -Xms...>"`

If you experience network issues within your container it is likely to be a DNS configuration issue
that you can solve by adding an explict DNS serveur IP address e.g. `--dns=8.8.8.8`

If required (e.g. in development) you can start a local Postfix SMTP server within the container by using `-e LOCAL_SMTP_SERVER=true`.
Using this feature requires that you build an extended image including the Postfix Package:

For CentOS-based image:

```
FROM simplicite/platform-4.0.Pxx-centos
RUN yum -y install postfix && yum clean all && rm -rf /var/cache/yum
RUN sed -i 's/^inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf
```

For Alpine-based image:

```
FROM simplicite/platform-4.0.Pxx-alpine
RUN apk add --update postfix && rm -rf /var/cache/apk/*
```

> **Note**: starting a Postfix process within the container is only not suitable for production where an external SMTP service must be used instead.

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

The base server images are based on the official [centos image](https://hub.docker.com/_/centos/) and [openjdk:alpine image](https://hub.docker.com/_/openjdk/)
and their standard additional packages. It also contains the following custom components:

- Apache Tomcat released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0)
- HyperSQL (HSQLDB) engine and JDBC driver released under [a custom BSD style license](http://hsqldb.org/web/hsqlLicense.html)
- MySQL connector/J JDBC driver released under [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.en.html)
- PostgreSQL JDBC driver released under [a custom BSD style license](https://jdbc.postgresql.org/about/license.html)
