#!/bin/bash
su nginx -s /bin/bash -c 'php7 -f /nextcloud/cron.php'
