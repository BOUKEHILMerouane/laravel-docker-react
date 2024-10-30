# Start with a more recent base image (PHP 7.4 or later)
FROM php:7.4-apache

# Update repository sources and install dependencies
RUN apt-get update && \
    apt-get install -y \
      libicu-dev \
      libpq-dev \
      libonig-dev \
      git \
      zip \
      unzip && \
      libzip-dev && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install \
      intl \
      mbstring \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      zip \
      opcache && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Set application folder as an environment variable
ENV APP_HOME /var/www/html

# Change UID and GID of Apache user to match Docker user
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

# Update web root to Laravel public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# Enable Apache module rewrite
RUN a2enmod rewrite

# Copy source files and install PHP dependencies with Composer
COPY . $APP_HOME
RUN composer install --no-interaction

# Change ownership of application files
RUN chown -R www-data:www-data $APP_HOME

# Generate Laravel application key
RUN php artisan key:generate

# Build front-end assets
RUN npm install && npm run dev
