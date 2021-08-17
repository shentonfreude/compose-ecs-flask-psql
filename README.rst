======================================================
 Docker Compose deploy to ECS Fargate: Flask and PSQL
======================================================

Docker Compose recently announced the ability to `deploy to AWS
Elastic Container Service
<https://www.docker.com/blog/docker-compose-for-amazon-ecs-now-available/>`_
directly from Compose files. This should make it much easier to
develop locally then deploy in the cloud.

When deploying to an old account (from 2013) without a "Default VPC"
it complained. I created a VPC but most not have gotten something
wrong, because the app server was not able to resolve the database
by its service name. I've overcome this and include a
``vpc-defaulty.yml`` CloudFormation you can use to deploy a VPC that
allows Service Discovery to succeed.

I'm using a ``Makefile`` to set AWS and ECS configs, as well as Docker
tags. I'm also leveraging the Compose ``.override.`` file for builds
and local-only features, and a ``.ecs.`` file for ECS-specific
overrides.

Simple Demo Runs Locally
========================

I want a simple demo that shows an app server connecting to a DB, both
running in containers. This works locally::

  docker compose build
  docker compose run

(You can also use ``make build`` and ``make run``).

Now you can visit URLs http://localhost/createtable,
http://localhost/insert (multiple times), and http://localhost/select.

Deploy to ECS
=============

Now we want to deploy it to AWS ECS, which Docker Compose now can do
for you! We'll need a VPC with at least 2 public subnets for the ALB.
You can use the vpc-defaulty.yml to create one if you need; I had
problems with others I used, and this was about as simple as I could
make it.

If you have a "Default VPC" and want to use it, comment out
``x-aws-vpc`` in ``docker-compose.ecs.yml``. If you have created one,
perhaps one you just created from ``vpc-defaulty.yml``, specify its ID
in that file.

We need to create a Docker "context" matching an AWS profile or
credentials; I'm calling mine ``wp-dev``, after my AWS_PROFILE name::

  docker context create ecs wp-dev
  ? Create a Docker context using: An existing AWS profile
  ? Select AWS Profile wp-dev
  Successfully created ecs context "wp-dev"

If you specify key and secret, it will also ask you for region; you
may need to set ``AWS_DEFAULT_REGION`` if it doesn't know.

In the ``Makefile`` set ``AWS_REGION`` and your ``ECS_CONTEXT`` name,
and update the ``TAG_NAME`` if you don't like mine. The rest of the
file should work without change.

ECS cannot build images for you, so we're assuming you've already
build an image locally, and it matches the ``TAG_NAME`` in the
``Makefile``.

Then create an ECR image repo so ECS can find your image, you only
have to do this once::

  make ecr_repo

Then use another make target to tag, push the image, and deploy to ECS::

  make deploy

This will take a few minutes to build, but should come up.

Does FlaskService fail to come up?
----------------------------------

It may be that the PSQL service starts, but the Flask app is unable to
connect to it by its Compose service name::

  FlaskappService EssentialContainerExited: Essential container in task exited

In the ECS > Clusters > flaskapp > Services >
flaskapp-FlaskappService-xxx > Logs we can briefly see (before the
stack is removed)::

  sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) could
  not translate host name "psql" to address: Name or service not known

The Docker ECS docs about `service names
<https://docs.docker.com/cloud/ecs-integration/#service-names>`_
indicates this works out of the box, via AWS Cloud Map, but it's not
resolving DNS names to servcies for me. I saw the AWS CloudMap and
private DNS looked sane. Using private FQDNs didn't help either.

AWS' Massimo Re Ferre' (mreferre) was exceptionally helpful on Stack
Overflow, I really appreciate his insights:
https://stackoverflow.com/questions/68764699/docker-compose-deploy-to-ecs-cannot-resolve-service-names-yelb

Turned out this problem occurred with an existing VPC I was reusing. I
don't know what it was missing, but deploying and using
``vpc-defaulty.yml`` fixed my problem.

I hope this repo and lessons learned the hard way may help someone
else.
