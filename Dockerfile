# Semi-replica of web server in Ubuntu
# 
# Andrew Hills (a.hills@sheffield.ac.uk)

FROM phusion/baseimage:master

CMD ["/sbin/my_init"]

# Set location
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

# Add repos and add nginx web server
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    apt-get update && \
    apt-get install -y nginx nginx-extras

# Add MongoDB to repo list
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list

# Install MongoDB, PHP and PHP MongoDB driver
RUN apt-get update && \
    apt-get update && \
    apt-get install -y mongodb-org php7.2-fpm php-mongodb composer

# Lastly, bring up to the latest version:
RUN apt-get update && \
    apt-get dist-upgrade -y

RUN mkdir -p /etc/my_init.d

# Add configuration files
COPY confs/nginx/default /etc/nginx/sites-available/
COPY confs/sudoers.d/nginxgit /etc/sudoers.d/
COPY scripts/bootscript.sh /etc/my_init.d/bootscript.sh

RUN ls -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN chmod 744 /etc/my_init.d/bootscript.sh


# Expose HTML directory and nginx configs
VOLUME ["/var/www/html"]

# Expose web server port
EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
