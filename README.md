# WordPress Dockerfiles

Dockerfiles of WordPress including PHP 7, MariaDB, WP-CLI, Wordmove, MailHog, Xdebug, PHPUnit. 

## Usage

### Docker

```shell
$ docker run -d -p 80:80 -p 3306:3306 -p 8025:8025 wocker/wordpress
```

### Wocker

```shell
$ wocker run wocker/wordpress
```
