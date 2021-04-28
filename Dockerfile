FROM ubuntu:20.04
LABEL maintainer="Lucas Monteiro"

# ubuntu environment params
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_19_6

# define main dir
WORKDIR /srv/app

# update apt repo packages
RUN apt-get update

# instal ubuntu libs
RUN apt install --no-install-recommends -y curl wget zip unzip \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
        libpcre3-dev

# Install php mods
RUN apt-get install php 7.4-json php7.4-fpm php7.4-ldap php7.4-gd php7.4-zip php7.4-curl php7.4-mbstring php7.4-dom php7.4-soap php7.4-dev -y

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Oracle Instant Client
RUN wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle/ \
    && wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip -P /opt/oracle/
RUN unzip /opt/oracle/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip -d /opt/oracle
#    && ln -sfn /opt/oracle/instantclient_19_6/libclntsh.so.18.1 /opt/oracle/instantclient_19_6/libclntsh.so \
#    && ln -sfn /opt/oracle/instantclient_19_6/libclntshcore.so.18.1 /opt/oracle/instantclient_19_6/libclntshcore.so \
#    && ln -sfn /opt/oracle/instantclient_19_6/libocci.so.18.1 /opt/oracle/instantclient_19_6/libocci.so

# Instalando oci pdo_oci para o PHP
RUN apt-get install --no-install-recommends php-pear php-bcmath libaio-dev -y
#RUN pecl channel-update pecl.php.net
RUN echo 'instantclient,/opt/oracle/instantclient_19_6' | pecl install oci8-2.2.0.tgz
RUN echo "extension=oci8.so" > /etc/php/7.4/cli/conf.d/oci8.ini \
    && echo "extension = oci8.so" >> /etc/php/7.4/fpm/php.ini
#    && echo "extension=oci8.so" > /etc/php/7.4/apache2/conf.d/oci8.ini

# Clear apt lists
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Expose php-fpm port
EXPOSE 9000

# Entrypoint
CMD ["php-fpm7.4","--nodaemonize"]
