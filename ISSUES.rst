==========
 Problems
==========

Recent Docker Compose does not work (with same CLI)
===================================================

On Mac with M1 I'm using:
* TODO: ``docker --context default compose build``?
* TDOO: ``docker create context ecs NAME`` ?  
* docker desktop 4.3.2
* docker --version: 20.10.12
* docker compose version: 2.2.3 (from homebrew insatll)
* turned on experimental:true

On Mac with Intel I'm using:
* Broken: ``docker --context`` uknown (maybe use DOCKER_CONTEXT)
* ``docker context create ecs NAME`` ok
* Docker Desktop 4.3.0
* Docker version 20.10.11, build dea9396
* Docker Compose version v2.2.1
* Docker Engine: buildkit: true, experimental: false

On old Mac Air with Intel -- works:
* Docker Desktop: 4.0.1
* Docker Engine: 20.10.8
* Docker Compose: v2.0.0-rc.3
* Docker Engine: experimental: false (no buildkit reference)
* Experimental Features: [x] Use Docker Compose V2 release candidate

Compose doesn't know ``--context``
==================================

When re-creating this on my new Mac M1 laptop, doing ``make build`` complained::

  AWS_ACCT=31415926535 AWS_REGION=us-east-1 docker --context default compose build
  unknown docker command: "compose compose"

This is a bug in my version of Docker Compose, v2.1.1, which is
reported fixed in 2.2.3. An update in the Docker Desktop GUI did not
get me a recent enough version of Compose, so I had to install it
with::

  brew install docker-compose

and follow its plugin symlink directions.

A workaround is to set the context with an environment variable
instead of flag, like::

  DOCKER_CONTEXT=default docker compose build

``docker context create ecs name`` fails
========================================

My M1 version of docker (and/or compose?) doesn't know about contexts::
  docker context create ecs killmeh

  "docker context create" requires exactly 1 argument.
  See 'docker context create --help'.
  Usage:  docker context create [OPTIONS] CONTEXT
  Create a context

See bug report on enabling "experimental" features, but from Dec 2020: 
https://github.com/docker/docker.github.io/issues/11845
https://github.com/docker/docker.github.io/issues/11949
https://github.com/docker/compose-cli/blob/main/INSTALL.md  (mreferre was last commit, but Linux only)

Compose CLI with "context" support for ECS (no macos instructuions?)
https://github.com/docker/compose-cli
