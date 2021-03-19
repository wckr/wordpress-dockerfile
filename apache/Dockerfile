FROM wocker/base

LABEL maintainer="ixkaito <ixkaito@gmail.com>"
LABEL version="2.0"

#
# PHP must be installed after Apache
#
RUN apt-get update; \
  apt-get clean; \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php \
    php-imagick \
    php7.3 \
    php7.3-bz \
    php7.3-cli \
    php7.3-curl \
    php7.3-gd \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-xdebug \
    php7.3-xml \
    php7.3-zip \
  ; \
  rm -rf /var/lib/apt/lists/*

#
# Apache settings
#
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf; \
  sed -i -e '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf; \
  sed -i -e "s#DocumentRoot.*#DocumentRoot ${DOCROOT}#" /etc/apache2/sites-available/000-default.conf; \
  sed -i -e "s/export APACHE_RUN_USER=.*/export APACHE_RUN_USER=wocker/" /etc/apache2/envvars; \
  sed -i -e "s/export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=wocker/" /etc/apache2/envvars; \
  a2enmod rewrite

#
# php.ini settings
#
RUN sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 32M/" /etc/php/7.3/apache2/php.ini; \
  sed -i -e "s/^post_max_size.*/post_max_size = 64M/" /etc/php/7.3/apache2/php.ini; \
  sed -i -e "s/^display_errors.*/display_errors = On/" /etc/php/7.3/apache2/php.ini; \
  sed -i -e "s/^;mbstring.internal_encoding.*/mbstring.internal_encoding = UTF-8/" /etc/php/7.3/apache2/php.ini; \
  sed -i -e "s#^;sendmail_path.*#sendmail_path = /usr/local/bin/mailhog sendmail#" /etc/php/7.3/apache2/php.ini

#
# Install WordPress
#
WORKDIR ${DOCROOT}
RUN service mysql start; \
  mysqladmin -u root password root; \
  mysql -uroot -proot -e \
    "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci; GRANT ALL PRIVILEGES ON wordpress.* TO username@'%' IDENTIFIED BY 'password';" \
  ; \
  wp core download --allow-root; \
  wp config create --allow-root \
    --dbname=wordpress \
    --dbuser=username \
    --dbpass=password \
  ; \
  chown -R wocker:wocker ${DOCROOT}
#
# Archive WordPress files
#
RUN mkdir -p /src; \
  tar -zcf /src/wordpress.tar.gz -C ${DOCROOT} .; \
  rm -rf ${DOCROOT}

VOLUME ${DOCROOT}

#
# Open ports
#
EXPOSE 80 3306 8025

COPY docker-entrypoint.sh ${BIN}
RUN chmod +x ${BIN}/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
