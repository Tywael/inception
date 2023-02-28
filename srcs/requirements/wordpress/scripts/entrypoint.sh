#!/bin/bash
target="/etc/php7/php-fpm.d/www.conf"
grep -E "listen = 127.0.0.1" $target >/dev/null 2>&1
if [ $? -eq 0 ]; then
  sed -i "s|.*listen = 127.0.0.1.*|listen = 0.0.0.0:9000|g" $target
fi
if [ ! -f "wp-config.php" ]; then
  wp core download
  cp /conf/phpinfo.php /var/www/"$DOMAIN"
  while [ ! -f "wp-config-sample.php" ]; do
    echo "not ready"
    sleep 1
  done
  wp core config \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST"
  while [ ! -f "wp-config.php" ]; do
      echo "not ready"
      sleep 1
  done
  wp core install \
    --url="https://$DOMAIN" \
    --title="$DOMAIN" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" --skip-email
  wp plugin update --all
  wp user create \
    "$WP_USER" \
    "$WP_USER_EMAIL" \
    --role=editor \
    --user_pass="$WP_USER_PWD"
fi

php-fpm7 --nodaemonize