#!/bin/bash

if [ ! -e index.php ] && [ ! -e wp-includes/version.php ] && [ -e /var/www/wordpress.tar.gz ]; then
  tar -zxf /var/www/wordpress.tar.gz -C /var/www
fi

if [ -e /var/www/wordpress.tar.gz ]; then
  rm /var/www/wordpress.tar.gz
fi

/usr/bin/mysqld_safe &

/usr/local/bin/mailhog &

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
