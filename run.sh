#!/bin/bash
# Add a base url if set
if [ ! -z ${BASE_URL+x} ]; then
    echo "BASE_URL is set to '$BASE_URL'";
    if [ ! -h "/var/www/html/$BASE_URL" ] ; then
        echo "/var/www/html/$BASE_URL doesn't exist yet"
        ln -Fs /var/www/html /var/www/html/${BASE_URL}
    fi
fi

source /etc/apache2/envvars
exec apache2 -D FOREGROUND
