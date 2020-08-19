FROM php:fpm-alpine AS builder

ADD https://cdn.jsdelivr.net/gh/mlocati/docker-php-extension-installer/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync && \
 install-php-extensions gd zip pdo_mysql mysqli pcntl intl gettext bcmath shmop soap sysvsem xmlrpc memcached opcache imagick sockets redis

RUN apk upgrade --update \
    && apk add --no-cache --virtual .build-deps \
    linux-headers \
    autoconf \
    openssl-dev \
    gcc \
    g++ \
    libc-dev \
    make \
    git \
    && cd / && git clone https://github.com/swoole/swoole-src.git \
    && ( \
        cd swoole-src \
        && phpize \
        && ./configure --enable-sockets --enable-openssl --enable-http2 --enable-mysqlnd \
        && make -j$(nproc) && make install \
        ) \
    && rm -r /swoole-src \
    && docker-php-ext-enable swoole \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/*

FROM php:fpm-alpine

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN apk add gnu-libiconv tzdata libwebp libpng libjpeg libxpm freetype libintl imagemagick icu-libs libmemcached zstd-dev libzip --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

RUN docker-php-ext-enable gd zip pdo_mysql mysqli pcntl intl gettext bcmath shmop soap sysvsem xmlrpc memcached opcache imagick sockets redis swoole

RUN ln -sf /usr/local/bin/php /usr/bin/php
