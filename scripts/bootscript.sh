#!/bin/bash

# This script is executed by docker on initialisation

# Initialise PHP-FPM
service php7.2-fpm start

# Then execute the web server
service nginx start
