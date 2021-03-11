#!/bin/bash

/usr/bin/mysqld_safe &

/usr/local/bin/mailhog &

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
