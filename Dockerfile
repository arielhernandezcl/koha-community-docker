# Base image with Koha compatibility
FROM debian:buster-slim

# Environment variables (optional)
ARG KOHA_VERSION=23.11  # Adjust as needed
ARG KOHA_PACKAGE=koha-common  # Adjust if installing a different Koha package

# Retry logic for package installation
RUN apt-get update || (echo "Failed to update package lists."; exit 1)
RUN apt-get install -y --no-install-recommends \
  wget \
  gnupg \
  apache2 \
  libapache2-mod-rewrite \
  libapache2-mod-headers \
  libapache2-mod-proxy-http \
  libapache2-mod-cgi || (echo "An error occurred while installing dependencies."; exit 1)

# Add Koha repository (conditional on PKG_URL for future flexibility)
RUN if [ "${KOHA_PACKAGE}" = "koha-common" ]; then \
        wget -q -O- https://debian.koha-community.org/koha/gpg.asc | apt-key add -; \
        echo "deb https://debian.koha-community.org/koha ${KOHA_VERSION} main" | tee /etc/apt/sources.list.d/koha.list; \
    fi

# Update package lists again and install Koha package
RUN apt-get update || (echo "Failed to update package lists."; exit 1)
RUN apt-get install -y "${KOHA_PACKAGE}"

# Apache configuration (consider these examples as a starting point)
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod proxy_http
RUN a2enmod cgi
RUN a2dissite 000-default

# Create directory for entrypoint script (optional)
RUN mkdir /docker

# Copy entrypoint script (assuming it exists)
COPY entrypoint.sh /docker/

# Make entrypoint script executable (if applicable)
RUN chmod +x /docker/entrypoint.sh

# Set entrypoint (if using an entrypoint script)
ENTRYPOINT ["/docker/entrypoint.sh"]
