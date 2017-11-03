FROM debian:stretch
MAINTAINER ixkaito <ixkaito@gmail.com>

RUN apt-get update \
  && apt-get clean \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    less \
    libsqlite3-dev \
    mysql-server \
    mysql-client \
    nginx \
    openssh-client \
    php7.0 \
    php7.0-cli \
    php7.0-curl \
    php7.0-gd \
    php7.0-mysql \
    php7.0-xdebug \
    php7.0-fpm \
    ruby \
    ruby-dev \
    software-properties-common \
    supervisor \
    vim \
  && rm -rf /var/lib/apt/lists/*

#
# Install Gems
#
RUN gem install mailcatcher
RUN gem install wordmove -v 2.0.0

#
# `mysqld_safe` patch
# @see https://github.com/wckr/wocker/pull/28#issuecomment-195945765
#
RUN sed -i -e 's/file) cmd="$cmd >> "`shell_quote_string "$err_log"`" 2>\&1" ;;/file) cmd="$cmd >> "`shell_quote_string "$err_log"`" 2>\&1 \& wait" ;;/' /usr/bin/mysqld_safe

#
# nginx settings
#
RUN adduser --uid 1000 --gecos '' --disabled-password wocker
RUN sed -i -e "s#root /var/www/html;#root /var/www/wordpress/;#" /etc/nginx/sites-available/default \
  && sed -i -e "s/index index.html/index index.php index.html/" /etc/nginx/sites-available/default \
  && sed -i -e "/location.*php/,/}/ s/#//" /etc/nginx/sites-available/default \
  && sed -i -e "/# With php-cgi.*/,/}/ s/fastcgi.*//" /etc/nginx/sites-available/default \
  && sed -i -e "s/server_name _;/server_name localhost;/" /etc/nginx/sites-available/default \
  && sed -i -e "s/user www-data/user wocker/" /etc/nginx/nginx.conf

#
# php-fpm settings
#
RUN sed -i -e "s/^user =.*/user = wocker/" /etc/php/7.0/fpm/pool.d/www.conf \
  && sed -i -e "s/^group = .*/group = wocker/" /etc/php/7.0/fpm/pool.d/www.conf \
  && sed -i -e "s/^listen.owner =.*/listen.owner = wocker/" /etc/php/7.0/fpm/pool.d/www.conf \
  && sed -i -e "s/^listen.group =.*/listen.group = wocker/" /etc/php/7.0/fpm/pool.d/www.conf

#
# php.ini settings
#
RUN sed -i -e "s/^upload_max_filesize.*/upload_max_filesize = 32M/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/^post_max_size.*/post_max_size = 64M/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/^display_errors.*/display_errors = On/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s/^;mbstring.internal_encoding.*/mbstring.internal_encoding = UTF-8/" /etc/php/7.0/fpm/php.ini \
  && sed -i -e "s#^;sendmail_path.*#sendmail_path = /usr/local/bin/catchmail#" /etc/php/7.0/fpm/php.ini

#
# Xdebug settings
#
ADD xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini

#
# Install PHPUnit
#
RUN curl -OL https://phar.phpunit.de/phpunit.phar \
  && chmod +x phpunit.phar \
  && mv phpunit.phar /usr/local/bin/phpunit

#
# Install WP-CLI
#
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

#
# MariaDB settings & install WordPress
#
RUN mkdir -p /var/www/wordpress
ADD wp-cli.yml /var/www
ADD Movefile /var/www/wordpress
WORKDIR /var/www/wordpress
RUN sed -i -e "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf \
  && service mysql start \
  && mysqladmin -u root password root \
  && mysql -uroot -proot -e \
    "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8; grant all privileges on wordpress.* to wordpress@'%' identified by 'wordpress';" \
  && wp core download --allow-root \
  && wp core config --allow-root \
    --dbname=wordpress \
    --dbuser=wordpress \
    --dbpass=wordpress \
    --dbhost=localhost
RUN chown -R wocker:wocker /var/www/wordpress

#
# Open ports
#
EXPOSE 80 3306

#
# Supervisor
#
RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
