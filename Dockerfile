FROM alpine
MAINTAINER David Elvers

RUN apk add --update bash tar gnupg nginx \
php7 php7-fpm php7-ctype php7-dom php7-gd php7-iconv php7-json \
libxml2 php7-xml php7-xmlreader php7-xmlwriter php7-simplexml php7-mbstring php7-posix php7-zip php7-zlib \
php7-session php7-pcntl php7-curl php7-openssl php7-pdo php7-pdo_mysql \
php7-ldap php7-mcrypt php7-sqlite3 php7-pgsql php7-bz2 php7-intl \
php7-imap php7-ldap php7-ftp \
php7-exif php7-gmp \
php7-apcu \
&& rm -rf /var/cache/apk/*

WORKDIR /tmp
# Download latest nextcloud (stable) version
ADD https://download.nextcloud.com/server/releases/latest.tar.bz2 /tmp/

# check hash
ADD https://download.nextcloud.com/server/releases/latest.tar.bz2.sha256 /tmp/
RUN sha256sum -c latest.tar.bz2.sha256 < latest.tar.bz2

# check signatur
ADD https://download.nextcloud.com/server/releases/latest.tar.bz2.asc /tmp/
ADD https://nextcloud.com/nextcloud.asc /tmp/
RUN gpg --import nextcloud.asc
RUN gpg --verify latest.tar.bz2.asc latest.tar.bz2

WORKDIR /
# extract nextcloud
RUN tar xvjf /tmp/latest.tar.bz2

# clean
RUN rm -R /tmp/*

# add nginx config
ADD nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /run/nginx/ && touch /run/nginx/nginx.pid

# add php config
ADD fpm-php.conf /etc/php7/php-fpm.d/www.conf
ADD php.ini /etc/php7/php.ini

# add data dirctory
RUN mkdir /nextcloud/data
RUN chown -R nginx:nginx /nextcloud

# save default apps
RUN mkdir /nextcloud/default_apps
RUN mv /nextcloud/apps/* /nextcloud/default_apps/

# add scripts
ADD entrypoint.sh /entrypoint.sh
ADD permissions.sh /permissions.sh
ADD occ /usr/bin/occ
RUN chmod +x /entrypoint.sh
RUN chmod +x /permissions.sh
RUN chmod +x /usr/bin/occ

WORKDIR /nextcloud

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
