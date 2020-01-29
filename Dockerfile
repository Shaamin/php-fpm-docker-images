FROM php:7.3-fpm-alpine

ENV SYMFONY_ENV dev

ARG USER_ID
ARG GROUP_ID

RUN apk add dockerize gosu --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

RUN apk add --no-cache --virtual .build-dependencies autoconf make g++ curl curl-dev icu-dev libzip-dev zlib-dev coreutils bash \
    && apk add postgresql-dev \
    && apk add make \
    && apk add --no-cache icu git openssh-client \
    && docker-php-ext-install -j$(nproc) curl iconv intl json mbstring opcache mysqli zip pdo pdo_pgsql \
    && pecl install apcu xdebug \
    && docker-php-ext-enable apcu xdebug \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && apk del .build-dependencies \
    && apk --no-cache add shadow

ADD conf.d /usr/local/etc/php/conf.d/
ADD pool.d /usr/local/etc/php-fpm.d/
ADD pool.d /usr/local/etc/php-fpm.d/

RUN usermod -u ${USER_ID} www-data && groupmod -g ${GROUP_ID} www-data

USER "${USER_ID}:${GROUP_ID}"
