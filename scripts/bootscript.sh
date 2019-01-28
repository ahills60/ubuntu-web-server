#/bin/bash

# This script is executed by docker on initialisation

# Start by initialising cron
service cron start

# Then execute the web server
service nginx start

# enable bash if necessary
bash

