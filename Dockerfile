FROM php:8.4-apache
LABEL maintainer="Rion Dooley <dooley@tacc.utexas.edu>"

ENV APACHE_DOCROOT="/var/www"

# Add custom default apache virtual host with combined error and access logging to stdout
COPY docker/apache_vhost /etc/apache2/sites-available/000-default.conf
COPY docker/php.ini /usr/local/etc/php

# Add custom entrypoint to inject runtime environment variables into beanstalk console config
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint
CMD ["/usr/local/bin/docker-entrypoint"]

WORKDIR "${APACHE_DOCROOT}"
COPY . ./
