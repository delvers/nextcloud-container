#!/bin/bash
if [ -e /nextcloud/apps/files ]
then
  echo "Apps seem to be ok..."
else
  mv /default_apps/* /nextcloud/apps/
fi

/permissions.sh

installed=`occ status | grep installed: | sed  's/^  - installed: \(.*\)$/\1/'`
version=`occ status | grep version: | sed  's/^  - version: \(.*\)$/\1/'`
old_version=`grep version config/config.php | sed " s/^  \'version\' => \'\(.*\)\',$/\1/"`


if [ $old_version != $version ]
then
  echo "#### Upgrade"
  occ upgrade
fi

if [ $installed == 'false' ]
then
  echo "#### Start install"
  occ maintenance:install -n \
  --database  "${DB_TYPE}" \
  --database-host "${DB_HOST}" \
  --database-name "${DB_NAME}" \
  --database-user "${DB_USER}" \
  --database-pass "${DB_PASSWORD}" \
  --admin-user "${ADMIN_USER}" \
  --admin-pass "${ADMIN_PASSWORD}"
  occ config:system:set memcache.local --value="\OC\Memcache\APCu"
  occ config:system:set trusted_domains 1 --value="${DOMAIN}"
  if [ -n ${USER} ]
  then
    export OC_PASS=${USER_PASSWORD}
    occ user:add --password-from-env ${USER}
  fi
fi

echo "#### Run Nextcloud"
php-fpm7
nginx
tail -f /var/log/nginx/error.log -f /nextcloud/data/nextcloud.log
