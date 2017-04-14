#!/bin/bash
if [ -e /nextcloud/apps/files ]
then
  echo "Apps seem to be ok..."
else
  mv /nextcloud/default_apps/* /nextcloud/apps/
fi

/permissions.sh

if [ -e /nextcloud/config/config.php ]
then
  echo "#### Run Nextcloud"
  php-fpm7
  nginx
  tail -f /var/log/nginx/error.log
else
  echo "#### Start install"
  su nginx -s /bin/bash -c 'php7 occ  maintenance:install -n \
  --database  "${DB_TYPE}" \
  --database-host "${DB_HOST}" \
  --database-name "${DB_NAME}" \
  --database-user "${DB_USER}" \
  --database-pass "${DB_PASSWORD}" \
  --admin-user "${ADMIN_USER}" \
  --admin-pass "${ADMIN_PASSWORD}"'
  su nginx -s /bin/bash -c 'php7 occ  config:system:set memcache.local --value="\OC\Memcache\APCu"'

  echo "#### Run Nextcloud"
  php-fpm7
  nginx
  tail -f /var/log/nginx/error.log -f /nextcloud/data/nextcloud.log
fi
