FROM php:8.2-apache

# Install PHP extensions as needed (mysqli/pdo_mysql covers most PHP/MySQL apps)
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache modules if your app needs them (rewrite is common)
RUN a2enmod rewrite

# Copy site into webroot
COPY src/ /var/www/html/

# Optional: set proper Apache docroot (if you want /var/www/html/public or similar)
# ENV APACHE_DOCUMENT_ROOT=/var/www/html
# RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf /etc/apache2/apache2.conf

EXPOSE 80
