#!/bin/bash
set -e

# Change ownership for apache happiness
chown -R www-data:www-data "${APACHE_DOCROOT}"

TARGET_LINE_PATTERN="^\s*'servers'\s*=>\s*array.*"

if [[ -n "$BEANSTALKD_HOST" ]]; then
  if [[ -z "$BEANSTALKD_PORT" ]]; then
    BEANSTALKD_PORT=11300
  fi
  REPLACEMENT_STRING="    'servers' => array('$BEANSTALKD_HOST' => 'beanstalk://$BEANSTALKD_HOST:$BEANSTALKD_PORT'),"
  sed -i "s#${TARGET_LINE_PATTERN}#${REPLACEMENT_STRING}#g" /var/www/config.php

elif [[ -n "$BEANSTALKD_PORT_11300_TCP_ADDR" ]]; then
  BEANSTALKD_HOST=$BEANSTALKD_PORT_11300_TCP_ADDR
  if [[ -z "$BEANSTALKD_PORT" ]]; then
    if [[ -n "$BEANSTALKD_PORT_11300_TCP_PORT" ]]; then
      BEANSTALKD_PORT=$BEANSTALKD_PORT_11300_TCP_PORT
    else # Default if specific port not found via link
      BEANSTALKD_PORT=11300
    fi
  fi
  if [[ -z "$BEANSTALKD_PORT" ]]; then # If BEANSTALKD_PORT (global) was not set
    if [[ -n "$BEANSTALKD_PORT_11300_TCP_PORT" ]]; then
      BEANSTALKD_PORT=$BEANSTALKD_PORT_11300_TCP_PORT
    else
      BEANSTALKD_PORT=11300 # Fallback if linked port is also not set
    fi
  fi

  REPLACEMENT_STRING="    'servers' => array('$BEANSTALKD_HOST' => 'beanstalk://$BEANSTALKD_HOST:$BEANSTALKD_PORT'),"
  sed -i "s#${TARGET_LINE_PATTERN}#${REPLACEMENT_STRING}#g" /var/www/config.php
fi

rm -f /var/run/apache2/apache2.pid

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND