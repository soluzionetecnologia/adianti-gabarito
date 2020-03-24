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
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update

# Set Timezone
RUN ln -fs /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && apt-get install -y --no-install-recommends tzdata \
    && dpkg-reconfigure --frontend noninteractive tzdata

# Install some system extensions
RUN apt-get install -y --no-install-recommends \
    rpl \
    zip \
    unzip \
    git \
    nano \
    vim \
    curl \
    wget

# Install Apache, PHP and PHP modules
RUN apt-get install -y --no-install-recommends \ 
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
    php7.4-zmq

# Install PHP databases extensions
RUN apt-get install -y --no-install-recommends \
    php7.4-sqlite3 \
    php7.4-pgsql \
    php7.4-mysql \
    php7.4-pdo-dblib \
    php7.4-pdo-firebird \
    php7.4-pdo-odbc

# Clean apt-get cache and temporary files
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

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
RUN echo "# Custom settings"                         >> /etc/php/7.4/apache2/php.ini \
    && echo "error_log = /tmp/php_errors.log"        >> /etc/php/7.4/apache2/php.ini \
    && echo "memory_limit = 256M"                    >> /etc/php/7.4/apache2/php.ini \
    && echo "max_execution_time = 120"               >> /etc/php/7.4/apache2/php.ini \
    && echo "file_uploads = On"                      >> /etc/php/7.4/apache2/php.ini \
    && echo "post_max_size = 100M"                   >> /etc/php/7.4/apache2/php.ini \
    && echo "upload_max_filesize = 100M"             >> /etc/php/7.4/apache2/php.ini \
    && echo "session.gc_maxlifetime = 14000"         >> /etc/php/7.4/apache2/php.ini \
    && echo "display_errors = $PHP_DISPLAY_ERRORS"   >> /etc/php/7.4/apache2/php.ini \
    && echo "error_reporting = $PHP_ERROR_REPORTING" >> /etc/php/7.4/apache2/php.ini

# Set PHP security settings
RUN echo "# Security settings"                       >> /etc/php/7.4/apache2/php.ini \
    && echo "session.name = CUSTOMSESSID"            >> /etc/php/7.4/apache2/php.ini \
    && echo "session.use_only_cookies = 1"           >> /etc/php/7.4/apache2/php.ini \
    && echo "session.cookie_httponly = true"         >> /etc/php/7.4/apache2/php.ini \
    && echo "session.use_trans_sid = 0"              >> /etc/php/7.4/apache2/php.ini \
    && echo "session.entropy_file = /dev/urandom"    >> /etc/php/7.4/apache2/php.ini \
    && echo "session.entropy_length = 32"            >> /etc/php/7.4/apache2/php.ini

# Defines directories that can be mapped
VOLUME ["/var/www/html"]

# Expose webserver port
EXPOSE 80

CMD apachectl start && /bin/bash