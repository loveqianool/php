FROM php:7-fpm-alpine AS builder

ADD https://cdn.jsdelivr.net/gh/mlocati/docker-php-extension-installer/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync \
  && install-php-extensions gd zip pdo_mysql mysqli pcntl intl gettext bcmath shmop soap sysvsem xmlrpc memcached opcache imagick sockets redis

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS curl-dev openssl-dev pcre-dev pcre2-dev zlib-dev \
  && pecl install --configureoptions \
    'enable-sockets="yes" \
    enable-openssl="yes" \
    enable-http2="yes" \
    enable-mysqlnd="yes" \
    enable-swoole-json="yes" \
    enable-swoole-curl="yes" \
    enable-cares="yes"' \
    https://pecl.php.net/get/swoole-4.8.12.tgz

FROM php:7-fpm-alpine

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apk add gnu-libiconv tzdata libwebp libpng libjpeg libxpm freetype libintl imagemagick icu-libs libmemcached zstd-dev libzip libavif libgomp --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted --no-cache
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN docker-php-ext-enable gd zip pdo_mysql mysqli pcntl intl gettext bcmath shmop soap sysvsem xmlrpc memcached opcache imagick sockets redis swoole

RUN ln -sf /usr/local/bin/php /usr/bin/php
