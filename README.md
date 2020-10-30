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

Add Simplicit&eacute;&reg; platform to a server image
-----------------------------------------------------

> **Note**: consider using the `simplicite/platform:<tag>` images prior to rebuilding your own images like described here.

To add a Simplicit&eacute;&reg; platform instance to the server image you need to create an image from the server image using:

```
FROM simplicite/server:<tag>
COPY <path to your Simplicit&eacute;&reg; webapp> /usr/local/tomcat/webapps/ROOT
```

> **Note**: the above path must be inside the build directory

Then you can build your instance's image by:

	sudo docker build -t simplicite/<my application name> .

### Add SQLServer client

The SQLServer client is not freely redistributable, if you want to use SQLServer with your images **in initial setup mode** you need to add the SQLServer client by building a custom image

```
FROM simplicite/<server|platform>:<tag>
RUN curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/msprod.repo && \
    sudo yum install mssql-tools unixODBC-devel
```

NB: the above URL may change

### Add Oracle client

The Oracle client is not freely redistributable, if you want to use Oracle with your images **in initial setup mode** you need to add the Oracle client by building a custom image

```
FROM simplicite/<server|platform>:<tag>
RUN rpm -i https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm
```

NB: the above URL may change

### Add a local email server

If required (e.g. in development) you can start a local Postfix SMTP server within the container by using `-e LOCAL_SMTP_SERVER=true`.

Using this feature requires that you build a custom image including the Postfix Package:

For CentOS-based images:

```
FROM simplicite/platform:<tag>
RUN yum -y install postfix && yum clean all && rm -rf /var/cache/yum
RUN sed -i 's/^inet_protocols = all/inet_protocols = ipv4/' /etc/postfix/main.cf
```

For Debian-based image:

```
FROM simplicite/platform-4.0.Pxx-alpine
RUN apk add --update postfix && rm -rf /var/cache/apk/*
```

> **Note**: starting a Postfix process within the container is only not suitable for production where an external SMTP service must be used instead.

Usage
-----

See [this document](https://docs.simplicite.io/documentation/90-operation/docker.md) for details

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
