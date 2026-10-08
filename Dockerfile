# Semi-replica of web server in Ubuntu
# 
# Andrew Hills (a.hills@sheffield.ac.uk)

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set location
RUN ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime

# Add repositories and install the development server stack
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates curl gnupg lsb-release \
        sudo git tzdata && \
    add-apt-repository -y ppa:ondrej/php && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
        gpg --dearmor -o /etc/apt/keyrings/mongodb-server-6.0.gpg && \
    chmod 644 /etc/apt/keyrings/mongodb-server-6.0.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mongodb-server-6.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" \
        > /etc/apt/sources.list.d/mongodb-org-6.0.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx php8.4-fpm php8.4-cli php8.4-mbstring \
        php8.4-intl php8.4-mongodb composer mongodb-org && \
    update-alternatives --set php /usr/bin/php8.4 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration files
COPY confs/nginx/default /etc/nginx/sites-available/default
COPY confs/sudoers.d/nginxgit /etc/sudoers.d/nginxgit
COPY scripts/start-services.sh /usr/local/bin/start-services.sh
COPY scripts/git-pull.php /usr/local/lib/git-pull.php

RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    chmod 440 /etc/sudoers.d/nginxgit && \
    chmod 755 /usr/local/bin/start-services.sh

# Expose HTML directory and nginx configs
VOLUME ["/var/www/html"]

# Expose web server port
EXPOSE 80

CMD ["/usr/local/bin/start-services.sh"]
