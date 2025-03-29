### STAGE 1: Build ###
FROM composer:2 AS builder
WORKDIR /app

# Copy application files first
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=ext-mongodb

### STAGE 2: Production ###
FROM php:8.2-fpm-alpine AS runner
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache nginx supervisor curl libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Copy application from builder stage
COPY --from=builder /app /app

# Set permissions
RUN chown -R www-data:www-data /app/storage /app/bootstrap/cache

# Expose port
EXPOSE 9000

# Run PHP-FPM
CMD ["php-fpm"]
