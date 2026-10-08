# Ubuntu Web Server

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Automated Builds](#automated-builds)

## Introduction
This dockerfile builds an Ubuntu 22.04 development web server with standard nginx (Ubuntu's 1.18 package line), PHP 8.4 (from ppa:ondrej/php), Composer, and MongoDB Community 6.0 (from MongoDB's official Jammy repository). Deploy site content using an external workflow, such as GitHub Actions.

The image tracks the MongoDB 6.0 package line rather than pinning exactly 6.0.29; installed patch versions depend on upstream availability. The `ubuntu:22.04` tag likewise tracks Jammy updates rather than a fixed 22.04.5 image. MongoDB 6.0 is end-of-life, so this stack is intended for development, not production.

At startup, `/usr/local/bin/start-services.sh` starts PHP-FPM and MongoDB without systemd, then runs nginx in the foreground. MongoDB keeps its package-default localhost binding and stores data in `/var/lib/mongodb`; mount that directory separately if database persistence is needed.

## Installation
Automated builds of this image are available on [Dockerhub](https://hub.docker.com/r/andrewhills/ubuntu-web-server) and is the recommmend method of installation.
```bash
docker pull andrewhills/ubuntu-web-server:latest
```

Alternatively, you can build this image locally:
```bash
docker build -t andrewhills/ubuntu-web-server github.com/ahills60/ubuntu-web-server

## Quick Start
You can manually launch the Ubuntu web server container by running:
```bash
docker run --name ubuntu-web-server -d \
    --publish 80:80 \
    --volume /srv/docker/www/:/var/www/html \
    andrewhills/ubuntu-web-server:latest
```

This will publish the web server on port 80 and serve web pages that are stored within `/srv/docker/www/`. 

Installation of additional packages using PHP Composer is possible by entering the container instance in bash:
```bash
docker exec -it ubuntu-web-server bash
```
Then navigate to the directory of interest, e.g. `/var/www/html`, and run php composer, e.g.
```bash
composer require monogodb/mongodb
```
## Automated Builds
A GitHub Actions workflow (`.github/workflows/docker-publish.yml`) builds the image from the checked-out branch's `Dockerfile` and pushes it to [Docker Hub](https://hub.docker.com/r/andrewhills/ubuntu-web-server):

| Branch      | Image tag                                 |
|-------------|-------------------------------------------|
| `master`    | `andrewhills/ubuntu-web-server:latest`    |
| `webserver` | `andrewhills/ubuntu-web-server:webserver` |

The workflow runs on every push to these branches and can also be triggered manually from the Actions tab. For it to work, the following repository secrets must be configured under *Settings > Secrets and variables > Actions*:

- `DOCKERHUB_USERNAME` - the Docker Hub username.
- `DOCKERHUB_TOKEN` - a Docker Hub [access token](https://docs.docker.com/security/for-developers/access-tokens/) with read/write permissions.

Note that the workflow file must be present on each branch it should run for (i.e. both `master` and `webserver`).
