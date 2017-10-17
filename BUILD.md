![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

Building Simplicit&eacute;&reg; server container
================================================

Build image
-----------

Clone the GitHub repositiory:

	git clone https://github.com/simplicitesoftware/docker.git
	cd docker

Copy a preconfigured Tomcat directory:

	cp -r <path to your preconfigured Tomcat directory, e.g. /var/simplicite/tomcat> tomcat

Build the image:

	sudo docker build -t simplicite/server .

Push do DockerHub
-----------------

Login to Docker Hub:

	sudo docker login

Push it to Docker Hub:

	sudo docker push simplicite/server
