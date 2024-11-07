FROM ghcr.io/dask/dask-gateway:2024.1.0

USER root
# Install dependencies necessary for execution (e.g. libpq) not compilation (gcc)
RUN \
    apt update && \
    apt install -y libpq-dev gcc && \
    rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

# Set environment variables for pygeoapi
ENV PYGEOAPI_CONFIG=/opt/config/config.yml
ENV PYGEOAPI_OPENAPI=/opt/config/openapi.json

# COPY ./resources/config /opt/config

# Install rs-server-common and rs-server-staging
RUN pip install --upgrade rs-server-common==0.2a5
RUN pip install --upgrade rs-server-staging==0.2a5

# Fix versions 
RUN pip install --force-reinstall \
    numpy==2.1.2 \
    pandas==2.2.3

# Add a default user
RUN useradd -m user
USER user
WORKDIR /home/user