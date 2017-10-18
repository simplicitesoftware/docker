![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

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

Run
---

Run the container by:

	sudo docker run -p <public port, e.g. 8080>:8080 simplicite/<my application name>

The container exposes 3 ports for different usage:

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

Third party components
----------------------

The image is based on the official [CentOS image](https://hub.docker.com/_/centos/) and its standard components (OpenJDK, ..).

The built image available on DockerHub also contains the following components:

- Apache Tomcat released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0)
- HyperSQL (HSQLDB) engine and JDBC driver released under [a custom BSD style license](http://hsqldb.org/web/hsqlLicense.html)
- MySQL connector/J JDBC driver released under [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.en.html)
- PostgreSQL JDBC driver released under [a custom BSD style license](https://jdbc.postgresql.org/about/license.html)
