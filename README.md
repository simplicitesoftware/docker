![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
***

Simplicit&eacute;&reg; sandbox container
========================================

[![](https://images.microbadger.com/badges/image/simplicite/sandbox.svg)](http://microbadger.com/images/simplicite/sandbox "Get your own image badge on microbadger.com")

Introduction
------------

This packages is a **minimalistic** [Docker](http://www.docker.com) container on which you can
run a Simplicit&eacute;&reg; application sandbox for **evaluation** or **testing** purposes.

It uses Apache Tomcat as the Java application server and an embedded HSQLDB engine as the database.
Within the container Apache Tomcat is configured to have only the `8080` HTTP connector exposed.

Get
---

You can get the sandbox container from [Docker Hub](https://registry.hub.docker.com/u/simplicite/sandbox/):

	docker pull simplicite/sandbox

Add application
---------------

To add a Simplicit&eacute;&reg; application you need to create a dedicated `Dockerfile`:

	vi Dockerfile

With this content:

```
FROM simplicite/sandbox
ADD <location of your Simplict&eacute;&reg; application package> /usr/local/tomcat/webapps/ROOT
```

Then you can build your application container:

	docker build [--build-arg tomcatpath=<path to tomcat dir>] -t simplicite/<my application name> .

Run
---

Start a container instance using:

	docker run -p <public port, e.g. 8080>:8080 simplicite/<my application name>

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
