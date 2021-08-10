======================================================
 Docker Compose deploy to ECS Fargate: Flask and PSQL
======================================================

Docker Compose recently announced the ability to `deploy to AWS
Elastic Container Service
<https://www.docker.com/blog/docker-compose-for-amazon-ecs-now-available/>`_
directly from Compose files. This should make it much easier to
develop locally then deploy in the cloud.

In my trials, the deploy works but the app server is not able to
resolve the DNS name of a dependent database server; to use this I
need to understand how to connect many services by their names.


Simple Demo Runs Locally
========================

I want a simple demo that shows an app server connecting to a DB, both
running in containers. This works locally::

  docker compose build
  docker compose run

Now you can visit URLs http://localhost/createtable,
http://localhost/insert, http://localhost/select .

Deploy to ECS
=============

Now we want to deploy it to AWS ECS, which Docker Compose now can do.
We'll need a VPC with 2 public subnets for the ALB, and we'll just
reuse one we already have.

We move a local host mount from ``docker-compose.yml`` to
``docker-compose.override.yml`` because it's incompatible with ECS.

We also need to create a context matching an AWS profile; I'm calling
mine wp-dev::

  docker context create ecs wp-dev
  ? Create a Docker context using: An existing AWS profile
  ? Select AWS Profile wp-dev
  Successfully created ecs context "wp-dev"

Tweak the ``TAG_NAME`` in the ``Makefile`` then create an ECR::

  make ecr_repo

Then use another make target to push the image and deploy to ECS::

  make deploy

This will take a few minutes to build, but eventually it fails. :-(
The PSQL service starts, but the flask app is unable to connect to it
by Compose service name::

  FlaskappService EssentialContainerExited: Essential container in task exited

In the ECS > Clusters > flaskapp > Services >
flaskapp-FlaskappService-xxx > Logs we see::

  sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) could
  not translate host name "psql" to address: Name or service not known

The Docker ECS docs about `service names
<https://docs.docker.com/cloud/ecs-integration/#service-names>`_
indicates this works out of the box, via AWS Cloud Map, but it's not
resolving DNS names to servcies for me.

I see the AWS CloudMap and private DNS look sane. I've also tried
referencing their FQDNs instead of bare service name in my app, but
it's no different.

I'm on Docker version 20.10.7, build f0df350.
