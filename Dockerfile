FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    nodejs \
    npm

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files first to leverage Docker cache
COPY composer.json composer.lock ./

# Install composer dependencies and ignore mongodb extension requirement
RUN composer install --no-interaction --no-dev --optimize-autoloader --no-scripts --ignore-platform-req=ext-mongodb

# Copy the rest of the application
COPY . .

# Generate autoload files
RUN composer dump-autoload --ignore-platform-req=ext-mongodb

# Set permissions
RUN chown -R www-data:www-data /var/www

# Install JS dependencies and build assets if needed
# Uncomment if you need to build frontend assets
# RUN npm install && npm run build

# Expose port 9000
EXPOSE 9000

# Start PHP-FPM server
CMD ["php-fpm"] 