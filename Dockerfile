FROM ubuntu:trusty

MAINTAINER cake17 <cake17@cake-websites.com>

# Install base packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get -yq install \
        curl \
        apache2 \
        libapache2-mod-php5 \
        php5-mysql \
        php5-intl \
        php5-mcrypt \
        php5-gd \
        php5-curl \
        php-pear \
        git \
        php-apc && \
    rm -rf /var/lib/apt/lists/*
RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini

# For mcrypt
RUN php5enmod mcrypt

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# export COMPOSER_HOME=/app;

# Add an ssh directory with good permisssion (for private repo)
RUN mkdir /root/.ssh
RUN chmod 700 /root/.ssh

# Add image configuration and scripts
ADD run.sh /run.sh
RUN chmod 755 /*.sh

# Configure /app folder with sample app
RUN mkdir -p /app && rm -rf /var/www/html && ln -s /app /var/www/html
ADD sample/ /app

# Add application code onbuild
ONBUILD RUN rm -fr /app
ONBUILD ADD . /app
ONBUILD RUN chown www-data:www-data /app -R

EXPOSE 80
WORKDIR /app
CMD ["/run.sh"]
