#!/bin/sh
# Run at container start: make /var/www/html writable by www-data (UID 33).
# Then start the original entrypoint. Host user should join group www-data (33)
# so they can edit files: sudo usermod -aG www-data $USER (then log out/in).

set -e
chown -R 33:33 /var/www/html
chmod -R g+rwX /var/www/html

if [ -x /usr/local/bin/docker-php-entrypoint ]; then
  exec /usr/local/bin/docker-php-entrypoint "$@"
else
  exec "$@"
fi
