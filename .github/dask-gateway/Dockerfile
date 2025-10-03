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
ARG DASK_TAG=2024.5.2
ARG DASK_GATEWAY_TAG=2024.1.0

USER root

COPY ./*.whl ./
COPY ./resources/requirements-dask-*.txt /opt/
COPY ./resources/post-install-dask-*.sh /opt/
COPY ./resources/layer-cleanup.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/layer-cleanup.sh

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libpq-dev libexpat1 gcc git wget && \
    pip install --no-cache-dir -q --upgrade pip && \
    layer-cleanup.sh

# Download and install dask-gateway-server requirements
RUN wget -q -P /opt/ "https://raw.githubusercontent.com/dask/dask-gateway/refs/tags/${DASK_GATEWAY_TAG}/dask-gateway-server/Dockerfile.requirements.txt" && \
    sed -i "s|\(^\s*dask-gateway-server\)|# \1|g" /opt/Dockerfile.requirements.txt && \
    pip install --no-cache-dir -r /opt/Dockerfile.requirements.txt && \
    layer-cleanup.sh

# pip install the requirements.txt file for the requested image IMAGE2BUILD
RUN --mount=type=secret,id=GITLAB_EOPF_TOKEN \
    GITLAB_EOPF_TOKEN=$(cat /run/secrets/GITLAB_EOPF_TOKEN) \
    RS_SERVER_COMMON_WHEEL=$(find . -maxdepth 1 -type f -name 'rs_server_common-*-py3-none-any.whl' | head -n 1) \
    RS_SERVER_STAGING_WHEEL=$(find . -maxdepth 1 -type f -name 'rs_server_staging-*-py3-none-any.whl' | head -n 1) \
    pip install -U -r /opt/requirements-${IMAGE2BUILD}.txt && \
    rm -f /opt/Dockerfile.requirements.txt /opt/requirements-dask-*.txt ./*.whl && \
    layer-cleanup.sh

# Install Dask with correct version
RUN pip install \
        dask[complete]==${DASK_TAG} \
        distributed==${DASK_TAG} \
        dask-gateway==${DASK_GATEWAY_TAG} \
        dask-gateway-server[kubernetes]==${DASK_GATEWAY_TAG} \
        bokeh">=3.1.0" \
        jupyter-server-proxy && \
    layer-cleanup.sh

# Install and auto configure opentelemetry
RUN pip install opentelemetry-distro opentelemetry-exporter-otlp opentelemetry-instrumentation-aws-lambda opentelemetry-test-utils && \
    opentelemetry-bootstrap -a install && \
    layer-cleanup.sh

RUN if [ "${IMAGE2BUILD}" != "dask-staging" ]; then \
        apt update && apt install -y python3-pydot graphviz && layer-cleanup.sh; \
    fi

# Run post-install script as root if it exists
RUN [ -f /opt/post-install-${IMAGE2BUILD}.sh ] && /opt/post-install-${IMAGE2BUILD}.sh && layer-cleanup.sh; \
    rm -f /opt/post-install-dask-*.sh

RUN apt autoremove -y gcc && layer-cleanup.sh

# Remove apt repository list and custom scripts
RUN rm -f /etc/apt/sources.list /usr/local/bin/layer-cleanup.sh /usr/local/bin/restore-apt.sh

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

# This Dockerfile is used to build:
# ghcr.io/rs-python/rs-infra-core-dask-staging
# ghcr.io/rs-python/rs-infra-core-dask-l0
# ghcr.io/rs-python/rs-infra-core-dask-s1ard

