# Semi-replica of web server in Ubuntu
# 
# Andrew Hills (a.hills@sheffield.ac.uk)

FROM ubuntu:bionic

# Set location
RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime

# Add repos and add nginx web server
RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt update && \
    apt -y upgrade && \
    apt install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    add-apt-repository -y ppa:ondrej/nginx && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    apt update && \
    apt install -y nginx

# Add MongoDB to repo list
RUN echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list

# Install MongoDB, PHP and PHP MongoDB driver
RUN apt update && \
    apt update && \
    apt install -y mongodb-org php7.2-fpm php-mongodb composer

# Lastly, bring up to the latest version:
RUN apt update && \
    apt dist-upgrade -y

# Finally, clear up
RUN rm -rf /var/lib/apt/lists/*

# Add configuration files
COPY confs/nginx/default /etc/nginx/sites-available/
COPY confs/sudoers.d/nginxgit /etc/sudoers.d/
RUN ls -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Expose HTML directory and nginx configs
VOLUME ["/var/www/html", "/etc/nginx/"]

# Expose web server port
EXPOSE 80

CMD ["/bin/bash"]
