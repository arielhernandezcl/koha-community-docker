# Base image with Debian Buster
FROM debian:buster-slim

# Actualizar los paquetes e instalar Apache y otros paquetes necesarios
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-rewrite \
    libapache2-mod-headers \
    libapache2-mod-proxy-http \
    libapache2-mod-cgi \
    wget \
    gnupg && \
    rm -rf /var/lib/apt/lists/*

# Agregar repositorio de Koha e instalar Koha
ARG KOHA_VERSION=23.11
RUN wget -q -O- https://debian.koha-community.org/koha/gpg.asc | apt-key add - && \
    echo "deb https://debian.koha-community.org/koha ${KOHA_VERSION} main" | tee /etc/apt/sources.list.d/koha.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    koha-common && \
    rm -rf /var/lib/apt/lists/*

# Habilitar los módulos de Apache necesarios
RUN a2enmod rewrite headers proxy_http cgi

# Deshabilitar el sitio predeterminado de Apache
RUN a2dissite 000-default

# Crear directorio para el script de entrada
RUN mkdir /docker

# Copiar el script de entrada
COPY entrypoint.sh /docker/

# Establecer permisos de ejecución para el script de entrada
RUN chmod +x /docker/entrypoint.sh

# Establecer el script de entrada
ENTRYPOINT ["/docker/entrypoint.sh"]

# Exponer el puerto 80 para Apache
EXPOSE 80
