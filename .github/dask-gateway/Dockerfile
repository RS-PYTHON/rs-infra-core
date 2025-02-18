# Copyright 2024 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ghcr.io/dask/dask-gateway:2024.1.0

ARG IMAGE2BUILD
ARG DASK_TAG="2024.5.2"
ARG DASK_GATEWAY_TAG="2024.1.0"
ARG PREFECT_TAG="3.1.4"

USER root

COPY ./resources/requirements-dask-eopf.txt /opt/
COPY ./resources/requirements-dask-staging.txt /opt/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

# Install dependencies necessary for execution (e.g. libpq) not compilation (gcc)
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libpq-dev libexpat1 gcc git wget && \
    layer-cleanup.sh

# Download and install dask-gateway-server requirements
RUN wget -P /opt/ "https://raw.githubusercontent.com/dask/dask-gateway/refs/tags/${DASK_GATEWAY_TAG}/dask-gateway-server/Dockerfile.requirements.txt" && \
    sed -i "s|\(^\s*dask-gateway-server\)|# \1|g" /opt/Dockerfile.requirements.txt && \
    pip install --no-cache-dir -r /opt/Dockerfile.requirements.txt && \
    layer-cleanup.sh

# Install whatever
RUN pip install -r /opt/requirements-${IMAGE2BUILD}.txt && \
    rm /opt/Dockerfile.requirements.txt /opt/requirements-dask-eopf.txt /opt/requirements-dask-staging.txt && \
    layer-cleanup.sh

# Install Dask with correct version
RUN pip install \
    dask[complete]==${DASK_TAG} \
    distributed==${DASK_TAG} \
    dask-gateway==${DASK_GATEWAY_TAG} \
    dask-gateway-server[kubernetes]==${DASK_GATEWAY_TAG} \
    bokeh">=3.1.0" \
    jupyter-server-proxy && \
    if [ "${IMAGE2BUILD}" = "dask-eopf" ]; then \
    pip install prefect[dask,aws]==${PREFECT_TAG} ; \
    fi && \
    layer-cleanup.sh

# Install and auto configure opentelemetry
RUN pip install opentelemetry-distro opentelemetry-exporter-otlp && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

RUN apt autoremove -y gcc

# Add a default user
RUN useradd -m user
USER user
WORKDIR /home/user

# Set labels based on the Open Containers Initiative (OCI):
# https://github.com/opencontainers/image-spec/blob/main/annotations.md#pre-defined-annotation-keys
#
LABEL org.opencontainers.image.source="https://github.com/RS-PYTHON/rs-infra-core"
LABEL org.opencontainers.image.ref.name="ghcr.io/rs-python/rs-infra-core-${IMAGE2BUILD}"
LABEL dockerfile.url="https://github.com/RS-PYTHON/rs-infra-core/blob/develop/.github/dask-gateway/Dockerfile"