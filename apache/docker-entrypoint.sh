# !/bin/bash

set -m

# /usr/bin/mysqld_safe &

# source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND &

# /usr/local/bin/mailhog


/usr/bin/supervisord

fg %1
