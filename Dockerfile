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
        tzdata && \
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
        php8.4-intl composer mongodb-org && \
    apt-get install -y --no-install-recommends \
        php8.4-dev php-pear build-essential pkg-config libssl-dev && \
    update-alternatives --set php /usr/bin/php8.4 && \
    update-alternatives --set phpize /usr/bin/phpize8.4 && \
    update-alternatives --set php-config /usr/bin/php-config8.4 && \
    printf '\n' | PHP_PEAR_PHP_BIN=/usr/bin/php8.4 pecl install mongodb-1.21.5 && \
    printf 'extension=mongodb.so\n' > /etc/php/8.4/mods-available/mongodb.ini && \
    phpenmod -v 8.4 -s cli mongodb && \
    phpenmod -v 8.4 -s fpm mongodb && \
    apt-get purge -y --auto-remove \
        php8.4-dev php-pear build-essential pkg-config libssl-dev && \
    php8.4 -r 'exit(phpversion("mongodb") === "1.21.5" ? 0 : 1);' && \
    php-fpm8.4 -i | grep -Fx 'MongoDB extension version => 1.21.5' && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add configuration files
COPY confs/nginx/default /etc/nginx/sites-available/default
COPY scripts/start-services.sh /usr/local/bin/start-services.sh

RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default && \
    chmod 755 /usr/local/bin/start-services.sh

# Expose HTML directory and nginx configs
VOLUME ["/var/www/html"]

# Expose web server port
EXPOSE 80

CMD ["/usr/local/bin/start-services.sh"]
