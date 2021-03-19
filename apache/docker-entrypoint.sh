#!/bin/bash

$user="$(id -u)"
$group="$(id -g)"

if [ ! -e index.php ] && [ ! -e wp-includes/version.php ] && [ -e /src/wordpress.tar.gz ]; then
  tar -zxf /src/wordpress.tar.gz -C .
fi

chown -R "$user:$group" .

/usr/bin/mysqld_safe &

/usr/local/bin/mailhog &

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
