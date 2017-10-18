![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

Using Simplicit&eacute;&reg; server container
=============================================

Introduction
------------

This packages is a base [Docker](http://www.docker.com) server container on which you can
run a Simplicit&eacute;&reg; instace.

It uses Apache Tomcat as application server and, by default, an embedded HSQLDB engine.

Get
---

You can get the server container from [Docker Hub](https://registry.hub.docker.com/u/simplicite/server/):

	sudo docker pull simplicite/server

Add application
---------------

To add a Simplicit&eacute;&reg; application you need to create a dedicated `Dockerfile`:

	vi Dockerfile

With this content:

```
FROM simplicite/server
ADD <location of your Simplict&eacute;&reg; application package> /usr/local/tomcat/webapps/ROOT
```

Then you can build your application container:

	sudo docker build -t simplicite/<my application name> .

Run
---

Start a container instance using:

	sudo docker run -p <public port, e.g. 8080>:8080 simplicite/<my application name>

The container instance exposes 3 ports for different usage:

- HTTP port `8080` for direct access or to be exposed thru an HTTP reverse proxy (Apache, NGINX, ...)
- HTTP port `8443` to be exposed thru an HTTPS reverse proxy (Apache, NGINX, ...)
- AJP port `8009` to be exposed thru an HTTP/HTTPS reverse proxy (Apache)

Note that if you experience network issues from your instance it is likely to be a DNS configuration issue
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

Third party licenses
--------------------

- Apache Tomcat is released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0)
- HyperSQL (HSQLDB) is released under [a specific BSD style license](http://hsqldb.org/web/hsqlLicense.html)
