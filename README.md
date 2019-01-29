# Ubuntu Web Server

- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Additional Features](#additional-features)

## Introduction
This dockerfile will build an Ubuntu-based web server that uses nginx, PHP7.2 (from ppa:ondrej/php) and MongoDB (community edition release).

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

## Additional Features
This container implements a `git pull` hook within nginx that activates on navigation to `/git-pull`. This will only work if credentials to the repository have been set up accordingly for the root user and that the html directory is a git repository.
