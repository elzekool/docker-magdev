FROM php:5.5-apache

MAINTAINER Elze Kool <info@kooldevelopment.nl>

WORKDIR /var/www/htdocs

# Setup magerun
ENV N98_MAGERUN_VERSION 1.96.1
ENV N98_MAGERUN_URL https://raw.githubusercontent.com/netz98/n98-magerun/$N98_MAGERUN_VERSION/n98-magerun.phar
RUN curl -o /usr/local/bin/n98-magerun -L $N98_MAGERUN_URL \
    && chmod +x /usr/local/bin/n98-magerun

# Setup Magento PHP requirements
RUN requirements="libpng12-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg62-turbo libpng12-dev libfreetype6-dev libjpeg62-turbo-dev mysql-client-5.5 libxml2-dev" \
    && apt-get update && apt-get install -y $requirements && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install soap \
    && requirementsToRemove="libpng12-dev libmcrypt-dev libcurl3-dev libpng12-dev libfreetype6-dev libjpeg62-turbo-dev" \
    && apt-get purge --auto-remove -y $requirementsToRemove

# Enable rewrite module
RUN a2enmod rewrite

# Change apache virtual host location
RUN sed -i -e 's/\/var\/www\/html/\/var\/www\/htdocs/' /etc/apache2/apache2.conf

# Set user ID for www-data to 1000, this corresponds
# to the first installed user in the host system
RUN usermod -u 1000 www-data

# Download magento
COPY ./bin/download-magento /usr/local/bin/download-magento
RUN chmod +x /usr/local/bin/download-magento

# Installation script for sample data
COPY ./sampledata/magento-sample-data-1.9.1.0.tgz /opt/
COPY ./bin/install-sampledata-1.9 /usr/local/bin/install-sampledata
RUN chmod +x /usr/local/bin/install-sampledata

# Installation script for Magento
COPY ./bin/install-magento /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

# Install Xdebug
RUN cd /tmp \
    && curl -o xdebug-2.4.0rc3.tgz -L http://xdebug.org/files/xdebug-2.4.0rc3.tgz \
    && tar -xvzf xdebug-2.4.0rc3.tgz \
    && cd xdebug-2.4.0RC3 \
    && phpize \
    && ./configure \
    && make \
    && cp modules/xdebug.so /usr/local/lib/php/extensions/no-debug-non-zts-20121212 \
    && echo "zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20121212/xdebug.so" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_connect_back=On" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/php.ini

# Install Git and make /var/www/.composer writable
RUN apt-get update && apt-get install -y git && \
    mkdir -p /var/www/.composer && \
    chmod a+rwX /var/www/.composer

# Install ZIP extension for Composer
RUN apt-get update && apt-get install -y zlibc zlib1g zlib1g-dev && \
    docker-php-ext-install zip







