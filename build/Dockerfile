FROM php:7.1-apache

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
        netcat \
        mysql-client \
        wget \
        unzip \
        git

RUN mkdir -p /elgg
COPY composer-install.sh /elgg
COPY php.ini /usr/local/etc/php/

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-install mbstring
RUN chmod +x /elgg/composer-install.sh && /elgg/composer-install.sh

WORKDIR /var/www/html/

RUN a2enmod rewrite

ENV TIMEZONE="America/Winnipeg"
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
#Set time zone in PHP
RUN sed -i "s#{{timezone}}#$TIMEZONE#g" /usr/local/etc/php/php.ini

RUN composer self-update && \
    composer global require "fxp/composer-asset-plugin:~1.3"

ENV ELGG_VERSION=2.3.4
RUN git clone https://github.com/Elgg/Elgg.git .
RUN git checkout ${ELGG_VERSION}

RUN mkdir -p /data && \
    chown -R www-data:www-data /data && \
    chmod -R 770 /data
    
ENV ELGG_DB_HOST=${ELGG_DB_HOST:-"mysql"}
ENV ELGG_DB_NAME=${ELGG_DB_NAME:-"elgg"}
ENV ELGG_DB_PORT=${MYSQL_PORT:-"3306"}
ENV ELGG_DB_PREFIX=${ELGG_DB_PREFIX:-"elgg_"}

# Elgg admin account
ENV ELGG_DISPLAY_NAME=${ELGG_DISPLAY_NAME:-"Admin"}
ENV ELGG_EMAIL=${ELGG_EMAIL:-"admin@myelgg.com"}
ENV ELGG_USERNAME=${ELGG_USERNAME:-"admin"}
ENV ELGG_PASSWORD=${ELGG_PASSWORD:-"admin-pass"}

ENV ELGG_SITE_NAME=${ELGG_SITE_NAME:-"Elgg Site"}
ENV ELGG_DATA_ROOT=${ELGG_DATA_ROOT:-"/data/"}
ENV ELGG_WWW_ROOT=${ELGG_WWW_ROOT:-"http://localhost:8000"}
ENV ELGG_SITE_ACCESS=${ELGG_SITE_ACCESS:-"2"}
ENV ELGG_PATH=${ELGG_PATH:-"/var/www/html/"}

COPY elgg-install.sh /elgg
RUN chmod +x /elgg/elgg-install.sh
COPY elgg-install.php /elgg
