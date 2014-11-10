# based on Tutum Dockerfile : https://github.com/tutumcloud/tutum-docker-php
# and on official php Dockerfile : https://github.com/docker-library/php
FROM ubuntu:trusty

MAINTAINER cake17 <cake17@cake-websites.com>

# Install base packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        curl \
        git \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-sqlite \
        php5-intl \
        php5-mcrypt \
        php5-gd \
        php5-curl \
        php-pear \
        php-apc && \
    rm -rf /var/lib/apt/lists/*
RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

# Necessary for mcrypt
RUN php5enmod mcrypt

# Apache2 config
RUN rm -rf /var/www/html && mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html && chown -R www-data:www-data /var/lock/apache2 /var/run/apache2 /var/log/apache2 /var/www/html

# Add Apache2 conf
RUN mv /etc/apache2/apache2.conf /etc/apache2/apache2.conf.dist
ADD apache2.conf /etc/apache2/apache2.conf

# activate Mod Rewrite for Apache
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# export COMPOSER_HOME=/app;

# Add an ssh directory with good permission (for private repo)
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Add sample in /var/www/html folder (only useful to test)
ADD sample/ /var/www/html

# Add application code onbuild (useful for "children Dockerfile" that build from this Dockerfile)
ONBUILD RUN rm -rf /var/www/html
ONBUILD ADD . /var/www/html
ONBUILD RUN chown www-data:www-data /var/www/html -R

EXPOSE 80
WORKDIR /var/www/html
CMD ["/run.sh"]
