![Simplicit&eacute; Software](https://www.simplicite.io/resources/logos/logo250.png)
* * *

Simplicite + PostgreSQL on Google Kubernetes Engine (GKE)
=========================================================

Prerequisites
-------------

Install and configure the [Google cloud SDK](https://cloud.google.com/sdk/docs/install).

And install the `kubectl` Kubernetes CLI:

	gcloud components install kubectl

Create a new **project** (or use an existing one):

	gcloud config set project <project ID>

Create a node **cluster** with at least 2 nodes with:

	gcloud container clusters create <cluster name, e.g. test-cluster> --num-nodes=<number of nodes, e.g. 2> --machine-type <type, e.g. g1-small> --zone <zone, e.g. us-central1-c>

Check the nodes status with `kubectl get nodes` and connect to the cluster with:

	gcloud container clusters get-credentials <cluster name, e.g. test-cluster> --zone <zone e.g us-central1-c>

Configure the Docker images registry:

	gcloud auth configure-docker

Tag the chosen Simplicité private image (previously pulled from DockerHub):

	docker tag simplicite/platform:<tag, e.g. 5-beta> <server, e.g. gcr.io>/<project ID>/simplicite/platform:<tag, e.g. 5-beta>

And push it to the registry:

	docker push <server, e.g. gcr.io>/<project ID>/simplicite/platform:<tag, e.g. 5-beta>

PostgreSQL database
-------------------

Create the **persistent disk** for the database data with:

	gcloud compute disks create postgresql-disk --size 50GB --zone <zone e.g. us-central1-c>

Create the **persistent volume** with:

	kubectl apply -f ./postgresql/volume.yml

Check the persistent volume status with `kubectl get pv`.

Create the **persistent volume claim** with:

	kubectl apply -f ./postgresql/volume-claim.yml

Check the persistent volume claim status with `kubectl get pvc`.

Create the **deployment** with:

	kubectl apply -f ./postgresql/deployment.yml

Check the deployment status with `kubectl get pod`.

Create the **service** with:

	kubectl apply -f ./postgresql/service.yml

Check the deployment status with `kubectl get svc`.

MySQL database
--------------

Create the **persistent disk** for the database data with:

	gcloud compute disks create mysql-disk --size 50GB --zone <zone e.g. us-central1-c>

Create the **persistent volume** with:

	kubectl apply -f ./mysql/volume.yml

Check the persistent volume status with `kubectl get pv`.

Create the **persistent volume claim** with:

	kubectl apply -f ./mysql/volume-claim.yml

Check the persistent volume claim status with `kubectl get pvc`.

Create the **deployment** with:

	kubectl apply -f ./mysql/deployment.yml

Check the deployment status with `kubectl get pod`.

Create the **service** with:

	kubectl apply -f ./mysql/service.yml

Check the deployment status with `kubectl get svc`.

Simplicité platform
-------------------

Create the **persistent disk** for the Git repositories of the Simplicité instance with:

	gcloud compute disks create simplicite-git-disk --size 10GB --zone <zone e.g. us-central1-c>

Create the **persistent volume** with:

	kubectl apply -f ./simplicite/git-volume.yml

Check the persistent volume status with `kubectl get pv`.

Create the **persistent volume claim** with:

	kubectl apply -f ./simplicite/git-volume-claim.yml

Check the persistent volume claim status with `kubectl get pvc`.

Create the **deployment** with:

	IMAGE=<image tag> DB=<mysql|postgresql> envsubst < ./simplicite/deployment.yml | kubectl apply -f -

where the image tag matches tag of the image you have pushed to the registry (see above).

Check the deployment status with `kubectl get pod`.

Create the **service** with:

	kubectl apply -f ./simplicite/service.yml

Check the deployment status with `kubectl get svc`.
