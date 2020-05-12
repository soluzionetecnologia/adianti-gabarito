# @version:     1.0
# @author:      Régis Kensy
# @company:     Soluzione Tecnologia
# @description: Container de desenvolvimento/produção Adianti Framework 7.1.0

FROM ubuntu:bionic

# Set default environment variables
ENV TIMEZONE America/Sao_Paulo

# Disable debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Add PHP PPA Repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:ondrej/php

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apt-get update \
    && apt-get install -y --no-install-recommends tzdata \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Install some system extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       rpl \
       zip \
       unzip \
       git \
       nano \
       vim \
       curl \
       wget

# Install Apache, PHP and PHP modules
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       libapache2-mod-php \
       php7.4-xdebug \
       php7.4-memcached \
       php7.4-gd \
       php-mbstring \
       php7.4-curl \
       php7.4-opcache \
       php7.4-xml \
       php7.4-bcmath \
       php7.4-soap \
       php7.4-bz2 \
       php7.4-intl \
       php7.4-zip \
       php7.4-xmlrpc \
       php7.4-xsl \
       php7.4-yaml \
       php7.4-zmq \
       php7.4-dev \
       php-pear \
       build-essential \
       libaio1 \
       composer

# Install PHP databases extensions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       php7.4-sqlite3 \
       php7.4-pgsql \
       php7.4-mysql \
       php7.4-pdo-dblib \
       php7.4-pdo-firebird \
       php7.4-pdo-odbc

# Clean apt-get cache and temporary files
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Disable/Enable modules
RUN a2dismod mpm_event \
    && a2dismod mpm_worker \
    && a2enmod mpm_prefork \
    && a2enmod php7.4 \
    && a2enmod rewrite

# Enable .htaccess reading
RUN LANG="en_US.UTF-8" rpl "AllowOverride None" "AllowOverride All" /etc/apache2/apache2.conf

# Set PHP default environment vars
ENV PHP_DISPLAY_ERRORS On
ENV PHP_ERROR_REPORTING E_ALL

# Set PHP custom settings
RUN echo "\n# Custom settings"                                    >> /etc/php/7.4/apache2/php.ini \
    && echo "error_log = /tmp/php_errors.log"                     >> /etc/php/7.4/apache2/php.ini \
    && echo "memory_limit = 256M"                                 >> /etc/php/7.4/apache2/php.ini \
    && echo "max_execution_time = 120"                            >> /etc/php/7.4/apache2/php.ini \
    && echo "file_uploads = On"                                   >> /etc/php/7.4/apache2/php.ini \
    && echo "post_max_size = 100M"                                >> /etc/php/7.4/apache2/php.ini \
    && echo "upload_max_filesize = 100M"                          >> /etc/php/7.4/apache2/php.ini \
    && echo "session.gc_maxlifetime = 14000"                      >> /etc/php/7.4/apache2/php.ini \
    && echo "display_errors = On"                                 >> /etc/php/7.4/apache2/php.ini \
    && echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT" >> /etc/php/7.4/apache2/php.ini

# Set PHP security settings
RUN echo "\n# Security settings"                    >> /etc/php/7.4/apache2/php.ini \
    && echo "session.name = CUSTOMSESSID"           >> /etc/php/7.4/apache2/php.ini \
    && echo "session.use_only_cookies = 1"          >> /etc/php/7.4/apache2/php.ini \
    && echo "session.cookie_httponly = true"        >> /etc/php/7.4/apache2/php.ini \
    && echo "session.use_trans_sid = 0"             >> /etc/php/7.4/apache2/php.ini \
    && echo "session.entropy_file = /dev/urandom"   >> /etc/php/7.4/apache2/php.ini \
    && echo "session.entropy_length = 32"           >> /etc/php/7.4/apache2/php.ini

# Link log and error files to stdout
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
    && ln -sf /dev/stderr /var/log/apache2/error.log

# Install Oracle client, OCI8 and PDO_OCI libs
RUN mkdir -p /opt/oracle \
    && cd /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip \
    && find . -name "*.zip" -exec unzip {} \; \
    && rm *.zip \
    && echo /opt/oracle/instantclient_19_6 > /etc/ld.so.conf.d/oracle-instantclient \
    && ldconfig \
    && pecl channel-update pecl.php.net \
    && sh -c "echo 'instantclient,/opt/oracle/instantclient_19_6' | pecl install oci8" \
    && echo "extension=oci8.so" >> /etc/php/7.4/cli/php.ini \
    && echo "extension=oci8.so" >> /etc/php/7.4/apache2/php.ini \
    && echo "export LD_LIBRARY_PATH=/opt/oracle/instantclient_19_6" >> /etc/apache2/envvars \
    && echo "export ORACLE_HOME=/opt/oracle/instantclient_19_6" >> /etc/apache2/envvars \
    && echo "LD_LIBRARY_PATH=/opt/oracle/instantclient_19_6:$LD_LIBRARY_PATH" >> /etc/environment \
    && cd /root \
    && wget https://github.com/php/php-src/archive/php-7.4.5.zip \
    && unzip *.zip \
    && rm -f *.zip \
    && cd php-src-php-7.4.5/ext/pdo_oci \
    && phpize \
    && ./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient_19_6,19.6 \
    && make install \
    && cd /root \
    && rm -Rf php-src-php-7.4.5 \
    && echo "extension=pdo_oci.so" >> /etc/php/7.4/mods-available/pdo_oci.ini \
    && cd /etc/php/7.4/apache2/conf.d \
    && ln -s /etc/php/7.4/mods-available/pdo_oci.ini pdo_oci.ini

# Defines directories that can be mapped
VOLUME ["/var/www/html", "/tmp", "/var/log/apache2", "/etc/apache2"]

# Expose webserver port
EXPOSE 80

CMD ["apachectl", "-DFOREGROUND"]