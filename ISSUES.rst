==========
 Problems
==========

I've got a 4-year old Intel Air running Docker Desktop 4.0.1 with
Compose v2.0.0-rc.3 which runs this fine. But a newer Intel PowerBook
had some problems, and my new M1 PowerBook had more problems.

It turned out I had installed docker with ``homebrew`` on the M1, so I
removed that. Manually uninstalling and reinstalling Docker (Desktop)
from the Docker site fixed both the old Intel and the new M1. This
caused the menubar Docker icon "About Docker Desktop" to report
different versions than the CLI commands, since the homebrew version
was getting called on the CLI on my M1. Derp!

Moral of the story: on macOS, install Docker Desktop (which includes
docker engine, compose, and others) from Docker:
https://docs.docker.com/desktop/mac/install/

Then, ``/usr/local/bin/docker`` will be symlinked into
``/Applications/Docker.app/...``.

Menubar Docker "About Docker Desktop" reports on my machines:
* Docker Desktop 4.4.2 (73305)
* Engine: 20.10.12
* Compose: 1.29.2

But the old Air, it reports:
* Compose: 2.2.3

CLI ``docker compose version`` on all three report 2.2.3; whatevs...

Compose doesn't know ``--context``
==================================

When re-creating this on my new Mac M1 laptop, doing ``make build`` complained::

  AWS_ACCT=31415926535 AWS_REGION=us-east-1 docker --context default compose build
  unknown docker command: "compose compose"

This may be due to an old version of docker, or docker compose (which
is built into recent versinos of docker).

A workaround is to set the context with an environment variable
instead of flag, like::

  DOCKER_CONTEXT=default docker compose build

``docker context create ecs name`` fails
========================================

My M1 version of docker (and/or compose?) doesn't know about contexts::

  docker context create ecs myecs

  "docker context create" requires exactly 1 argument.
  See 'docker context create --help'.
  Usage:  docker context create [OPTIONS] CONTEXT
  Create a context

The only thing that fixed this was ensuring I was using the lates
official Docker Desktop installation and not some old homebrew
version.
