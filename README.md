![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

<a href="https://www.simplicite.io"><img src="https://img.shields.io/badge/author-Simplicite_Software-blue.svg?style=flat-square" alt="Author"></a>
&nbsp;<img src="https://img.shields.io/badge/license-Apache--2.0-orange.svg?style=flat-square" alt="License">

Using Simplicit&eacute;&reg; server image
=========================================

Introduction
------------

This repository contains the scripts used to **build** [Docker](http://www.docker.com) images that contains a pre-configured
[Tomcat](http://tomcat.apache.org/) server on which can be run a [Simplicit&eacute;&reg;](http://www.simplicitesoftware.com)
low code platform instance.

The images built using these tools are **available on [DockerHub](https://hub.docker.com/r/simplicite/)**:

- Public **server** images (not containing the Simplicit&eacute; platform)
- Private **platform** images (containing the Simplicit&eacute; platform)

It also contains other scripts for building other Simplicit&eacute;&reg;-related images.

Usage
-----

- See [this document](https://docs.simplicite.io/documentation/90-operation/docker-tutorial.md) for a basic tutorial.
- See [this document](https://docs.simplicite.io/documentation/90-operation/docker.md) for more details and advanced usages.

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

The base server images are based on the official CentOS, AdoptOpenJDK and Apline images and their standard additional packages.
They also contain the following additional components:

- Apache Tomcat released under the [Apache License](http://www.apache.org/licenses/LICENSE-2.0) with:
	- the MySQL connector/J JDBC driver released under [LGPL license](https://www.gnu.org/licenses/lgpl-3.0.en.html)
	- the PostgreSQL JDBC driver released under [a custom BSD style license](https://jdbc.postgresql.org/about/license.html)
