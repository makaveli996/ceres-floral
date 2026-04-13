#!/bin/sh
# Run at container start: make /var/www/html writable by www-data (UID 33).
# Then run PrestaShop image startup (/tmp/docker_run.sh) so PS_INSTALL_AUTO runs
# install/index_cli.php and Apache starts last. Without this, only apache2-foreground
# ran and the web installer appeared. Host: sudo usermod -aG www-data $USER (once).

set -e
chown -R 33:33 /var/www/html
chmod -R g+rwX /var/www/html

# Official image CMD is /tmp/docker_run.sh (wait for DB, CLI install, exec apache).
if [ -x /tmp/docker_run.sh ]; then
  if [ -x /usr/local/bin/docker-php-entrypoint ]; then
    exec /usr/local/bin/docker-php-entrypoint /tmp/docker_run.sh
  else
    exec /tmp/docker_run.sh
  fi
fi

if [ -x /usr/local/bin/docker-php-entrypoint ]; then
  exec /usr/local/bin/docker-php-entrypoint "$@"
else
  exec "$@"
fi
