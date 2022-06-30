FROM nginx:1.21.6

VOLUME [ "/code" ]
ENV ACCEPT_EULA=Y
WORKDIR /code

RUN ln -fs /usr/share/zoneinfo/America/Rio_Branco /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt update && \
    apt -y upgrade && \
    echo "pt_BR.UTF-8 UTF-8" > /etc/locale.gen && \
    apt install -y ca-certificates \
                   apt-transport-https \
                   lsb-release \
                   gnupg \
                   curl \
                   wget \
                   vim \
                   dirmngr \
                   software-properties-common \
                   rsync \
                   gettext \
                   locales \
                   gcc \
                   g++ \
                   make \
                   unzip && \
    locale-gen && \
    curl -o /etc/apt/trusted.gpg.d/php.gpg -fSL "https://packages.sury.org/php/apt.gpg" && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt -y update && \
    apt -y install --allow-unauthenticated php7.4 \
                   php7.4-fpm \
                   php7.4-mysql \
                   php7.4-mbstring \
                   php7.4-soap \
                   php7.4-gd \
                   php7.4-xml \
                   php7.4-intl \
                   php7.4-dev \
                   php7.4-curl \
                   php7.4-zip \
                   php7.4-imagick \
                   php7.4-gmp \
                   php7.4-ldap \
                   php7.4-bcmath \
                   php7.4-bz2 \
                   php7.4-phar \
                   php7.4-sqlite3 \
                   gcc \
                   g++ \
                   make \
                   autoconf \
                   libc-dev \
                   pkg-config && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    apt-get install -y msodbcsql18 && \
    apt-get install -y unixodbc-dev && \
    pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini && \
    printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini && \
    phpenmod -v 7.4 sqlsrv pdo_sqlsrv && \
    rm -rf /var/lib/apt/lists/* && \
    apt upgrade -y && \
    apt autoremove -y && \
    apt clean && \
    chown -R www-data:www-data -R /code &&  \
    printf "# priority=30\nservice php7.4-fpm start\n" > /docker-entrypoint.d/30-php7.4-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php7.4-fpm.sh && \
    chmod 755 /docker-entrypoint.d/30-php7.4-fpm.sh
    
ADD config_cntr/php.ini /etc/php/7.4/fpm/php.ini
ADD config_cntr/www.conf /etc/php/7.4/fpm/pool.d/www.conf
ADD config_cntr/nginx.conf /etc/nginx

ADD config_cntr/default.conf /etc/nginx/conf.d