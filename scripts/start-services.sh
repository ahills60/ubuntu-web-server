#!/bin/bash

# This script is executed by docker on initialisation
set -e

shutdown() {
    trap - EXIT TERM INT
    if [[ -n "${nginx_pid:-}" ]]; then
        kill -TERM "$nginx_pid" 2>/dev/null || true
        wait "$nginx_pid" 2>/dev/null || true
    fi
    service php8.4-fpm stop || true
    mongod --config /etc/mongod.conf --shutdown || true
}

trap shutdown EXIT
trap 'exit 0' TERM INT

# Initialise PHP-FPM
mkdir -p /run/php
service php8.4-fpm start

# MongoDB's package uses systemd, which is not running in this container
mkdir -p /var/lib/mongodb /var/log/mongodb
chown mongodb:mongodb /var/lib/mongodb /var/log/mongodb
runuser -u mongodb -- mongod --config /etc/mongod.conf --fork

# Then execute the web server
nginx -g 'daemon off;' &
nginx_pid=$!
wait "$nginx_pid"
