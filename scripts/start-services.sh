#!/bin/bash

# This script is executed by docker on initialisation
set -e

# Initialise PHP-FPM
mkdir -p /run/php
service php8.4-fpm start

# MongoDB's package uses systemd, which is not running in this container
mkdir -p /var/lib/mongodb /var/log/mongodb
chown mongodb:mongodb /var/lib/mongodb /var/log/mongodb
runuser -u mongodb -- mongod --config /etc/mongod.conf --fork

# Then execute the web server
exec nginx -g 'daemon off;'
